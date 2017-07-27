
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
if 1
  % This is the setup used in the paper
  a=30;
  M=60; 
  L=a*M; 
  W=4;
  nrep=20;
else
  a=16;
  M=64; 
  L=a*M; 
  W=1;
  nrep=4;  
  
end;

system('rm crossover.log');
%for gl=M:M:20*M
for gl=M:M:16*M
  s=sprintf('./time_dgt_fb %i %i %i %i %i %i >> crossover.log\n',a,M,L,W,gl,nrep);
  
  disp(s);
  system(s);
end;

s=sprintf('./time_dgt_fac %i %i %i %i %i > crossover.ref\n',a,M,L,W,nrep);

disp(s);
system(s);