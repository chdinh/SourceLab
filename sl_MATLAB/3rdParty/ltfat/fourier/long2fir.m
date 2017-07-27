function g=long2fir(g,L,symmetry);
%LONG2FIR   Cut LONG window to FIR
%   Usage:  g=long2fir(g,L);
%
%   LONG2FIR(g,L) will cut the LONG window g to a length L FIR window by
%   cutting out the middle part. Note that this is a slightly different
%   behaviour than MIDDLEPAD.
%
%   LONG2FIR(g,L,'wp') or LONG2FIR(g,L,'hp') does the same assuming the
%   input window is a WPE or HPE window, respectively.
%
%   See also:  fir2long, middlepad

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

error(nargchk(2,3,nargin));

W=length(g);

if W<L
  error('L must be smaller than length of window.');
end;


if nargin==2
  % No assumption on the symmetry of the window.

  if rem(L,2)==0
    % HPE middlepad works the same way as the FIR cutting (e.g. just
    % removing middle points) for even values of L.
    g=middlepad(g,L,'hp');
  else
    % WPE middlepad works the same way as the FIR cutting (e.g. just
    % removing middle points) for odd values of L.
    g=middlepad(g,L);
  end;
  
else
  switch(lower(symmetry))
    case 'wp'
      g=middlepad(g,L);
      if rem(L,2)==0
	g(L/2+1)=0;
      end;
    case 'hp'
      g=middlepad(g,L,'hp');
      if rem(L,2)==1
	g(ceil(L/2))=0;
      end;
    otherwise
      error('Unknown symmetry.');
  end;
end;
