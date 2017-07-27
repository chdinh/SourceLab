function [f]=comp_idwiltiii(coef,g)
%COMP_IDWILTIII  Compute Inverse discrete Wilson transform type III.
% 
%   This is a computational routine. Do not call it
%   directly.

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

M=size(coef,1);
N=size(coef,2);
W=size(coef,3);
a=M;

L=N*M;

coef2=zeros(2*M,N,W);

coef2(1:2:M,1:2:N,:)        = exp( i*pi/4)*coef(1:2:M,1:2:N,:);
coef2(2*M:-2:M+1,1:2:N,:)   = exp(-i*pi/4)*coef(1:2:M,1:2:N,:);

coef2(1:2:M,2:2:N,:)        = exp(-i*pi/4)*coef(1:2:M,2:2:N,:);
coef2(2*M:-2:M+1,2:2:N,:)   = exp( i*pi/4)*coef(1:2:M,2:2:N,:);

coef2(2:2:M,1:2:N,:)        = exp(-i*pi/4)*coef(2:2:M,1:2:N,:);
coef2(2*M-1:-2:M+1,1:2:N,:) = exp( i*pi/4)*coef(2:2:M,1:2:N,:);

coef2(2:2:M,2:2:N,:)        = exp( i*pi/4)*coef(2:2:M,2:2:N,:);
coef2(2*M-1:-2:M+1,2:2:N,:) = exp(-i*pi/4)*coef(2:2:M,2:2:N,:);

% Apply the generalized DGT and scale.
f=comp_igdgt(coef2,g,a,2*M,L,0,.5,0,0)/sqrt(2);

if isreal(coef) && isreal(g)
  f=real(f);
end;
