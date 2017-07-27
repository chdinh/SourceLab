function gamma=gabmixdual(g1,g2,a,M,L)
%GABMIXDUAL  Computes the mixdual of g1
%   Usage: gamma=mixdual(g1,g2,a,M)
%
%   Input parameters:
%        g1     : Window 1
%        g2     : Window 2
%        a      : Length of time shift.
%        M      : Number of modulations.
%
%   Output parameters:
%        gammaf : Mixdual of window 1.
%
%   MIXDUAL(g1,g2,a,M) computes a dual window of g1 from a mix of the
%   canonical dual windows of g1 and g2.
%
%   See also:  gabdual, gabprojdual
%
%   Demos: demo_mixdual   
%
%   References:
%     T. Werther, Y. Eldar, and N. Subbana. Dual Gabor Frames: Theory and
%     Computational Aspects. IEEE Trans. Signal Processing, 53(11), 2005.
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

%   AUTHOR : Peter Soendergaard.

% Assert correct input.

if nargin<4
  error('Too few input parameters.');
end;

if nargin>4
  error('Too many input parameters.');
end;

assert_squarelat(a,M,1,'MIXDUAL',1);

if size(g1,2)>1
  if size(g1,1)>1
    error('g1 must be a vector');
  else
    % g1 was a row vector.
    g1=g1(:);
  end;
end;

if size(g2,2)>1
  if size(g2,1)>1
    error('g2 must be a vector');
  else
    % g2 was a row vector.
    g2=g2(:);
  end;
end;

Ls=size(g1,1);
Lwindow=size(g2,1);

if nargin<5
  [b,N,L]=assert_L(Ls,Lwindow,[],a,M,'MIXDUAL');
else
  [b,N,L]=assert_L(Ls,Lwindow,L,a,M,'MIXDUAL');
  g1=fir2long(g1,L);
  g2=fir2long(g2,L);
end;

gf1=comp_wfac(g1,a,M);
gf2=comp_wfac(g2,a,M);

gammaf=comp_gabmixdual_fac(gf1,gf2,L,a,M);

gamma=comp_iwfac(gammaf,L,a,M);

