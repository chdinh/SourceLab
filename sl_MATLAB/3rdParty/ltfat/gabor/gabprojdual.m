function gd=projdual(gm,g,a,M,L);
%PROJDUAL   Dual window by projection.
%   Usage:  gd=projdual(gm,g,a,M)
%           gd=projdual(gm,g,a,M,L)
%
%   Input parameters:
%         gm    : Window to project.
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : Total length of vectors (optional).
%   Output parameters:
%         gd    : Dual window.
%
%   PROJDUAL(gm,g,a,M) calculates the dual window of the Gabor frame given
%   by g, a and M closest to gm measured in the l^2 norm.
%
%   PROJDUAL(gm,g,a,M,L) first extends the windows g and gm to length L.
%
%   See also:  gabdual, gabtight, gabdualnorm, fir2long

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

if nargin<3
  error('To few input parameters.');
end;

if nargin>5
  error('To many input parameters.');
end;

assert_squarelat(a,M,1,'PROJDUAL',1);

if size(g,2)>1
  if size(g,1)>1
    error('g must be a vector');
  else
    % g was a row vector.
    g=g(:);
  end;
end;

wasrow=0;
if size(gm,2)>1
  if size(gm,1)>1
    error('gm must be a vector');
  else
    % gm was a row vector.
    wasrow=1;
    gm=gm(:);
  end;
end;

if nargin<5
  [b,N,L]=assert_L(Ls,Lwindow,[],a,M,'PROJDUAL');
else
  [b,N,L]=assert_L(Ls,Lwindow,L,a,M,'PROJDUAL');
  g1=fir2long(g1,L);
  g2=fir2long(g2,L);
end;

% Calculate the canonical dual.
gamma0=gabdual(g,a,M);
  
% Get the residual
gres=gm-gamma0;

% Calculate parts that lives in span of adjoint lattice.
gk=idgt(dgt(gres,gamma0,M,a),g,M)*M/a;

% Construct dual window
gd=gamma0+(gres-gk);

if wasrow
  gd=gd.';
end;


