function qgc = gc_mu_uquant(gc,Nbits,mu)
%
% Uniform quantization of Gabor coefficients after mu-law companding
%   qgc = gc_mu_uquant(gc,Nbits,mu)
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

gc_r = real(gc);
gc_i = imag(gc);

[mu_gc_r,weight_r] = mulawencode(gc_r,mu);
[mu_gc_i,weight_i] = mulawencode(gc_i,mu);
qgc_r = uquant(mu_gc_r,Nbits);
qgc_i = uquant(mu_gc_i,Nbits);
qgc_r = mulawdecode(qgc_r,mu,weight_r);
qgc_i = mulawdecode(qgc_i,mu,weight_i);
qgc = qgc_r + i* qgc_i;


