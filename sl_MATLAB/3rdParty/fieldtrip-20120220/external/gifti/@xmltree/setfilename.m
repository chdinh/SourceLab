function tree = setfilename(tree,filename)
% XMLTREE/SETFILENAME Set filename method
% FORMAT tree = setfilename(tree,filename)
% 
% tree     - XMLTree object
% filename - XML filename
%_______________________________________________________________________
%
% Set the filename linked to the XML tree as filename.
%_______________________________________________________________________
% Copyright (C) 2002-2008  http://www.artefact.tk/

% Guillaume Flandin <guillaume@artefact.tk>
% $Id: setfilename.m 3261 2011-03-31 15:06:56Z roboos $

tree.filename = filename;
