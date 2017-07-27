%COMPUTE_LONGER  Vary the length of the transform
%
%  This script computes the running time for longer and longer
%  transforms. Use the script plot_longer to visualize the result.
%
%  All other parameters except L remain fixed. The window length for the
%  filter bank algorithm is also kept fixed.
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
a_init=16;
W=4;
nrep=20;

for a=a_init:a_init:50*a_init
  M=2*a;
  gl=10*a;
  for L=gl:M:50*M
    s=sprintf('./time_dgt_fb %i %i %i %i %i %i >> big_fb.log\n',a,M,L,W, ...
              gl,nrep);
    disp(s);
    system(s);
    
    s=sprintf('./time_dgt_fac %i %i %i %i %i >> big_fac.log\n',a,M,L,W,nrep);  
    disp(s);
    system(s);
  end;
end;
