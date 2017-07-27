function [eventlist] = mne_read_events(filename)
%
% [eventlist] = mne_read_events(filename)
%
% Read an event list from a fif file
%

%
%   Copyright 2008
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
%   $Id: mne_read_events.m 2628 2009-04-27 21:17:31Z msh $
%   
%   Revision 1.2  2008/08/21 18:03:16  msh
%   Fixed possibility for closing the file twice
%
%   Revision 1.1  2008/06/16 17:27:50  msh
%   Added mne_read_events and mne_write_events functions
%
%
global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

me='MNE:mne_read_events';


%
% Open file
%
[ fid, tree ] = fiff_open(filename);
%
%   Find the desired block
%
events = fiff_dir_tree_find(tree,FIFF.FIFFB_MNE_EVENTS);
if length(events) == 0
  fclose(fid);
  error(me,'Could not find event data');
end

eventlist = [];
for k = 1:events.nent
    kind = events.dir(k).kind;
    pos  = events.dir(k).pos;
    if kind == FIFF.FIFF_MNE_EVENT_LIST
      tag = fiff_read_tag(fid,pos);
      eventlist = tag.data;
      break;
    end
end
fclose(fid);
if isempty(eventlist)
   error(me,'Could not find any events');
else
   eventlist = reshape(eventlist',3,size(eventlist,1)/3)';
end

return;

