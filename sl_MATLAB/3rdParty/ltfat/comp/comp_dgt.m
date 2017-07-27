function c=comp_dgt(f,g,a,M,L,phasetype)
%COMP_DGT  Compute a DGT
%   Usage:  c=comp_dgt(f,g,a,M,L,phasetype);
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
%   If phasetype is zero, a freq-invariant transform is computed. If
%   phase-type is one, a time-invariant transform is computed.

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
%   TESTING: OK
%   REFERENCE: OK

Lwindow=size(g,1);

W=size(f,2);
N=L/a;

if Lwindow<L
  % Do the filter bank algorithm
  % Periodic boundary conditions
  c=comp_dgt_fb(f,g,a,M,0);

else
  % Do the factorization algorithm
  c=comp_dgt_long(f,g,a,M);

end;

c=reshape(c,M,N,W);

if phasetype==1
  c=phaselock(c,a);
end;
