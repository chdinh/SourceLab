function fiff_end_block(fid,kind)
%
% fiff_end_block(fid,kind)
% 
% Writes a FIFF_BLOCK_END tag
%
%     fid           An open fif file descriptor
%     kind          The block kind to end
%

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
%   $Id: fiff_end_block.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.3  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.2  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%   Revision 1.1  2005/12/05 16:01:04  msh
%   Added an initial set of fiff writing routines.
%
%
%

me='MNE:fiff_end_block';

if nargin ~= 2
        error(me,'Incorrect number of arguments');
end

FIFF_BLOCK_END=105;
fiff_write_int(fid,FIFF_BLOCK_END,kind);

return;
