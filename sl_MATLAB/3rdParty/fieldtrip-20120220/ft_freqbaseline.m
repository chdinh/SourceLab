function [freq] = ft_freqbaseline(cfg, freq)

% FT_FREQBASELINE performs baseline normalization for time-frequency data
%
% Use as
%    [freq] = ft_freqbaseline(cfg, freq)
% where the freq data comes from FT_FREQANALYSIS and the configuration
% should contain
%   cfg.baseline     = [begin end] (default = 'no')
%   cfg.baselinetype = 'absolute', 'relchange' or 'relative' (default = 'absolute')
%   cfg.param        = field for which to apply baseline normalization, or
%                      cell array of strings to specify multiple fields to normalize
%                      (default = 'powspctrm')
%
% See also FT_FREQANALYSIS, FT_TIMELOCKBASELINE, FT_FREQCOMPARISON

% Undocumented local options:
%   cfg.inputfile  = one can specifiy preanalysed saved data as input
%   cfg.outputfile = one can specify output as file to save to disk

% Copyright (C) 2004-2006, Marcel Bastiaansen
% Copyright (C) 2005-2006, Robert Oostenveld
% Copyright (C) 2011, Eelke Spaak
%
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
% $Id: ft_freqbaseline.m 4658 2011-11-02 19:49:23Z roboos $

revision = '$Id: ft_freqbaseline.m 4658 2011-11-02 19:49:23Z roboos $';

% do the general setup of the function
ft_defaults
ft_preamble help
ft_preamble callinfo
ft_preamble trackconfig
ft_preamble loadvar freq

% check if the input data is valid for this function
freq = ft_checkdata(freq, 'datatype', 'freq', 'feedback', 'yes');

% set the defaults
cfg.baseline     =  ft_getopt(cfg, 'baseline', 'no');
cfg.baselinetype =  ft_getopt(cfg, 'baselinetype', 'absolute');
cfg.param        =  ft_getopt(cfg, 'param', 'powspctrm');
cfg.inputfile    =  ft_getopt(cfg, 'inputfile', []);
cfg.outputfile   =  ft_getopt(cfg, 'outputfile', []);

% check validity of input options
cfg =               ft_checkopt(cfg, 'baseline', {'char', 'doublevector'});
cfg =               ft_checkopt(cfg, 'baselinetype', 'char', {'absolute', 'relative', 'relchange'});
cfg =               ft_checkopt(cfg, 'param', {'char', 'charcell'});

% make sure cfg.param is a cell array of strings
if (~isa(cfg.param, 'cell'))
  cfg.param = {cfg.param};
end

% is input consistent?
if ischar(cfg.baseline) && strcmp(cfg.baseline, 'no') && ~isempty(cfg.baselinetype)
  warning('no baseline correction done');
end

% process possible yes/no value of cfg.baseline
if ischar(cfg.baseline) && strcmp(cfg.baseline, 'yes')
  % default is to take the prestimulus interval
  cfg.baseline = [-inf 0];
elseif ischar(cfg.baseline) && strcmp(cfg.baseline, 'no')
  % nothing to do
  return
end

% check if the field of interest is present in the data
if (~all(isfield(freq, cfg.param)))
  error('cfg.param should be a string or cell array of strings referring to (a) field(s) in the freq input structure')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize output structure
freqOut        = [];
freqOut.label  = freq.label;
freqOut.freq   = freq.freq;
freqOut.dimord = freq.dimord;
freqOut.time   = freq.time;

if isfield(freq, 'grad')
  freqOut.grad = freq.grad;
end
if isfield(freq, 'elec')
  freqOut.elec = freq.elec;
end
if isfield(freq, 'trialinfo')
  freqOut.trialinfo = freq.trialinfo;
end

% loop over all fields that should be normalized
for k = 1:numel(cfg.param)
  par = cfg.param{k};
  
  if strcmp(freq.dimord, 'chan_freq_time')
    
    freqOut.(par) = ...
      performNormalization(freq.time, freq.(par), cfg.baseline, cfg.baselinetype);
    
  elseif strcmp(freq.dimord, 'rpt_chan_freq_time') || strcmp(freq.dimord, 'chan_chan_freq_time')
    
    freqOut.(par) = zeros(size(freq.(par)));
    
    % loop over trials, perform normalization per trial
    for l = 1:size(freq.(par), 1)
      tfdata = freq.(par)(l,:,:,:);
      siz    = size(tfdata);
      tfdata = reshape(tfdata, siz(2:end));
      freqOut.(par)(l,:,:,:) = ...
        performNormalization(freq.time, tfdata, cfg.baseline, cfg.baselinetype);
    end
    
  else
    error('unsupported data dimensions: %s', freq.dimord);
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output scaffolding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% do the general cleanup and bookkeeping at the end of the function
ft_postamble trackconfig
ft_postamble callinfo
ft_postamble previous freq

% rename the output variable to accomodate the savevar postamble
freq = freqOut;

ft_postamble history freq
ft_postamble savevar freq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION that actually performs the normalization on an arbitrary quantity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = performNormalization(timeVec, data, baseline, baselinetype)

baselineTimes = (timeVec >= baseline(1) & timeVec <= baseline(2));

if length(size(data)) ~= 3,
  error('time-frequency matrix should have three dimensions (chan,freq,time)');
end

% compute mean of time/frequency quantity in the baseline interval,
% ignoring NaNs, and replicate this over time dimension
meanVals = repmat(nanmean(data(:,:,baselineTimes), 3), [1 1 size(data, 3)]);

if (strcmp(baselinetype, 'absolute'))
  data = data - meanVals;
elseif (strcmp(baselinetype, 'relative'))
  data = data ./ meanVals;
elseif (strcmp(baselinetype, 'relchange'))
  data = (data - meanVals) ./ meanVals;
else
  error('unsupported method for baseline normalization: %s', baselinetype);
end

