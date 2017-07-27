function [f]=idgt(coef,g,a,varargin)
%IDGT  Inverse discrete Gabor transform.
%   Usage:  f=idgt(c,g,a);
%           f=idgt(c,g,a,Ls);
%
%   Input parameters:
%         c     : Array of coefficients.
%         g     : Window function.
%         a     : Length of time shift.
%         Ls    : length of signal.
%   Output parameters:
%         f     : Signal.
%
%   IDGT(c,g,a) computes the Gabor expansion of the input coefficients
%   c with respect to the window g and time shift a. The number of 
%   channels is deduced from the size of the coefficients c.
%
%   IDGT(c,g,a,Ls) does as above but cuts or extends f to length Ls.
%
%   For perfect reconstruction, the window used must be a dual window of the
%   one used to generate the coefficients.
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of GABWIN for more details.
%
%   If g is a row vector, then the output will also be a row vector. If c is
%   3-dimensional, then IDGT will return a matrix consisting of one column
%   vector for each of the TF-planes in c.
%
%   Assume that f=IDGT(c,g,a,L) for an array c of size M x N. 
%   Then the following holds for k=0,...,L-1: 
% 
%             N-1 M-1          
%   f(l+1)  = sum sum c(m+1,n+1)*exp(2*pi*i*m*l/M)*g(l-a*n+1)
%             n=0 m=0          
%
%   IDGT takes the following flags at the end of the line of input
%   arguments:
%
%      'freqinv'  - Compute an IDGT using a frequency-invariant phase. This
%                   is the default convention described above.
%
%      'timeinv'  - Compute an IDGT using a time-invariant phase. This
%                   convention is typically used in filter bank algorithms.
%
%   See also:  dgt, gabwin, dwilt, gabtight

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

%   AUTHOR : Peter Soendergaard.
%   TESTING: TEST_DGT
%   REFERENCE: OK

% Check input paramameters.

if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

if numel(g)==1
  error('g must be a vector (you probably forgot to supply the window function as input parameter.)');
end;

definput.keyvals.Ls=[];
definput.flags.phase={'freqinv','timeinv'};
[flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);

wasrow=0;

if isnumeric(g)
  if size(g,2)>1
    if size(g,1)>1
      error('g must be a vector');
    else
      % g was a row vector.
      g=g(:);
      
      % If the input window is a row vector, and the dimension of c is
      % equal to two, the output signal will also
      % be a row vector.
      if ndims(coef)==2
        wasrow=1;
      end;
    end;
  end;
end;

M=size(coef,1);
N=size(coef,2);
W=size(coef,3);

% use assert_squarelat to check a and the window size.
assert_squarelat(a,M,1,'IDGT');

L=N*a;

g=gabwin(g,a,M,L,'IDGT');

assert_L(L,size(g,1),L,a,M,'IDGT');

f=comp_idgt(coef,g,a,M,L,flags.do_timeinv);

% Cut or extend f to the correct length, if desired.
if ~isempty(Ls)
  f=postpad(f,Ls);
else
  Ls=L;
end;

f=comp_sigreshape_post(f,Ls,wasrow,[0; W]);




