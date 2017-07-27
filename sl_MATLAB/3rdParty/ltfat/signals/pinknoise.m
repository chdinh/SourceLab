function outsig = pinknoise(siglen,nsigs)
% PINKNOISE Generates a pink noise signal
%   Usage: outsig = pinknoise(siglen,nsigs);
%
%   Input parameters:
%       siglen    - Length of the noise (samples)
%       nsigs     - Number of signals (default is 1)
%
%   Output parameters:
%       outsig      - siglen x nsigs signal vector
%
%   PINKNOISE(siglen,nsigs) generates nsigs channels containing pink noise
%   (1/f spectrum) with the length of siglen. The signals are arranged as
%   columns in the output.

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

%   AUTHOR: Hagen Wierstorf


% ------ Checking of input parameter -------------------------------------

error(nargchk(1,2,nargin));

if ~isnumeric(siglen) || ~isscalar(siglen) || siglen<=0
    error('%s: siglen has to be a positive scalar.',upper(mfilename));
end

if nargin==1
  nsigs=1;
end;

if ~isnumeric(nsigs) || ~isscalar(nsigs) || nsigs<=0
    error('%s: siglen has to be a positive scalar.',upper(mfilename));
end

% --- Handle trivial condition

if siglen==1
  outsig=ones(1,nsigs);
  return;
end;

% ------ Computation -----------------------------------------------------
fmax = floor(siglen/2)-1;
f = (2:(fmax+1)).';
% 1/f amplitude factor
a = 1./sqrt(f);
% Random phase
p = randn(fmax,nsigs) + i*randn(fmax,nsigs);
sig = repmat(a,1,nsigs).*p;

outsig = ifftreal([ones(1,nsigs); sig; 1/(fmax+2)*ones(1,nsigs)],siglen);

% Scale output
%outsig = outsig ./ (max(abs(outsig(:)))+eps);
