function f=peven(f,dim)
%PEVEN   Even part of periodic function
%   Usage:  fe=peven(f);
%           fe=peven(f,dim);
%
%   PEVEN(f) returns the even part of the periodic sequence f.
%
%   PEVEN(f,dim) does the same along dimension dim.
% 
%   See also:  podd, dft, involute, pconv

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
  
f=(f+involute(f))/2;

