function h=ref_tconv_1(f,g,a)
%REF_TCONV_1  Reference TCONV
%   Usage:  h=ref_tconv_1(f,g)
%
%   REF_TCONV_1(f,g,a) computes the twisted convolution of f and g.
%
%   Version for sparse matrices without precomputation of the 
%   position of non-zeros coefficients.

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

% AUTHOR: Floret Jaillet

L=size(f,1);

h=zeros(L,L);


% precompute the Lth roots of unity
% Optimization note : the special properties and symetries of the 
% roots of unitycould be exploited to reduce this computation.
% Furthermore here we precompute every possible root if some are 
% unneeded. 
temp=exp((-i*2*pi/L)*(0:L-1)');
[rowf,colf,valf]=find(f);
[rowg,colg,valg]=find(g);

h=sparse(L,L);

for indf=1:length(valf)
  for indg=1:length(valg)
    m=mod(rowf(indf)+rowg(indg)-2, L);
    n=mod(colf(indf)+colg(indg)-2, L);
    h(m+1,n+1)=h(m+1,n+1)+valf(indf)*valg(indg)*temp(mod((m-(rowf(indf)-1))*(colf(indf)-1),L)+1);
  end
end

