
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
data_fb =load("longer_fb.log");
data_fac=load("longer_fac.log");

% Columns in data, fb : a M L W gl time
% Columns in data, fac: a M L W time
Ls=data_fb(:,3);
t_fb =data_fb(:,6);
t_fac=data_fac(:,5);
figure(1);

plot(Ls,t_fb,Ls,t_fac);
legend('FB','FAC');
xlabel('Signal length / samples');
ylabel('Running time / seconds');
