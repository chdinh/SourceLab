function p = parent(tree,uid)
% XMLTREE/PARENT Parent Method
% FORMAT uid = parent(tree,uid)
% 
% tree   - XMLTree object
% uid    - UID of the lonely child
% p      - UID of the parent ([] if root is the child)
%_______________________________________________________________________
%
% Return the uid of the parent of a node.
%_______________________________________________________________________
% Copyright (C) 2002-2008  http://www.artefact.tk/

% Guillaume Flandin <guillaume@artefact.tk>
% $Id: parent.m 3261 2011-03-31 15:06:56Z roboos $

p = tree.tree{uid}.parent;
