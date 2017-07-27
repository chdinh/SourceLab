function [f,g,L,Ls,W,info] = gabpars_from_windowsignal(f,g,a,M,L,callfun)
%GABPARS_FROM_WINDOWSIGNAL  Compute g and L from window and signal
%   Usage: [g,g.info,L] = gabpars_from_windowsignal(f,g,a,M);
%
%   Use this function if you know an input signal, a window and a lattice
%   for the DGT. The function will calculate a transform length L and
%   evaluate the window g into numerical form. The signal will be padded and
%   returned as a column vector.
%
%   If the transform length is unknown (as it usually is unless explicitly
%   specified by the user), set L to be [] in the input to this function.

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
  
if nargin<6
  stacknames=dbstack;  
  callfun=stacknames(2).name;
end;

assert_squarelat(a,M,1,callfun,0);

if ~isempty(L)
  if (prod(size(L))~=1 || ~isnumeric(L))
    error('%s: L must be a scalar',callfun);
  end;
  
  if rem(L,1)~=0
    error('%s: L must be an integer',callfun);
  end;
end;

% Change f to correct shape.
[f,Ls,W,wasrow,remembershape]=comp_sigreshape_pre(f,callfun,0);

if isnumeric(g)
  if ~isvector(g)
    error('%s: g must be a vector',upper(callfun));
  end;
  Lwindow=length(g);
else
  Lwindow=0;
end;


if isempty(L)
  % Smallest length transform.
  Lsmallest=lcm(a,M);

  % Choose a transform length larger than both the length of the
  % signal and the window.
  L=ceil(max(Ls,Lwindow)/Lsmallest)*Lsmallest;
else

  if rem(L,M)~=0
    error('%s: The length of the transform must be divisable by M = %i',...
          callfun,M);
  end;

  if rem(L,a)~=0
    error('%s: The length of the transform must be divisable by a = %i',...
          callfun,a);
  end;

  if L<Lwindow
    error('%s: Window is too long.',callfun);
  end;

end;

b=L/M;
N=L/a;

[g,info]=gabwin(g,a,M,L,callfun);

f=postpad(f,L);

% If the signal is single precision, make the window single precision as
% well to avoid mismatches.
if isa(f,'single')
  g=single(g);
end;


