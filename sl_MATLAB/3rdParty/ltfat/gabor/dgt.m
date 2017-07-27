function [c,Ls]=dgt(f,g,a,M,varargin)
%DGT  Discrete Gabor transform.
%   Usage:  c=dgt(f,g,a,M);
%           c=dgt(f,g,a,M,L);
%           [c,Ls]=dgt(f,g,a,M);
%           [c,Ls]=dgt(f,g,a,M,L);
%
%   Input parameters:
%         f     : Input data
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of channels.
%         L     : Length of transform to do.
%   Output parameters:
%         c     : M*N array of coefficients.
%         Ls    : Length of input signal.
%
%   DGT(f,g,a,M) computes the Gabor coefficients of the input
%   signal f with respect to the window g and parameters a and M. The
%   output is a vector/matrix in a rectangular layout.
%
%   The length of the transform will be the smallest multiple of a and M
%   that is larger than the signal. f will be zero-extended to the length of
%   the transform. If f is a matrix, the transformation is applied to each
%   column. The length of the transform done can be obtained by
%   L=size(c,2)*a;
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of GABWIN for more details.
%
%   DGT(f,g,a,M,L) computes the Gabor coefficients as above, but does
%   a transform of length L. f will be cut or zero-extended to length L before
%   the transform is done.
%
%   [c,Ls]=DGT(f,g,a,M) or [c,Ls]=DGT(f,g,a,M,L) additionally returns the
%   length of the input signal f. This is handy for reconstruction:
%
%                [c,Ls]=dgt(f,g,a,M);
%                fr=idgt(c,gd,a,Ls);
%
%   will reconstruct the signal f no matter what the length of f is, provided
%   that gd is a dual window of g.
%
%   The Discrete Gabor Transform is defined as follows: Consider a window g
%   and a one-dimensional signal f of length L and define N=L/a.
%   The output from c=DGT(f,g,a,M) is then given by
%
%                  L-1 
%     c(m+1,n+1) = sum f(l+1)*exp(-2*pi*i*m*l/M)*conj(g(l-a*n+1)), 
%                  l=0  
%
%   where m=0,...,M-1 and n=0,...,N-1 and l-an is computed modulo
%   L.
%
%   DGT takes the following flags at the end of the line of input
%   arguments:
%
%      'freqinv'  - Compute a DGT using a frequency-invariant phase. This
%                   is the default convention described above.
%
%      'timeinv'  - Compute a DGT using a time-invariant phase. This
%                   convention is typically used in filter bank algorithms.
%
%   See also:  idgt, gabwin, dwilt, gabdual, phaselock
%
%   Demos:  demo_dgt
%
%   References:
%     K. Gröchenig. Foundations of Time-Frequency Analysis. Birkhäuser, 2001.
%     
%     H. G. Feichtinger and T. Strohmer, editors. Gabor Analysis and
%     Algorithms. Birkhäuser, Boston, 1998.

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
%   REFERENCE: REF_DGT
  
% Assert correct input.

if nargin<4
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.keyvals.L=[];
definput.flags.phase={'freqinv','timeinv'};
[flags,kv]=ltfatarghelper({'L'},definput,varargin);

[f,g,L,Ls] = gabpars_from_windowsignal(f,g,a,M,kv.L);

c=comp_dgt(f,g,a,M,L,flags.do_timeinv);

