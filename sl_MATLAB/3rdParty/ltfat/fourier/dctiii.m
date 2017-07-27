function c=dctiii(f,L,dim)
%DCTIII  Discrete Consine Transform type III
%   Usage:  c=dctiii(f);
%           c=dctiii(f,L);
%           c=dctiii(f,[],dim);
%           c=dctiii(f,L,dim);
%
%   DCTIII(f) computes the discrete consine transform of type III of the
%   input signal f. If f is a matrix, then the transformation is applied to
%   each column. For N-D arrays, the transformation is applied to the first
%   dimension.
%
%   DCTIII(f,L) zero-pads or truncates f to length L before doing the
%   transformation.
%
%   DCTIII(f,[],dim) applies the transformation along dimension dim. 
%   DCTIII(f,L,dim) does the same, but pads or truncates to length L.
%
%   The transform is real (output is real if input is real) and
%   it is orthonormal.
%
%   This is the inverse of DCTII
%
%   Let f be a signal of length L, let c=DCTIII(f) and define the vector
%   w of length L by  
%     w = [1/sqrt(2) 1 1 1 1 ...]
%   Then 
% 
%                          L-1
%     c(n+1) = sqrt(2/L) * sum w(n+1)*f(m+1)*cos(pi*(n+.5)*m/L) 
%                          m=0 
% 
%   See also:  dctii, dctiv, dstii
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
%   REFERENCE: REF_DCTIII

error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;

[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DCTIII');

if ~isempty(L)
  f=postpad(f,L);
end;

c=zeros(2*L,W);

m1=1/sqrt(2)*exp(-(0:L-1)*pi*i/(2*L)).';
m1(1)=1;
  
m2=1/sqrt(2)*exp((L-1:-1:1)*pi*i/(2*L)).';

for w=1:W
  c(:,w)=[m1.*f(:,w);0;m2.*f(L:-1:2,w)];
end;

c=fft(c)/sqrt(L);

c=c(1:L,:);

if isreal(f)
  c=real(c);
end;

c=assert_sigreshape_post(c,dim,permutedsize,order);

% This is a slow, but convenient way of expressing the above algorithm.
%R=1/sqrt(2)*[diag(exp(-(0:L-1)*pi*i/(2*L)));...
%	     zeros(1,L); ...
%	     [zeros(L-1,1),flipud(diag(exp((1:L-1)*pi*i/(2*L))))]];

%R(1,1)=1;

%c=fft(R*f)/sqrt(L);

%c=c(1:L,:);
