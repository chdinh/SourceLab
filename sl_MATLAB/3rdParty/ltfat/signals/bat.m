function s=bat()
%BAT  Load the 'bat' test signal.
%   Usage:  s=bat;
%
%   BAT loads the 'bat' signal. It is a 400 samples long recording
%   of a bat chirp sampled with a sampling period of 7 microseconds.
%   This gives a sampling rate of 143 khz.
%
%   The signal can be obtained from
%   http://dsp.rice.edu/software/bat-echolocation-chirp
%
%   Please acknowledge use of this data in publications as follows:
%   ``The author wishes to thank Curtis Condon, Ken White, and Al Feng of
%   the Beckman Institute of the University of Illinois for the bat data
%   and for permission to use it in this paper.''
%
%   See also:  batmask

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

s=load('-ascii',[f,'.asc']);
