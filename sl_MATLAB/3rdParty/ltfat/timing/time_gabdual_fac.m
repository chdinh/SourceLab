
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
a=300;
M=400;

L=a*M;

N=L/a;
b=L/M;

c=gcd(a,M);
p=a/c;
q=M/c;
d=N/q;

gf=crand(p*q,c*d);

tic;
gdf1=comp_gabdual_fac(gf,L,a,M);
toc

tic
gdf2=ref_gabdual_fac_time(gf,L,a,M);
toc
