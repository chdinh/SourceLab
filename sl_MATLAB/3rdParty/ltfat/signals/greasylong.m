function s=greasylong()
%GREASYLONG  Load the 'greasylong' test signal.
%   Usage:  s=greasylong;
%
%   GREASYLONG loads the 'greasylong' signal. It is a recording of a woman
%   pronouncing the sentence 'She had your dark suit in greasy wash-water
%   all year'. The sentence is the very first one in the TIMIT database.
%
%   The signal is 20768 samples long and recorded at 8 khz.
%
%   The signal was obtained from the CAAR publications page:
%     http://www.isr.umd.edu/CAAR/pubs.html

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


