function [xo,N]=wilgrouplasso(xi,lambda,varargin);
%WILGROUPLASSO   group lasso estimate (hard/soft) in time-frequency domain
%   Usage:  xo=wilgrouplasso(x,lambda,...);
%           [xo,N]=wilgrouplasso(x,lambda,...));
%
%   WILGROUPLASSO(x,lambda,'time','hard') will perform
%   group thresholding on x, i.e. all time-frequency
%   groups whose norm is less than lambda will be set to zero.
%
%   The function takes the following optional parameters at the end of
%   the line of input arguments:
%
%       'freq' - Group in frequency (search for tonal components). This is the
%                default.
%
%       'time' - Group in time (search for transient components). 
%
%       'hard' - Use hard thresholding. This is the default.
%
%       'soft' - Use soft thresholding.
%
%   [xo,N]=WILGROUPLASSO(x,lambda,...) additionally returns
%   a number N specifying how many numbers where kept.
%
%   The function may meaningfully be applied to output from WMDCT or from
%   WIL2RECT(DWILT(...)) using an ortonormal transform.
%
%   See also:  gablasso
%
%   Demos: demo_audioshrink
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
  error('%s: Too few input parameters.',upper(mfilename));
end;

% Define initial value for flags and key/value pairs.
definput.flags.group={'freq','time'};
definput.flags.thresh={'hard','soft'};

[flags,kv]=ltfatarghelper({},definput,varargin);

M = size(xi,1);
N = size(xi,2);

xo = zeros(size(xi));

if flags.do_time
  for t=1:N,
    threshold = norm(xi(:,t));
    mask = (1-lambda/threshold);
    if flags.do_soft
      mask = mask * (mask>0);
    else
      mask = (mask>0);
    end
    xo(:,t) = xi(:,t) * mask;
  end
else
  for f=1:M,
    threshold = norm(xi(f,:));
    mask = (1-lambda/threshold);
    mask = mask * (mask>0);
    if flags.do_soft
      mask = mask * (mask>0);
    else
      mask = (mask>0);
    end
    xo(f,:) = xi(f,:) * mask;
  end
end;

if nargout==2
    signif_map = (abs(xo)>0);
    N = sum(signif_map(:));
end
