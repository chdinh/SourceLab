function outsig=rampsignal(insig,L,varargin)
%RAMPUP  Rising ramp function
%   Usage: outsig=rampup(insig,L);
%
%   RAMPSIGNAL(insig,L) will apply a ramp function of length L to the
%   beginning and the end of the input signal. The ramp is a sinusoide
%   starting from zero and ending at one.
%
%   If L is scalar, the starting and ending ramps will be of the same
%   length. If L is a vector of length 2, the first entry will be used
%   for the rising ramp, and the second for the falling.
%
%   If the input is a matrix or and 
%
%   RAMPUP(insig,L,wintype) will use another window for ramping. This may be
%   any of the window types from FIRWIN. Please see the help on FIRWIN
%   for more information. The default is to use a piece of the Hann
%   window.
%
%   For very long signals, it may be more efficient to manually do the
%   ramping by using RAMPUP and RAMPDOWN, because Matlab/Octave does not
%   need to copy the entire input signal.
%
%   See also: rampdown, rampsignal, firwin

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

definput.import={'firwin'};
definput.keyvals.dim=[];
[flags,kv]=ltfatarghelper({},definput,varargin);
  
switch numel(L)
 case 1
  L1=L;
  L2=L;
 case 2
  L1=L(1);
  L2=L(2);
 otherwise
  error('%s: The length must a scalar or vector.',upper(mfilename));
end;

r1=rampup(L1,flags.wintype);
r2=rampdown(L2,flags.wintype);

L=[];
[insig,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(insig,L,kv.dim,'RAMPSIGNAL');
% Note: Meaning of L has changed, it is now the length of the signal.

if L<L1+L2
  error(['%s: The length of the input signal must be greater than the length of the ramps ' ...
         'combined.'],upper(mfilename));
end;

ramp=[r1;ones(L-L1-L2,1);r2];

% Apply the ramp
for ii=1:W
  insig(:,ii)=insig(:,ii).*ramp;
end;

outsig=assert_sigreshape_post(insig,dim,permutedsize,order);

  