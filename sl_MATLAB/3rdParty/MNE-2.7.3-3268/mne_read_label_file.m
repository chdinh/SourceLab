function [label] = mne_read_label_file(filename)
%
% [label] = mne_read_label_file(filename)
% 
% Reads a label file. The returned structure has the following fields
%
%     comment        comment from the first line of the label file
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
%   $Id: mne_read_label_file.m 2653 2009-05-03 16:14:55Z msh $
%   

%
% This is based on the FreeSurfer read_label routine
% SUBJECTS_DIR environment variable is not consulted for the standard location
%

me='MNE:mne_read_label_file';
if(nargin ~= 1)
   error(me,'usage: mne_read_label_file(filename)');
end

[fid,message] = fopen(filename,'r');
if (fid < 0)
   error(me,'Cannot open file %s (%s)', filename,message);
end

comment = fgets(fid) ;
line = fgets(fid) ;
nv = sscanf(line, '%d') ;
data = fscanf(fid, '%d %f %f %f %f\n') ;
data = reshape(data, 5, nv);

for k = 2:length(comment)
   if comment(k) ~= ' '
      break;
   end
end
if comment(length(comment)) == 10
   comment = comment(1:end-1);
end
label.comment  = comment(k:end);
label.vertices = int32(data(1,:));
label.pos      = 1e-3*data(2:4,:)';
label.values   = data(5,:);
fclose(fid);


