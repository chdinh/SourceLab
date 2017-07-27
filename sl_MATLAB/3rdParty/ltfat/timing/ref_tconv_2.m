function h=ref_tconv_2(f,g)
%REF_TCONV_2  Reference TCONV
%   Usage:  h=ref_tconv_2(f,g)
%
%   REF_TCONV_2(f,g,a) computes the twisted convolution of f and g.
%
%   Version for sparse matrices with precomputation of  the 
%   position of non-zeros coefficients. It uses more memory, is much
%   less readable, but faster

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
  
L=size(f,1);
  
        
[rowf,colf,valf]=find(f);
nf=length(valf);
[rowg,colg,valg]=find(g);
ng=length(valg);

% precompute the position of non-zeros coefficient (stored in mn)
% for this we need two matrices m and n that can be big 
% (of size ngxnf)
m=mod(repmat(rowf'-2,ng,1)+repmat(rowg,1,nf), L);
n=mod(repmat(colf'-2,ng,1)+repmat(colg,1,nf), L);
[mn,I,J] = unique([m(:),n(:)], 'rows');

% precompute the Lth roots of unity
% Optimization note : the special properties and symetries of the 
% roots of unitycould be exploited to reduce this computation.
% Furthermore here we precompute every possible root if some are 
% unneeded. 
temp=exp((-i*2*pi/L)*(0:L-1)');

% compute the value of the non-zeros coefficients
valh=zeros(size(mn,1),1);
for indf=1:length(valf)
  for indg=1:length(valg)
    ind=J((indf-1)*ng+indg);
    valh(ind)=valh(ind)+valf(indf)*valg(indg)*...
              temp(mod((m(indg,indf)-(rowf(indf)-1))*...
                       (colf(indf)-1),L)+1);
  end
end

% construct the sparse result
h=sparse(mn(:,1)+1,mn(:,2)+1,valh,L,L);
