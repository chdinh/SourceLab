function s=linus()
%LINUS  Load the 'linus' test signal.
%   Usage:  s=linus;
%
%   LINUS loads the 'linus' signal. It is a recording
%   of Linus Thorvalds pronouncing the words "Hello. My name is Linus
%   Thorvalds, and I pronounce Linux as Linux".
%
%   The signal is 41461 samples long and is sampled at 8kHz.
%
%   See http://www.paul.sladen.org/pronunciation/

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

