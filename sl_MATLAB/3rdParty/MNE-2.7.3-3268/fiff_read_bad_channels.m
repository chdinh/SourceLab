function [bads] = fiff_read_bad_channels(fid,node)
%
% [bads] = fiff_read_bad_channels(fid,node)
%
% Reas the bad channel list from a node if it exists
%
% fid      - The file id
% node     - The node of interes
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
%   $Id: fiff_read_bad_channels.m 2678 2009-05-13 21:22:35Z msh $
%   
%   Revision 1.5  2006/05/03 18:53:04  msh
%   Approaching Matlab 6.5 backward compatibility
%
%   Revision 1.4  2006/05/03 15:51:17  msh
%   Re-added fiff_read_bad_channels
%
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/12 17:09:28  msh
%   Added routines for reading noise-covariance matrices
%
%
%

me='MNE:fiff_read_bad_channels';

global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

node = fiff_dir_tree_find(node,FIFF.FIFFB_MNE_BAD_CHANNELS);

bads = [];
if ~isempty(node)
    tag = find_tag(node,FIFF.FIFF_MNE_CH_NAME_LIST);
    if ~isempty(tag)
        bads = fiff_split_name_list(tag.data);
    end
end

return;

    function [tag] = find_tag(node,findkind)
    
        for p = 1:node.nent
            kind = node.dir(p).kind;
            pos  = node.dir(p).pos;
            if kind == findkind
                tag = fiff_read_tag(fid,pos);
                return;
            end
        end
        tag = [];
        return
    end

end
