function g=fir2long(g,Llong);
%FIR2LONG   Extend FIR window to LONG
%   Usage:  g=fir2long(g,Llong);
%
%   FIR2LONG(g,Llong) will extend the FIR window g to a length Llong window
%   by inserting zeros. Note that this is a slightly different behaviour
%   than MIDDLEPAD.
%
%   FIR2LONG can also be used to extend a FIR window to a longer FIR window,
%   for instance in order to satisfy that the window length is divisible by
%   the number of channels.
%
%   See also:  long2fir, middlepad

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

error(nargchk(2,2,nargin));

Lfir=length(g);


if Lfir>Llong
  error('Llong must be larger than length of window.');
end;

if rem(Lfir,2)==0
  % HPE middlepad works the same way as the FIR extension (e.g. just
  % inserting zeros) for even-length signals.
  g=middlepad(g,Llong,'hp');
else
  % WPE middlepad works the same way as the FIR extension (e.g. just
  % inserting zeros) for odd-length signals.
  g=middlepad(g,Llong);
end;
  
