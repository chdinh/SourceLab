function chanunit = ft_chanunit(hdr, desired)

% FT_CHANUNIT is a helper function that tries to determine the physical
% units of each channel. In case the type of channel is not detected, it
% will return 'unknown' for that channel.
%
% Use as
%   unit = ft_chanunit(hdr)
% or as
%   unit = ft_chanunit(hdr, desired)
%
% If the desired unit is not specified as second input argument, this
% function returns a Nchan*1 cell array with a string describing the
% physical units of each channel, or 'unknown' if those cannot be
% determined.
%
% If the desired unit is specified as second input argument, this function
% returns a Nchan*1 boolean vector with "true" for the channels that match
% the desired physical units and "false" for the ones that do not match.
%
% The specification of the channel units depends on the acquisition system,
% for example the neuromag306 system includes channel with the following
% units: uV, T and T/cm.
%
% See also FT_CHANTYPE

% Copyright (C) 2011, Robert Oostenveld
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
% $Id: ft_chanunit.m 5074 2011-12-22 09:06:45Z roboos $

if isfield(hdr, 'chanunit')
  if ~isequal(size(hdr.chanunit), size(hdr.label))
    error('the size of hdr.chanunit is inconsistent with hdr.label');
  else
    % return the already assigned channel types
    chanunit = hdr.chanunit;
  end
  
else
  % start with 'unknown' for all channels
  chanunit = repmat({'unknown'}, size(hdr.label));
  
  % note that these unit assignments assume that the data has not yet been
  % converted into other units. These units are consistent with the default
  % output of ft_read_data.
  
  % FIXME I have not validated the channel units below
  
  % look at the type of the channels, these are obtained from FT_CHANTYPE
  if ft_senstype(hdr, 'neuromag')
    chanunit(strcmp('analog trigger',   hdr.chantype)) = {'unknown'};
    chanunit(strcmp('digital trigger',  hdr.chantype)) = {'unknown'};
    chanunit(strcmp('eeg',              hdr.chantype)) = {'uV'};
    chanunit(strcmp('emg',              hdr.chantype)) = {'uV'};
    chanunit(strcmp('eog',              hdr.chantype)) = {'uV'};
    chanunit(strcmp('ecg',              hdr.chantype)) = {'uV'};
    chanunit(strcmp('megmag',           hdr.chantype)) = {'T'};
    chanunit(strcmp('megplanar',        hdr.chantype)) = {'T/cm'};
    
%   elseif ft_senstype(hdr, 'ctf')
%     error('not yet implemented');
%     
%   elseif ft_senstype(hdr, '4d')
%     error('not yet implemented');
    
  else
    chanunit = cell(size(hdr.label));
    for i=1:length(chanunit)
      chanunit{i} = 'unknown';
    end
  end % if senstype
  
end % if isfield

if nargin>1
  chanunit = strcmp(desired, chanunit);
end

