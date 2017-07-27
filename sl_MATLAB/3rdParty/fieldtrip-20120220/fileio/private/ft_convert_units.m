function [obj] = ft_convert_units(obj, target)

% FT_CONVERT_UNITS changes the geometrical dimension to the specified SI unit.
% The units of the input object is determined from the structure field
% object.unit, or is estimated based on the spatial extend of the structure, 
% e.g. a volume conduction model of the head should be approximately 20 cm large.
%
% Use as
%   [object] = ft_convert_units(object, target)
%
% The following input objects are supported
%   simple dipole position
%   electrode definition
%   gradiometer array definition
%   volume conductor definition
%   dipole grid definition
%   anatomical mri
%
% Possible target units are 'm', 'dm', 'cm ' or 'mm'.
%
% See FT_ESTIMATE_UNITS, FT_READ_VOL, FT_READ_SENS

% Copyright (C) 2005-2008, Robert Oostenveld
%
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
% $Id: ft_convert_units.m 5284 2012-02-15 10:24:48Z crimic $

% This function consists of three parts:
%   1) determine the input units
%   2) determine the requested scaling factor to obtain the output units
%   3) try to apply the scaling to the known geometrical elements in the input object

% determine the unit-of-dimension of the input object
if isfield(obj, 'unit') && ~isempty(obj.unit)
  % use the units specified in the object
  unit = obj.unit;

else
  % try to estimate the units from the object
  % Ergo: determine the units by looking at the size
  if ft_senstype(obj, 'meg')
    siz = norm(idrange(obj.chanpos));
    unit = ft_estimate_units(siz);

  elseif ft_senstype(obj, 'eeg')
    siz = norm(idrange(obj.chanpos));
    unit = ft_estimate_units(siz);

  elseif isfield(obj, 'pnt') && ~isempty(obj.pnt)
    siz = norm(idrange(obj.pnt));
    unit = ft_estimate_units(siz);
    
  elseif isfield(obj, 'pos') && ~isempty(obj.pos)
    siz = norm(idrange(obj.pos));
    unit = ft_estimate_units(siz);
  
  elseif isfield(obj, 'chanpos') && ~isempty(obj.chanpos)
    siz = norm(idrange(obj.chanpos));
    unit = ft_estimate_units(siz);
    
  elseif isfield(obj, 'transform') && ~isempty(obj.transform)
    % construct the corner points of the volume in voxel and in head coordinates
    [pos_voxel, pos_head] = cornerpoints(obj.dim, obj.transform);
    siz = norm(idrange(pos_head));
    unit = ft_estimate_units(siz);
    
  elseif isfield(obj, 'fid') && isfield(obj.fid, 'pnt') && ~isempty(obj.fid.pnt)
    siz = norm(idrange(obj.fid.pnt));
    unit = ft_estimate_units(siz);
  
  elseif ft_voltype(obj,'infinite')
    unit = target;
    % there is nothing to do to convert the units
    
  elseif ft_voltype(obj,'singlesphere')
    siz = obj.r;
    unit = ft_estimate_units(siz);
    
  elseif ft_voltype(obj,'multisphere')
    siz = median(obj.r);
    unit = ft_estimate_units(siz);
    
  elseif ft_voltype(obj,'concentric')
    siz = max(obj.r);
    unit = ft_estimate_units(siz);
    
  elseif ft_voltype(obj,'nolte')
    siz = norm(idrange(obj.bnd.pnt));
    unit = ft_estimate_units(siz);
    
  elseif ft_voltype(obj,'bem') | ft_voltype(obj,'dipoli') | ft_voltype(obj,'bemcp') | ft_voltype(obj,'asa')| ft_voltype(obj,'avo') | ft_voltype(obj,'openmeeg') 
    siz = norm(idrange(obj.bnd(1).pnt));
    unit = ft_estimate_units(siz);
    
  else
    error('cannot determine geometrical units');
    
  end % recognized type of volume conduction model or sensor array
end % determine input units

if nargin<2
  % just remember the units in the output and return
  obj.unit = unit;
  return
elseif strcmp(unit, target)
  % no conversion is needed
  obj.unit = unit;
  return
end

% give some information about the conversion
fprintf('converting units from ''%s'' to ''%s''\n', unit, target)

if strcmp(unit, 'm')
  unit2meter = 1;
elseif strcmp(unit, 'dm')
  unit2meter = 0.1;
elseif strcmp(unit, 'cm')
  unit2meter = 0.01;
elseif strcmp(unit, 'mm')
  unit2meter = 0.001;
end

% determine the unit-of-dimension of the output object
if strcmp(target, 'm')
  meter2target = 1;
elseif strcmp(target, 'dm')
  meter2target = 10;
elseif strcmp(target, 'cm')
  meter2target = 100;
elseif strcmp(target, 'mm')
  meter2target = 1000;
end

% combine the units into one scaling factor
scale = unit2meter * meter2target;

% volume conductor model
if isfield(obj, 'r'), obj.r = scale * obj.r; end
if isfield(obj, 'o'), obj.o = scale * obj.o; end
if isfield(obj, 'bnd'), for i=1:length(obj.bnd), obj.bnd(i).pnt = scale * obj.bnd(i).pnt; end, end

% gradiometer array
if isfield(obj, 'pnt1'), obj.pnt1 = scale * obj.pnt1; end
if isfield(obj, 'pnt2'), obj.pnt2 = scale * obj.pnt2; end
if isfield(obj, 'prj'),  obj.prj  = scale * obj.prj;  end

% gradiometer array, electrode array, head shape or dipole grid
if isfield(obj, 'pnt'),     obj.pnt     = scale * obj.pnt; end
if isfield(obj, 'chanpos'), obj.chanpos = scale * obj.chanpos; end
if isfield(obj, 'coilpos'), obj.coilpos = scale * obj.coilpos; end
if isfield(obj, 'elecpos'), obj.elecpos = scale * obj.elecpos; end

% fiducials
if isfield(obj, 'fid') && isfield(obj.fid, 'pnt'), obj.fid.pnt = scale * obj.fid.pnt; end

% dipole grid
if isfield(obj, 'pos'), obj.pos = scale * obj.pos; end

% anatomical MRI or functional volume
if isfield(obj, 'transform'),
  H = diag([scale scale scale 1]);
  obj.transform = H * obj.transform;
end

if isfield(obj, 'transformorig'),
  H = diag([scale scale scale 1]);
  obj.transformorig = H * obj.transformorig;
end
    
% remember the unit
obj.unit = target;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDRANGE interdecile range for more robust range estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = idrange(x, dim)
  if nargin == 1
    dim = [];
  end

  [x, perm, nshifts] = shiftdata(x, dim);        % reorder dims

  sx = sort(x, 1);
  ii = round(interp1([0, 1], [1, size(x, 1)], [.1, .9]));
  vals = sx(ii, :);

  vals = unshiftdata(vals, perm, nshifts);       % restore original dims
  r = diff(vals, dim);                           % calculate actual range
