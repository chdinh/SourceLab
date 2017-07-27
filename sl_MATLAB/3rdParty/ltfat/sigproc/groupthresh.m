function [xo]=groupthresh(xi,lambda,varargin)
%GROUPTHRESH   group (hard/soft) thresholding
%   Usage:  xo=groupthresh(x,lambda);
%
%   GROUPTHRESH(x,lambda) will perform hard group thresholding on x, with
%   threshold lambda xi is a two-dimensional array, the first dimension
%   labelling groups, and the second one labelling members All coefficients
%   within a given group are shrunk according to the value of the L2 norm of
%   the group in comparison to the threshold lambda
%
%   GROUPTHRESH(x,lambda,'soft') will do the same using soft
%   thresholding.
%
%   GROUPTHRESH takes the following flags at the end of the line of input
%   arguments:
%
%      'hard'   - Perform hard thresholding. This is the default.
%
%      'soft'   - Perform soft thresholding.  
%
%      'full'   - Returns the output as a full matrix. This is the default.
%
%      'sparse' - Returns the output as a sparse matrix.
%  
%   See also:  gabgrouplasso
%
%   Demos:  demo_audioshrink
%
%   References:
%     M. Kowalski. Sparse regression using mixed norms. Appl. Comput. Harmon.
%     Anal., 2009. accepted.
%     
%     M. Kowalski and B. Torrésani. Sparsity and persistence: mixed norms
%     provide simple signal models with dependent coefficients. Signal, Image
%     and Video Processing, 2008. To appear.

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

%   AUTHOR : Bruno Torresani.  
%   REFERENCE: OK
 
if nargin<2
  error('Too few input parameters.');k
end;

if (prod(size(lambda))~=1 || ~isnumeric(lambda))
  error('lambda must be a scalar.');
end;

% Define initial value for flags and key/value pairs.
definput.flags.iofun={'hard','soft'};
definput.flags.outclass={'full','sparse'};

[flags,keyvals]=ltfatarghelper({},definput,varargin);

NbGroups = size(xi,1);
NbMembers = size(xi,2);

xo = zeros(size(xi));

for g=1:NbGroups,
    threshold = norm(xi(g,:));
    mask = (1-lambda/threshold);
    mask = mask * (mask>0);
    if flags.do_hard
      mask = (mask>0);
    else      
      mask = mask * (mask>0);
    end;
    xo(g,:) = xi(g,:) * mask;
end
