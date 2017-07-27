function s = char(tree)
% XMLTREE/CHAR Converter function from XMLTree to a description string
% FORMAT s = char(tree)
%
% tree - XMLTree object
% s    - a description string of an XMLTree
%_______________________________________________________________________
%
% Return a string describing the XMLTree:
%               'XMLTree object (x nodes) [filename]'
%_______________________________________________________________________
% Copyright (C) 2002-2008  http://www.artefact.tk/

% Guillaume Flandin <guillaume@artefact.tk>
% $Id: char.m 3261 2011-03-31 15:06:56Z roboos $

s = strcat('XMLTree object (',num2str(length(tree)),' nodes) [',getfilename(tree),']');
