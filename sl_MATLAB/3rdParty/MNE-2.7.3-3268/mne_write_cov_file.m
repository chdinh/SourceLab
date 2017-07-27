function mne_write_cov_file(fname,cov)
%
%   function mne_write_cov_file(name,cov)
%
%   Write a complete fif file containing a covariance matrix
%
%   fname    filename
%   cov      the covariance matrix to write
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
%   $Id: mne_write_cov_file.m 2628 2009-04-27 21:17:31Z msh $
%   
%   Revision 1.3  2008/10/10 16:13:57  msh
%   Added mne_ex_read_epochs. Fixed help text of mne_write_cov_file.m
%
%   Revision 1.2  2006/05/03 18:53:06  msh
%   Approaching Matlab 6.5 backward compatibility
%
%   Revision 1.1  2006/04/29 12:44:10  msh
%   Added covariance matrix writing routines.
%
%
%

me='MNE:mne_write_cov_file';

global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

fid = fiff_start_file(fname);

try
    mne_write_cov(fid,cov);
catch
    delete(fname);
    error(me,'%s',mne_omit_first_line(lasterr));
end
    

fiff_end_file(fid);

return;


end
