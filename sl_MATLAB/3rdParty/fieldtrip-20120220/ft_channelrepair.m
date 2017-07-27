function [data] = ft_channelrepair(cfg, data)

% FT_CHANNELREPAIR repairs bad or missing channels in MEG or EEG data by
% replacing them with the average of its neighbours (nearest-neighbour
% approach). It cannot be used reliably to repair multiple bad channels
% that lie next to each other.
%
% Use as
%   [interp] = ft_channelrepair(cfg, data)
%
% The configuration must contain
%   cfg.badchannel     = cell-array, see FT_CHANNELSELECTION for details
%   cfg.missingchannel = cell-array, see FT_CHANNELSELECTION for details
%   cfg.neighbours     = neighbourhoodstructure, see also FT_PREPARE_NEIGHBOURS
%   cfg.trials         = 'all' or a selection given as a 1xN vector (default = 'all')
%
% For reconstructing channels that are absent in your data, please define
% your neighbours by setting cfg.method='template' and call
% FT_PREPARE_NEIGHBOURS *without* the data argument:
%   cfg.neighbours = ft_prepare_neighbours(cfg);
% This will include channels that are missing in your in the neighbour-
% definition.
%
% You should define sensor positions as defined by FT_FETCH_SENS, but sens
% definitions in the cfg will be preferred over sens definition from the
% data
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following options:
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%
% See also FT_MEGREALIGN, FT_MEGPLANAR, FT_NEIGHBOURSELECTION,
% FT_FETCH_SENS

% Copyright (C) 2004-2009, Robert Oostenveld

% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_channelrepair.m 5229 2012-02-02 15:56:06Z jorhor $

revision = '$Id: ft_channelrepair.m 5229 2012-02-02 15:56:06Z jorhor $';

% do the general setup of the function
ft_defaults
ft_preamble help
ft_preamble callinfo
ft_preamble trackconfig
ft_preamble loadvar data

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'required', {'neighbours'});

% set the default configuration
if ~isfield(cfg, 'badchannel'),     cfg.badchannel = {};           end
if ~isfield(cfg, 'missingchannel'), cfg.missingchannel = {};       end
if ~isfield(cfg, 'trials'),         cfg.trials = 'all';            end

% check if the input data is valid for this function
data = ft_checkdata(data, 'datatype', 'raw', 'feedback', 'yes');

% store original datatype
dtype = ft_datatype(data);

% select trials of interest
if ~strcmp(cfg.trials, 'all')
  fprintf('selecting %d trials\n', length(cfg.trials));
  data = ft_selectdata(data, 'rpt', cfg.trials);
end

% determine the type of data
iseeg = ft_senstype(data, 'eeg');
ismeg = ft_senstype(data, 'meg');

% prefer sens from cfg over sens from data
try
  sens = ft_fetch_sens(cfg);
catch
  sens = ft_fetch_sens(cfg, data);
end


channels = ft_channelselection(cfg.badchannel, data.label);
% get selection of channels that are missing
cfg.missingchannel = [cfg.missingchannel cfg.badchannel(~ismember(cfg.badchannel, channels))];

