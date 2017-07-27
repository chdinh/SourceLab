function [pinfo] = mne_patch_info(nearest)
%
% [pinfo] = mne_patch_info(nearest)
%
% Generate the patch information from the 'nearest' vector in a source space
%

%
%
%   Copyright 2009
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
%   $Id: mne_patch_info.m 2678 2009-05-13 21:22:35Z msh $
%

me='MNE:mne_patch_info';

if nargin ~= 1
   error(me,'Incorrect number of arguments');
end

if isempty(nearest)
   pinfo = [];
   return;
end

[ sorted, indn ] = sort(nearest);

[uniq,firsti,dum] = unique(sorted,'first');
[uniq,lasti,dum] = unique(sorted,'last');

for k = 1:length(uniq)
   pinfo{k} = indn(firsti(k):lasti(k));
end

return;

