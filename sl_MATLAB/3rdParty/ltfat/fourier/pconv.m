function h=pconv(f,g,varargin)
%PCONV  Periodic convolution
%   Usage:  h=pconv(f,g)
%           h=pconv(ptype,f,g); 
%
%   PCONV(f,g) computes the periodic convolution of f and g. The convolution
%   is given by
%
%               L-1
%      h(l+1) = sum f(k+1) * g(l-k+1)
%               k=0
%
%   PCONV('r',f,g) computes the alternative where g is reversed given by
%
%               L-1
%      h(l+1) = sum f(k+1) * conj(g(k-l+1))
%               k=0
%
%   PCONV('rr',f,g) computes the alternative where both f and g are reversed
%   given by
%
%               L-1
%      h(l+1) = sum conj(f(-k+1)) * conj(g(k-l+1))
%               k=0
%     
%   In the above formulas, l-k, k-l and -k are computed modulo L.
%
%   See also: dft, involute

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
%   TESTING: TEST_PCONV
%   REFERENCE: REF_PCONV

% Assert correct input.
if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ~all(size(f)==size(g))
  error('f and g must have the same size.');
end;

definput.flags.type={'default','r','rr'};

[flags,kv]=ltfatarghelper({},definput,varargin);

if flags.do_default
    h=ifft(fft(f).*fft(g));
end;

if flags.do_r
  h=ifft(fft(f).*conj(fft(g)));
end;

if flags.do_rr
  h=ifft(conj(fft(f)).*conj(fft(g)));
end;

% Clean output if input was real-valued
if isreal(f) && isreal(g)
  h=real(h);
end;