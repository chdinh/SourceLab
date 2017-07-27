function fiff_write_complex(fid,kind,data)
%
% fiff_write_complex(fid,kind,data)
% 
% Writes a single-precision complex tag to a fif file
%
%     fid           An open fif file descriptor
%     kind          Tag kind
%     data          The data
%

%
%   Copyright 2006
%
%   Matti Hamalainen
%   Athinoula A. Martinos Center for Biomedical Imaging
%   Massachusetts General Hospital
%   Charlestown, MA, USA
%
%   No part of this program may be photocopied, reproduced,
%   or translated to another program language without the
%   prior written consent of the author.
%
%   $Id: fiff_write_complex.m 2670 2009-05-11 17:10:51Z msh $
%   
%   Revision 1.1  2006/09/23 14:43:56  msh
%   Added routines for writing complex and double complex matrices.
%   Added routine for writing double-precision real matrix.
%
%
%

me='MNE:fiff_write_complex';

if nargin ~= 3
        error(me,'Incorrect number of arguments');
end

FIFFT_COMPLEX_FLOAT=20;
FIFFV_NEXT_SEQ=0;
nel=prod(size(data));
datasize=2*nel*4;
count = fwrite(fid,int32(kind),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_COMPLEX_FLOAT),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(datasize),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFV_NEXT_SEQ),'int32');
if count ~= 1
   error(me,'write failed');
end
for k = 1:nel
   count = fwrite(fid,real(data(k)),'single');
   if count ~= 1
      error(me,'write failed');
   end
   count = fwrite(fid,imag(data(k)),'single');
   if count ~= 1
      error(me,'write failed');
   end
end
return;

