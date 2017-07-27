function ft_preamble(cmd, varargin)

% FT_PREAMBLE is a helper function that is included in many of the FieldTrip
% functions and which takes care of some general settings and operations at the
% begin of the function
%
% See also FT_POSTAMBLE

% Copyright (C) 2011-2012, Robert Oostenveld, DCCN
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
% $Id: ft_preamble.m 5113 2012-01-11 07:57:16Z roboos $

% ideally this would be a script, because the local variables would then be
% shared with the calling function. Instead, this is a function which then
% passes the variables explicitely to another script which is eval'ed.

% the following ensures that these scripts are included as dependencies
% when using the MATLAB compiler
%
%#function ft_preamble_help
%#function ft_preamble_distribute
%#function ft_preamble_trackconfig
%#function ft_preamble_callinfo
%#function ft_preamble_loadvar

global ft_default

% this is a trick to pass the input arguments into the ft_preamble_xxx script
ft_default.preamble = varargin;

if exist(['ft_preamble_' cmd], 'file')
  evalin('caller', ['ft_preamble_' cmd]);
end

if isfield(ft_default, 'preamble')
  % the preamble field should not remain in the ft_default structure
  ft_default = rmfield(ft_default, 'preamble');
end