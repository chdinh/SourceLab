function mne_write_stc_file1(filename,stc)
%
% mne_write_stc_file1(filename,stc)
% 
% writes an stc file
%
%     filename      output file
%     stc           a stucture containing the stc data with fields:
%
%     tmin          The time of the first frame in seconds
%     tstep         Time between frames in seconds
%     vertices      Vertex indices (1 based)
%     data          The data matrix nvert * ntime
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
%     $Id: mne_write_stc_file1.m 3211 2010-09-22 14:39:30Z msh $
%     
me='MNE:mne_write_stc_file1';
if(nargin ~= 2)
   error(me,'usage: mne_write_stc_file1(filename, stc)');
end

stc.vertices = stc.vertices - 1;
try
   mne_write_stc_file(filename,stc);
   stc.vertices = stc.vertices + 1;
catch 
   stc.vertices = stc.vertices - 1; 
   error(me,'%s',mne_omit_first_line(lasterr));
end

return;


