function cout = symphase(cin,a)
%SYMPHASE  Change Gabor coefficients to symmetric phase
%   Usage:  c=symphase(c,a);
%
%   SYMPHASE(c,a) alters the phase of the Gabor coefficients c so as if they
%   were obtained from a Gabor transform based on symmetric time/frequency
%   shifts. The coefficient must have been obtained from a DGT with
%   parameter a.
%
%   See also: dgt phaselock
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

%   AUTHORS : Peter Balazs
%             Peter Soendergaard.

error(nargchk(2,2,nargin));

if  (prod(size(a))~=1 || ~isnumeric(a))
  error('a must be a scalar');
end;

if rem(a,1)~=0
  error('a must be an integer');
end;

M=size(cin,1);
N=size(cin,2);
L=N*a;
b=L/M;

if rem(b,1)~=0
  error('Lattice error. The a parameter is probably incorrect.');
end;

TimeInd = (0:(N-1))/N;
FreqInd = (0:(M-1))*b;
    
phase = FreqInd'*TimeInd;
phase = exp(i*pi*phase);

% Handle multisignals
cout=zeros(size(cin));
for w=1:size(cin,3)
  cout(:,:,w) = cin(:,:,w).*phase;
end;
