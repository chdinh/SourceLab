function [res] = mne_file_name(dir,name)
%
%   [name] = mne_file_name(dir,name)
%
%   Compose a file name under MNE_ROOT
%
%   dir     - Name of the directory containing the file name
%   name    - Name of the file under that directory
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

me='MNE:mne_file_name';

if ~ispref('MNE','MNE_ROOT')
    error(me,'MNE_ROOT not defined');
end
mne_root=getpref('MNE','MNE_ROOT');

if nargin == 2
    res = sprintf('%s/%s/%s',mne_root,dir,name);
elseif nargin == 1
    res = sprintf('%s/%s',mne_root,dir);
else
    error(me,'incorrect number of arguments');
end 

return;

end
        
