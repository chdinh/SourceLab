function c=comp_dgtreal(f,g,a,M,L,phasetype)
%COMP_DGTREAL  Compute a DGTREAL
%   Usage:  c=comp_dgt_real(f,g,a,M,L);
%
%   Input parameters:
%         f     : Input data
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : Length of transform to do.
%   Output parameters:
%         c     : M*N array of coefficients.
%

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

%   AUTHOR : Peter Soendergaard.

Lwindow=size(g,1);

W=size(f,2);
N=L/a;

M2=floor(M/2)+1;

if Lwindow<L
  % Do the filter bank algorithm
  % Periodic boundary conditions
  c=comp_dgtreal_fb(f,g,a,M,0);
  
else
  % Do the factorization algorithm 
  c=comp_dgtreal_long(f,g,a,M);
  
end;

c=reshape(c,M2,N,W);

if phasetype==1
    
    TimeInd = (0:(N-1))*a;
    FreqInd = (0:(M2-1))/M;
    
    phase = FreqInd'*TimeInd;
    phase = exp(2*i*pi*phase);
    
    for w=1:W
        c(:,:,w) = c(:,:,w).*phase;
    end;

end;


