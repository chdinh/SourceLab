% nanmean() - Average, not considering NaN values
%
% Usage: same as mean()
% Note: all nanXXX.m functionalities are implemented through mex-files that 
% are more memory-efficient. The code in the MATLAB mfile is not necessarily
% identical to that in the mex-file.

% Author: Arnaud Delorme, CNL / Salk Institute, 16 Oct 2002

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: nanmean.m 5129 2012-01-11 14:40:24Z jansch $

function out = nanmean(in, dim)

if nargin < 1
    help nanmean;
    return;
end;
if nargin < 2
  dim = find(size(in)>1,1,'first');  
end
tmpin = in;
tmpin(find(isnan(in(:)))) = 0;
out = sum(tmpin, dim) ./ sum(~isnan(in),dim);

