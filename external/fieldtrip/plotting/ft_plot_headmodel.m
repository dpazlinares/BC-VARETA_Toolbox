function ft_plot_headmodel(headmodel, varargin)

% FT_PLOT_HEADMODEL visualizes the boundaries in the volume conduction model of the head as
% specified in the headmodel structure
%
% Use as
%   hs = ft_plot_headmodel(headmodel, varargin)
%
% Optional arguments should come in key-value pairs and can include
%   'facecolor'    = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx3 or Nx1 array where N is the number of faces
%   'vertexcolor'  = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx3 or Nx1 array where N is the number of vertices
%   'edgecolor'    = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r'
%   'faceindex'    = true or false
%   'vertexindex'  = true or false
%   'facealpha'    = transparency, between 0 and 1 (default = 1)
%   'edgealpha'    = transparency, between 0 and 1 (default = 1)
%   'surfaceonly'  = true or false, plot only the outer surface of a hexahedral or tetrahedral mesh (default = false)
%   'unit'         = string, convert to the specified geometrical units (default = [])
%   'grad'         = gradiometer array, used in combination with local spheres model
%
% Example
%   headmodel   = [];
%   headmodel.r = [86 88 92 100];
%   headmodel.o = [0 0 40];
%   figure, ft_plot_headmodel(headmodel)
%
% See also FT_PREPARE_HEADMODEL, FT_PLOT_MESH, FT_PLOT_SENS

% Copyright (C) 2009, Cristiano Micheli
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
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
% $Id$

ws = ft_warning('on', 'MATLAB:divideByZero');

% ensure that the volume conduction model description is up-to-date (Dec 2012)
headmodel = ft_datatype_headmodel(headmodel);

% get the optional input arguments
faceindex   = ft_getopt(varargin, 'faceindex', 'none');
vertexindex = ft_getopt(varargin, 'vertexindex', 'none');
vertexsize  = ft_getopt(varargin, 'vertexsize', 10);
facecolor   = ft_getopt(varargin, 'facecolor', 'white');
vertexcolor = ft_getopt(varargin, 'vertexcolor', 'none');
edgecolor   = ft_getopt(varargin, 'edgecolor'); % the default for this is set below
facealpha   = ft_getopt(varargin, 'facealpha', 1);
surfaceonly = ft_getopt(varargin, 'surfaceonly');
unit        = ft_getopt(varargin, 'unit');
grad        = ft_getopt(varargin, 'grad');

if ~isempty(unit)
  headmodel = ft_convert_units(headmodel, unit);
  if ~isempty(grad)
    grad = ft_convert_units(grad, unit);
  end
end

faceindex   = istrue(faceindex);   % yes=view the face number
vertexindex = istrue(vertexindex); % yes=view the vertex number

% we will probably need a sphere, so let's prepare one
[pos, tri] = mesh_sphere(2562);

% prepare a single or multiple triangulated boundaries
switch ft_headmodeltype(headmodel)
  case {'singlesphere' 'concentricspheres'}
    headmodel.r = sort(headmodel.r);
    bnd = repmat(struct(), numel(headmodel.r));
    for i=1:numel(headmodel.r)
      bnd(i).pos(:,1) = pos(:,1)*headmodel.r(i) + headmodel.o(1);
      bnd(i).pos(:,2) = pos(:,2)*headmodel.r(i) + headmodel.o(2);
      bnd(i).pos(:,3) = pos(:,3)*headmodel.r(i) + headmodel.o(3);
      bnd(i).tri = tri;
    end
    if isempty(edgecolor)
      edgecolor = 'none';
    end

  case 'localspheres'
    if ~isempty(grad)
      ft_notice('estimating point on head surface for each gradiometer');
      [headmodel, grad] = ft_prepare_vol_sens(headmodel, grad);
      [bnd.pos, bnd.tri] = headsurface(headmodel, grad);
    else
      ft_notice('plotting sphere for each gradiometer');
      bnd = repmat(struct(), numel(headmodel.label));
      for i=1:numel(headmodel.label)
        bnd(i).pos(:,1) = pos(:,1)*headmodel.r(i) + headmodel.o(i,1);
        bnd(i).pos(:,2) = pos(:,2)*headmodel.r(i) + headmodel.o(i,2);
        bnd(i).pos(:,3) = pos(:,3)*headmodel.r(i) + headmodel.o(i,3);
        bnd(i).tri = tri;
      end
    end
    if isempty(edgecolor)
      edgecolor = 'none';
    end

  case {'bem', 'dipoli', 'asa', 'bemcp', 'singleshell' 'openmeeg'}
    % these already contain one or multiple triangulated surfaces for the boundaries
    bnd = headmodel.bnd;

  case 'simbio'
    % the ft_plot_mesh function below wants the SIMBIO tetrahedral or hexahedral mesh
    bnd = headmodel;

    % only plot the outer surface of the volume
    surfaceonly = true;

  case 'interpolate'
    xgrid = 1:headmodel.dim(1);
    ygrid = 1:headmodel.dim(2);
    zgrid = 1:headmodel.dim(3);
    [x, y, z] = ndgrid(xgrid, ygrid, zgrid);
    gridpos = ft_warp_apply(headmodel.transform, [x(:) y(:) z(:)]);

    % plot the dipole positions that are inside
    plot3(gridpos(headmodel.inside, 1), gridpos(headmodel.inside, 2), gridpos(headmodel.inside, 3), 'k.');

    % there is no boundary to be displayed
    bnd = [];

  case {'infinite' 'infinite_monopole' 'infinite_currentdipole' 'infinite_magneticdipole'}
    ft_warning('there is nothing to plot for an infinite volume conductor')

    % there is no boundary to be displayed
    bnd = [];

  otherwise
    ft_error('unsupported headmodel type')
end

% all models except for the spherical ones
if isempty(edgecolor)
  edgecolor = 'k';
end

% plot the triangulated surfaces of the volume conduction model
for i=1:length(bnd)
  ft_plot_mesh(bnd(i),'faceindex',faceindex,'vertexindex',vertexindex, ...
    'vertexsize',vertexsize,'facecolor',facecolor,'edgecolor',edgecolor, ...
    'vertexcolor',vertexcolor,'facealpha',facealpha, 'surfaceonly', surfaceonly);
end

% revert to original state
ft_warning(ws);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  if radius < 1 * ft_scalingfactor('mm', unit)
  ft_warning('radius is smaller than 1 mm');
end
if rmin < 1 * ft_scalingfactor('mm', unit)
  ft_warning('rmin is smaller than 1 mm');
end

if ~isempty(meshplot)
  % mesh should be a cell-array
  if isstruct(meshplot)
    tmp = meshplot;
    meshplot = cell(size(tmp));
    for i=1:numel(tmp)
      meshplot{i} = tmp(i);
    end
  elseif iscell(meshplot)
    % do nothing
  else
    meshplot = {};
  end
  
  % replace pnt by pos
  for k = 1:numel(meshplot)
    meshplot{k} = fixpos(meshplot{k});
  end
  
  for k = 1:numel(meshplot)
    if ~isfield(meshplot{k}, 'pos') || ~isfield(meshplot{k}, 'tri')
      % ft_error('the mesh should be a structure with pos and tri');
      meshplot{k}.pos = [];
      meshplot{k}.tri = [];
    end
  end
  
  % facecolor, edgecolor, and vertexcolor should be cell-array
  if ~iscell(facecolor)
    tmp = facecolor;
    if ischar(tmp)
      facecolor = {tmp};
    elseif ismatrix(tmp) && size(tmp, 2) == 3
      facecolor = cell(size(tmp,1), 1);
      for i=1:size(tmp,1)
        facecolor{i} = tmp(i, 1:3);
      end
    else
      facecolor = {};
    end
  end
  if ~iscell(edgecolor)
    tmp = edgecolor;
    if ischar(tmp)
      edgecolor = {tmp};
    elseif ismatrix(tmp) && size(tmp, 2) == 3
      edgecolor = cell(size(tmp,1), 1);
      for i=1:size(tmp,1)
        edgecolor{i} = tmp(i, 1:3);
      end
    else
      edgecolor = {};
    end
  end
  if ~iscell(vertexcolor)
    tmp = vertexcolor;
    if ischar(tmp)
      vertexcolor = {tmp};
    elseif ismatrix(tmp) && size(tmp, 2) == 3
      vertexcolor = cell(size(tmp,1), 1);
      for i=1:size(tmp,1)
        vertexcolor{i} = tmp(i, 1:3);
      end
    else
      vertexcolor = {};
    end
  end
  
  % make sure each mesh has plotting options specified
  if numel(meshplot) > 1
    nmesh = numel(meshplot);
    if numel(facecolor) < numel(meshplot)
      for m = numel(facecolor)+1:nmesh
        facecolor{m} = facecolor{1};
      end
    end
    if numel(edgecolor) < numel(meshplot)
      for m = numel(edgecolor)+1:nmesh
        edgecolor{m} = edgecolor{1};
      end
    end
    if numel(facealpha) < numel(meshplot)
      for m = numel(facealpha)+1:nmesh
        facealpha(m) = facealpha(1);
      end
    end
    if numel(edgealpha) < numel(meshplot)
      for m = numel(edgealpha)+1:nmesh
        edgealpha(m) = edgealpha(1);
      end
    end
    if numel(vertexcolor) < numel(meshplot)
      for m = numel(vertexcolor)+1:nmesh
        vertexcolor(m) = vertexcolor(1);
      end
    end
  end
