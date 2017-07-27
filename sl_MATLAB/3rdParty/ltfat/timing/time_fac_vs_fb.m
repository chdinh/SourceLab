%TIME_FAC_VS_FB
%
%   The purpose of this test is to compare the fastest of the factorization
%   routines against the fastest of the filter bank routines for different
%   problems.
%
%   Some results: The FB computation seems to be completely memory bound:
%   increasing the length of the window does not impact the running time.
%
%   For the common 2xoversampling case with a long signal, the
%   factorization routine falls thorugh and is more than 10 times slower,
%   for the other case it is 3 times slower.

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


Lr=[480000*sf^2,480000*sf^2,262144*sf^2,262144*sf^2,900*sf^2,600];
ar=[     600*sf,     600*sf,        512,        512,       2, 20];
Mr=[     800*sf,     800*sf,       1024,       1024,  600*sf, 30];
gr=[     800*sf,480000*sf^2,       1024,     40*512,  600*sf,400];
Wr=[          2,          2,          2,          2,       1,600];

for ii=1:length(Lr)

  L=Lr(ii);
  
  M=Mr(ii);
  a=ar(ii);

  gl=gr(ii);
  W=Wr(ii);

  N=L/a;
  c=gcd(a,M);
  p=a/c;
  q=M/c;
  d=N/q;

  disp(sprintf('L:%6i W:%2i a:%4i M:%4i gl:%4i c:%4i d:%4i',L,W,a,M,gl,c,d));
  
  f=rand(L,W);
  gfir=rand(gl,1);  
  c2=mex_dgt_fb_2(f,gl,a,M,1); 
  
  f=rand(L,W);
  gf=rand(p*q,c*d);  
  c1=mex_dgt_fac_7(f,gf,a,M,1);
  
end;
