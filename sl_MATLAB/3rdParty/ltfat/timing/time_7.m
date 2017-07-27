%TIME_7
%
%   The purpose of this test is to compare the FB routines.
%
%   fb_1 is the original, using two passes through memory and no integer
%   optimizations.
%
%   fb_2 use only one pass and integer optimizations.

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


Lr=[480000*sf^2,480000*sf^2,262144*sf^2,262144*sf^2,900*sf^2];
ar=[     600*sf,     600*sf,        512,        512,       2];
Mr=[     800*sf,     800*sf,       1024,       1024,  600*sf];
gr=[     800*sf,  40*600*sf,       1024,     40*512,  600*sf];

for ii=1:length(Lr)

  L=Lr(ii);
  
  M=Mr(ii);
  a=ar(ii);

  gl=gr(ii);
  
  g=rand(L,1);
  f=rand(L,1);
  gfir=rand(gl,1);
  
  [L, a, M, gl]
  
  c1=mex_dgt_fb_1(f,gl,a,M,1);
  c2=mex_dgt_fb_2(f,gl,a,M,1);

end;
