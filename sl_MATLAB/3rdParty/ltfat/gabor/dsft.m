function F=dsft(F);
%DSFT  Discrete Symplectic Fourier Transform
%   Usage:  C=dsft(F);
%
%   DSFT(F) computes the discrete symplectic Fourier transform of F.
%   F must be a matrix or a 3D array. If F is a 3D array, the 
%   transformation is applied along the first two dimensions.
%
%   Let F be a K x L matrix. Then the DSFT of F is given by
%
%                               L-1 K-1
%    C(m+1,n+1) = 1/sqrt(K*L) * sum sum F(k+1,l+1)*exp(2*pi*i(k*n/K-l*m/L))
%                               l=0 k=0
%
%   for m=0,...,L-1 and n=0,...,K-1.
%
%   The DSFT is its own inverse.
%
%   References:
%     H. G. Feichtinger, W. Kozek, and F. Luef. Gabor analysis over finite
%     Abelian groups. Appl. Comput. Harmon. Anal., submitted, 2007.
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

error(nargchk(1,1,nargin));

D=ndims(F);

if (D<2) || (D>3)
  error('Input must be two/three dimensional.');
end;

W=size(F,3);

if W==1
  F=dft(idft(F).');
else
  % Apply to set of planes.
  
  R1=size(F,1);
  R2=size(F,2);
  Fo=zeros(R2,R1,W);
  for w=1:W
    Fo(:,:,w)=dft(idft(F(:,:,w).'));
  end;
  F=Fo;
end;