function err = mne_write_w_file1(filename, w)
% mne_write_w_file1(filename, w)
% 
%  writes a binary 'w' file
%
%  filename - name of file to write to
%  w        - a structure with the following fields:
%
% vertices - vector of vertex indices (1-based)
% data     - vector of data values
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
% $Id: mne_write_w_file1.m 3211 2010-09-22 14:39:30Z msh $
% 
% Revision 1.5  2006/04/23 15:29:41  msh
% Added MGH to the copyright
%
% Revision 1.4  2006/04/10 23:26:54  msh
% Added fiff reading routines
%
% Revision 1.3  2005/12/05 20:23:21  msh
% Added fiff_save_evoked. Improved error handling.
%
% Revision 1.2  2005/11/21 03:19:12  msh
% Improved error handling
%
% Revision 1.1  2005/11/21 02:15:51  msh
% Added more routines
%
%
me='MNE:mne_write_w_file1';
if(nargin ~= 2)
  error(me,'usage: mne_write_w_file1(filename, w)');
  return;
end

try
   w.vertices = w.vertices - 1;
   mne_write_w_file(filename,w);
catch
   w.vertices = w.vertices - 1; 
   error(me,'%s',mne_omit_first_line(lasterr));
end

return;
