function mne_write_label_file(filename,label)
%
% write_read_label_file(filename,label)
% 
% Writes label file. The returned structure has the following fields
%
%     filename      output file
%     label         a stucture containing the stc data with fields:
%
%     comment        comment for the first line of the label file
%     vertices       vertex indices (0 based, column 1)
%     pos            locations in meters (columns 2 - 4 divided by 1000)
%     values         values at the vertices (column 5)
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
%   No part of this program may be photocopied, reproduced,
%   or translated to another program language without the
%   prior written consent of the author.
%
%   $Id: mne_write_label_file.m 2653 2009-05-03 16:14:55Z msh $
%   

%
% This is based on the FreeSurfer read_label routine
% SUBJECTS_DIR environment variable is not consulted for the standard location
%

me='MNE:mne_write_label_file';
if(nargin ~= 2)
   error(me,'usage: mne_read_label_file(filename, label)');
end

if length(label.vertices) ~= length(label.values) || length(label.vertices) ~= size(label.pos,1) || size(label.pos,2) ~= 3
   error(me,'fields of the label structure have conflicting or incorrect dimensions');
end

[fid,message] = fopen(filename,'w');
if (fid < 0)
   error(me,'Cannot open file %s (%s)', filename,message);
end;

if ~isempty(label.comment)
   fprintf(fid,'# %s\n',label.comment);
else
   fprintf(fid,'# label file written with mne_write_label\n');
end
fprintf(fid,'%d\n',length(label.vertices));
for k = 1:length(label.vertices)
   fprintf(fid,'%d %.2f %.2f %.2f %f\n',label.vertices(k),1000*label.pos(k,:),label.values(k));
end
fclose(fid);


