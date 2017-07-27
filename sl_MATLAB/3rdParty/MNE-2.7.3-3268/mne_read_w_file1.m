function [w] = mne_read_w_file(filename)
%
% [w] = mne_read_w_file(filename)
%
% Reads a binary w file into the structure w with the following fields
%
% vertices - vector of vertex indices (1-based)
% data     - vector of data values
%

%
%   Copyright 2006 - 2010
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
%
%     $Id: mne_read_w_file1.m 3211 2010-09-22 14:39:30Z msh $
%
me='MNE:mne_read_w_file1';
if(nargin ~= 1)
   error(me,'usage: [w] = mne_read_w_file1(filename)');
end

try
   w = mne_read_w_file(filename);
   w.vertices = w.vertices + 1;
catch
   error(me,'%s',mne_omit_first_line(lasterr));
end

return;






