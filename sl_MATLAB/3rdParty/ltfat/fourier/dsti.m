function c=dsti(f,L,dim)
%DSTI  Discrete Sine Transform type I
%   Usage:  c=dsti(f);
%           c=dsti(f,L);
%           c=dsti(f,[],dim);
%           c=dsti(f,L,dim);
%
%   DSTI(f) computes the discrete sine transform of type I of the
%   input signal f. If f is a matrix, then the transformation is applied to
%   each column. For N-D arrays, the transformation is applied to the first
%   dimension.
%
%   DSTI(f,L) zero-pads or truncates f to length N before doing the
%   transformation.
%
%   DSTI(f,[],dim) applies the transformation along dimension dim. 
%   DSTI(f,L,dim) does the same, but pads or truncates to length L.
%
%   The transform is real (output is real if input is real) and
%   it is orthonormal.
%
%   This transform is its own inverse.
%
%   Let f be a signal of length L and let c=DSTI(f). Then 
% 
%                              L-1
%     c(n+1) = sqrt(2/(L+1)) * sum sin(pi*(n+1)*(m+1)/(L+1)) 
%                              m=0 
%
%   The implementation of this functions uses a simple algorithm that require
%   an FFT of length 2N+2, which might potentially be the product of a large
%   prime number. This may cause the function to sometimes execute slowly.
%   If guaranteed high speed is a concern, please consider using one of the
%   other DST transforms.
% 
%   See also:  dcti, dstiii, dstiv
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
%   REFERENCE: REF_DSTI

  
error(nargchk(1,3,nargin));

if nargin<3
  dim=[];
end;

if nargin<2
  L=[];
end;

[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'DSTI');

if ~isempty(L)
  f=postpad(f,L);
end;

if L==1
  c=f;
 
else

  c=zeros(L,W);

  s1=dft([zeros(1,W);...
	      f;...
	      zeros(1,W);...
	      -flipud(f)]);


  % This could be done by a repmat instead.
  for w=1:W
    c(:,w)=s1(2:L+1,w)-s1(2*L+2:-1:L+3,w);
  end;

  c=c*i/2;
  
  if isreal(f)
    c=real(c);
  end;

end;

c=assert_sigreshape_post(c,dim,permutedsize,order);
