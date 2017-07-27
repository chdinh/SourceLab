function [res] = mne_transpose_named_matrix(mat)
%
% [res] = mne_transpose_named_matrix(mat)
%
% Transpose a named matrix
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
%   $Id: mne_transpose_named_matrix.m 2623 2009-04-25 21:21:54Z msh $
%   
%   Revision 1.2  2006/04/23 15:29:41  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/18 23:21:22  msh
%   Added mne_transform_source_space_to and mne_transpose_named_matrix
%
%
%

res.nrow = mat.ncol;
res.ncol = mat.nrow;
res.row_names = mat.col_names;
res.col_names = mat.row_names;
res.data      = mat.data';

return;

end

