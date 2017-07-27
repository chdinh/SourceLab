function gd=gabdual(g,a,M,L)
%GABDUAL  Canonical dual window.
%   Usage:  gd=gabdual(g,a,M);
%           gd=gabdual(g,a,M,L);
%
%   Input parameters:
%         g     : Gabor window.
%         a     : Length of time shift.
%         M     : Number of channels.
%         L     : Length of window. (optional)
%   Output parameters:
%         gd : Canonical dual window.
%
%   GABDUAL(g,a,M) computes the canonical dual window of the discrete Gabor
%   frame with window g and parameters a, M.
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of GABWIN for more details.
%
%   If the length of g is equal to M, then the input window is assumed to
%   be a FIR window. In this case, the canonical dual window also has
%   length of M. Otherwise the smallest possible transform length is
%   chosen as the window length.
%
%   GABDUAL(g,a,M,L) returns a window that is the dual window for a system
%   of length L. Unless the dual window is a FIR window, the dual window
%   will have length L.
%
%   If a>M then the dual window of the Gabor Riesz sequence with window g
%   and parameters a and M will be calculated.
%
%   See also:  gabtight, gabwin, fir2long, dgt

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
%   TESTING: TEST_DGT
%   REFERENCE: REF_GABDUAL.
  
% ------ Direct checks on input parameters ----

error(nargchk(3,4,nargin));  

if nargin==3
  L=[];
end;

[g,L,info] = gabpars_from_window(g,a,M,L);
  
% -------- Are we in the Riesz sequence of in the frame case

scale=1;
if a>M
  % Handle the Riesz basis (dual lattice) case.
  % Swap a and M, and scale differently.
  scale=a/M;
  tmp=a;
  a=M;
  M=tmp;
end;

% -------- Compute ------------- 

if (info.gl<=M)
     
  % FIR case
  N_win = ceil(info.gl/a);
  Lwin_new = N_win*a;
  if Lwin_new ~= info.gl
    g_new = fir2long(g,Lwin_new);
  else
    g_new = g;
  end
  weight = sum(reshape(abs(g_new).^2,a,N_win),2);
  
  gd = g_new./repmat(weight,N_win,1);
  gd = gd/M;
  if Lwin_new ~= info.gl
    gd = long2fir(gd,info.gl);
  end
  
else
  
  % Long window case

  % Just in case, otherwise the call is harmless. 
  g=fir2long(g,L);
  
  gd=comp_gabdual_long(g,a,M)*scale;
  
end;

% --------- post process result -------
      
if info.wasrow
  gd=gd.';
end;
