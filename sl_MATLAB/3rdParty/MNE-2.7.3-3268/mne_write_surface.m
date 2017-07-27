function mne_write_surface(fname,verts,faces,comment)
%
% mne_write_surface(fname,verts,faces)
%
% Writes a FreeSurfer surface file
%
% fname       - The file to write
% verts       - Vertex coordinates in meters
% faces       - The triangle descriptions
% comment     - Optional comment to include
%

%
%
%   Copyright 2009
%
%   Matti Hamalainen
%   Athinoula A. Martinos Center for Biomedical Imaging
%   Massachusetts General Hospital
%   Charlestown, MA, USA
%
%
%   No part of this program may be photocopied, reproduced,
%   or translated to another program language without the
%   prior written consent of the author.
%
%   $Id: mne_write_surface.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.1  2009/01/28 19:27:59  msh
%   Added mne_write_surface
%
%
me='MNE:mne_write_surface';

if nargin < 4
   comment = 'Triangle file written with MNE Matlab tools';
end
%
%   The input file will be big endian
%
fid = fopen(fname,'wb','ieee-be');

if (fid < 0)
   error(me,'Cannot open file %s', fname);
end
%
%   Magic number to identify a TRIANGLE file
%
%
TRIANGLE_FILE_MAGIC_NUMBER =  16777214 ;

mne_fwrite3(fid,TRIANGLE_FILE_MAGIC_NUMBER) ;
fprintf(fid,'%s\n\n',comment);
fwrite(fid, size(verts,1), 'int32') ;
fwrite(fid, size(faces,1), 'int32') ;
fwrite(fid, 1000.0*reshape(verts',1,prod(size(verts))), 'float32') ;
fwrite(fid, reshape(faces',1,prod(size(faces))) - 1, 'int32') ;
fclose(fid) ;
fprintf(1,'\tWrote the surface file %s with %d vertices and %d triangles\n',fname,size(verts,1),size(faces,1));

return;
