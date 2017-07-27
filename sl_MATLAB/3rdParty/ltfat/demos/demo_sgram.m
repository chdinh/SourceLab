%DEMO_sgram  Give a simple spectrogram demo
%
%   This script displays two spectrogram of the "greasy" test signal,
%   demonstrating some common switches.
%
%   FIGURE 1 Spectrogram using default window
%
%     The figure shows a spectrogram of the 'greasy' test signal. The
%     magnitude of the Gagor coefficients is shown on a logarithmic
%     scale, and only the largest coefficients are shown, corresponding
%     to a dynamic range of 50 dB.
%
%   FIGURE 2 Spectrogram using longer window
%
%     Same spectrogram as Figure 1, but now using a longer window, with a
%     window length of 20 ms. This gives a sharper view of the partials,
%     at the expense of a more blurred view along the time dimension.
%
%   See also: sgram, greasy

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

% Test signal
f=greasy;

% Sampling frequency of the signal
fs=16000;

% Default window
figure(1)
sgram(f,fs,'dynrange',50);

% Longer window, 20 ms.
figure(2)
sgram(f,fs,'wlen',round(20/1000*fs),'dynrange',50);
