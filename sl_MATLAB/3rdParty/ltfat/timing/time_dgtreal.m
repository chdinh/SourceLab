%TIME_DGTREAL  Time the DGT versus DGTREAL
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

a=1000;
M=1500;

L=a*M;
W=4;

f=randn(L,W);

g=randn(L,1);

tic;
  c1 = dgt(f,g,a,M);
  
t1=toc;

disp(sprintf('Time to execute dgt:     %f',t1));

tic;
  c2 = dgtreal(f,g,a,M);
t2=toc;

disp(sprintf('Time to execute dgtreal: %f',t2));