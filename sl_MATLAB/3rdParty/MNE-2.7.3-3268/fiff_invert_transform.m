function [itrans] = fiff_invert_transform(trans)
%
% [itrans] = fiff_invert_transform(trans)
%
% Invert a coordinate transformation
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
%   $Id: fiff_invert_transform.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/14 00:45:42  msh
%   Added channel picking and fiff_invert_transform
%
%

me='MNE:fiff_invert_transform';

if nargin ~= 1
    error(me,'Incorrect number of arguments');
end

itrans        = trans;
help          = itrans.from;
itrans.from   = itrans.to;
itrans.to     = help;
itrans.trans  = inv(itrans.trans);

return;


