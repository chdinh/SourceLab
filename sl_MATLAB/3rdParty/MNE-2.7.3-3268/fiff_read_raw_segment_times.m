function [data,times] = fiff_read_raw_segment_times(raw,from,to,sel)
%
% [data,times] = fiff_read_raw_segment_times(raw,from,to)
%
% Read a specific raw data segment
%
% raw    - structure returned by fiff_setup_read_raw
% from   - starting time of the segment in seconds
% to     - end time of the segment in seconds
% sel    - optional channel selection vector
%
% data   - returns the data matrix (channels x samples)
% times  - returns the time values corresponding to the samples (optional)
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
%   $Id: fiff_read_raw_segment_times.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.3  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.2  2006/04/21 14:23:16  msh
%   Further improvements in raw data reading
%
%

me='MNE:fiff_read_raw_segment_times';

if nargin == 3
   sel = [];
elseif nargin ~= 4
   error(me,'Incorrect number of arguments');
end
%
%   Convert to samples
%
from = floor(from*raw.info.sfreq);
to   = ceil(to*raw.info.sfreq);
%
%   Read it
%
[ data, times ] = fiff_read_raw_segment(raw,from,to,sel);

return;

end

