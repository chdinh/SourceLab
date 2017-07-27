function gt=gabtight(p1,p2,p3,p4)
%GABTIGHT  Canonical tight window.
%   Usage:  gt=gabtight(a,M,L);
%           gt=gabtight(g,a,M);
%           gt=gabtight(g,a,M,L);
%
%   Input parameters:
%         g     : Gabor window.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : Length of window. (optional)
%   Output parameters:
%         gt    : Canonical tight window, column vector.
%
%   GABTIGHT(a,M,L) computes a nice tight LONG window of length L for a
%   lattice with parameters a, M.
%
%   GABTIGHT(g,a,M) computes the canonical tight window of the Gabor frame
%   with window g and parameters a, M.
%
%   The window g may be a vector of numerical values, a text string or a
%   cell array. See the help of GABWIN for more details.
%  
%   If the length of g is equal to M, then the input window is assumed to
%   be a FIR window. In this case, the canonical dual window also has
%   length of M. Otherwise the smallest possible transform length is
%   chosen as the window length.
%
%   GABTIGHT(g,a,M,L) returns a window that is tight for a system of
%   length L. Unless the tight window is a FIR window, the tight window
%   will have length L.
%
%   If a>M then an orthonormal window of the Gabor Riesz sequence with
%   window g and parameters a and M will be calculated.
%
%   See also:  gabdual, gabwin, fir2long, dgt

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
%   REFERENCE: OK

%% ------------ decode input parameters ------------
  
if numel(p1)==1
  % First argument is a scalar.

  error(nargchk(3,3,nargin));

  a=p1;
  M=p2;
  L=p3;

  g='gauss';
  
else    
  % First argument assumed to be a vector.
    
  error(nargchk(3,4,nargin));
  
  g=p1;
  a=p2;
  M=p3;
    
  if nargin==3
    L=[];
  else
    L=p4;
  end;

end;

[g,L,info] = gabpars_from_window(g,a,M,L);
  
% -------- Are we in the Riesz sequence of in the frame case

scale=1;
if a>M
  % Handle the Riesz basis (dual lattice) case.
  % Swap a and M, and scale differently.
  scale=sqrt(a/M);
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
  weight = sqrt(sum(reshape(abs(g_new).^2,a,N_win),2));
  
  gt = g_new./repmat(weight,N_win,1);
  gt = gt/sqrt(M);
  if Lwin_new ~= info.gl
    gt = long2fir(gt,info.gl);
  end
  
else
  
  % Long window case

  % Just in case, otherwise the call is harmless. 
  g=fir2long(g,L);
  
  gt=comp_gabtight_long(g,a,M)*scale;
  
end;

% --------- post process result -------

%if info.wasreal
%  gt=real(gt);
%end;
      
if info.wasrow
  gt=gt.';
end;







