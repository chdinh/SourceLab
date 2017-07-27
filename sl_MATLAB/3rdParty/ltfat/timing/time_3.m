%TIME_3
%
%   The purpose of this test is to determine whether it pays of to do
%   contiquous FFTs in stead of strided FFTs
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

Lr=[480000*sf^2,262144*sf^2,900*sf^2];
ar=[     600*sf,        512,       2];
Mr=[     800*sf,       1024,  600*sf];

for ii=1:length(Lr)

  L=Lr(ii);
  
  M=Mr(ii);
  a=ar(ii);
  
  g=rand(L,1);
  f=rand(L,1);
  
  [L, a, M]

  N=L/a;
  c=gcd(a,M);
  p=a/c;
  q=M/c;
  d=N/q;

  f=rand(L,1);
  gf=rand(p*q,c*d);  
  c1=mex_dgt_fac_1(f,gf,a,M,1);
  
  f=rand(L,1);
  gf=rand(p*q,c*d);  
  c2=mex_dgt_fac_3(f,gf,a,M,1);

end;