function cadj=ref_spreadadj_1(coef)
%REF_SPREADADJ_1  Symbol of adjoint spreading function.
%   Usage: cadj=ref_spreadadj_1(c,number);
%
%   Development version by FJ for comparison of different implementations
%   cadj=SPREADADJ(c) will compute the symbol cadj of the spreading 
%   operator that is the adjoint of the spreading operator with symbol c. 
%
%   This is the implementation previously in the toolbox, 
%   with the addition of an initialisation of cadj before the loop 
%   leading to a huge speed improvement :

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

L=size(coef,1);

% Matlab cannot handle an FFT of a sparse matrix.
coef=ifft(full(coef));

cadj = zeros(L);
for ii=0:L-1
  for jj=0:L-1
    cadj(ii+1,jj+1)=conj(coef(mod(ii-jj,L)+1,mod(-jj,L)+1));
  end;
end;

cadj=fft(full(cadj));
