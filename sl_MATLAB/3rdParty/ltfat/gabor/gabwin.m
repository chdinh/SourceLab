function [g,info] = gabwin(g,a,M,L,callfun);
%GABWIN  Compute a Gabor window from text or cell array.
%   Usage: [g,info] = gabwin(g,a,M,L);
%
%   [g,info]=GABWIN(g,a,M,L) computes a window that fits well with the
%   specified number of channels M, time shift a and transform length
%   L. The window itself is specified by a text description or a cell array
%   containing additional parameters.
%
%   The window can be specified directly as a vector of numerical
%   values. In this case, GABWIN only checks assumptions about transform
%   sizes etc.
%
%   [g,info]=GABWIN(g,a,M) does the same, but the window must be a FIR
%   window, as the transform length is unspecified.
%
%   The window can be specified as one of the following text strings:
%  
%       'gauss'     - Gaussian window fitted to the lattice, i.e. tfr=a*M/L.
%
%       'dualgauss' - Canonical dual of Gaussian window.
%
%       'tight'     - Tight window generated from a Gaussian.
%
%   In these cases, a long window is generated with a length of L.
%
%   It is also possible to specify one of the window names from FIRWIN. In
%   such a case, GABWIN will generate the specified FIR window with a length
%   of M.
%
%   The window can also be specified as cell array. The possibilities are:
%
%     {'gauss',...} - Additional parameters are passed to PGAUSS
%
%     {'dual',...}  - Canonical dual window of whatever follows. See the
%                   examples below.
%
%     {'tight',...} - Canonical tight window of whatever follows.
%
%   It is also possible to specify one of the window names from FIRWIN as
%   the first field in the cell array. In this case, the remaining
%   entries of the cell array are passed directly to FIRWIN.
%
%   Some examples:
%
%      g=gabwin('gauss',a,M,L);
%
%   This computes a Gaussian window of length L fitted for a system with
%   time-shift a and M channels.
%
%     g=gabwin({'gauss',1},a,M,L);
%
%   This computes a Gaussian window with equal time and frequency support
%   irrespective of a and M.
%
%     gd=gabwin('gaussdual',a,M,L);
%
%   This computes the canonical dual of a Gaussian window fitted for a
%   system with time-shift a and M channels.
%
%     gd=gabwin({'tight','gauss'},a,M,L);
%
%   This computes the canonical tight window of the Gaussian window fitted
%   for the system.
%
%     g=gabwin({'dual',{'hann',20}},a,M,L);
%
%   This computes the dual of a Hann window of length 20.  
%
%   The structure info provides some information about the computed
%   window:
%
%      info.gauss   - True if the window is a Gaussian.
%
%      info.tfr     - Time/frequency support ratio of the window. Set
%                     whenever it makes sense.
%
%      info.wasrow  - Input was a row window
%
%      info.isfir   - Input is a FIR window
%
%      info.isdual  - Output is the dual window of the aux window.
%
%      info.istight - Output is known to be a tight window.
%
%      info.auxinfo - Info about auxiliary window.
%
%      info.gl      - Length of window.
%
%   See also: pgauss, firwin, wilwin

% Copyright (C) 2005-2011 Peter L. Soendergaard.
% This file is part of LTFAT version 0.98
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
% Assert correct input.
error(nargchk(3,5,nargin));

if nargin==3
  L=[];
end;

[g,info] = comp_window(g,a,M,L,'GABWIN');

if (info.isfir)  
  if info.istight
    g=g/sqrt(2);
  end;  
end;