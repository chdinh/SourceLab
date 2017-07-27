function cadj=ref_spreadadj_3(coef)
%REF_SPREADADJ_3  Symbol of adjoint spreading function.
%   Usage: cadj=ref_spreadadj_3(c,number);
%
%   Development version by FJ for comparison of different implementations
%   cadj=SPREADADJ(c) will compute the symbol cadj of the spreading 
%   operator that is the adjoint of the spreading operator with symbol c. 
%
%   This is an improved implementation of the direct formula with low memory
%   needs
%
%   This implementation uses the direct formula given in case 2 with 
%   the following Optimizations :
%
%      Avoiding mod : In the loop of case 2, we see that 
%      mod(L-ii,L)~=L-ii only for ii==0 (idem for jj), so we can
%      remove the mod by processing separetly the cases ii==0 or
%      jj==0.
%
%      Precomputation of exp : In the loop of case 2, we see that we
%      compute many time complex exponential terms with the same 
%      values. Using precomputation and modulo, we can reduce the
%      computation time
% 
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

L=size(coef,1);

cadj=zeros(L);

% Proceesing for ii==0 or jj==0
cadj(1,1)=conj(coef(1,1));
cadj(2:end,1)=conj(coef(end:-1:2,1));
cadj(1,2:end,1)=conj(coef(1,end:-1:2));

% Proceesing for ii~=0 and jj~=0

% Precomputation for exponential term
% Optimization note : here we are computing the Lth root of unity 
% which have many known special properties and symetries that 
% could be exploited to highly reduce the computation for the 
% following line (this is not a critical part but some 
% improvements Optimizations are easy to identify)
temp=exp((-i*2*pi/L)*(0:L-1));

for ii=1:L-1
  for jj=1:L-1
    cadj(ii+1,jj+1)=conj(coef(L-ii+1,L-jj+1))...
        *temp(mod(ii*jj,L)+1);
  end;
end;
