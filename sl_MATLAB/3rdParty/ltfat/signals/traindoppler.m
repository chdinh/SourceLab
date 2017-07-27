function s=traindoppler()
%TRAINDOPPLER  Load the 'traindoppler' test signal.
%   Usage:  s=traindoppler;
%
%   TRAINDOPPLER loads the 'traindoppler' signal. It is a recording
%   of a train passing close by with a clearly audible doppler shift of
%   the train whistle sound.
%
%   The signal is 157058 samples long and sampled at 8 kHz.
%
%   The signal was obtained from
%      http://www.fourmilab.ch/cship/doppler.html

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

s=wavread([f,'.wav']);

