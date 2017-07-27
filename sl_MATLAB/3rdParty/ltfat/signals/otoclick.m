function s=otoclick()
%OTOCLICK  Load the 'otoclick' test signal.
%   Usage:  s=otoclick;
%
%   OTOCLICK loads the 'otoclick' signal. The signal is a click-evoked
%   otoacoustic emission. It consists of two clear clicks followed by a
%   ringing.
%
%   It was measured by Sarah Verhulst at CAHR (Centre of Applied Hearing
%   Research) at Department of Eletrical Engineering, Technical University
%   of Denmark
%
%   The signal is 2210 samples long and sampled at 44.1 kHz.

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
