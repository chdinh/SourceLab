%DEMO_ZAK  Some Zak-transforms
%
%   This scripts creates plots of three different Zak-transforms of a
%   Gaussian, a spline and a Hermite function
%
%   FIGURE 1 Gaussian and spline
%
%     This figure shows the absolute value of the Zak-transform of
%     a Gaussian to the left, and a second order spline to the right.
%     Notice that both Zak-transforms are 0 in only a single
%     point right in the middle of the plot. The spline is constructed
%     by sampling and periodization of the continuous second order spline.
%
%   FIGURE 2 Funny Zaks
%
%     The left figure shows the absolute value of the Zak-transform of
%     a 4th order Hermite function and the left shows a chirp.
%     Notice how the Zak transform of the Hermite functions is zero on a
%     circle centered on the corner.
%
%   See also:   zak, izak

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

disp('Type "help demo_zak" to see a description of how this demo works.');

% Setup parameters and length of signal

% We want critical sampling
a=64;
L=a^2; 

% Make a Gaussian function
g=pgauss(L);

% Compute the Zak-transform in square layout.
zg=zak(g,a);

% Visualize it
figure(1);

subplot(1,2,1);
mesh(abs(zg));
legend('off');
%axis('vis3d');

subplot(1,2,2);
%mesh(abs(zak(pbspline('ec',L,2,a),a)));
legend('off');
%axis('vis3d');

% Do the same for the Hermite function.
figure(2);

subplot(1,2,1);
mesh(abs(zak(pherm(L,4),a)));
legend('off');
%axis('vis3d');

subplot(1,2,2);
mesh(abs(zak(pchirp(L,1),a)));
legend('off');
%axis('vis3d');
