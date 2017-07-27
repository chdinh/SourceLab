function [stc] = mne_read_stc_file1(filename)
%
% [stc] = mne_read_stc_file1(filename)
% 
% Reads an stc file. The returned structure has the following fields
%
%     tmin           The first time point of the data in seconds
%     tstep          Time between frames in seconds
%     vertices       vertex indices (1 based)
%     data           The data matrix (nvert * ntime)
%
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
%   $Id: mne_read_stc_file1.m 3211 2010-09-22 14:39:30Z msh $
%   
me='MNE:mne_read_stc_file1';
if(nargin ~= 1)
   error(me,'usage: [stc] = mne_read_stc_file1(filename)');
end

try
   stc = mne_read_stc_file(filename);
   stc.vertices = stc.vertices + 1;
catch
   error(me,'%s',mne_omit_first_line(lasterr));
end

return;


