%TEST_TIMING_DGT_FB  Test timing filter bank DGTs
%
%   This script test the timing DGTs by comparing the results to the full
%   DGT implementation in main toolbox. Therefore, the correctness of DGT
%   must be verified first.

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
 
routinemax=2;

Lr  = [24, 24,35, 35, 24,144,108,144,135,77];
ar  = [ 6,  6, 5,  5,  4,  9,  9, 12,  9, 7];
Mr  = [ 8,  8, 7,  7,  6, 16, 12, 24,  9,11];
glr = [16, 24,14, 21, 12, 48, 12, 24, 18,22];

test_failed=0;

disp('--- Used subroutines ---');

for ii=1:routinemax
  which(['mex_dgt_fb_',num2str(ii)])
end;

for ii=1:length(Lr);

  L=Lr(ii);
  
  M=Mr(ii);
  a=ar(ii);
  gl=glr(ii);

  b=L/M;
  N=L/a;
  
  for W=1:3
    
    for R=1:3

      for rtype=1:2
      
        if rtype==1
          rname='REAL ';	
          f=rand(L,W);
          g=rand(gl,R);
        else
          rname='CMPLX';	
          f=crand(L,W);
          g=crand(gl,R);
        end;
        
        gfac=comp_wfac(fir2iir(g,L),a,M);
        cc  = comp_dgt_fac(f,gfac,a,M);
        
        for rout=2:routinemax
          
          cc2=feval(['mex_dgt_fb_',num2str(rout)],f,g,a,M,0);
          
          cdiff=cc-cc2;
          res=norm(cdiff(:));      
          
          fail='';
          if res>10e-10
            fail='FAILED';
            test_failed=test_failed+1;
          end;
          
          s=sprintf('DGT  %s %i L:%3i W:%2i R:%2i a:%3i M:%3i gl:%3i %0.5g %s',rname,rout,L,W,R,a,M,gl,res,fail);
          disp(s)        
          
        end;
        
      end;  
      
    end;
    
  end;
  
end;

test_failed