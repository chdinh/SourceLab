function xo=uquant(xi,nbits,xmax,varargin);
%UQUANT  Simulate uniform quantization.
%   Usage:  x=uquant(x,nbits,xmax);
%           x=uquant(x,nbits,xmax,...);
%
%   UQUANT(x,nbits,xmax) simulates the effect of uniform quantization of x using
%   nbits bit. The output is simply x rounded to 2^{nbits} different values.
%   The xmax parameters specify the maximal value that should be quantifiable.
%
%   UQUANT takes the following flags at the end of the input arguments.
%
%    's' - Signed quantization. This assumes that the signal

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
           has a both positive and negative part. Useful for sound
           signals. This is the default
%
%-   'u' - Unsigned quantization. Assumes the signal is positive.
%          Negative values are silently rounded to zero.
%          Useful for images.
%
%   If this function is applied to a complex signal, it will simply be
%   applied to the real and imaginary part separately.
%

%   AUTHOR : Peter Soendergaard and Bruno Torresani.  
%   TESTING: OK
%   REFERENCE: OK

if nargin<4
  error('Too few input parameters.');
end;

% Define initial value for flags and key/value pairs.
definput.flags.sign={'s','u'};

[flags,keyvals]=ltfatarghelper({},definput,varargin);

% ------ handle complex values ------------------
if ~isreal(xi)
  xo = uquant(real(xi),nbits,xmax,varargin{:}) + ...
	i*uquant(imag(xi),nbits,xmax,varargin{:});
  return
end;

if nbits<1
  error('Must specify at least 2 bits.');
end;

% Calculate number of buckets.
nbuck=2^nbits;    

if xmax<max(abs(xi(:)))
  error('Signal contains values higher than xmax.');
end;

if flags.do_s
  
  % ------------ unsigned case -----------------
  
  bucksize=xmax/(nbuck/2-1);
  
  xo=round(xi/bucksize)*bucksize;        
  
else

  % ------------- signed case------------
  
  bucksize=xmax/(nbuck-.51);
  
  % Thresh all negative values to zero.
  xi=xi.*(xi>0);
  
  xo=round(xi/bucksize)*bucksize;        
  
end;

