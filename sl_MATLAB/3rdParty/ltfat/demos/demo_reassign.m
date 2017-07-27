%DEMO_REASSIGN  Give demos of Gabor reassignment
%
%   This script loads a sample signal and computes.

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


% Load bat sonar signal
batsignal = bat;
siglength = length(batsignal);
fs = 143;

% Compute Gabor transform and phase gradients, and reassigned Gabor
% transform
a = 1;
M = 200;
Mover2 = M/2;
[tgrad, fgrad, batgt] = gabphasegrad('dgt',batsignal,'gauss',a,M);
batreass = gabreassign(abs(batgt).^2,tgrad,fgrad,1);

% Displays
ttt = (1:siglength)*1000/fs;
fff = (0:(Mover2-1))*fs/M;

figure('name','Gabor transform modulus');
imagesc(ttt,fff,abs(batgt(1:100,:))); axis xy;
xlabel('Time (msec.)');
ylabel('Frequency (Hz)');
title('Gabor transform modulus');

figure('name','Reassigned Gabor transform modulus');
imagesc(ttt,fff,abs(batreass(1:100,:))); axis xy;
xlabel('Time (msec.)');
ylabel('Frequency (Hz)');
title('Reassigned Gabor transform modulus');

