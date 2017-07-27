function c=dstiv(f,L,dim)
%DSTIV  Discrete Sine Transform type IV
%   Usage:  c=dstiv(f);
%           c=dstiv(f,L);
%           c=dstiv(f,[],dim);
%           c=dstiv(f,L,dim);
%
%   DSTIV(f) computes the discrete sine transform of type IV of the
%   input signal f. If f is a matrix, then the transformation is applied to
%   each column. For N-D arrays, the transformation is applied to the first
%   dimension.
%
%   DSTIV(f,L) zero-pads or truncates f to length L before doing the
%   transformation.
%
%   DSTIV(f,[],dim) applies the transformation along dimension dim. 
%   DSTIV(f,L,dim) does the same, but pads or truncates to length L.
%   
%   The transform is real (output is real if input is real) and
%   it is orthonormal. It is its own inverse.
%
%   Let f be a signal of length L and let c=DSTIV(f). Then
% 
%                          L-1
%     c(n+1) = sqrt(2/L) * sum f(m+1)*sin(pi*n*(m+.5)/L) 
%                          m=0 
% 
%   See also:  dstii, dstiii, dctii
% 
%   References:
%     K. Rao and P. Yip. Discrete Cosine Transform, Algorithms, Advantages,
%     Applications. Academic Press, 1990.
%     
%     M. V. Wickerhauser. Adapted wavelet analysis from theory to software.
%     Wellesley-Cambridge Press, Wellesley, MA, 1994.

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

%   AUTHOR: Peter Soendergaard
%   TESTING: TEST_PUREFREQ
%   REFERENCE: REF_DSTIV

error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;
    
[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DSTIV');

if ~isempty(L)
  f=postpad(f,L);
end;

s1=zeros(2*L,W);
c=zeros(L,W);

m1=1/sqrt(2)*exp(-(0:L-1)*pi*i/(2*L)).';
m2=-1/sqrt(2)*exp((1:L)*pi*i/(2*L)).';

for w=1:W
  s1(:,w)=[m1.*f(:,w);flipud(m2).*f(L:-1:1,w)];
end;
  
s1=i*exp(-pi*i/(4*L))*fft(s1)/sqrt(2*L);

% This could be done by a repmat instead.
for w=1:W
  c(:,w)=s1(1:L,w).*m1+s1(2*L:-1:L+1,w).*m2;
end;

if isreal(f)
  c=real(c);
end;

c=assert_sigreshape_post(c,dim,permutedsize,order);

% This is a slow, but convenient way of expressing the algorithm.
%R=1/sqrt(2)*[diag(exp(-(0:L-1)*pi*i/(2*L)));...
%	     flipud(diag(-exp((1:L)*pi*i/(2*L))))];

%c=i*(exp(-pi*i/(4*L))*R.'*fft(R*f)/sqrt(2*L));
