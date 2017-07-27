function fiff_write_string(fid,kind,data)
%
% fiff_write_string(fid,kind,data)
% 
% Writes a string tag
%
%     fid           An open fif file descriptor
%     kind          The tag kind
%     data          The string data to write
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
%   $Id: fiff_write_string.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%

me='MNE:fiff_write_string';

if nargin ~= 3
        error(me,'Incorrect number of arguments');
end

FIFFT_STRING=10;
FIFFV_NEXT_SEQ=0;
datasize=size(data,2);
count = fwrite(fid,int32(kind),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_STRING),'int32');
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
count = fwrite(fid,data,'uchar');
if count ~= datasize
    error(me,'write failed');
end
