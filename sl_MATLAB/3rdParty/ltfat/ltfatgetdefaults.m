function d=ltfatgetdefaults(fname)
%LTFATGETDEFAULTS  Get default parameters of function
%
%  LTFATGETDEFAULTS(fname) will return the default parameters
%  of the function fname as a cell array.
%
%  LTFATGETDEFAULTS('all') will return all the set defaults.
%
%  See also: ltfatsetdefaults, ltfatstart

% Copyright (C) 2005-2011 Peter L. Soendergaard.
% This file is part of LTFAT version 0.98
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

if nargin<1
    error('%s: Too few input arguments',upper(mfilename));
end;

if strcmpi(fname,'all')
  d=ltfatarghelper('all');
else
  d=ltfatarghelper('get',fname);
end;