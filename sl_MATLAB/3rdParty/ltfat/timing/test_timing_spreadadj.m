%TEST_TIMING_DGT_FAC  Test timing factorization DGTs
%
%   This script test the timing SPREADADJs by comparing the results to
%   spreadadj in the main toolbox. Therefore, the correctness of
%   spreadadj must be verified first.

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


routinemax=6;

spfraction=.1;

test_failed=0;

disp('--- Used subroutines ---');


for rtype=1:2
  
  if rtype==1
    rname='REAL ';	
  else
    rname='CMPLX';	
  end;
  
  for sptype=1:2
    
    if sptype==1
      spname='FULL  ';	
    else
      spname='SPARSE';	
    end;
    
    for L=12:13

      if rtype==1
        if sptype==1
          coef=rand(L,L);
        else
          coef=sprand(L,L,spfraction);
        end;
      else
        if sptype==1
          coef=crand(L,L);
        else
          coef=spcrand(L,L,spfraction);
        end;
      end;      
      
      cadj=spreadadj(coef);
      
      for rout=1:routinemax
        cadj2=feval(['ref_spreadadj_',num2str(rout)],coef);
                  
        rdiff=cadj-cadj2;
        
        res=norm(rdiff(:));      
        
        fail='';
        if res>10e-10
          fail='FAILED';
          test_failed=test_failed+1;
        end;
        
        s=sprintf('ADJ %s %s %i L:%3i %0.5g %s',rname,spname,rout,L,res,fail);
        disp(s)
      end;

      
    end;

  end;  
  
end;


test_failed