end

if strcmp(sli, '2d') || strcmp(sli, '3d')
  if isempty(meshplot)
    ft_error('plotting a slice requires a mesh as input')
  else
    dointersect = 1;
  end
else
  dointersect = 0;
end

if dointersect % check intersection inputs
  % color and linestyle should be cell-array
  if ~iscell(intersectcolor)
    tmp = intersectcolor;
    if ischar(tmp)
      intersectcolor = {tmp};
    elseif ismatrix(tmp) && size(tmp, 2) == 3
      intersectcolor = cell(size(tmp,1), 1);
      for i=1:size(tmp,1)
        intersectcolor{i} = tmp(i, 1:3);
      end
    else
      intersectcolor = {};
    end
  end
  if ischar(intersectlinestyle)
    intersectlinestyle = {intersectlinestyle};
  elseif iscell(intersectlinestyle)
    % do nothing
  else
    intersectlinestyle = {};
  end
  
  % make sure each intersection has plotting options specified
  if numel(meshplot) > 1
    nmesh = numel(meshplot);
    if numel(intersectcolor) < numel(meshplot)
      for m = numel(intersectcolor)+1:nmesh
        intersectcolor{m} = intersectcolor{1};
      end
    end
    if numel(intersectlinewidth) < numel(meshplot)
      for m = numel(intersectlinewidth)+1:nmesh
        intersectlinewidth(m) = intersectlinewidth(1);
      end
    end
    if numel(intersectlinestyle) < numel(meshplot)
      for m = numel(intersectlinestyle)+1:nmesh
        intersectlinestyle{m} = intersectlinestyle{1};
      end
    end
  end % end intersection plotting checks
end % end dointersect checks

if dointersect
  % set the orientation of the slice plane
  if strcmp(ori, 'x')
    oriX = 1; oriY = 0; oriZ = 0;
  elseif strcmp(ori, 'y')
    oriX = 0; oriY = 1; oriZ = 0;
  elseif strcmp(ori, 'z')
    oriX = 0; oriY = 0; oriZ = 1;
  else
    ft_error('ori must be "x", "y" or "z"')
  end
end

if isempty(clim)
  clim = [min(val) max(val)]; % use the data
end

% functional data scaling factors
if ischar(cmap)
  if strcmp(cmap, 'default')
    cmapsc = get(0, 'DefaultFigureColormap');
  else
    cmapsc = feval(cmap, 201); % an odd number
  end
else
  cmapsc = cmap;
end

cmid   = size(cmapsc,1)/2;                          % colorbar middle
colscf = 2*( (val-clim(1)) / (clim(2)-clim(1)) )-1; % color between -1 and 1, bottom vs. top colorbar
colscf(colscf>1)=1; colscf(colscf<-1)=-1;           % clip values outside the [-1 1] range
radscf = val-(min(abs(val)) * sign(max(val)));      % radius between 0 and 1, small vs. large pos/neg effect
radscf = abs( radscf / max(abs(radscf)) );

if strcmp(scalerad, 'yes')
  rmax = rmin+(radius-rmin)*radscf; % maximum radius of the clouds
else
  rmax = ones(length(pos), 1)*radius; % each cloud has the same radius
end

if dointersect
  % generate circle points
  angles = linspace(0,2*pi,50);
  x = cos(angles)';
  y = sin(angles)';
  slicedim = zeros(length(angles),1);
  
  if strcmp(slicepos, 'auto') % search each slice for largest area of data
    % find the potential limits of the interpolation
    intxmax = max(pos(:,1))+radius; intxmin = min(pos(:,1))-radius;
    intymax = max(pos(:,2))+radius; intymin = min(pos(:,2))-radius;
    intzmax = max(pos(:,3))+radius; intzmin = min(pos(:,3))-radius;
    
    % define potential slices with data
    if oriX; potent_slices = round(intxmin):round(intxmax); end
    if oriY; potent_slices = round(intymin):round(intymax); end
    if oriZ; potent_slices = round(intzmin):round(intzmax); end
    
    area = NaN(length(pos),length(potent_slices));  % preallocate matrix of electrode interpolation area for each slice
    for s = 1:length(potent_slices)                 % only search slices that could potentially contain data
      distance = NaN(length(pos),1);                % preallocate vector for each electrodes distance from the slice
      for c = 1:length(pos)
        indpos = pos(c, :);
        if oriX; distance(c) = abs(indpos(1)-potent_slices(s)); end
        if oriY; distance(c) = abs(indpos(2)-potent_slices(s)); end
        if oriZ; distance(c) = abs(indpos(3)-potent_slices(s)); end
        
        if distance(c) < rmax(c) % if there is any data from this electrode in this slice
          % find the circle points for the interpolation of this electrode
          xmax = rmax(c)*x;
          ymax = rmax(c)*y;
          
          % find the maximum radius of a cross section of the virtual sphere in the given slice
          xmaxdif = abs(xmax-distance(c));
          imindif = find(xmaxdif == min(xmaxdif), 1); % index of x value closest to distance(e)
          rcmax = abs(ymax(imindif));
          
          area(c, s) = 0.5*pi*rcmax^2;
        else % area must be zero
          area(c, s) = 0;
        end
      end % for each loop
    end % for each slice
    totalarea = sum(area);
    
    slicepos = zeros(nslices,1);
    for n = 1:nslices
      imaxslice = find(totalarea == max(totalarea), 1);       % index of the slice with the maximum area
      slicepos(n) = potent_slices(imaxslice);                 % position of the yet unlisted slice with the maximum area
      totalarea(imaxslice-minspace:imaxslice+minspace) = 0;   % change the totalarea of the chosen slice and those within minspace to 0 so that it is not chosen again
    end
  end
  
  % pre-allocate logical array specifying whether intersection with a given mesh (k) actually exists within a given slice (s)
  intersect_exists = zeros(numel(slicepos), numel(meshplot));
end

