function t = numel(obj)
% Number of simple file arrays involved.
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: numel.m 2781 2011-02-03 10:48:53Z roboos $


% Should be this, but it causes problems when accessing
% obj as a structure.
%t = prod(size(obj));

t  = numel(struct(obj));
