function s=gspi()
%GSPI  Load the 'glockenspiel' test signal.
%
%   GSPI loads the 'glockenspiel' signal. The is 262144 samples long,
%   mono, recorded at 44100 Hz using 16 bit quantization.
%   
%   The signal, and other similar audio tests signals, can be found on
%   http://andrew.csie.ncyu.edu.tw/html/mpeg4/sound.media.mit.edu/mpeg4/audio/sqam/index.html
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

% Load audio signal
s = wavread([f,'.wav']);