% draw figure
if strcmp(sli, '2d')
  % pre-allocate interpolation limits of each slice to facilitate inding overall limits of all slices after plotting
  xsmax = NaN(numel(slicepos),1); xsmin = NaN(numel(slicepos),1);
  ysmax = NaN(numel(slicepos),1); ysmin = NaN(numel(slicepos),1);
  zsmax = NaN(numel(slicepos),1); zsmin = NaN(numel(slicepos),1);
  
  for s = 1:numel(slicepos) % slice loop
    subplot(numel(slicepos),1,s); hold on;
    
    % pre-allocate interpolation limits of each cloud to facilitate finding slice limits after plotting
    xcmax = NaN(length(pos(:,1)),1); xcmin = NaN(length(pos(:,1)),1);
    ycmax = NaN(length(pos(:,1)),1); ycmin = NaN(length(pos(:,1)),1);
    zcmax = NaN(length(pos(:,1)),1); zcmin = NaN(length(pos(:,1)),1);
    
    for c = 1:length(pos(:,1)) % cloud loop
      indpos = pos(c, :);
      % calculate distance from slice
      if oriX; distance = abs(indpos(1)-slicepos(s)); end
      if oriY; distance = abs(indpos(2)-slicepos(s)); end
      if oriZ; distance = abs(indpos(3)-slicepos(s)); end
      
      if distance < rmax(c)
        switch (cloudtype)
          case 'surf'
            xmax = rmax(c)*x;
            ymax = rmax(c)*y;
            
            if strcmp(scalealpha, 'yes')
              maxalpha = (rmax(c)-distance)/rmax(c);
            else
              maxalpha = 1;
            end
            
            % find the maximum radius of a cross section of the virtual sphere in the given slice
            xmaxdif = abs(xmax-distance);
            imindif = find(xmaxdif == min(xmaxdif), 1); % index of x value closest to distance(e)
            rcmax = abs(ymax(imindif));
            
            % determine points along outermost circle
            xe = rcmax*x;
            ye = rcmax*y;
            
            % jitter values of points in the slice plane so no surfaces overlap
            slicedime = slicedim+(0.01*rand*ones(length(x), 1));
            
            % plot concentric circles
            for n = 0:ncirc-1 % circle loop
              xo = xe*((ncirc-n)/ncirc);    % outer x points
              yo = ye*((ncirc-n)/ncirc);    % outer z points
              xi = xe*((ncirc-1-n)/ncirc);  % inner x points
              yi = ye*((ncirc-1-n)/ncirc);  % inner z points
              if n == ncirc-1 % for the last concentric circle
                if oriX; hs = fill3(slicepos(s)+slicedime, indpos(2)+xo, indpos(3)+yo, val(c)); end
                if oriY; hs = fill3(indpos(1)+xo, slicepos(s)+slicedime, indpos(3)+yo, val(c)); end
                if oriZ; hs = fill3(indpos(1)+xo, indpos(2)+yo, slicepos(s)+slicedime, val(c)); end
              else
                if oriX; hs = fill3([slicepos(s)+slicedime; slicepos(s)+slicedim], [indpos(2)+xo; indpos(2)+xi], [indpos(3)+yo; indpos(3)+yi], val(c)); end
                if oriY; hs = fill3([indpos(1)+xo; indpos(1)+xi], [slicepos(s)+slicedime; slicepos(s)+slicedim], [indpos(3)+yo; indpos(3)+yi], val(c)); end
                if oriZ; hs = fill3([indpos(1)+xo; indpos(1)+xi], [indpos(2)+yo; indpos(2)+yi], [slicepos(s)+slicedime; slicepos(s)+slicedim], val(c)); end
              end
              set(hs, 'EdgeColor', 'none', 'FaceAlpha', maxalpha*n/ncirc)
            end % end circle loop
            
            % find the limits of the plotted surfaces for this electrode
            if oriX
              xcmax(c) = max(slicedime+slicepos(s)); xcmin(c) = min(slicedime+slicepos(s));
              ycmax(c) = max(xe+indpos(2)); ycmin(c) = min(xe+indpos(2));
              zcmax(c) = max(ye+indpos(3)); zcmin(c) = min(ye+indpos(3));
            elseif oriY
              xcmax(c) = max(xe+indpos(1)); xcmin(c) = min(xe+indpos(1));
              ycmax(c) = max(slicedime+slicepos(s)); ycmin(c) = min(slicedime+slicepos(s));
              zcmax(c) = max(ye+indpos(3)); zcmin(c) = min(ye+indpos(3));
            elseif oriZ
              xcmax(c) = max(xe+indpos(1)); xcmin(c) = min(xe+indpos(1));
              ycmax(c) = max(ye+indpos(2)); ycmin(c) = min(ye+indpos(2));
              zcmax(c) = max(slicedime+slicepos(s)); zcmin(c) = min(slicedime+indpos(s));
            end
            
          case 'cloud'
            rng(0, 'twister');                          % random number generator
            npoints = round(ptdensity*pi*rmax(c)^2);       % number of points based on area of cloud cross section
            azimuth = 2*pi*rand(npoints,1);             % azimuthal angle for each point
            radii = rmax(c)*(rand(npoints,1).^ptgradient);  % radius value for each point
            radii = sort(radii);                        % sort radii in ascending order so they are plotted from inside out
            % convert to Carthesian; note that second input controls third output
            if oriX; [y,z,x] = sph2cart(azimuth, zeros(npoints,1)+0.01*rand(npoints,1), radii); end
            if oriY; [x,z,y] = sph2cart(azimuth, zeros(npoints,1)+0.01*rand(npoints,1), radii); end
            if oriZ; [x,y,z] = sph2cart(azimuth, zeros(npoints,1)+0.01*rand(npoints,1), radii); end
            
            % color axis with radius scaling
            if strcmp(colorgrad, 'white') % color runs up to white
              fcolidx = ceil(cmid) + sign(colscf(c))*floor(abs(colscf(c)*cmid));
              if fcolidx == 0; fcolidx = 1; end
              fcol = cmapsc(fcolidx,:); % color [Nx3]
              ptcol = [linspace(fcol(1), 1, npoints)' linspace(fcol(2), 1, npoints)' linspace(fcol(3), 1, npoints)'];
            elseif isscalar(colorgrad) % color runs down towards colorbar middle
              rnorm = radii/rmax(c); % normalized radius
              if radscf(c)>=.5 % extreme values
                ptcol = val(c) - (flip(1-rnorm).^inv(colorgrad))*val(c); % scaled fun [Nx1]
              elseif radscf(c)<.5 % values closest to zero
                ptcol = val(c) + (flip(1-rnorm).^inv(colorgrad))*abs(val(c)); % scaled fun [Nx1]
              end
            else
              ft_error('color gradient should be either ''white'' or a scalar determining the fall-off')
            end
            
            % draw the points
            if oriX; scatter3(x+slicepos(s), y+indpos(2), z+indpos(3), ptsize, ptcol, '.'); end
            if oriY; scatter3(x+indpos(1), y+slicepos(s), z+indpos(3), ptsize, ptcol, '.'); end
            if oriZ; scatter3(x+indpos(1), y+indpos(2), z+slicepos(s), ptsize, ptcol, '.'); end
            
            % find the limits of the plotted points for this electrode
            if oriX
              xcmax(c) = max(x+slicepos(s)); xcmin(c) = min(x+slicepos(s));
              ycmax(c) = max(y+indpos(2)); ycmin(c) = min(y+indpos(2));
              zcmax(c) = max(z+indpos(3)); zcmin(c) = min(z+indpos(3));
            elseif oriY
              xcmax(c) = max(x+indpos(1)); xcmin(c) = min(x+indpos(1));
              ycmax(c) = max(y+slicepos(s)); ycmin(c) = min(y+slicepos(s));
              zcmax(c) = max(z+indpos(3)); zcmin(c) = min(z+indpos(3));
            elseif oriZ
              xcmax(c) = max(x+indpos(1)); xcmin(c) = min(x+indpos(1));
              ycmax(c) = max(y+indpos(2)); ycmin(c) = min(y+indpos(2));
              zcmax(c) = max(z+slicepos(s)); zcmin(c) = min(z+slicepos(s));
            end
            
          otherwise
            ft_error('unsupported cloudtype "%s"', cloudtype);
            
        end % switch cloudtype
      end % if distance < rmax(c)
    end % for each position
    
    if dointersect
      if oriX; ori = [1 0 0]; loc = [slicepos(s) 0 0]; end
      if oriY; ori = [0 1 0]; loc = [0 slicepos(s) 0]; end
      if oriZ; ori = [0 0 1]; loc = [0 0 slicepos(s)]; end
      
      % normalise the orientation vector to one
      ori = ori./sqrt(sum(ori.^2));
      
      % shift the location to be along the orientation vector
      loc = ori*dot(loc,ori);
      
      % determine three points on the plane
      inplane = eye(3) - (eye(3) * ori') * ori;
      v1 = loc + inplane(1,:);
      v2 = loc + inplane(2,:);
      v3 = loc + inplane(3,:);
      
      for k = 1:numel(meshplot)
        
        % only plot if the mesh actually intersects the plane
        xmmax = max(meshplot{k}.pos(:,1)); xmmin = min(meshplot{k}.pos(:,1));
        ymmax = max(meshplot{k}.pos(:,2)); ymmin = min(meshplot{k}.pos(:,2));
        zmmax = max(meshplot{k}.pos(:,3)); zmmin = min(meshplot{k}.pos(:,3));
        
        if oriX
          if slicepos(s) < xmmax && slicepos(s) > xmmin
            intersect_exists(s,k) = 1;
          else
            intersect_exists(s,k) = 0;
          end
        elseif oriY
          if slicepos(s) < ymmax && slicepos(s) > ymmin
            intersect_exists(s,k) = 1;
          else
            intersect_exists(s,k) = 0;
          end
        elseif oriZ
          if slicepos(s) < zmmax && slicepos(s) > zmmin
            intersect_exists(s,k) = 1;
          else
            intersect_exists(s,k) = 0;
          end
        end
        
        if intersect_exists(s,k)
          [xmesh, ymesh, zmesh] = intersect_plane(meshplot{k}.pos, meshplot{k}.tri, v1, v2, v3);
          
          % draw each individual line segment of the intersection
          if ~isempty(xmesh)
            p = patch(xmesh', ymesh', zmesh', nan(1, size(xmesh,1)));
            if ~isempty(intersectcolor),     set(p, 'EdgeColor', intersectcolor{k}); end
            if ~isempty(intersectlinewidth), set(p, 'LineWidth', intersectlinewidth(k)); end
            if ~isempty(intersectlinestyle), set(p, 'LineStyle', intersectlinestyle{k}); end
          end
          
          % find the limits of the lines and add them to the limits of the
          % interpolation to facilitate finding the limits of the slice
          xcmax(end+1) = max(xmesh(:)); xcmin(end+1) = min(xmesh(:));
          ycmax(end+1) = max(ymesh(:)); ycmin(end+1) = min(ymesh(:));
          zcmax(end+1) = max(zmesh(:)); zcmin(end+1) = min(zmesh(:));
        end
      end % for each mesh
    end % if dointersect
    
    % find limits of this particular slice
    xsmax(s) = max(xcmax); xsmin(s) = min(xcmin);
    ysmax(s) = max(ycmax); ysmin(s) = min(ycmin);
    zsmax(s) = max(zcmax); zsmin(s) = min(zcmin);
    
    % color settings
    colormap(cmap);
    if ~isempty(clim) && clim(2)>clim(1)
      caxis(gca, clim);
    end
    
    % axis and view settings
    set(gca, 'DataAspectRatio', [1 1 1])
    if oriX
      view([90 0]);
    elseif oriY
      view([180 0]);
    elseif oriZ
      view([90 90]);
    end
    
    % add title to differentiate slices
    if oriX; title(['slicepos = [' num2str(slicepos(s)) ' 0 0]']); end
    if oriY; title(['slicepos = [0 ' num2str(slicepos(s)) ' 0]']); end
    if oriZ; title(['slicepos = [0 0 ' num2str(slicepos(s)) ']']); end
  end
  
  % set matching limits in the non-slice dimensions for each slice
  for s = 1:numel(slicepos) % slice loop
    subplot(numel(slicepos),1,s);
    if oriX
      xlim([xsmin(s)-2 xsmax(s)+2]);
      ylim([min(ysmin)-2 max(ysmax)+2]);
      zlim([min(zsmin)-2 max(zsmax)+2]);
    elseif oriY
      xlim([min(xsmin)-2 max(xsmax)+2]);
      ylim([ysmin(s)-2 ysmax(s)+2]);
      zlim([min(zsmin)-2 max(zsmax)+2]);
    elseif oriZ
      xlim([min(xsmin)-2 max(xsmax)+2]);
      ylim([min(ysmin)-2 max(ysmax)+2]);
      zlim([zsmin(s)-2 zsmax(s)+2]);
    end
  end
  
else % plot 3d cloud
  hold on;
  for n = 1:size(pos,1) % cloud loop
    switch (cloudtype)
      case 'cloud'
        % point cloud with radius scaling
        rng(0, 'twister'); % random number generator
        npoints   = round(ptdensity*(4/3)*pi*rmax(n)^3);      % number of points based on cloud volume
        elevation = asin(2*rand(npoints,1)-1);                % elevation angle for each point
        azimuth   = 2*pi*rand(npoints,1);                     % azimuth angle for each point
        radii     = rmax(n)*(rand(npoints,1).^ptgradient);    % radius value for each point
        radii     = sort(radii);                              % sort radii in ascending order so they are plotted from inside out
        [x,y,z]   = sph2cart(azimuth, elevation, radii);      % convert to Carthesian
        
        % color axis with radius scaling
        if strcmp(colorgrad, 'white')                   % color runs up to white
          indx  = ceil(cmid) + sign(colscf(n))*floor(abs(colscf(n)*cmid));
          indx  = max(min(indx,size(cmapsc,1)),1);      % index should fall within the colormap
          fcol  = cmapsc(indx,:);                       % color [Nx3]
          ptcol = [linspace(fcol(1), 1, npoints)' linspace(fcol(2), 1, npoints)' linspace(fcol(3), 1, npoints)'];
        elseif isscalar(colorgrad)                      % color runs down towards colorbar middle
          rnorm = radii/rmax(n);                        % normalized radius
          if radscf(n)>=.5                              % extreme values
            ptcol = val(n) - (flip(1-rnorm).^inv(colorgrad))*val(n); % scaled fun [Nx1]
          elseif radscf(n)<.5                           % values closest to zero
            ptcol = val(n) + (flip(1-rnorm).^inv(colorgrad))*abs(val(n)); % scaled fun [Nx1]
          end
        else
          ft_error('color gradient should be either ''white'' or a scalar determining color falloff')
        end
        
        % draw the points
        scatter3(x+pos(n,1), y+pos(n,2), z+pos(n,3), ptsize, ptcol, '.');
        
      case 'surf'
        indx  = ceil(cmid) + sign(colscf(n))*floor(abs(colscf(n)*cmid));
        indx  = max(min(indx,size(cmapsc,1)),1);  % index should fall within the colormap
        fcol  = cmapsc(indx,:);                   % color [Nx3]
        [xsp, ysp, zsp] = sphere(100);
        hs = surf(rmax(n)*xsp+pos(n,1), rmax(n)*ysp+pos(n,2), rmax(n)*zsp+pos(n,3));
        set(hs, 'EdgeColor', 'none', 'FaceColor', fcol, 'FaceAlpha', 1);
        
      otherwise
        ft_error('unsupported cloudtype "%s"', cloudtype);
        
    end % switch cloudtype
  end % end cloud loop
  
  if ~isempty(meshplot)
    for k = 1:numel(meshplot) % mesh loop
      ft_plot_mesh(meshplot{k}, 'facecolor', facecolor{k}, 'EdgeColor', edgecolor{k}, ...
        'facealpha', facealpha(k), 'edgealpha', edgealpha(k), 'vertexcolor', vertexcolor{k});
      material dull
    end % end mesh loop
    
    if dointersect % plot the outlines on the mesh
      for s = 1:numel(slicepos) % slice loop
        if oriX; ori = [1 0 0]; loc = [slicepos(s) 0 0]; end
        if oriY; ori = [0 1 0]; loc = [0 slicepos(s) 0]; end
        if oriZ; ori = [0 0 1]; loc = [0 0 slicepos(s)]; end
        
        % normalise the orientation vector to one
        ori = ori./sqrt(sum(ori.^2));
        
        % shift the location to be along the orientation vector
        loc = ori*dot(loc,ori);
        
        % determine three points on the plane
        inplane = eye(3) - (eye(3) * ori') * ori;
        v1 = loc + inplane(1,:);
        v2 = loc + inplane(2,:);
        v3 = loc + inplane(3,:);
        
        for k = 1:numel(meshplot)
          
          % only plot if the mesh actually intersects the plane
          xmmax = max(meshplot{k}.pos(:,1)); xmmin = min(meshplot{k}.pos(:,1));
          ymmax = max(meshplot{k}.pos(:,2)); ymmin = min(meshplot{k}.pos(:,2));
          zmmax = max(meshplot{k}.pos(:,3)); zmmin = min(meshplot{k}.pos(:,3));
          
          if oriX
            if slicepos(s) < xmmax && slicepos(s) > xmmin
              intersect_exists(s,k) = 1;
            else
              intersect_exists(s,k) = 0;
            end
          elseif oriY
            if slicepos(s) < ymmax && slicepos(s) > ymmin
              intersect_exists(s,k) = 1;
            else
              intersect_exists(s,k) = 0;
            end
          elseif oriZ
            if slicepos(s) < zmmax && slicepos(s) > zmmin
              intersect_exists(s,k) = 1;
            else
              intersect_exists(s,k) = 0;
            end
          end
          
          if intersect_exists(s,k)
            [xmesh, ymesh, zmesh] = intersect_plane(meshplot{k}.pos, meshplot{k}.tri, v1, v2, v3);
            
            % draw each individual line segment of the intersection
            if ~isempty(xmesh)
              p = patch(xmesh', ymesh', zmesh', nan(1, size(xmesh,1)));
              if ~isempty(intersectcolor),     set(p, 'EdgeColor', intersectcolor{k}); end
              if ~isempty(intersectlinewidth), set(p, 'LineWidth', intersectlinewidth(k)); end
              if ~isempty(intersectlinestyle), set(p, 'LineStyle', intersectlinestyle{k}); end
            end
          end
        end % for each mesh
      end % for each slice
    end % if dointersect
  end % if plotting mesh
  
  % axis settings
  axis off
  axis vis3d
  axis equal
  
  % color settings
  colormap(cmap);
  if ~isempty(clim) && clim(2)>clim(1)
    caxis(gca, clim);
  end
end
                                                                                                                                                                                                                                                                                                                                                                                                                        'skull'))
        segmented.skull = skullmask;
        remove(strcmp(remove,'skull'))=[];
        if numel(outp)==1
          break
        end
      end
      
      % output: scalp (exclusive type)
      if numel(outp) > 1 && any(strcmp('scalp', outp))
        scalpmask(brainmask>0)=0;
        clear brainmask
        scalpmask(skullmask>0)=0;
        clear skullmask
        segmented.scalp=scalpmask;
        remove(strcmp(remove,'scalp'))=[];
        clear scalpmask
      end
    end
    
    createoutputs = false; % exit the while loop
  end % while createoutputs
  
else
  ft_error('unknown output %s requested\n', cfg.output{:});
end

% remove unnecessary fields
segmented = removefields(segmented, remove);

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous   mri
ft_postamble provenance segmented
ft_postamble history    segmented
ft_postamble savevar    segmented
                                                              sform_interactive = M;
      
      % touch it to survive trackconfig
      cfg.transform_interactive;
      
      % update the relevant geometrical info
      scalp  = ft_transform_geometry(M, scalp);
    end % dointeractive
    
    % always perform an icp-step, because this will give an estimate of the
    % initial distance of the corresponding points. depending on the value
    % for doicp, deal with the output differently
    if doicp
      numiter = 50;
    else
      numiter = 1;
    end
    
    if ~isfield(cfg, 'weights')
      w = ones(size(shape.pos,1),1);
    else
      w = cfg.weights(:);
      if numel(w)~=size(shape.pos,1)
        ft_error('number of weights should be equal to the number of points in the headshape');
      end
    end
    
    % the icp function wants this as a function handle.
    weights = @(x)assignweights(x,w);
    
    ft_hastoolbox('fileexchange',1);
    
    % construct the coregistration matrix
    nrm = normals(scalp.pos, scalp.tri, 'vertex');
    [R, t, err, dummy, info] = icp(scalp.pos', shape.pos', numiter, 'Minimize', 'plane', 'Normals', nrm', 'Weight', weights, 'Extrapolation', true, 'WorstRejection', 0.05);
    
    if doicp
      fprintf('doing iterative closest points realignment with headshape\n');
      % create the additional transformation matrix and compute the
      % distance between the corresponding points, both prior and after icp
      
      % this one transforms from scalp 'headspace' to shape 'headspace'
      M2 = inv([R t;0 0 0 1]);
      
      % warp the extracted scalp points to the new positions
      scalp.pos = ft_warp_apply(M2, scalp.pos);
      
      target        = scalp;
      target.pos    = target.pos;
      target.inside = (1:size(target.pos,1))';
      
      functional          = rmfield(shape, 'pos');
      functional.distance = info.distanceout(:);
      functional.pos      = info.qout';
      
      tmpcfg              = [];
      tmpcfg.parameter    = 'distance';
      tmpcfg.interpmethod = 'sphere_avg';
      tmpcfg.sphereradius = 10;
      tmpcfg.feedback     = 'none';
      smoothdist          = ft_sourceinterpolate(tmpcfg, functional, target);
      scalp.distance      = smoothdist.distance(:);
      
      functional.pow      = info.distancein(:);
      smoothdist          = ft_sourceinterpolate(tmpcfg, functional, target);
      scalp.distancein    = smoothdist.distance(:);
      
      cfg.icpinfo = info;
      cfg.transform_icp = M2;
      
      % touch it to survive trackconfig
      cfg.icpinfo;
      cfg.transform_icp;
    else
      % compute the distance between the corresponding points, prior to icp:
      % this corresponds to the final result after interactive only
      
      M2 = eye(4); % this is needed later on
      
      target        = scalp;
      target.pos    = target.pos;
      target.inside = (1:size(target.pos,1))';
      
      functional     = rmfield(shape, 'pos');
      functional.pow = info.distancein(:);
      functional.pos = info.qout';
      
      tmpcfg              = [];
      tmpcfg.parameter    = 'pow';
      tmpcfg.interpmethod = 'sphere_avg';
      tmpcfg.sphereradius = 10;
      smoothdist          = ft_sourceinterpolate(tmpcfg, functional, target);
      scalp.distance      = smoothdist.pow(:);
      
    end % doicp
    
    % create headshape structure for mri-based surface point cloud
    if isfield(mri, 'coordsys')
      scalp.coordsys = mri.coordsys;
      
      % coordsys is the same as input mri
      coordsys = mri.coordsys;
    else
      coordsys  = 'unknown';
    end
    
    % update the cfg
    cfg.headshape.headshape    = shape;
    cfg.headshape.headshapemri = scalp;
    
    % touch it to survive trackconfig
    cfg.headshape;
    
    if doicp && dointeractive
      transform = M2*M;
    elseif doicp
      transform = M2;
    elseif dointeractive
      transform = M;
    end
    
  case 'fsl'
    if ~isfield(cfg, 'fsl'), cfg.fsl = []; end
    cfg.fsl.path         = ft_getopt(cfg.fsl, 'path',         '');
    cfg.fsl.costfun      = ft_getopt(cfg.fsl, 'costfun',      'corratio');
    cfg.fsl.interpmethod = ft_getopt(cfg.fsl, 'interpmethod', 'trilinear');
    cfg.fsl.dof          = ft_getopt(cfg.fsl, 'dof',          6);
    cfg.fsl.reslice      = ft_getopt(cfg.fsl, 'reslice',      'yes');
    cfg.fsl.searchrange  = ft_getopt(cfg.fsl, 'searchrange',  [-180 180]);
    
    % write the input and target to a temporary file
    % and create some additional temporary file names to contain the output
    filename_mri    = tempname;
    filename_target = tempname;
    filename_output = tempname;
    filename_mat    = tempname;
    
    tmpcfg           = [];
    tmpcfg.parameter = 'anatomy';
    tmpcfg.filename  = filename_mri;
    tmpcfg.filetype  = 'nifti';
    fprintf('writing the input volume to a temporary file: %s\n', [filename_mri, '.nii']);
    ft_volumewrite(tmpcfg, mri);
    tmpcfg.filename  = filename_target;
    fprintf('writing the  target volume to a temporary file: %s\n', [filename_target, '.nii']);
    ft_volumewrite(tmpcfg, target);
    
    % create the command to call flirt
    fprintf('using flirt for the coregistration\n');
    r1  = num2str(cfg.fsl.searchrange(1));
    r2  = num2str(cfg.fsl.searchrange(2));
    str = sprintf('%s/flirt -in %s -ref %s -out %s -omat %s -bins 256 -cost %s -searchrx %s %s -searchry %s %s -searchrz %s %s -dof %s -interp %s',...
      cfg.fsl.path, filename_mri, filename_target, filename_output, filename_mat, cfg.fsl.costfun, r1, r2, r1, r2, r1, r2, num2str(cfg.fsl.dof), cfg.fsl.interpmethod);
    if isempty(cfg.fsl.path), str = str(2:end); end % remove the first filesep, assume path to flirt to be known
    
    % system call
    system(str);
    
    % process the output
    if ~istrue(cfg.fsl.reslice)
      % get the transformation that corresponds to the coregistration and
      % reconstruct the mapping from the target's world coordinate system
      % to the input's voxel coordinate system
      
      fid = fopen(filename_mat);
      flirtmat = textscan(fid, '%f');
      fclose(fid);
      
      % this contains the coregistration information in FSL convention
      flirtmat = reshape(flirtmat{1},4,4)';
      
      % The following chunck of code is from Ged Ridgway's
      % flirtmat2worldmat code
      % src = inv(flirtmat) * trg
      % srcvox = src.mat \ inv(flirtmat) * trg.mat * trgvox
      % BUT, flirt doesn't use src.mat, only absolute values of the 
      % scaling elements from it,
      % AND, if images are not radiological, the x-axis is flipped, see:
      %  https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind0810&L=FSL&P=185638
      %  https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind0903&L=FSL&P=R93775
      scl_target = diag([sqrt(sum(target.transform(1:3,1:3).^2)) 1]);
      if det(target.transform(1:3,1:3)) > 0
        % neurological, x-axis is flipped, such that [3 2 1 0] and [0 1 2 3]
        % have the same *scaled* coordinates:
        xflip       = diag([-1 1 1 1]);
        xflip(1, 4) = target.dim(1)-1; % reflect about centre
        scl_target = scl_target * xflip;
      end
      scl_mri    = diag([sqrt(sum(mri.transform(1:3,1:3).^2))    1]);
      if det(mri.transform(1:3,1:3)) > 0
        % neurological, x-axis is flipped, such that [3 2 1 0] and [0 1 2 3]
        % have the same *scaled* coordinates:
        xflip       = diag([-1 1 1 1]);
        xflip(1, 4) = mri.dim(1)-1; % reflect about centre
        scl_mri     = scl_mri * xflip;
      end
      % AND, Flirt's voxels are zero-based, while SPM's are one-based...
      addone = eye(4);
      addone(:, 4) = 1;
      
      fslvoxmat  = inv(scl_mri) * inv(flirtmat) * scl_target;
      spmvoxmat  = addone * (fslvoxmat / addone);
      target2mri = mri.transform * (spmvoxmat / target.transform);
      transform  = inv(target2mri); 

      if isfield(target, 'coordsys')
        coordsys = target.coordsys;
      else
        coordsys = 'unknown';
      end
      
    else
      % get the updated anatomy
      mrinew        = ft_read_mri([filename_output, '.nii.gz']);
      mri.anatomy   = mrinew.anatomy;
      mri.transform = mrinew.transform;
      mri.dim       = mrinew.dim;
      
      transform = eye(4);
      if isfield(target, 'coordsys')
        coordsys = target.coordsys;
      else
        coordsys = 'unknown';
      end
    end
    delete([filename_mri,    '.nii']);
    delete([filename_target, '.nii']);
    delete([filename_output, '.nii.gz']);
    delete(filename_mat);
    
  case 'spm'
    % check that the preferred SPM version is on the path
    ft_hastoolbox(cfg.spmversion, 1);
    
    if strcmpi(cfg.spmversion, 'spm2') || strcmpi(cfg.spmversion, 'spm8')
      
      if ~isfield(cfg, 'spm'), cfg.spm = []; end
      cfg.spm.regtype = ft_getopt(cfg.spm, 'regtype', 'subj');
      cfg.spm.smosrc  = ft_getopt(cfg.spm, 'smosrc',  2);
      cfg.spm.smoref  = ft_getopt(cfg.spm, 'smoref',  2);
      
      if ~isfield(mri,    'coordsys')
        mri = ft_determine_coordsys(mri);
      else
        fprintf('Input volume has coordinate system ''%s''\n', mri.coordsys);
      end
      if ~isfield(target, 'coordsys')
        target = ft_determine_coordsys(target);
      else
        fprintf('Target volume has coordinate system ''%s''\n', target.coordsys);
      end
      if strcmp(mri.coordsys, target.coordsys)
        % this should hopefully work
      else
        % only works when it is possible to approximately align the input to the target coordsys
        if strcmp(target.coordsys, 'acpc')
          mri = ft_convert_coordsys(mri, 'acpc');
        else
          ft_error('The coordinate systems of the input and target volumes are different, coregistration is not possible');
        end
      end
      
      % flip and permute the 3D volume itself, so that the voxel and
      % headcoordinates approximately correspond
      [tmp,    pvec_mri,    flip_mri, T] = align_ijk2xyz(mri);
      [target]                           = align_ijk2xyz(target);
      
      tname1 = [tempname, '.img'];
      tname2 = [tempname, '.img'];
      V1 = ft_write_mri(tname1, mri.anatomy,    'transform', mri.transform,    'spmversion', spm('ver'), 'dataformat', 'nifti_spm');
      V2 = ft_write_mri(tname2, target.anatomy, 'transform', target.transform, 'spmversion', spm('ver'), 'dataformat', 'nifti_spm');
      
      flags         = cfg.spm;
      flags.nits    = 0; %set number of non-linear iterations to zero
      params        = spm_normalise(V2,V1, [], [], [],flags);
      %mri.transform = (target.transform/params.Affine)/T;
      transform     = (target.transform/params.Affine)/T/mri.transform;
      % transform     = eye(4);
      
    elseif strcmpi(cfg.spmversion, 'spm12')
      
      if ~isfield(cfg, 'spm'), cfg.spm = []; end
      
      tname1 = [tempname, '.nii'];
      tname2 = [tempname, '.nii'];
      V1 = ft_write_mri(tname1, mri.anatomy, 'transform', mri.transform, 'spmversion', spm('ver'), 'dataformat', 'nifti_spm'); % source (moved) image
      V2 = ft_write_mri(tname2, target.anatomy, 'transform', target.transform, 'spmversion', spm('ver'), 'dataformat', 'nifti_spm'); % reference image
      
      flags         = cfg.spm;
      x             = spm_coreg(V2,V1,flags); % spm_realign does within modality rigid body movement parameter estimation
      transform     = inv(spm_matrix(x(:)')); % from V1 to V2, to be multiplied still with the original transform (mri.transform), see below
      
    end
    
    if isfield(target, 'coordsys')
      coordsys = target.coordsys;
    else
      coordsys = 'unknown';
    end
    
    % delete the temporary files
    delete(tname1);
    delete(tname2);
  otherwise
    ft_error('unsupported method "%s"', cfg.method);
end

if any(strcmp(cfg.method, {'fiducial', 'interactive'}))
  
  % the fiducial locations are specified in voxels, convert them to head
  % coordinates according to the existing transform matrix
  fid1_vox  = cfg.fiducial.(fidlabel{1});
  fid2_vox  = cfg.fiducial.(fidlabel{2});
  fid3_vox  = cfg.fiducial.(fidlabel{3});
  fid1_head = ft_warp_apply(mri.transform, fid1_vox);
  fid2_head = ft_warp_apply(mri.transform, fid2_vox);
  fid3_head = ft_warp_apply(mri.transform, fid3_vox);
  
  if length(fidlabel)>3
    % the 4th point is optional
    fid4_vox  = cfg.fiducial.(fidlabel{4});
    fid4_head = ft_warp_apply(mri.transform, fid4_vox);
  else
    fid4_head = [nan nan nan];
  end
  
  if ~any(isnan(fid4_head))
    [transform, coordsys] = ft_headcoordinates(fid1_head, fid2_head, fid3_head, fid4_head, cfg.coordsys);
  else
    [transform, coordsys] = ft_headcoordinates(fid1_head, fid2_head, fid3_head, cfg.coordsys);
  end
end

% copy the input anatomical or functional volume
realign = mri;

if ~isempty(transform) && ~any(isnan(transform(:)))
  % combine the additional transformation with the original one
  realign.transformorig = mri.transform;
  realign.transform     = transform * mri.transform;
  realign.coordsys      = coordsys;
else
  ft_warning('no coordinate system realignment has been done');
end

% visualize result
% all plotting for the realignment is done in voxel space
% for view the results however, it needs be in coordinate system space (necessary for the two volume case below)
% to be able to reuse all the plotting code, several workarounds are in place, which convert the indices
% from voxel space to the target coordinate system space
if viewresult
  % set flags for one or twovol case
  if hastarget
    twovol  = true; % input was two volumes, base to be plotted on is called target, the aligned mri is named realign
    basevol = target;
  else
    twovol  = false; % input was one volumes, base is called realign
    basevol = realign;
  end
  
  
  % input was a single vol
  % start building the figure
  h = figure('numbertitle', 'off', 'name', 'realignment result');
  set(h, 'visible', 'on');
  
  % axes settings
  if strcmp(cfg.axisratio, 'voxel')
    % determine the number of voxels to be plotted along each axis
    axlen1 = basevol.dim(1);
    axlen2 = basevol.dim(2);
    axlen3 = basevol.dim(3);
  elseif strcmp(cfg.axisratio, 'data')
    % determine the length of the edges along each axis
    [cp_voxel, cp_head] = cornerpoints(basevol.dim, basevol.transform);
    axlen1 = norm(cp_head(2,:)-cp_head(1,:));
    axlen2 = norm(cp_head(4,:)-cp_head(1,:));
    axlen3 = norm(cp_head(5,:)-cp_head(1,:));
  elseif strcmp(cfg.axisratio, 'square')
    % the length of the axes should be equal
    axlen1 = 1;
    axlen2 = 1;
    axlen3 = 1;
  end
  
  % this is the size reserved for subplot h1, h2 and h3
  h1size(1) = 0.82*axlen1/(axlen1 + axlen2);
  h1size(2) = 0.82*axlen3/(axlen2 + axlen3);
  h2size(1) = 0.82*axlen2/(axlen1 + axlen2);
  h2size(2) = 0.82*axlen3/(axlen2 + axlen3);
  h3size(1) = 0.82*axlen1/(axlen1 + axlen2);
  h3size(2) = 0.82*axlen2/(axlen2 + axlen3);
  
  if strcmp(cfg.voxelratio, 'square')
    voxlen1 = 1;
    voxlen2 = 1;
    voxlen3 = 1;
  elseif strcmp(cfg.voxelratio, 'data')
    % the size of the voxel is scaled with the data
    [cp_voxel, cp_head] = cornerpoints(basevol.dim, basevol.transform);
    voxlen1 = norm(cp_head(2,:)-cp_head(1,:))/norm(cp_voxel(2,:)-cp_voxel(1,:));
    voxlen2 = norm(cp_head(4,:)-cp_head(1,:))/norm(cp_voxel(4,:)-cp_voxel(1,:));
    voxlen3 = norm(cp_head(5,:)-cp_head(1,:))/norm(cp_voxel(5,:)-cp_voxel(1,:));
  end
  
  %% the figure is interactive, add callbacks
  set(h, 'windowbuttondownfcn', @cb_buttonpress);
  set(h, 'windowbuttonupfcn',   @cb_buttonrelease);
  set(h, 'windowkeypressfcn',   @cb_keyboard);
  set(h, 'CloseRequestFcn',     @cb_quit);
  
  % axis handles will hold the anatomical functional if present, along with labels etc.
  h1 = axes('position', [0.06                0.06+0.06+h3size(2) h1size(1) h1size(2)]);
  h2 = axes('position', [0.06+0.06+h1size(1) 0.06+0.06+h3size(2) h2size(1) h2size(2)]);
  h3 = axes('position', [0.06                0.06                h3size(1) h3size(2)]);
  
  set(h1, 'Tag', 'ij', 'Visible', 'off', 'XAxisLocation', 'top');
  set(h2, 'Tag', 'jk', 'Visible', 'off', 'YAxisLocation', 'right'); % after rotating in ft_plot_ortho this becomes top
  set(h3, 'Tag', 'ik', 'Visible', 'off');
  
  set(h1, 'DataAspectRatio', 1./[voxlen1 voxlen2 voxlen3]);
  set(h2, 'DataAspectRatio', 1./[voxlen1 voxlen2 voxlen3]);
  set(h3, 'DataAspectRatio', 1./[voxlen1 voxlen2 voxlen3]);
  
  % start with center view
  xc = round(basevol.dim(1)/2);
  yc = round(basevol.dim(2)/2);
  zc = round(basevol.dim(3)/2);
  
  % normalize data to go from 0 to 1
  dat = double(basevol.(cfg.parameter));
  dmin = min(dat(:));
  dmax = max(dat(:));
  dat  = (dat-dmin)./(dmax-dmin);
  if hastarget % do the same for the target
    realigndat = double(realign.(cfg.parameter));
    dmin = min(realigndat(:));
    dmax = max(realigndat(:));
    realigndat  = (realigndat-dmin)./(dmax-dmin);
  end
  
  if isfield(cfg, 'pnt')
    pnt = cfg.pnt;
  else
    pnt = zeros(0,3);
  end
  markerpos   = zeros(0,3);
  markerlabel = {};
  markercolor = {};
  
  % determine clim if empty (setting to [0 1] could be done at the top, but not sure yet if it interacts with the other visualizations -roevdmei)
  if isempty(cfg.clim)
    cfg.clim = [min(dat(:)) min([.5 max(dat(:))])]; %
  end
  
  % determine apprioriate [left bottom width height] of intensity range sliders
  posbase = [];
  posbase(1) = h1size(1) + h2size(1)/2 + 0.06*2; % horizontal center of the second plot
  posbase(2) = h3size(2)/2 + 0.06; % vertical center of the third plot
  posbase(3) = 0.01; % width of the sliders is not so important, if it falls below a certain value, it's a vertical slider, otherwise a horizontal one
  posbase(4) = h3size(2)/3 + 0.06; % a third of the height of the third plot
  %
  posh45text = [posbase(1)-posbase(3)*5 posbase(2)-.1 posbase(3)*10 posbase(4)+0.07];
  posh4text  = [posbase(1)-.04-posbase(3)*2 posbase(2)-.1 posbase(3)*5 posbase(4)+0.035];
  posh5text  = [posbase(1)+.04-posbase(3)*2 posbase(2)-.1 posbase(3)*5 posbase(4)+0.035];
  posh4slid  = [posbase(1)-.04 posbase(2)-.1 posbase(3) posbase(4)];
  posh5slid  = [posbase(1)+.04 posbase(2)-.1 posbase(3) posbase(4)];
  
  % intensity range sliders
  if twovol
    h45texttar = uicontrol('Style', 'text',...
      'String', 'Intensity target volume (red)',...
      'Units', 'normalized', ...
      'Position',posh45text,...
      'HandleVisibility', 'on');
    
    h4texttar = uicontrol('Style', 'text',...
      'String', 'Min',...
      'Units', 'normalized', ...
      'Position',posh4text,...
      'HandleVisibility', 'on');
    
    h5texttar = uicontrol('Style', 'text',...
      'String', 'Max',...
      'Units', 'normalized', ...
      'Position',posh5text,...
      'HandleVisibility', 'on');
    
    h4tar = uicontrol('Style', 'slider', ...
      'Parent', h, ...
      'Min', 0, 'Max', 1, ...
      'Value', cfg.clim(1), ...
      'Units', 'normalized', ...
      'Position', posh4slid, ...
      'Callback', @cb_minslider,...
      'tag', 'tar');
    
    h5tar = uicontrol('Style', 'slider', ...
      'Parent', h, ...
      'Min', 0, 'Max', 1, ...
      'Value', cfg.clim(2), ...
      'Units', 'normalized', ...
      'Position', posh5slid, ...
      'Callback', @cb_maxslider,...
      'tag', 'tar');
  end
  
  % intensity range sliders
  if ~twovol
    str = 'Intensity realigned volume';
  else
    str = 'Intensity realigned volume (blue)';
  end
  h45textrel = uicontrol('Style', 'text',...
    'String',str,...
    'Units', 'normalized', ...
    'Position',posh45text,...
    'HandleVisibility', 'on');
  
  h4textrel = uicontrol('Style', 'text',...
    'String', 'Min',...
    'Units', 'normalized', ...
    'Position',posh4text,...
    'HandleVisibility', 'on');
  
  h5textrel = uicontrol('Style', 'text',...
    'String', 'Max',...
    'Units', 'normalized', ...
    'Position',posh5text,...
    'HandleVisibility', 'on');
  
  h4rel = uicontrol('Style', 'slider', ...
    'Parent', h, ...
    'Min', 0, 'Max', 1, ...
    'Value', cfg.clim(1), ...
    'Units', 'normalized', ...
    'Position', posh4slid, ...
    'Callback', @cb_minslider,...
    'tag', 'rel');
  
  h5rel = uicontrol('Style', 'slider', ...
    'Parent', h, ...
    'Min', 0, 'Max', 1, ...
    'Value', cfg.clim(2), ...
    'Units', 'normalized', ...
    'Position', posh5slid, ...
    'Callback', @cb_maxslider,...
    'tag', 'rel');
  
  % create structure to be passed to gui
  opt               = [];
  opt.twovol        = twovol;
  opt.viewresult    = true; % flag to use for certain keyboard/redraw calls
  opt.dim           = basevol.dim;
  opt.ijk           = [xc yc zc];
  opt.h1size        = h1size;
  opt.h2size        = h2size;
  opt.h3size        = h3size;
  opt.handlesaxes   = [h1 h2 h3];
  opt.handlesfigure = h;
  opt.quit          = false;
  opt.ana           = dat; % keep this as is, to avoid making exceptions for opt.viewresult all over the plotting code
  if twovol
    opt.realignana  = realigndat;
    % set up the masks in an intelligent way based on the percentile of the anatomy (this avoids extremely skewed data making one of the vols too transparent)
    sortana = sort(dat(:));
    cutoff  = sortana(find(cumsum(sortana ./ sum(sortana(:)))>.99,1));
    mask    = dat;
    mask(mask>cutoff) = cutoff;
    mask    = (mask ./ cutoff) .* .5;
    opt.targetmask = mask;
    sortana = sort(realigndat(:));
    cutoff  = sortana(find(cumsum(sortana ./ sum(sortana(:)))>.99,1));
    mask    = realigndat;
    mask(mask>cutoff) = cutoff;
    mask    = (mask ./ cutoff) .* .5;
    opt.realignmask = mask;
  end
  opt.update        = [1 1 1];
  opt.init          = true;
  opt.tag           = 'ik';
  opt.mri           = basevol;
  if twovol
    opt.realignvol  = realign;
  end
  opt.showcrosshair = true;
  opt.showmarkers   = false;
  opt.markers       = {markerpos markerlabel markercolor};
  if ~twovol
    opt.realignclim = cfg.clim;
  else
    opt.realignclim = cfg.clim;
    opt.targetclim  = cfg.clim;
  end
  opt.fiducial      = [];
  opt.fidlabel      = [];
  opt.fidletter     = [];
  opt.pnt           = pnt;
  if isfield(mri, 'unit') && ~strcmp(mri.unit, 'unknown')
    opt.unit = mri.unit;  % this is shown in the feedback on screen
  else
    opt.unit = '';        % this is not shown
  end
  
  % add to figure and start initial draw
  setappdata(h, 'opt', opt);
  cb_redraw(h);
  
end


% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous   mri
ft_postamble provenance realign
ft_postamble history    realign
ft_postamble savevar    realign

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = assignweights(x, w)

% x is an indexing vector with the same number of arguments as w
y = w(:)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_redraw_surface(h, eventdata)
h   = getparent(h);
opt = getappdata(h, 'opt');

markercolor = {'r', 'g', 'b', 'y'};

if opt.init
  ft_plot_mesh(opt.scalp, 'edgecolor', 'none', 'facecolor', 'skin')
  hold on
end

% recreate the camera lighting
delete(opt.camlighthandle);
opt.camlighthandle = camlight;

% remove the previous fiducials
delete(opt.handlesmarker(opt.handlesmarker(:)>0));
opt.handlesmarker = [];

% redraw the fiducials
for i=1:length(opt.fidlabel)
  lab = opt.fidlabel{i};
  pos = ft_warp_apply(opt.mri.transform, opt.fiducial.(lab));
  if all(~isnan(pos))
    opt.handlesmarker(i,1) = plot3(pos(1), pos(2), pos(3), 'marker', 'o', 'color', markercolor{i});
    opt.handlesmarker(i,2) = text(pos(1), pos(2), pos(3), lab);
  end
end

opt.init = false;
setappdata(h, 'opt', opt);
uiresume

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_keyboard_surface(h, eventdata)
h   = getparent(h);
opt = getappdata(h, 'opt');

if isempty(eventdata)
  % determine the key that corresponds to the uicontrol element that was activated
  key = get(h, 'userdata');
else
  % determine the key that was pressed on the keyboard
  key = parsekeyboardevent(eventdata);
end

% get the most recent surface position that was clicked with the mouse
pos = select3d(opt.handlesaxes);

sel = find(strcmp(opt.fidletter, key));
if ~isempty(sel)
  % update the corresponding fiducial
  opt.fiducial.(opt.fidlabel{sel}) = ft_warp_apply(inv(opt.mri.transform), pos(:)');
end

fprintf('==================================================================================\n');
for i=1:length(opt.fidlabel)
  lab = opt.fidlabel{i};
  vox = opt.fiducial.(lab);
  ind = sub2ind(opt.mri.dim(1:3), round(vox(1)), round(vox(2)), round(vox(3)));
  pos = ft_warp_apply(opt.mri.transform, vox);
  switch opt.unit
    case 'mm'
      fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.1f %.1f %.1f] %s\n', lab, ind, round(vox), pos, opt.unit);
    case 'cm'
      fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.2f %.2f %.2f] %s\n', lab, ind, round(vox), pos, opt.unit);
    case 'm'
      fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.4f %.4f %.4f] %s\n', lab, ind, round(vox), pos, opt.unit);
    otherwise
      fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%f %f %f] %s\n', lab, ind, round(vox), pos, opt.unit);
  end
end

setappdata(h, 'opt', opt);

if isequal(key, 'q')
  cb_quit(h);
else
  cb_redraw_surface(h);
end

uiresume(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_redraw(h, eventdata)
h   = getparent(h);
opt = getappdata(h, 'opt');

curr_ax = get(h, 'currentaxes');
tag = get(curr_ax, 'tag');

mri = opt.mri;

h1 = opt.handlesaxes(1);
h2 = opt.handlesaxes(2);
h3 = opt.handlesaxes(3);

% extract to-be-plotted/clicked location and check whether inside figure
xi = opt.ijk(1);
yi = opt.ijk(2);
zi = opt.ijk(3);
if any([xi yi zi] > mri.dim) || any([xi yi zi] <= 0)
  return;
end

% transform here to coordinate system space instead of voxel space if viewing results
% the code were this transform will impact fiducial/etc coordinates is unaffected, as it is switched off
% (note: fiducial/etc coordinates are transformed into coordinate space in the code dealing with realignment)
if opt.viewresult
  tmp = ft_warp_apply(mri.transform, [xi yi zi]);
  xi = tmp(1);
  yi = tmp(2);
  zi = tmp(3);
end

if opt.init
  % create the initial figure
  if ~opt.viewresult
    % if realigning, plotting is done in voxel space
    ft_plot_ortho(opt.ana, 'transform', eye(4), 'location', [xi yi zi], 'style', 'subplot', 'parents', [h1 h2 h3], 'update', opt.update, 'doscale', false, 'clim', opt.clim);
  else
    % if viewing result, plotting is done in head coordinate system space
    if ~opt.twovol
      % one vol case
      ft_plot_ortho(opt.ana, 'transform', mri.transform, 'location', [xi yi zi], 'style', 'subplot', 'parents', [h1 h2 h3], 'update', opt.update, 'doscale', false, 'clim', opt.realignclim);
    else
      % two vol case
      % base volume, with color red
      hbase = []; % need the handle for the individual surfs
      [hbase(1), hbase(2), hbase(3)] = ft_plot_ortho(opt.ana, 'transform', mri.transform, 'unit', mri.unit, 'location', [xi yi zi], 'style', 'subplot', 'parents', [h1 h2 h3], 'update', opt.update, 'doscale', false, 'clim', opt.targetclim, 'datmask',opt.targetmask, 'opacitylim', [0 1]);
      for ih = 1:3
        col = get(hbase(ih), 'CData');
        col(:,:,2:3) = 0;
        set(hbase(ih), 'CData',col);
      end
      % aligned volume, with color blue
      hreal = []; % need the handle for the individual surfs
      [hreal(1), hreal(2), hreal(3)] = ft_plot_ortho(opt.realignana, 'transform', opt.realignvol.transform, 'unit', opt.realignvol.unit, 'location', [xi yi zi], 'style', 'subplot', 'parents', [h1 h2 h3], 'update', opt.update, 'doscale', false, 'clim', opt.realignclim, 'datmask',opt.realignmask, 'opacitylim', [0 1]);
      for ih = 1:3
        col = get(hreal(ih), 'CData');
        col(:,:,1:2) = 0;
        set(hreal(ih), 'CData',col);
      end
    end
  end % if ~opt.viewresult
  
  % fetch surf objects, set ana tag, and put in surfhandles
  if ~opt.viewresult || (opt.viewresult && ~opt.twovol)
    opt.anahandles = findobj(opt.handlesfigure, 'type', 'surface')';
    parenttag = get(opt.anahandles, 'parent');
    parenttag{1} = get(parenttag{1}, 'tag');
    parenttag{2} = get(parenttag{2}, 'tag');
    parenttag{3} = get(parenttag{3}, 'tag');
    [i1,i2,i3] = intersect(parenttag, {'ik';'jk';'ij'});
    opt.anahandles = opt.anahandles(i3(i2)); % seems like swapping the order
    opt.anahandles = opt.anahandles(:)';
    set(opt.anahandles, 'tag', 'ana');
  else
    % this should do the same as the above
    set(hbase, 'tag', 'ana');
    set(hreal, 'tag', 'ana');
    opt.anahandles = {hbase, hreal};
  end
else
  % update the existing figure
  if ~opt.viewresult
    % if realigning, plotting is done in voxel space
    ft_plot_ortho(opt.ana, 'transform', eye(4), 'location', [xi yi zi], 'style', 'subplot', 'surfhandle', opt.anahandles, 'update', opt.update, 'doscale', false, 'clim', opt.clim);
  else
    % if viewing result, plotting is done in head coordinate system space
    if ~opt.twovol
      % one vol case
      ft_plot_ortho(opt.ana, 'transform', mri.transform, 'unit', mri.unit, 'location', [xi yi zi], 'style', 'subplot', 'surfhandle', opt.anahandles, 'update', opt.update, 'doscale', false, 'clim', opt.realignclim);
    else
      % two vol case
      % base volume, with color red
      hbase = []; % need the handle for the individual surfs
      [hbase(1), hbase(2), hbase(3)] = ft_plot_ortho(opt.ana, 'transform', mri.transform, 'unit', mri.unit, 'location', [xi yi zi], 'style', 'subplot', 'surfhandle', opt.anahandles{1}, 'update', opt.update, 'doscale', false, 'clim', opt.targetclim, 'datmask', opt.targetmask, 'opacitylim', [0 1]);
      for ih = 1:3
        col = get(hbase(ih), 'CData');
        col(:,:,2:3) = 0;
        set(hbase(ih), 'CData', col);
      end
      % aligned volume, with color blue
      hreal = []; % need the handle for the individual surfs
      [hreal(1), hreal(2), hreal(3)] = ft_plot_ortho(opt.realignana, 'transform', opt.realignvol.transform, 'unit', opt.realignvol.unit, 'location', [xi yi zi], 'style', 'subplot', 'surfhandle', opt.anahandles{2}, 'update', opt.update, 'doscale', false, 'clim', opt.realignclim, 'datmask', opt.realignmask, 'opacitylim', [0 1]);
      for ih = 1:3
        col = get(hreal(ih), 'CData');
        col(:,:,1:2) = 0;
        set(hreal(ih), 'CData', col);
      end
    end
  end % if ~opt.viewresult
  
  % display current location
  if ~opt.viewresult
    % if realigning, plotting is done in voxel space
    if all(round([xi yi zi])<=mri.dim) && all(round([xi yi zi])>0)
      fprintf('==================================================================================\n');
      
      lab = 'crosshair';
      vox = [xi yi zi];
      ind = sub2ind(mri.dim(1:3), round(vox(1)), round(vox(2)), round(vox(3)));
      pos = ft_warp_apply(mri.transform, vox);
      switch opt.unit
        case 'mm'
          fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.1f %.1f %.1f] %s\n', lab, ind, vox, pos, opt.unit);
        case 'cm'
          fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.2f %.2f %.2f] %s\n', lab, ind, vox, pos, opt.unit);
        case 'm'
          fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%.4f %.4f %.4f] %s\n', lab, ind, vox, pos, opt.unit);
        otherwise
          fprintf('%10s: voxel %9d, index = [%3d %3d %3d], head = [%f %f %f] %s\n', lab, ind, vox, pos, opt.unit);
      end
    end
    
    for i=1:length(opt.fidlabel)
      lab = opt.fidlabel{i};
      vox = opt.fiducial.(lab);
      ind = sub2ind(mri.dim(1:3), round(vox(1)), round(vox(2)), r