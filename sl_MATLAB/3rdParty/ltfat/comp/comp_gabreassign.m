function sr=comp_gabreassign(s,tgrad,fgrad,a);
%COMP_GABREASSIGN  Reassign time-frequency distribution.
%   Usage:  sr = comp_gabreassign(s,tgrad,fgrad,a);
%
%   COMP_GABREASSIGN(s,tgrad,fgrad,a) will reassign the values of the positive
%   time-frequency distribution s using the instantaneous time and frequency
%   fgrad and ifdummy. The lattice is determined by the time shift a and
%   the number of channels deduced from the size of s.
%
%   See also: gabreassign
%
%   References:
%     F. Auger and P. Flandrin. Improving the readability of time-frequency
%     and time-scale representations by the reassignment method. IEEE Trans.
%     Signal Process., 43(5):1068-1089, 1995.

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
%   TESTING: OK
%   REFERENCE: OK
  
[M,N,W]=size(s);
L=N*a;
b=L/M;

freqpos=fftindex(M);  
for w=1:W
  tgrad(:,:,w)=tgrad(:,:,w)/b+repmat(freqpos,1,N);
end;

timepos=fftindex(N);
for w=1:W
  fgrad(:,:,w)=fgrad(:,:,w)/a+repmat(timepos.',M,1);
end;

tgrad=round(tgrad);
fgrad=round(fgrad);

tgrad=mod(tgrad,M);
fgrad=mod(fgrad,N);  
  
sr=zeros(M,N,W);

fgrad=fgrad+1;
tgrad=tgrad+1;

for ii=1:M
  for jj=1:N      
    sr(tgrad(ii,jj),fgrad(ii,jj)) = sr(tgrad(ii,jj),fgrad(ii,jj))+s(ii,jj);
  end;
end;  

