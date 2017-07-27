function filename = getfilename(tree)
% XMLTREE/GETFILENAME Get filename method
% FORMAT filename = getfilename(tree)
% 
% tree     - XMLTree object
% filename - XML filename
%_______________________________________________________________________
%
% Return the filename of the XML tree if loaded from disk and an empty 
% string otherwise.
%_______________________________________________________________________
% Copyright (C) 2002-2008  http://www.artefact.tk/

% Guillaume Flandin <guillaume@artefact.tk>
% $Id: getfilename.m 3261 2011-03-31 15:06:56Z roboos $

filename = tree.filename;
