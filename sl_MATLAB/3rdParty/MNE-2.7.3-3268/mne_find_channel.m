function [which] = mne_find_channel(info,name)
%
% [which] = mne_find_channel(info,name)
%
% Find a channel by name employing the info structure
% output by mne_raw2mat or mne_epochs2mat
%
% epoch - The data structure containing the channel information
% name  - name of the channel to look for
%
% Returns index of the channel in the data
% If the channel is not found, returns -1
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
%     $Id: mne_find_channel.m 2623 2009-04-25 21:21:54Z msh $
%     
%     Revision 1.4  2006/04/23 15:29:40  msh
%     Added MGH to the copyright
%
%     Revision 1.3  2006/04/14 15:49:49  msh
%     Improved the channel selection code and added ch_names to measurement info.
%
%     Revision 1.2  2006/04/10 23:26:54  msh
%     Added fiff reading routines
%
%     Revision 1.1  2006/02/20 15:45:05  msh
%     Added mne_find_channel.m and mne_read_epoch.m
%
%
%
me='MNE:mne_find_channel';
if(nargin ~= 2)
   error(me,'Usage : [which] = mne_find_channel(info,which)');
end

which = strmatch(name,info.ch_names,'exact');

return;
