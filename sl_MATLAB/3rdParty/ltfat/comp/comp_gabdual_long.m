function gd=comp_gabdual_long(g,a,M);
%COMP_GABDUAL_LONG  Compute dual window
%
%  This is a computational subroutine, do not call it directly, use
%  GABDUAL instead.
%
%  See also: gabdual

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
  
L=length(g);

gf=comp_wfac(g,a,M);

b=L/M;
N=L/a;

c=gcd(a,M);
d=gcd(b,N);
  
p=b/d;
q=N/d;

gdf=zeros(p*q,c*d);

G=zeros(p,q);
for ii=1:c*d
  % This essentially computes pinv of each block.

  G(:)=gf(:,ii);
  S=G*G';
  Gpinv=(S\G);

  gdf(:,ii)=Gpinv(:);
end;

gd=comp_iwfac(gdf,L,a,M);

if isreal(g)
  gd=real(gd);
end;
