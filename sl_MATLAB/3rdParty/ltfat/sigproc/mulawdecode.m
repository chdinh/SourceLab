function sig = mulawdecode(codedsig,mu,sigweight);
%MULAWDECODE  Inverse of Mu-Law companding
%   Usage:  sig = mulawdecode(codedsig,mu,sigweight);
%
%   MULAWDECODE(codedsig,mu,sigweight) inverts a previously
%   applied mu-law companding to the signal codedsig. The parameters
%   mu and sigweight must match those from the call to MULAWENCODE
%  
%   References:
%     S. Jayant and P. Noll. Digital Coding of Waveforms: Principles and
%     Applications to Speech and Video. Prentice Hall, 1990.
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

% AUTHOR: Bruno Torresani and Peter Soendergaard

error(nargchk(3,3,nargin));

cst = (1+mu);
sig = cst.^(abs(codedsig));
sig = sign(codedsig) .* (sig-1);
sig = sig * sigweight/mu;
