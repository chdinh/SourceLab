function [rest] = mne_omit_first_line(str)
%
% [rest] = mne_omit_first_line(str)
%
% Omit the first line in a multi-line string (useful for handling
% error messages)
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
%
%   $Id: mne_omit_first_line.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/17 11:52:15  msh
%   Added coil definition stuff
%
%
%
me='MNE:mne_omit_first_line';

lf = findstr(10,str);
if isempty(lf)
    rest = str;
else    
    rest = str(lf+1:size(str,2));
end

return;

end

