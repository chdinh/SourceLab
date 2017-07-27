function c=zak(f,a);
%ZAK  Zak transform
%   Usage:  c=zak(f,a);
%
%   ZAK(f,a) computes the Zak transform of f with parameter a.
%   The coefficients are arranged in an a x L/a matrix, where L is the
%   length of f.
%
%   If f is a matrix, then the transformation is applied to each column.
%   This is then indexed by the third dimension of the output.
%
%
%   Assume that c=ZAK(f,a), where f is a column vector of length L and
%   N=L/a. Then the following holds for m=0,...,a-1 and n=0,...,N-1
%
%                          N-1  
%     c(m+1,n+1)=1/sqrt(N)*sum f(m-k*a+1)*exp(2*pi*i*n*k/N)
%                          k=0
%
%   See also:  izak
%
%   References:
%     A. J. E. M. Janssen. Duality and biorthogonality for discrete-time
%     Weyl-Heisenberg frames. Unclassified report, Philips Electronics,
%     002/94.
%     
%     H. Bölcskei and F. Hlawatsch. Discrete Zak transforms, polyphase
%     transforms, and applications. IEEE Trans. Signal Process.,
%     45(4):851-866, april 1997.

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

%   AUTHOR : Peter Soendergaard
%   TESTING: TEST_ZAK
%   REFERENCE: REF_ZAK

error(nargchk(2,2,nargin));

if (prod(size(a))~=1 || ~isnumeric(a))
  error([callfun,': a must be a scalar']);
end;

if rem(a,1)~=0
  error([callfun,': a must be an integer']);
end;


if size(f,2)>1 && size(f,1)==1
  % f was a row vector.
  f=f(:);
end;

L=size(f,1);
W=size(f,2);
N=L/a;

if rem(N,1)~=0
  error('The parameter for ZAK must divide the length of the signal.');
end;

c=zeros(a,N,W);

for ii=1:W
  % Compute it, it can be done in one line!
  % We use a normalized DFT, as this gives the correct normalization
  % of the Zak transform.
  c(:,:,ii)=dft(reshape(f(:,ii),a,N),[],2);
end;

