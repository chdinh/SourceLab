function [xo]=largestn(xi,N,mtype)
%LARGESTN   Keep N largest coefficients.
%   Usage:  xo=largestn(x,N);
%           xo=largestn(x,N,mtype);
%
%   LARGESTN(x,N) returns an array of the same size as x keeping
%   the N largest coefficients.
%
%   LARGESTN(x,N,'full') returns the output as a full matrix. This is the
%   default.
%
%   LARGESTN(x,N,'sparse') returns the output as a sparse matrix.
%
%   If the coefficients represents a signal expanded in an orthonormal
%   basis, then this will be the best N-term approximation.
%
%   See also:  largestr
%
%   References:
%     S. Mallat. A wavelet tour of signal processing. Academic Press, San
%     Diego, CA, 1998.
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

%   AUTHOR : Peter Soendergaard and Bruno Torresani.  
%   TESTING: OK
%   REFERENCE: OK

error(nargchk(2,3,nargin));

if (prod(size(N))~=1 || ~isnumeric(N))
  error('N must be a scalar.');
end;

dosparse=0;
if nargin==3
  switch(lower(mtype))
    case {'full'}
    case {'sparse'}
      if ndims(xi)>2
	error('Sparse output is only supported for 1D/2D input. This is a limitation of Matlab/Octave.');
      end;
      dosparse=1;      
    otherwise
      error('The output type (last argument) must be either "full" or "sparse".');
  end;
end;

% Determine the size of the array.
ss=prod(size(xi));

% Handle the trivial cases.
if N>=ss
  xo=xi;
  return;
end;

if dosparse
  xo=sparse(size(xi,1),size(xi,2));
else
  xo=zeros(size(xi));
end;

if N<=0
  return;
end;

% Sort the absolute values of the coefficients.
sxi=sort(abs(xi(:)));

% Find the coeffiecient sitting at position N through the array,
% and use this as a threshing value. 
lambda=sxi(ss-N+1);

% Do the threshing.
signifmap=find(abs(xi)>=lambda);
xo(signifmap)=xi(signifmap);

