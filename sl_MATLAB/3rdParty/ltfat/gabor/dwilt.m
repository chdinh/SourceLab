function [c,Ls]=dwilt(f,g,M,L)
%DWILT  Discrete Wilson transform.
%   Usage:  c=dwilt(f,g,M);
%           c=dwilt(f,g,M,L);
%           [c,Ls]=dwilt(f,g,M);
%           [c,Ls]=dwilt(f,g,M,L);
%
%   Input parameters:
%         f     : Input data
%         g     : Window function.
%         M     : Number of bands.
%         L     : Length of transform to do.
%   Output parameters:
%         c     : 2*M x N array of coefficients.
%         Ls    : Length of input signal.
%
%   DWILT(f,g,M) computes a discrete Wilson transform
%   with M bands and window g.
%
%   The length of the transform will be the smallest possible that is
%   larger than the signal. f will be zero-extended to the length of the 
%   transform. If f is a matrix, the transformation is applied to each column.
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of WILWIN for more details.
%
%   DWILT(f,g,M,L) computes the Wilson transform as above, but does
%   a transform of length L. f will be cut or zero-extended to length L before
%   the transform is done.
%
%   [c,Ls]=DWILT(f,g,M) or [c,Ls]=DWILT(f,g,M,L) additionally return the
%   length of the input signal f. This is handy for reconstruction:
%
%                [c,Ls]=dwilt(f,g,M);
%                fr=idwilt(c,gd,M,Ls);
%
%   will reconstruct the signal f no matter what the length of f is, provided
%   that gd is a dual Wilson window of g.
%
%   A Wilson transform is also known as a maximally decimated, even-stacked
%   cosine modulated filter bank.
%
%   Use the function WIL2RECT to visualize the coefficients or to work
%   with the coefficients in the TF-plane.
%
%   Assume that the following code has been executed for a column vector f:
%
%     c=dwilt(f,g,M);  % Compute a Wilson transform of f.
%     N=size(c,2)*2;   % Number of translation coefficients.
%
%   The following holds for m=0,...,M-1 
%   and n=0,...,N/2-1:
%
%   If m=0:
%
%                    L-1 
%     c(m+1,n+1)   = sum f(l+1)*g(l-2*n*M+1)
%                    l=0  
%
%   If m is odd and less than M
%
%                    L-1 
%     c(m+1,n+1)   = sum f(l+1)*sqrt(2)*sin(pi*m/M*l)*g(k-2*n*M+1)
%                    l=0  
% 
%                    L-1 
%     c(m+M+1,n+1) = sum f(l+1)*sqrt(2)*cos(pi*m/M*l)*g(k-(2*n+1)*M+1)
%                    l=0  
%
%   If m is even and less than M
%
%                    L-1 
%     c(m+1,n+1)   = sum f(l+1)*sqrt(2)*cos(pi*m/M*l)*g(l-2*n*M+1)
%                    l=0  
% 
%                    L-1 
%     c(m+M+1,n+1) = sum f(l+1)*sqrt(2)*sin(pi*m/M*l)*g(l-(2*n+1)*M+1)
%                    l=0  
%
%   if m=M and M is even:
%
%                    L-1 
%     c(m+1,n+1)   = sum f(l+1)*(-1)^(l)*g(l-2*n*M+1)
%                    l=0
%
%   else if m=M and M is odd
%
%                    L-1 
%     c(m+1,n+1)   = sum f(l+1)*(-1)^l*g(l-(2*n+1)*M+1)
%                    l=0
%
%   See also:  idwilt, wilwin, wil2rect, dgt, wmdct, wilorth
%
%   References:
%     H. Bölcskei, H. G. Feichtinger, K. Gröchenig, and F. Hlawatsch.
%     Discrete-time Wilson expansions. In Proc. IEEE-SP 1996 Int. Sympos.
%     Time-Frequency Time-Scale Analysis, june 1996.
%     
%     Y.-P. Lin and P. Vaidyanathan. Linear phase cosine modulated maximally
%     decimated filter banks with perfectreconstruction. IEEE Trans. Signal
%     Process., 43(11):2525-2539, 1995.

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
%   TESTING: TEST_DWILT
%   REFERENCE: REF_DWILT

error(nargchk(3,4,nargin));

if nargin<4
  L=[];
end;

[f,g,L,Ls,W,info] = gabpars_from_windowsignal(f,g,M,2*M,L,'DWILT');

% Call the computational subroutines.
c=comp_dwilt(f,g,M,L);


