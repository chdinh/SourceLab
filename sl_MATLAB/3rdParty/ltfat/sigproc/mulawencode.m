function [outsig, sigweight] = mulawencode(insig,mu)
%MULAWENCODE   Mu-Law compand signal 
%   Usage: [outsig, sigweight] = mulawencode(insig,mu);
%   
%   [outsig, sigweight]=MULAWENCODE(insig,mu) mu-law compands the input
%   signal insig using mu-law companding with parameters mu.
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

% AUTHOR: Bruno Torresani

error(nargchk(2,2,nargin));

tmp = log(1+mu);

sigweight = max(abs(insig(:)));
insig = insig/sigweight;

outsig = sign(insig) .* log(1+mu*abs(insig))/tmp;

