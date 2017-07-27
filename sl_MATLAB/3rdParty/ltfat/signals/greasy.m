function s=greasy()
%GREASY  Load the 'greasy' test signal.
%   Usage:  s=greasy;
%
%   GREASY loads the 'greasy' signal. It is a recording of a woman
%   pronouncing the word "greasy".
%
%   The signal is 5880 samples long and recorded at 16 khz with around 11
%   bits of effective quantization.
%
%   The signal has been scaled to not produce any clipping when
%   played. To get integer values use round(greasy*2048).
%
%   The signal was obtained from Wavelab:
%     http://www-stat.stanford.edu/~wavelab/
%
%   References:
%     S. Mallat and Z. Zhang. Matching pursuits with time-frequency
%     dictionaries. IEEE Trans. Signal Process., 41(12):3397-3415, 1993.
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
%   TESTING: TEST_SIGNALS
%   REFERENCE: OK
  
if nargin>0
  error('This function does not take input arguments.')
end;

f=mfilename('fullpath');

s = wavread([f,'.wav']);

