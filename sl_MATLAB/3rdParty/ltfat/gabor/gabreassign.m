function sr=gabreassign(s,tgrad,fgrad,a,p5);
%GABREASSIGN  Reassign time-frequency distribution.
%   Usage:  sr = gabreassign(s,tgrad,fgrad,a);
%           sr = gabreassign(s,tgrad,fgrad,a,'aa');
%
%   GABREASSIGN(s,tgrad,fgrad,a) will reassign the values of the positive
%   time-frequency distribution s using the phase gradient given by fgrad
%   and tgrad. The lattice is determined by the time shift a and the number
%   of channels deduced from the size of s.
%
%   fgrad and tgrad can be obtained by the routine GABPHASEGRAD
%
%   The standard way of calling this routine to generate a reassigned
%   spectrogram from a signal f is:
%
%      [fgrad, tgrad, c] = gabphasegrad('dgt',f,'gauss',a,M);
%      sr = gabreassign(abs(c).^2,tgrad,fgrad,a);
%  
%   See also: resgram, gabphasegrad
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

% AUTHOR: Peter L. Soendergaard, 2008.
  
error(nargchk(4,5,nargin));

if nargin==5
  switch(lower(p5))
   case {'aa'}
    
    % --- use antialiasing ----

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
    
    fk=mod(floor(tgrad),M)+1;
    ck=mod(ceil(tgrad),M)+1;
    fn=mod(floor(fgrad),N)+1;
    cn=mod(ceil(fgrad),N)+1;
    
    alpha = fgrad-floor(fgrad);
    beta  = tgrad-floor(tgrad);
    m1 =(1-alpha).*(1-beta).*s;
    m2 =(1-alpha).*beta.*s;
    m3 =alpha.*(1-beta).*s;
    m4 =alpha.*beta.*s;
    for ii=1:M
      for jj=1:N
        sr(fk(ii,jj),fn(ii,jj))=sr(fk(ii,jj),fn(ii,jj))+m1(ii,jj);
        sr(ck(ii,jj),fn(ii,jj))=sr(ck(ii,jj),fn(ii,jj))+m2(ii,jj);
        sr(fk(ii,jj),cn(ii,jj))=sr(fk(ii,jj),cn(ii,jj))+m3(ii,jj);
        sr(ck(ii,jj),cn(ii,jj))=sr(ck(ii,jj),cn(ii,jj))+m4(ii,jj);
        
      end;
    end;
  end;
else

  sr=comp_gabreassign(s,tgrad,fgrad,a);
  
end;
