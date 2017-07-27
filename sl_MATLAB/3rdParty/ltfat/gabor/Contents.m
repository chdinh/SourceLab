% LTFAT - Gabor analysis
%
%  Peter L. Soendergaard, 2007 - 2011.
%
%  Basic Time/Frequency analysis
%    TCONV          -  Twisted convolution.
%    DSFT           -  Discrete Symplectic Fourier Transform
%    ZAK            -  Zak transform.
%    IZAK           -  Inverse Zak transform.
%    COL2DIAG       -  Move columns of a matrix to diagonals.
%    S0NORM         -  Compute the S0-norm.
%    TFMAT          -  Matrix of transform or operator in LTFAT.
%
%  Gabor systems
%    DGT            -  Discrete Gabor transform.
%    IDGT           -  Inverse discrete Gabor transform.
%    ISGRAM         -  Iterative reconstruction from spectrogram.
%    DGT2           -  2D Discrete Gabor transform.
%    IDGT2          -  2D Inverse discrete Gabor transform.
%    DGTREAL        -  DGT for real-valued signals.
%    IDGTREAL       -  IDGT for real-valued signals.
%    GABWIN         -  Evaluate Gabor window.
%    LONGPAR        -  Easy calculation of LONG parameters.
%
%  Wilson bases and WMDCT
%    DWILT          -  Discrete Wilson transform.
%    IDWILT         -  Inverse discrete Wilson transform.
%    DWILT2         -  2-D Discrete Wilson transform.
%    IDWILT2        -  2-D inverse discrete Wilson transform.
%    WMDCT          -  Modified Discrete Cosine transform.
%    IWMDCT         -  Inverse MDCT.
%    WMDCT2         -  2-D MDCT.
%    IWMDCT2        -  2-D inverse MDCT.
%    WIL2RECT       -  Rectangular layout of Wilson coefficients.
%    RECT2WIL       -  Inverse of WIL2RECT.
%    WILWIN         -  Evaluate Wilson window.
%
%  Reconstructing windows
%    GABDUAL        -  Canonical dual window.
%    GABTIGHT       -  Canonical tight window.
%    GABPROJDUAL    -  Dual window by projection.
%    GABMIXDUAL     -  Dual window by mixing windows.
%    WILORTH        -  Window of Wilson/WMDCT orthonormal basis.
%    WILDUAL        -  Riesz dual window of Wilson/WMDCT basis. 
%
%  Time/Frequency operators
%    GABMUL         -  Gabor multiplier.
%    GABMULEIGS     -  Eigenpairs of Gabor multiplier.
%    GABMULAPPR     -  Best approximation by a Gab. mult.
%    SPREADOP       -  Spreading operator.
%    SPREADINV      -  Apply inverse spreading operator.
%    SPREADADJ      -  Symbol of adjoint spreading operator.
%    SPREADFUN      -  Symbol of operator expressed as a matrix.
%    SPREADEIGS     -  Eigenpairs of spreading operator.
%
%  Conditions numbers
%    GABFRAMEBOUNDS -  Frame bounds of Gabor system.
%    GABRIESZBOUNDS -  Riesz sequence/basis bounds of Gabor system.
%    WILBOUNDS      -  Frame bounds of Wilson basis.
%    GABDUALNORM    -  Test if two windows are dual.
%
%  Phase gradient methods and reassignment
%    GABPHASEGRAD   -  Instantaneous time/frequency from signal.
%    GABREASSIGN    -  Reassign positive distribution.
%
%  Phase conversions
%    PHASELOCK      -  Phase Lock Gabor coefficients to time.
%    PHASEUNLOCK    -  Undo phase locking.
%    SYMPHASE       -  Convert to symmetric phase.
%
%  Plots
%    SGRAM          -  Spectrogram based on DGT.
%    GABIMAGEPARS   -  Choose paramets for nice Gabor image.
%    RESGRAM        -  Reassigned spectrogram.
%    INSTFREQPLOT   -  Plot of the instantaneous frequency.
%    PHASEPLOT      -  Plot of STFT phase.
%
%  For help, bug reports, suggestions etc. please send email to
%  ltfat-help@lists.sourceforge.net

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