% warn if nearest neighbour approach (see
% http://bugzilla.fcdonders.nl/show_bug.cgi?id=634)
if ~isempty(cfg.missingchannel)
  warning('Reconstructing missing channels using the nearest neighbour approach is not recommended!');
end

% get the selection of channels that are bad
cfg.badchannel = channels;

% first repair badchannels
[goodchanlabels,goodchanindcs] = setdiff(data.label,cfg.badchannel);
goodchanindcs = sort(goodchanindcs); % undo automatical sorting by setdiff
connectivityMatrix = channelconnectivity(cfg, data);
connectivityMatrix = connectivityMatrix(:, goodchanindcs); % all chans x good chans

Ntrials = length(data.trial);
Nchans  = length(data.label);
Nsens   = length(sens.label);

repair  = eye(Nchans,Nchans);
badindx = match_str(data.label, cfg.badchannel);

for k=badindx'
  fprintf('repairing channel %s\n', data.label{k});
  repair(k,k) = 0;
  l = goodchanindcs(connectivityMatrix(k, :));
  % get bad channels out
  [a, b] = setdiff(data.label(l), data.label(badindx));
  b = sort(b); % undo automatical sorting by setdiff
  l(~ismember(find(l), b)) = [];
  % get corresponding ids for sens structure
  [a, b] = match_str(sens.label, data.label(l));
  goodsensindx = a(b);
  [a, b] = match_str(sens.label, data.label(k));
  badsensindx = a(b);
  fprintf('\tusing neighbour %s\n', sens.label{goodsensindx});
  distance = sqrt(sum((sens.chanpos(goodsensindx,:) - repmat(sens.chanpos(badsensindx, :), numel(goodsensindx), 1)).^2, 2));
  repair(k,l) = (1./distance);
  repair(k,l) = repair(k,l) ./ sum(repair(k,l));
end

% use sparse matrix to speed up computations
repair = sparse(repair);

% compute the repaired data for each trial
fprintf('\n');
fprintf('repairing bad channels for %i trials %d', Ntrials);
for i=1:Ntrials
  fprintf('.');
  interp.trial{i} = repair * data.trial{i};
end
fprintf('\n');

% store the realigned data in a new structure
interp.fsample = data.fsample;
interp.time    = data.time;
interp.label   = data.label;
if iseeg
  interp.elec  = sens;
else
  interp.grad  = sens;
end

if isfield(data, 'sampleinfo')
  interp.sampleinfo = data.sampleinfo;
end

if isfield(data, 'trialinfo')
  interp.trialinfo = data.trialinfo;
end


% interpolation missing channels
goodchanindcs = 1:numel(data.label);
for chan=1:numel(cfg.missingchannel)
  interp.label{end+1} = cfg.missingchannel{chan};
  % creating dummy trial data
  for i=1:Ntrials
    interp.trial{i}(end+1, :) = 0;
  end
end
connectivityMatrix = channelconnectivity(cfg, interp);
connectivityMatrix = connectivityMatrix(:, goodchanindcs); % all chans x good chans

Ntrials = length(interp.trial);
Nchans  = length(interp.label);
Nsens   = length(sens.label);

repair  = eye(Nchans,Nchans);
missingindx = match_str(interp.label, cfg.missingchannel);
unable = [];
for k=missingindx'
  fprintf('trying to reconstruct missing channel %s\n', interp.label{k});
  repair(k,k) = 0;
  l = goodchanindcs(connectivityMatrix(k, :));  
  % get bad channels out
  [a, b] = setdiff(data.label(l), interp.label(missingindx));
  b = sort(b); % undo automatical sorting by setdiff
  l(~ismember(find(l), b)) = [];
  % get corresponding ids for sens structure
  [a, b] = match_str(sens.label, interp.label(l));
  goodsensindx = a(b);
  if isempty(goodsensindx)
    fprintf('\tcannot reconstruct channel - no neighbours in the original data or in the sensor position\n');
    unable = [unable k];
  else
    [a, b] = match_str(sens.label, interp.label(k));
    badsensindx = a(b);  
    fprintf('\tusing neighbour %s\n', sens.label{goodsensindx});
    distance = sqrt(sum((sens.chanpos(goodsensindx,:) - repmat(sens.chanpos(badsensindx, :), numel(goodsensindx), 1)).^2, 2));
    repair(k,l) = (1./distance);
    repair(k,l) = repair(k,l) ./ sum(repair(k,l));
  end
end

% use sparse matrix to speed up computations
repair = sparse(repair);

fprintf('\n');
% compute the missing data for each trial and remove those could not be
% reconstructed
fprintf('\n');
fprintf('interpolating missing channel for %i trials %d', Ntrials);
for i=1:Ntrials
  fprintf('.');
  interp.trial{i} = repair * interp.trial{i};
  interp.trial{i}(unable, :) = [];
end
interp.label(unable) = [];
fprintf('\n');

% convert back to input type if necessary
switch dtype
  case 'timelock'
    interp = ft_checkdata(interp, 'datatype', 'timelock');
  otherwise
    % keep the output as it is
end

% do the general cleanup and bookkeeping at the end of the function
ft_postamble trackconfig
ft_postamble callinfo
ft_postamble previous data

% rename the output variable to accomodate the savevar postamble
data = interp;

ft_postamble history data
ft_postamble savevar data

