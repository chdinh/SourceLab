function g=pchirp(L,n)
%PCHIRP  Periodic chirp
%   Usage:  g=pchirp(L,n);
%
%   PCHIRP(L,n) returns a periodic, discrete chirp of length L that revolves
%   n times around the time-frequency plane in frequency. n must be a whole
%   number.
%
%   To get a chirp that revolves around the time-frequency plane in time,
%   use
%
%      dft(pchirp(L,N));  
%
%   The chirp is computed by:
%   
%      g(l+1) = exp(pi*i*n*l^2/L) for l=0,...,L-1
%
%   The chirp has absolute value 1 everywhere. To get a chirp with unit
%   l^2-norm, divide the chirp by sqrt(L).
%
%   See also: dft, expwave
%
%   References:
%     H. G. Feichtinger, M. Hazewinkel, N. Kaiblinger, E. Matusiak, and
%     M. Neuhauser. Metaplectic operators on c^n. To appear, 2006.
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

%   AUTHOR : Peter Soendergaard
%   TESTING: OK
%   REFERENCE: OK

error(nargchk(2,2,nargin));

% Compute normalized chirp
g=(exp((0:L-1).^2/L*pi*i*n)/sqrt(L)).';
