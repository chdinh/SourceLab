function f=comp_idgt(coef,g,a,M,L,phasetype)
%COMP_IDGT  Compute IDGT
%   Usage:  f=comp_idgt(c,g,a,M,L,phasetype);
%
%   Input parameters:
%         c     : Array of coefficients.
%         g     : Window function.
%         a     : Length of time shift.
%         M     : Number of modulations.
%         L     : length of transform.
%   Output parameters:
%         f     : Signal.
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

% AUTHOR : Peter Soendergaard.

b=L/M;
N=L/a;

Lwindow=size(g,1);
W=size(coef,3);

if phasetype==1
    coef=phaseunlock(coef,a);
end;

% FIXME: This line is necessary because the mex and oct interfaces expect
% a matrix as input.
coef=reshape(coef,M,prod(size(coef))/M);

if L==Lwindow
  % Do full-window algorithm.

  % Get the factorization of the window.
  gf = comp_wfac(g,a,M);      

  % Call the computational subroutine.
  f  = comp_idgt_fac(coef,gf,L,a,M);
  
 else
   
  % Do filter bank algorithm.
  % Call the computational subroutine.
  f=comp_idgt_fb(coef,g,L,a,M);

end;