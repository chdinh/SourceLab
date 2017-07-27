
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


if 0
  
  % Long example
  reps=10;
  
  a=600;
  M=800;
  
  K=10*lcm(a,M);
  W=2;

  ndatapoints=10;
  
  glfac=3;

end;

if 1
  
  % Short example
  reps=1000;
  
  a=20;
  M=30;
  
  K=lcm(a,M);
  W=2;
  
  glfac=3;

end;
  
  data_fac = zeros(ndatapoints,1);
  data_fb  = zeros(ndatapoints,1);

  x=K*(1:ndatapoints);
  

for ii=1:ndatapoints
  L=x(ii);
  L
  
  f=randn(L,W);
  g=pgauss(L,1);
  gc=middlepad(g,glfac*M);
  
  tic;
  for jj=1:reps
    c=dgt(f,g,a,M);
  end;
  data_fac(ii)=toc/reps;
  
  tic;
  for jj=1:reps
    c=dgt(f,gc,a,M);
  end;
  data_fb(ii)=toc/reps;
    
end;
  
plot(x,data_fac,'x',...
     x,data_fb,'o');

legend;