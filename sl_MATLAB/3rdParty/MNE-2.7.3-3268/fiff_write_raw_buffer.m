function fiff_write_raw_buffer(fid,buf,cals)
%
% function fiff_write_raw_buffer(fid,info,buf)
%
% fid        of an open raw data file
% buf        the buffer to write
% cals       calibration factors
%
%

%
%   Copyright 2007
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
% $Id: fiff_write_raw_buffer.m 2678 2009-05-13 21:22:35Z msh $
% 
% Revision 1.1  2007/11/07 16:05:05  msh
% New routines for writing raw files
%
%
%
%
me='MNE:fiff_write_raw_buffer';
if nargin ~= 3
        error(me,'Incorrect number of arguments');
end

if size(buf,1) ~= length(cals)
    error(me,'buffer and calibration sizes do not match');
end

global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

fiff_write_float(fid,FIFF.FIFF_DATA_BUFFER,inv(diag(cals))*buf);

return;
