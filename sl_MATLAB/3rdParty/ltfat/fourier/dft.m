function f=dft(f,N,dim);
%DFT   Normalized Discrete Fourier Transform
%   Usage: f=dft(f);
%          f=dft(f,N,dim);
%
%   DFT computes a normalized discrete Fourier transform. This is nothing
%   but a scaled version of the output from FFT. The function takes exactly
%   the same arguments as FFT. See the help on FFT for a thorough
%   description.
%
%   See also:  idft

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
%   TESTING: OK
%   REFERENCE: OK

error(nargchk(1,3,nargin));

if nargin<3
  dim=[];  
end;

if nargin<2
  N=[];
end;

[f,N,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,N,dim,'DFT');

% Force FFT along dimension 1, since we have permuted the dimensions
% manually
f=fft(f,N,1)/sqrt(N);

f=assert_sigreshape_post(f,dim,permutedsize,order);
