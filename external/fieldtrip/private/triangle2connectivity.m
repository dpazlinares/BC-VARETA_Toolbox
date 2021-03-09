function [connmat] = triangle2connectivity(tri, pos)

% TRIANGLE2CONNECTIVITY computes a connectivity-matrix from a triangulation.
%
% Use as
%  [connmat] = triangle2connectivity(tri)
% or
%  [connmat] = triangle2connectivity(tri, pos)
%
% The input tri is an Mx3 matrix describing a triangulated surface,
% containing indices to connecting vertices. The output connmat is a sparse
% logical NxN matrix, with ones, where vertices are connected, and zeros
% otherwise.
%
% If you specify the vertex positions in the second input argument as Nx3
% matrix, the output will be a sparse matrix with the lengths of the
% edges between the connected vertices.

% Copyright (C) 2015, Jan-Mathijs Schoffelen
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

% ensure that the vertices are indexed starting from 1
if min(tri(:))==0,
  tri = tri + 1;
end

% ensure that the vertices are indexed according to 1:number of unique vertices
tri = tri_reindex(tri);

% create the unique edges from the triangulation
edges  = [tri(:,[1 2]); tri(:,[1 3]); tri(:,[2 3])];
edges  = double(unique(sort([edges; edges(:,[2 1])],2), 'rows'));

% fill the connectivity matrix
n        = size(edges,1);
if nargin<2
  % create sparse binary matrix
  connmat = sparse([edges(:,1);edges(:,2)],[edges(:,2);edges(:,1)],true(2*n,1));
else
  % create sparse matrix with edge lengths
  dpos    = sqrt(sum( (pos(edges(:,1),:) - pos(edges(:,2),:)).^2, 2));
  connmat = sparse([edges(:,1);edges(:,2)],[edges(:,2);edges(:,1)],[dpos(:);dpos(:)]);
end

function [newtri] = tri_reindex(tri)

% this subfunction reindexes tri such that they run from 1:number of unique vertices
newtri       = tri;
[srt, indx]  = sort(tri(:));
tmp          = cumsum(double(diff([0;srt])>0));
newtri(indx) = tmp;
                                                                                   ore weight the
  % Nyquist bin with a factor of sqrt(2) to get a correct two-sided representation
  if mod(size(Harr,3),2)==0
    Harr(:,:,N) = Harr(:,:,N).*sqrt(2);
  end
  
  % invert the transfer matrix to get the fourier representation of the
  % coefficients, and add an identity matrix 
  I = eye(siz(1));
  for k = 1:size(Harr,3)
    Harr(:,:,k) = I-inv(Harr(:,:,k));
  end
  
  % take the inverse fft to get the coefficients
  A = ifft(reshape(permute(Harr, [3 1 2]), N2, []), 'symmetric');
  A = A(2:end,:);
  A = ipermute(reshape(A, [N2-1 siz(1) siz(1)]), [3 1 2]);
  
  if ~isempty(maxlag)
    A = A(:,:,1:maxlag);
  end
else
  % check whether the last frequency bin is strictly real-valued.
  % if that's the case, then it is assumed to be the Nyquist frequency
  % and the two-sided spectral density will have an even number of
  % frequency bins. if not, in order to preserve hermitian symmetry,
  % the number of frequency bins needs to be odd.
  Hend = H(:,end);
  N    = numel(freq);
  m    = size(H,1);
  if all(imag(Hend(:))<max(abs(Hend))*1e-9)
    % the above heuristic may be a bit silly, FIXME
    N2 = 2*(N-1);
  else
    N2 = 2*(N-1)+1;
  end

  % preallocate memory for efficiency
  Harr   = zeros(m,N2) + 1i.*zeros(m,N2);

  % the input cross-spectral density is assumed to be weighted with a
  % factor of 2 in all non-DC and Nyquist bins, therefore weight the
  % DC-bin with a factor of sqrt(2) to get a correct two-sided representation
  Harr(:,1) = H(:,1).*sqrt(2);
  for k = 2:N
    Harr(:,       k) = H(:,k);
    Harr(:,(N2+2)-k) = conj(H(:,k));
  end
  
  % the input cross-spectral density is assumed to be weighted with a
  % factor of 2 in all non-DC and Nyquist bins, therefore weight the
  % Nyquist bin with a factor of sqrt(2) to get a correct two-sided representation
  if mod(size(Harr,3),2)==0
    Harr(:,N) = Harr(:,N).*sqrt(2);
  end
  
  % invert the transfer matrix to get the fourier representation of the
  % coefficients, and add an identity matrix 
  %
  % this assumes Harr to be in the rows quadruplets of pairwise
  % decompositions, i.e. reshapable, without checking the labelcmb
  ncmb = size(Harr,1)./4;
  I = eye(2);
  for k = 1:N2
    Htmp = reshape(Harr(:,k), [2 2 ncmb]);
    Htmp = repmat(I, [1 1 ncmb]) - inv2x2(Htmp);
    Harr(:,k) = Htmp(:);
  end
    
  % take the inverse fft to get the coefficients
  A = ifft(permute(Harr, [2 1]), 'symmetric');
  A = A(2:end,:);
  A = ipermute(A, [2 1]);
  
  if ~isempty(maxlag)
    A = A(:,1:maxlag);
  end

end
                                         ',     {'hlcolor',       'highlightcolor'});
cfg = ft_checkconfig(cfg, 'renamed',     {'hlmarkersize',  'highlightsize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'maplimits',     'zlim'});
% old ft_checkconfig adapted partially from topoplot.m (backwards backwards compatability)
cfg = ft_checkconfig(cfg, 'renamed',     {'grid_scale',    'gridscale'});
cfg = ft_checkconfig(cfg, 'renamed',     {'interpolate',   'interpolation'});
cfg = ft_checkconfig(cfg, 'renamed',     {'numcontour',    'contournum'});
cfg = ft_checkconfig(cfg, 'renamed',     {'electrod',      'marker'});
cfg = ft_checkconfig(cfg, 'renamed',     {'electcolor',    'markercolor'});
cfg = ft_checkconfig(cfg, 'renamed',     {'emsize',        'markersize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'efsize',        'markerfontsize'});
cfg = ft_checkconfig(cfg, 'renamed',     {'headlimits',    'interplimits'});
% check for forbidden options
cfg = ft_checkconfig(cfg, 'forbidden',  {'hllinewidth', ...
  'headcolor', ...
  'hcolor', ...
  'hlinewidth', ...
  'contcolor', ...
  'outline', ...
  'highlightfacecolor', ...
  'showlabels'});

if ft_platform_supports('griddata-v4')
  default_interpmethod = 'v4';
else
  % Octave does not support 'v4', and 'cubic' not yet implemented
  default_interpmethod = 'linear';
end

% Set other config defaults
cfg.xlim              = ft_getopt(cfg, 'xlim',             'maxmin');
cfg.ylim              = ft_getopt(cfg, 'ylim',             'maxmin');
cfg.zlim              = ft_getopt(cfg, 'zlim',             'maxmin');
cfg.style             = ft_getopt(cfg, 'style',            'both');
cfg.gridscale         = ft_getopt(cfg, 'gridscale',         67);
cfg.interplimits      = ft_getopt(cfg, 'interplimits',     'head');
cfg.interpolation     = ft_getopt(cfg, 'interpolation',     default_interpmethod);
cfg.contournum        = ft_getopt(cfg, 'contournum',        6);
cfg.colorbar          = ft_getopt(cfg, 'colorbar',         'no');
cfg.colorbartext      = ft_getopt(cfg, 'colorbartext',    '');
cfg.shading           = ft_getopt(cfg, 'shading',          'flat');
cfg.comment           = ft_getopt(cfg, 'comment',          'auto');
cfg.fontsize          = ft_getopt(cfg, 'fontsize',          8);
cfg.fontweight        = ft_getopt(cfg, 'fontweight',       'normal');
cfg.baseline          = ft_getopt(cfg, 'baseline',         'no'); % to avoid warning in timelock/freqbaseline
cfg.trials            = ft_getopt(cfg, 'trials',           'all', 1);
cfg.interactive       = ft_getopt(cfg, 'interactive',      'yes');
cfg.hotkeys           = ft_getopt(cfg, 'hotkeys',          'yes');
cfg.renderer          = ft_getopt(cfg, 'renderer',          []); % let MATLAB decide on the default
cfg.marker            = ft_getopt(cfg, 'marker',           'on');
cfg.markersymbol      = ft_getopt(cfg, 'markersymbol',     'o');
cfg.markercolor       = ft_getopt(cfg, 'markercolor',       [0 0 0]);
cfg.markersize        = ft_getopt(cfg, 'markersize',        2);
cfg.markerfontsize    = ft_getopt(cfg, 'markerfontsize',    8);
cfg.highlight         = ft_getopt(cfg, 'highlight',        'off');
cfg.highlightchannel  = ft_getopt(cfg, 'highlightchannel', 'all', 1); % highlight may be 'on', making highlightchannel {} meaningful
cfg.highlightsymbol   = ft_getopt(cfg, 'highlightsymbol',  '*');
cfg.highlightcolor    = ft_getopt(cfg, 'highlightcolor',    [0 0 0]);
cfg.highlightsize     = ft_getopt(cfg, 'highlightsize',     6);
cfg.highlightfontsize = ft_getopt(cfg, 'highlightfontsize', 8);
cfg.labeloffset       = ft_getopt(cfg, 'labeloffset',       0.005);
cfg.maskparameter     = ft_getopt(cfg, 'maskparameter',     []);
cfg.component         = ft_getopt(cfg, 'component',         []);
cfg.directionality    = ft_getopt(cfg, 'directionality',    []);
cfg.channel           = ft_getopt(cfg, 'channel',          'all');
cfg.refchannel        = ft_getopt(cfg, 'refchannel',        []);
cfg.figurename        = ft_getopt(cfg, 'figurename',        []);
cfg.interpolatenan    = ft_getopt(cfg, 'interpolatenan',   'yes');
cfg.commentpos        = ft_getopt(cfg, 'commentpos',       'layout');
cfg.scalepos          = ft_getopt(cfg, 'scalepos',         'layout');

% the user can either specify a single group of channels for highlighting
% which are all to be plotted in the same style, or multiple groups with a
% different style for each group. The latter is used by ft_clusterplot.
if iscell(cfg.highlightchannel) && ~isempty(cfg.highlightchannel) && ischar(cfg.highlightchannel{1})
  % it is a single cell-array with channels names, e.g. {'C1', 'Cz', 'C2'}
  cfg.highlightchannel = {cfg.highlightchannel};
elseif isnumeric(cfg.highlightchannel)
  % it is a numeric selection of channels, e.g. [1 2 3 4]
  cfg.highlightchannel = {cfg.highlightchannel};
elseif ischar(cfg.highlightchannel)
  % it is a single channel or single channel group, e.g. 'all'
  cfg.highlightchannel = {{cfg.highlightchannel}};
end
if ~iscell(cfg.highlight)
  cfg.highlight = {cfg.highlight};
end
if ~iscell(cfg.highlightsymbol)
  cfg.highlightsymbol = {cfg.highlightsymbol};
end
if ~iscell(cfg.highlightcolor)
  cfg.highlightcolor = {cfg.highlightcolor};
end
if ~iscell(cfg.highlightsize)
  cfg.highlightsize = {cfg.highlightsize};
end
if ~iscell(cfg.highlightfontsize)
  cfg.highlightfontsize = {cfg.highlightfontsize};
end
% make sure all cell-arrays for options are sufficiently long
ncellhigh = length(cfg.highlightchannel);
if length(cfg.highlight)          < ncellhigh,   cfg.highlight{ncellhigh}          = [];  end
if length(cfg.highlightsymbol)    < ncellhigh,   cfg.highlightsymbol{ncellhigh}    = [];  end
if length(cfg.highlightcolor)     < ncellhigh,   cfg.highlightcolor{ncellhigh}     = [];  end
if length(cfg.highlightsize)      < ncellhigh,   cfg.highlightsize{ncellhigh}      = [];  end
if length(cfg.highlightfontsize)  < ncellhigh,   cfg.highlightfontsize{ncellhigh}  = [];  end
% make sure all cell-arrays for options are not too long
cfg.highlight         (ncellhigh+1:end) = [];
cfg.highlightsymbol   (ncellhigh+1:end) = [];
cfg.highlightcolor    (ncellhigh+1:end) = [];
cfg.highlightsize     (ncellhigh+1:end) = [];
cfg.highlightfontsize (ncellhigh+1:end) = [];
% then default all empty cells
for icell = 1:ncellhigh
  if isempty(cfg.highlight{icell}),          cfg.highlight{icell} = 'on';          end
  if isempty(cfg.highlightsymbol{icell}),    cfg.highlightsymbol{icell} = 'o';     end
  if isempty(cfg.highlightcolor{icell}),     cfg.highlightcolor{icell} = [0 0 0];  end
  if isempty(cfg.highlightsize{icell}),      cfg.highlightsize{icell} = 6;         end
  if isempty(cfg.highlightfontsize{icell}),  cfg.highlightfontsize{icell} = 8;     end
end

% for backwards compatability
if strcmp(cfg.marker, 'highlights')
  ft_warning('using cfg.marker option -highlights- is no longer used, please use cfg.highlight')
  cfg.marker = 'off';
end

% check colormap is proper format and set it
if isfield(cfg, 'colormap')
  if ~isnumeric(cfg.colormap)
    cfg.colormap = colormap(cfg.colormap);
  end
  if size(cfg.colormap,2)~=3
    ft_error('cfg.colormap must be Nx3');
  end
  colormap(cfg.colormap);
  ncolors = size(cfg.colormap,1);
else
  ncolors = []; % let the low-level function deal with this
end


%% Section 2: data handling, this also includes converting bivariate (chan_chan and chancmb) into univariate data

dtype  = ft_datatype(data);
hastime = isfield(data, 'time');

% Set x/y/parameter defaults according to datatype and dimord
switch dtype
  case 'timelock'
    xparam = ft_getopt(cfg, 'xparam', 'time');
    yparam = ft_getopt(cfg, 'yparam', '');
    if isfield(data, 'trial')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'trial');
    elseif isfield(data, 'individual')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'individual');
    elseif isfield(data, 'avg')
      cfg.parameter = ft_getopt(cfg, 'parameter', 'avg');
    end
  case 'freq'
    if hastime
      xparam = ft_getopt(cfg, 'xparam', 'time');
      yparam = ft_getopt(cfg, 'yparam', 'freq');
      cfg.parameter = ft_getopt(cfg, 'parameter', 'powspctrm');
    else
      xparam = 'freq';
      yparam = '';
      cfg.parameter = ft_getopt(cfg, 'parameter', 'powspctrm');
    end
  case 'comp'
    % Add a pseudo-axis with the component numbers
    data.comp = 1:size(data.topo,2);
    if ~isempty(cfg.component)
      % make a selection of components
      data.comp  = data.comp(cfg.component);
      data.topo  = data.topo(:,cfg.component);
      try, data.label     = data.label(cfg.component); end
      try, data.unmixing  = data.unmixing(cfg.component,:); end
    end
    % Rename the field with topographic label information
    data.label      = data.topolabel;
    data.topodimord = 'chan_comp';
    data = removefields(data, {'topolabel', 'unmixing', 'unmixingdimord'}); % not needed any more
    xparam = 'comp';
    yparam = '';
    cfg.parameter = ft_getopt(cfg, 'parameter', 'topo');
  otherwise
    % if the input data is not one of the standard data types, or if the functional
    % data is just one value per channel: in this case xparam, yparam are not defined
    % and the user should define the parameter
    if ~isfield(data, 'label'),     ft_error('the input data should at least contain a label-field');            end
    if ~isfield(cfg,  'parameter'), ft_error('the configuration should at least contain a ''parameter'' field'); end
    if ~isfield(cfg,  'xparam')
      cfg.xlim = [1 1];
      xparam   = '';
    end
end

% check whether rpt/subj is present and remove if necessary
dimord = getdimord(data, cfg.parameter);
dimtok = tokenize(dimord, '_');
hasrpt = any(ismember(dimtok, {'rpt' 'subj'}));

if ~hasrpt
  assert(isequal(cfg.trials, 'all') || isequal(cfg.trials, 1), 'incorrect specification of cfg.trials for data without repetitions');
else
  assert(~isempty(cfg.trials), 'empty specification of cfg.trials for data with repetitions');
end

% parse cfg.channel
if isfield(cfg, 'channel') && isfield(data, 'label')
  cfg.channel = ft_channelselection(cfg.channel, data.label);
elseif isfield(cfg, 'channel') && isfield(data, 'labelcmb')
  cfg.channel = ft_channelselection(cfg.channel, unique(data.labelcmb(:)));
end

% Apply baseline correction
if ~strcmp(cfg.baseline, 'no')
  % keep mask-parameter if it is set
  if ~isempty(cfg.maskparameter)
    tempmask = data.(cfg.maskparameter);
  end
  tmpcfg = removefields(cfg, 'inputfile');
  if strcmp(xparam, 'time') && strcmp(yparam, 'freq')
    data = ft_freqbaseline(tmpcfg, data);
  elseif strcmp(xparam, 'time') && strcmp(yparam, '')
    data = ft_timelockbaseline(tmpcfg, data);
  end
  % put mask-parameter back if it is set
  if ~isempty(cfg.maskparameter)
    data.(cfg.maskparameter) = tempmask;
  end
end

% time and/or frequency should NOT be selected and averaged here, since a singleplot might follow in interactive mode
tmpcfg = keepfields(cfg, {'channel', 'showcallinfo', 'trials'});
if hasrpt
  tmpcfg.avgoverrpt = 'yes';
else
  tmpcfg.avgoverrpt = 'no';
end
tmpvar = data;
ws = ft_warning('off', 'FieldTrip:getdimord:warning_dimord_could_not_be_determined');
[data] = ft_selectdata(tmpcfg, data);
ft_warning(ws);
% restore the provenance information
[cfg, data] = rollback_provenance(cfg, data);

if isfield(tmpvar, cfg.maskparameter) && ~isfield(data, cfg.maskparameter)
  % the mask parameter is not present after ft_selectdata, because it is
  % not included in all input arguments. Make the same selection and copy
  % it over
  tmpvar = ft_selectdata(tmpcfg, tmpvar);
  data.(cfg.maskparameter) = tmpvar.(cfg.maskparameter);
end

clear tmpvar tmpcfg dimord dimtok hastime hasfreq hasrpt

% ensure that the preproc specific options are located in the cfg.preproc
% substructure, but also ensure that the field 'refchannel' remains at the
% highest level in the structure. This is a little hack by JM because the field
% refchannel can relate to connectivity or to an EEG reference.

if isfield(cfg, 'refchannel'), refchannelincfg = cfg.refchannel; cfg = rmfield(cfg, 'refchannel'); end
cfg = ft_checkconfig(cfg, 'createsubcfg',  {'preproc'});
if exist('refchannelincfg', 'var'), cfg.refchannel  = refchannelincfg; end

if ~isempty(cfg.preproc)
  % preprocess the data, i.e. apply filtering, baselinecorrection, etc.
  fprintf('applying preprocessing options\n');
  if ~isfield(cfg.preproc, 'feedback')
    cfg.preproc.feedback = cfg.interactive;
  end
  data = ft_preprocessing(cfg.preproc, data);
end

% Handle the bivariate case
dimord = getdimord(varargin{1}, cfg.parameter);
if startsWith(dimord, 'chan_chan_') || startsWith(dimord, 'chancmb_')
  % convert the bivariate data to univariate and call the parent plotting function again
  s = dbstack;
  cfg.originalfunction = s(2).name;
  cfg.trials = 'all'; % trial selection has been taken care off
  bivariate_common(cfg, varargin{:});
  return
end

% Apply channel-type specific scaling
tmpcfg = keepfields(cfg, {'parameter', 'chanscale', 'ecgscale', 'eegscale', 'emgscale', 'eogscale', 'gradscale', 'magscale', 'megscale', 'mychan', 'mychanscale'});
data = chanscale_common(tmpcfg, data);


%% Section 3: select the data to be plotted and determine min/max range

dimord = getdimord(varargin{1}, cfg.parameter);
dimtok = tokenize(dimord, '_');

% Create time-series of small topoplots
if ~ischar(cfg.xlim) && length(cfg.xlim)>2 %&& any(ismember(dimtok, 'time'))
  % Switch off interactive mode:
  cfg.interactive = 'no';
  xlims = cfg.xlim;
  % Iteratively call topoplotER with different xlim values:
  nplots = numel(xlims)-1;
  nyplot = ceil(sqrt(nplots));
  nxplot = ceil(nplots./nyplot);
  tmpcfg = removefields(cfg, 'inputfile');
  for i=1:length(xlims)-1
    subplot(nxplot, nyplot, i);
    tmpcfg.xlim = xlims(i:i+1);
    ft_topoplotTFR(tmpcfg, data);
  end
  return
end

% Get physical min/max range of x
if strcmp(cfg.xlim, 'maxmin')
  xmin = min(data.(xparam));
  xmax = max(data.(xparam));
else
  xmin = cfg.xlim(1);
  xmax = cfg.xlim(2);
end
xminindx = nearest(data.(xparam), xmin);
xmaxindx = nearest(data.(xparam), xmax);
xmin = data.(xparam)(xminindx);
xmax = data.(xparam)(xmaxindx);
selx = xminindx:xmaxindx;

% Get physical min/max range of y
if ~isempty(yparam)
  if strcmp(cfg.ylim, 'maxmin')
    ymin = min(data.(yparam));
    ymax = max(data.(yparam));
  else
    ymin = cfg.ylim(1);
    ymax = cfg.ylim(2);
  end
  yminindx = nearest(data.(yparam), ymin);
  ymaxindx = nearest(data.(yparam), ymax);
  ymin = data.(yparam)(yminindx);
  ymax = data.(yparam)(ymaxindx);
  sely = yminindx:ymaxindx;
end

% Take subselection of channels, this only works if the interactive mode is switched off
if exist('selchannel', 'var')
  sellab = match_str(data.label, selchannel);
  label  = data.label(sellab);
else
  sellab = 1:numel(data.label);
  label  = data.label;
end

% Make data vector with one scalar value for each channel
dat = data.(cfg.parameter);
% get dimord dimensions
ydim = find(strcmp(yparam, dimtok));
xdim = find(strcmp(xparam, dimtok));
zdim = setdiff(1:ndims(dat), [ydim xdim]);
% and permute
dat = permute(dat, [zdim(:)' ydim xdim]);

if ~isempty(yparam)
  % time-frequency data
  dat = dat(sellab, sely, selx);
  dat = nanmean(nanmean(dat, 3), 2);
elseif ~isempty(cfg.component)
  % component data, nothing to do
else
  % time or frequency data
  dat = dat(sellab, selx);
  dat = nanmean(dat, 2);
end
dat = dat(:);

if isfield(data, cfg.maskparameter)
  % Make mask vector with one value for each channel
  msk = data.(cfg.maskparameter);
  % get dimord dimensions
  ydim = find(strcmp(yparam, dimtok));
  xdim = find(strcmp(xparam, dimtok));
  zdim = setdiff(1:ndims(dat), [ydim xdim]);
  % and permute
  msk = permute(msk, [zdim(:)' ydim xdim]);
  
  if ~isempty(yparam)
    % time-frequency data
    msk = msk(sellab, sely, selx);
  elseif ~isempty(cfg.component)
    % component data, nothing to do
  else
    % time or frequency data
    msk = msk(sellab, selx);
  end
  
  if size(msk,2)>1 || size(msk,3)>1
    ft_warning('no masking possible for average over multiple latencies or frequencies -> cfg.maskparameter cleared')
    msk = [];
  end
  
else
  msk = [];
end

% Select the channels in the data that match with the layout:
[seldat, sellay] = match_str(label, cfg.layout.label);
if isempty(seldat)
  ft_error('labels in data and labels in layout do not match');
end

dat = dat(seldat);
if ~isempty(msk)
  msk = msk(seldat);
end

% Select x and y coordinates and labels of the channels in the data
chanX = cfg.layout.pos(sellay,1);
chanY = cfg.layout.pos(sellay,2);

% Get physical min/max range of z:
if strcmp(cfg.zlim, 'maxmin')
  zmin = min(dat);
  zmax = max(dat);
elseif strcmp(cfg.zlim, 'maxabs')
  zmin = -max(max(abs(dat)));
  zmax = max(max(abs(dat)));
elseif strcmp(cfg.zlim, 'zeromax')
  zmin = 0;
  zmax = max(dat);
elseif strcmp(cfg.zlim, 'minzero')
  zmin = min(dat);
  zmax = 0;
else
  zmin = cfg.zlim(1);
  zmax = cfg.zlim(2);
end

% Construct comment
switch cfg.comment
  case 'auto'
    comment = date;
    if ~isempty(xparam)
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, xparam, xmin, xmax);
    end
    if ~isempty(yparam)
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, yparam, ymin, ymax);
    end
    if ~isempty(cfg.parameter)
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.parameter, zmin, zmax);
    end
  case 'xlim'
    comment = '';
    if ~isempty(xparam)
      comment = sprintf('%0s=[%.3g %.3g]', xparam, xmin, xmax);
    end
  case 'ylim'
    comment = '';
    if ~isempty(yparam)
      comment = sprintf('%0s=[%.3g %.3g]', yparam, ymin, ymax);
    end
  case 'zlim'
    comment = '';
    if ~isempty(yparam)
      comment = sprintf('%0s=[%.3g %.3g]', cfg.parameter, zmin, zmax);
    end
  otherwise
    comment = cfg.comment; % allow custom comments (e.g., ft_clusterplot specifies custom comments)
end % switch comment

if ~isempty(cfg.refchannel)
  if iscell(cfg.refchannel)
    comment = sprintf('%s\nreference=%s %s', comment, cfg.refchannel{:});
  else
    comment = sprintf('%s\nreference=%s %s', comment, cfg.refchannel);
  end
end

% Draw topoplot
cla
hold on

% check for nans
nanInds = isnan(dat);
if strcmp(cfg.interpolatenan, 'yes') && any(nanInds)
  ft_warning('removing NaNs from the data');
  chanX(nanInds) = [];
  chanY(nanInds) = [];
  dat(nanInds)   = [];
  if ~isempty(msk)
    msk(nanInds) = [];
  end
end

% Set ft_plot_topo specific options
if strcmp(cfg.interplimits, 'head')
  interplimits = 'mask';
else
  interplimits = cfg.interplimits;
end
if strcmp(cfg.style, 'both');            style = 'surfiso';     end
if strcmp(cfg.style, 'straight');        style = 'surf';        end
if strcmp(cfg.style, 'contour');         style = 'iso';         end
if strcmp(cfg.style, 'fill');            style = 'isofill';     end
if strcmp(cfg.style, 'straight_imsat');  style = 'imsat';       end
if strcmp(cfg.style, 'both_imsat');      style = 'imsatiso';    end

% Draw plot
if ~strcmp(cfg.style, 'blank')
  opt = {'interpmethod', cfg.interpolation, ...
    'interplim',    interplimits, ...
    'gridscale',    cfg.gridscale, ...
    'outline',      cfg.layout.outline, ...
    'shading',      cfg.shading, ...
    'isolines',     cfg.contournum, ...
    'mask',         cfg.layout.mask, ...
    'style',        style, ...
    'datmask',      msk};
  if strcmp(style, 'imsat') || strcmp(style, 'imsatiso')
    % add clim to opt
    opt = [opt {'clim', [zmin zmax], 'ncolors',ncolors}];
  end
  ft_plot_topo(chanX, chanY, dat, opt{:});
elseif ~strcmp(cfg.style, 'blank')
  ft_plot_layout(cfg.layout, 'box', 'no', 'label', 'no', 'point', 'no')
end

% For Highlight (channel-selection)
for icell = 1:length(cfg.highlight)
  if ~strcmp(cfg.highlight{icell}, 'off')
    cfg.highlightchannel{icell} = ft_channelselection(cfg.highlightchannel{icell}, data.label);
    [dum, layoutindex] = match_str(cfg.highlightchannel{icell}, cfg.layout.label);
    templay = [];
    templay.outline = cfg.layout.outline;
    templay.mask    = cfg.layout.mask;
    templay.pos     = cfg.layout.pos(layoutindex,:);
    templay.width   = cfg.layout.width(layoutindex);
    templay.height  = cfg.layout.height(layoutindex);
    templay.label   = cfg.layout.label(layoutindex);
    if strcmp(cfg.highlight{icell}, 'labels') || strcmp(cfg.highlight{icell}, 'numbers')
      labelflg = 1;
    else
      labelflg = 0;
    end
    if strcmp(cfg.highlight{icell}, 'numbers')
      for ichan = 1:length(layoutindex)
        templay.label{ichan} = num2str(match_str(data.label, templay.label{ichan}));
      end
    end
    
    ft_plot_layout(templay, 'box', 'no', 'label', labelflg, 'point', ~labelflg, ...
      'pointsymbol',  cfg.highlightsymbol{icell}, ...
      'pointcolor',   cfg.highlightcolor{icell}, ...
      'pointsize',    cfg.highlightsize{icell}, ...
      'fontsize',     cfg.highlightfontsize{icell}, ...
      'labeloffset',  cfg.labeloffset, ...
      'labelalignh', 'center', ...
      'labelalignv', 'middle');
  end
end % for icell

% For Markers (all channels)
switch cfg.marker
  case {'off', 'no'}
    % do not show the markers
  case {'on', 'labels', 'numbers'}
    channelsToMark = 1:length(data.label);
    channelsToHighlight = [];
    for icell = 1:length(cfg.highlight)
      if ~strcmp(cfg.highlight{icell}, 'off')
        channelsToHighlight = [channelsToHighlight; match_str(data.label, cfg.highlightchannel{icell})];
      end
    end
    if strcmp(cfg.interpolatenan, 'no')
      channelsNotMark = channelsToHighlight;
    else
      channelsNotMark = union(find(isnan(dat)), channelsToHighlight);
    end
    channelsToMark(channelsNotMark) = [];
    [dum, layoutindex] = match_str(ft_channelselection(channelsToMark, data.label), cfg.layout.label);
    templay = [];
    templay.outline = cfg.layout.outline;
    templay.mask    = cfg.layout.mask;
    templay.pos     = cfg.layout.pos(layoutindex,:);
    templay.width   = cfg.layout.width(layoutindex);
    templay.height  = cfg.layout.height(layoutindex);
    templay.label   = cfg.layout.label(layoutindex);
    if strcmp(cfg.marker, 'labels') || strcmp(cfg.marker, 'numbers')
      labelflg = 1;
    else
      labelflg = 0;
    end
    if strcmp(cfg.marker, 'numbers')
      for ichan = 1:length(layoutindex)
        templay.label{ichan} = num2str(match_str(data.label,templay.label{ichan}));
      end
    end
    ft_plot_layout(templay, 'box', 'no', 'label',labelflg, 'point', ~labelflg, ...
      'pointsymbol',  cfg.markersymbol, ...
      'pointcolor',   cfg.markercolor, ...
      'pointsize',    cfg.markersize, ...
      'fontsize',     cfg.markerfontsize, ...
      'labeloffset',  cfg.labeloffset, ...
      'labelalignh', 'center', ...
      'labelalignv', 'middle');
  otherwise
    ft_error('incorrect value for cfg.marker');
end

if isfield(cfg, 'vector')
  % FIXME this is not documented
  vecX = nanmean(real(data.(cfg.vector)(:,selx)), 2);
  vecY = nanmean(imag(data.(cfg.vector)(:,selx)), 2);
  
  % scale quiver relative to largest gradiometer sample
  k = 0.15/max([max(abs(real(data.(cfg.vector)(:)))) max(abs(imag(data.(cfg.vector)(:))))]);
  quiver(chanX, chanY, k*vecX, k*vecY, 0, 'red');
end

% Write comment
if strcmp(cfg.comment, 'no')
  comment_handle = [];
elseif strcmp(cfg.commentpos, 'title')
  comment_handle = title(comment, 'FontSize', cfg.fontsize);
elseif ~isempty(strcmp(cfg.layout.label, 'COMNT'))
  x_comment = cfg.layout.pos(strcmp(cfg.layout.label, 'COMNT'), 1);
  y_comment = cfg.layout.pos(strcmp(cfg.layout.label, 'COMNT'), 2);
  % 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom',
  comment_handle = ft_plot_text(x_comment, y_comment, comment, 'FontSize', cfg.fontsize, 'FontWeight', cfg.fontweight);
else
  comment_handle = [];
end

% Set colour axis
if ~strcmp(cfg.style, 'blank')
  caxis([zmin zmax]);
end

% Plot colorbar
if isfield(cfg, 'colorbar')
  if strcmp(cfg.colorbar, 'yes')
    c = colorbar;
    ylabel(c, cfg.colorbartext);
  elseif ~strcmp(cfg.colorbar, 'no')
    c = colorbar('location', cfg.colorbar);
    ylabel(c, cfg.colorbartext);
  end
end

% Set renderer if specified
if ~isempty(cfg.renderer)
  set(gcf, 'renderer', cfg.renderer)
end

% set the figure window title, but only if the user has not changed it
if isempty(get(gcf, 'Name'))
  if isfield(cfg, 'funcname')
    funcname = cfg.funcname;
  else
    funcname = mfilename;
  end
  if isempty(cfg.figurename)
    dataname_str = join_str(', ', dataname);
    set(gcf, 'Name', sprintf('%d: %s: %s', double(gcf), funcname, dataname_str));
    set(gcf, 'NumberTitle', 'off');
  else
    set(gcf, 'name', cfg.figurename);
    set(gcf, 'NumberTitle', 'off');
  end
end

axis off
hold off
axis equal

if strcmp('yes', cfg.hotkeys)
  %  Attach data and cfg to figure and attach a key listener to the figure
  set(gcf, 'KeyPressFcn', {@key_sub, zmin, zmax})
end

% Make the figure interactive
if strcmp(cfg.interactive, 'yes')
  % add the cfg/data/channel information to the figure under identifier linked to this axis
  ident                    = ['axh' num2str(round(sum(clock.*1e6)))]; % unique identifier for this axis
  set(gca, 'tag',ident);
  info                     = guidata(gcf);
  info.(ident).x           = cfg.layout.pos(:, 1);
  info.(ident).y           = cfg.layout.pos(:, 2);
  info.(ident).label       = cfg.layout.label;
  info.(ident).dataname    = dataname;
  info.(ident).cfg         = cfg;
  info.(ident).commenth    = comment_handle;
  if ~isfield(info.(ident),'datvarargin')
    info.(ident).datvarargin = varargin(1:Ndata); % add all datasets to figure
  end
  info.(ident).datvarargin{indx} = data; % update current dataset (e.g. baselined, channel selection, etc)
  guidata(gcf, info);
  if any(strcmp(data.dimord, {'chan_time', 'chan_freq', 'subj_chan_time', 'rpt_chan_time', 'chan_chan_freq', 'chancmb_freq', 'rpt_chancmb_freq', 'subj_chancmb_freq'}))
    set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonUpFcn'});
    set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonDownFcn'});
    set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER}, 'event', 'WindowButtonMotionFcn'});
  elseif any(strcmp(data.dimord, {'chan_freq_time', 'subj_chan_freq_time', 'rpt_chan_freq_time', 'rpttap_chan_freq_time', 'chan_chan_freq_time', 'chancmb_freq_time', 'rpt_chancmb_freq_time', 'subj_chancmb_freq_time'}))
    set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonUpFcn'});
    set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonDownFcn'});
    set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR}, 'event', 'WindowButtonMotionFcn'});
  else
    ft_warning('unsupported dimord "%s" for interactive plotting', data.dimord);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotER(label)
ident       = get(gca, 'tag');
info        = guidata(gcf);
cfg         = info.(ident).cfg;
datvarargin = info.(ident).datvarargin;
if ~isempty(label)
  cfg = removefields(cfg, 'inputfile');       % the reading has already been done and varargin contains the data
  cfg.baseline = 'no';                        % make sure the next function does not apply a baseline correction again
  cfg.channel = label;
  cfg.dataname = info.(ident).cfg.dataname;   % put data name in here, this cannot be resolved by other means
  cfg.trials = 'all';                         % trial selection has already been taken care of
  cfg.xlim = 'maxmin';
  % if user specified a zlim, copy it over to the ylim of singleplot
  if isfield(cfg, 'zlim')
    cfg.ylim = cfg.zlim;
    cfg = rmfield(cfg, 'zlim');
  end
  fprintf('selected cfg.channel = {%s}\n', join_str(', ', cfg.channel));
  % ensure that the new figure appears at the same position
  f = figure('Position', get(gcf, 'Position'), 'Visible', get(gcf, 'Visible'));
  ft_singleplotER(cfg, datvarargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotTFR(label)
ident       = get(gca, 'tag');
info        = guidata(gcf);
cfg         = info.(ident).cfg;
datvarargin = info.(ident).datvarargin;
if ~isempty(label)
  cfg = removefields(cfg, 'inputfile');   % the reading has already been done and varargin contains the data
  cfg.baseline = 'no';                    % make sure the next function does not apply a baseline correction again
  cfg.channel = label;
  cfg.dataname = info.(ident).dataname;   % put data name in here, this cannot be resolved by other means
  cfg.trials = 'all';                     % trial selection has already been taken care of
  cfg.xlim = 'maxmin';
  cfg.ylim = 'maxmin';
  fprintf('selected cfg.channel = {%s}\n', join_str(', ', cfg.channel));
  % ensure that the new figure appears at the same position
  f = figure('Position', get(gcf, 'Position'), 'Visible', get(gcf, 'Visible'));
  ft_singleplotTFR(cfg, datvarargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which handles hot keys in the current plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key_sub(handle, eventdata, varargin)
ident       = get(gca, 'tag');
info        = guidata(gcf);

climits = caxis;
incr_c  = abs(climits(2) - climits(1)) /10;

newz = climits;
if length(eventdata.Modifier) == 1 && strcmp(eventdata.Modifier{:}, 'control')
  % TRANSLATE by 10%
  switch eventdata.Key
    case 'pageup'
      newz = [climits(1)+incr_c climits(2)+incr_c];
    case 'pagedown'
      newz = [climits(1)-incr_c climits(2)-incr_c];
  end % switch
else
  % ZOOM by 10%
  switch eventdata.Key
    case 'pageup'
      newz = [climits(1)-incr_c climits(2)+incr_c];
    case 'pagedown'
      newz = [climits(1)+incr_c climits(2)-incr_c];
    case 'm'
      newz = [varargin{1} varargin{2}];
  end % switch
end % if

% update the color axis
caxis(newz);

if ~isempty(ident) && isfield(info.(ident), 'commenth') && ~isempty(info.(ident).commenth)
  commentstr = get(info.(ident).commenth, 'string');
  sel        = contains(commentstr, info.(ident).cfg.parameter);
  if any(sel)
    commentstr{sel} = sprintf('%0s=[%.3g %.3g]', info.(ident).cfg.parameter, newz(1), newz(2));
    set(info.(ident).commenth, 'string', commentstr);
  end
end
                                                                                                                                                                                                                                                                                                                                                                                                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_startDrag(h, eventdata)
f = get(h, 'Parent');
while ~strcmp(get(f, 'Tag'), 'mainFigure')
  f = get(f, 'Parent');
end
opt =  guidata(f);
opt.handles.current.line = h;

if strfind(get(h, 'Tag'), 'Color')>0
  opt.handles.current.axes = opt.handles.colorbar;
  opt.handles.current.color = true;
else
  disp('Figure out if it works for xparam and yparam');
  keyboard
end

set(f, 'WindowButtonMotionFcn', @cb_dragLine);

guidata(h, opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_getposition(h, eventdata)

h   = findobj(h, 'tag', 'mainFigure');
opt = guidata(h);

pos = get(get(h, 'currentaxes'), 'currentpoint');
switch get(get(h, 'currentaxes'), 'tag'),
  case 'geometry'
    if opt.ismesh
      % get the intersection with the mesh
      [ipos, d] = intersect_line(opt.anatomy.pos, opt.anatomy.tri, pos(1,:), pos(2,:));
      [md, ix]  = min(abs(d));
   
      dpos     = opt.anatomy.pos - ipos(ix*ones(size(opt.anatomy.pos,1),1),:);
      opt.valz = nearest(sum(dpos.^2,2),0);
   
    elseif opt.isvolume
    else
    end
    
  case 'other'
  otherwise
end

% if strcmp(get(get(h, 'currentaxes'), 'tag'), 'timecourse')
%   % get the current point
%   pos = get(opt.hy, 'currentpoint');
%   set(opt.sliderx, 'value', nearest(opt.xparam, pos(1,1))./numel(opt.xparam));
%   if isfield(opt, 'hline')
%     set(opt.slidery, 'value', nearest(opt.yparam, pos(1,2))./numel(opt.yparam));
%   end
% elseif strcmp(get(get(h, 'currentaxes'), 'tag'), 'mesh')
%   % get the current point, which is defined as the intersection through the
%   % axis-box (in 3D)
%   pos       = get(opt.hx, 'currentpoint');
%   
%   % get the intersection with the mesh
%   [ipos, d] = intersect_line(opt.pos, opt.tri, pos(1,:), pos(2,:));
%   [md, ix]  = min(abs(d));
%   
%   dpos      = opt.pos - ipos(ix*ones(size(opt.pos,1),1),:);
%   opt.vindx = nearest(sum(dpos.^2,2),0);
%   
%   if isfield(opt, 'parcellation')
%     opt.pindx = find(opt.parcellation(opt.vindx,:));
%     disp(opt.pindx);
%   end
% elseif strcmp(get(get(h, 'currentaxes'), 'tag'), 'mesh2')
%   % get the current point, which is defined as the intersection through the
%   % axis-box (in 3D)
%   pos       = get(opt.hz, 'currentpoint');
%   
%   % get the intersection with the mesh
%   [ipos, d] = intersect_line(opt.pos, opt.tri, pos(1,:), pos(2,:));
%   [md, ix]  = min(abs(d));
%   
%   dpos      = opt.pos - ipos(ix*ones(size(opt.pos,1),1),:);
%   opt.vindx = nearest(sum(dpos.^2,2),0);
%   
%   if isfield(opt, 'parcellation')
%     opt.pindx2 = find(opt.parcellation(opt.vindx,:));
%     disp(opt.pindx2);
%   end
%   
% end
guidata(h, opt);
cb_slider(h);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_dragLine(h, eventdata)
opt =  guidata(h);
pt = get(opt.handles.current.axes, 'CurrentPoint');
yLim = get(opt.handles.colorbar, 'YLim');

% upper (lower) bar must not below (above) lower (upper) bar
if ~(opt.handles.current.line == opt.handles.lines.upperColor && ...
    (any(pt(3)*[1 1]<get(opt.handles.lines.lowerColor, 'YData')) || ...
    yLim(end) <= pt(3))) ...
    && ~(opt.handles.current.line == opt.handles.lines.lowerColor && ...
    (any(pt(3)*[1 1]>get(opt.handles.lines.upperColor, 'YData')) || ...
    yLim(1) >= pt(3)))
  set(opt.handles.current.line, 'YData', pt(3)*[1 1]);
end

adjust_colorbar(opt);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_stopDrag(h, eventdata)
while ~strcmp(get(h, 'Tag'), 'mainFigure')
  h = get(h, 'Parent');
end
set(h, 'WindowButtonMotionFcn', '');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adjust_colorbar(opt)
  % adjust colorbar
  upper = get(opt.handles.lines.upperColor, 'YData');
  lower = get(opt.handles.lines.lowerColor, 'YData');
  if any(round(upper)==0) || any(round(lower)==0)
    return;
  end
  maps = get(opt.handles.menu.colormap, 'String');
  cmap = feval(maps{get(opt.handles.menu.colormap, 'Value')}, size(colormap, 1));
  cmap(round(lower(1)):round(upper(1)), :) = repmat(cmap(round(lower(1)), :), 1+round(upper(1))-round(lower(1)), 1);
  for i=1:numel(opt.dat)
    colormap(opt.handles.axes.movie_subplot{i}, cmap);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opt = plot_geometry(opt)
  numArgs = numel(opt.dat);
  numRows = floor(sqrt(numArgs));
  numCols = ceil(sqrt(numArgs));
  for i=1:numArgs
    axes(opt.handles.axes.movie);
    opt.handles.axes.movie_subplot{i} = gca;
    if isfield(opt, 'anatomy') && opt.ismesh
      if isfield(opt.anatomy, 'sulc') && ~isempty(opt.anatomy.sulc)
        vdat = opt.anatomy.sulc;
        vdat(vdat>0.5) = 0.5;
        vdat(vdat<-0.5)= -0.5;
        vdat = vdat-min(vdat);
        vdat = 0.35.*(vdat./max(vdat))+0.3;
        vdat = repmat(vdat,[1 3]);
        mesh = ft_plot_mesh(opt.anatomy, 'edgecolor', 'none', 'vertexcolor', vdat);
      else
        mesh = ft_plot_mesh(opt.anatomy, 'edgecolor', 'none', 'facecolor', [0.5 0.5 0.5]);
      end
      lighting gouraud
      % set(mesh, 'Parent', opt.handles.axes.movie);
      % mesh = ft_plot_mesh(source, 'edgecolor', 'none', 'vertexcolor', 0*opt.dat(:,1,1), 'facealpha', 0*opt.mask(:,1,1));
      opt.handles.mesh{i} = ft_plot_mesh(opt.anatomy, 'edgecolor', 'none', 'vertexcolor', opt.dat{i}(:,1,1));
      set(opt.handles.mesh{i}, 'AlphaDataMapping', 'scaled');
      set(opt.handles.mesh{i}, 'FaceVertexAlphaData', opt.mask{i}(:,opt.valx,opt.valy));
      % TODO FIXME below does not work
      %set(opt.handles.mesh, 'FaceAlpha', 'flat');
      %set(opt.handles.mesh, 'EdgeAlpha', 'flat');

      lighting gouraud
      cam1 = camlight('left');
%       set(cam1, 'Parent', opt.handles.axes.movie);
      cam2 = camlight('right');
%       set(cam2, 'Parent', opt.handles.axes.movie);
%       set(opt.handles.mesh, 'Parent', opt.handles.axes.movie);
      %   cameratoolbar(opt.handles.figure, 'Show');
    else
      axes(opt.handles.axes.movie)
      [dum, opt.handles.grid{i}] = ft_plot_topo(opt.layout{i}.pos(opt.sellay,1), opt.layout{i}.pos(opt.sellay,2), zeros(numel(opt.sellay{i}),1), 'mask', opt.layout{i}.mask, 'outline', opt.layout{i}.outline, 'interpmethod', 'v4', 'interplim', 'mask', 'parent', opt.handles.axes.movie);
      %[dum, opt.handles.grid] = ft_plot_topo(layout.pos(sellay,1), layout.pos(sellay,2), zeros(numel(sellay),1), 'mask',layout.mask,  'outline', layout.outline, 'interpmethod', 'v4', 'interplim', 'mask', 'parent', opt.handles.axes.movie);
      % set(opt.handles.grid, 'Parent', opt.handles.axes.movie);
      opt.xdata{i}   = get(opt.handles.grid{i}, 'xdata');
      opt.ydata{i}   = get(opt.handles.grid{i}, 'ydata');
      opt.nanmask{i} = 1-get(opt.handles.grid{i}, 'cdata');
      if (gcf~=opt.handles.figure)
        close gcf; % sometimes there is a new window that opens up
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opt = plot_other(opt)
  dimord  = opt.dimord;
  
  switch dimord
    case {'pos_time' 'pos_freq' 'chan_time' 'chan_freq'}
      opt.doplot    = true;
      opt.doimagesc = false;
    case {'pos_freq_time' 'chan_freq_time' 'chan_chan_freq' 'chan_chan_time' 'pos_pos_freq' 'pos_pos_time'}
      opt.doplot    = false;
      opt.doimagesc = false;
    otherwise
  end
  
  if opt.doplot
    plot(opt.handles.axes.other, opt.xvalues, nanmean(opt.dat{1}(opt.valz,:),1));
  elseif opt.doimagesc
  end
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = ikelvin(m)
%  pos    hue   sat   value
cu = [
  0.0     1/2   0     1.0
  0.125   1/2   0.6   0.95
  0.375   2/3   1.0   0.8
  0.5     2/3   1.0   0.3
  ];

cl = cu;
cl(:, 3:4) = cl(end:-1:1, 3:4);
cl(:, 2)   = cl(:, 2) - 0.5;
cu(:,1)    = cu(:,1)+.5;

x = linspace(0, 1, m)';
l = (x < 0.5); u = ~l;
for i = 1:3
  h(l, i) = interp1(cl(:, 1), cl(:, i+1), x(l));
  h(u, i) = interp1(cu(:, 1), cu(:, i+1), x(u));
end
c = hsv2rgb(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = ikelvinr(m)
%  pos    hue   sat   value
cu = [
  0.0     1/2   0     1.0
  0.125   1/2   0.6   0.95
  0.375   2/3   1.0   0.8
  0.5     2/3   1.0   0.3
  ];

cl = cu;
cl(:, 3:4) = cl(end:-1:1, 3:4);
cl(:, 2)   = cl(:, 2) - 0.5;
cu(:,1)    = cu(:,1)+.5;

x = linspace(0, 1, m)';
l = (x < 0.5); u = ~l;
for i = 1:3
  h(l, i) = interp1(cl(:, 1), cl(:, i+1), x(l));
  h(u, i) = interp1(cu(:, 1), cu(:, i+1), x(u));
end
c = hsv2rgb(h);

c = flipud(c);
end
                                                                                                                                                                                                                                                                                       '
        'MEG0942'  'MEG0943'  'MEG0941'  'MEG0942+0943'
        'MEG1012'  'MEG1013'  'MEG1011'  'MEG1012+1013'
        'MEG1022'  'MEG1023'  'MEG1021'  'MEG1022+1023'
        'MEG1032'  'MEG1033'  'MEG1031'  'MEG1032+1033'
        'MEG1042'  'MEG1043'  'MEG1041'  'MEG1042+1043'
        'MEG1112'  'MEG1113'  'MEG1111'  'MEG1112+1113'
        'MEG1122'  'MEG1123'  'MEG1121'  'MEG1122+1123'
        'MEG1132'  'MEG1133'  'MEG1131'  'MEG1132+1133'
        'MEG1142'  'MEG1143'  'MEG1141'  'MEG1142+1143'
        'MEG1212'  'MEG1213'  'MEG1211'  'MEG1212+1213'
        'MEG1222'  'MEG1223'  'MEG1221'  'MEG1222+1223'
        'MEG1232'  'MEG1233'  'MEG1231'  'MEG1232+1233'
        'MEG1242'  'MEG1243'  'MEG1241'  'MEG1242+1243'
        'MEG1312'  'MEG1313'  'MEG1311'  'MEG1312+1313'
        'MEG1322'  'MEG1323'  'MEG1321'  'MEG1322+1323'
        'MEG1332'  'MEG1333'  'MEG1331'  'MEG1332+1333'
        'MEG1342'  'MEG1343'  'MEG1341'  'MEG1342+1343'
        'MEG1412'  'MEG1413'  'MEG1411'  'MEG1412+1413'
        'MEG1422'  'MEG1423'  'MEG1421'  'MEG1422+1423'
        'MEG1432'  'MEG1433'  'MEG1431'  'MEG1432+1433'
        'MEG1442'  'MEG1443'  'MEG1441'  'MEG1442+1443'
        'MEG1512'  'MEG1513'  'MEG1511'  'MEG1512+1513'
        'MEG1522'  'MEG1523'  'MEG1521'  'MEG1522+1523'
        'MEG1532'  'MEG1533'  'MEG1531'  'MEG1532+1533'
        'MEG1542'  'MEG1543'  'MEG1541'  'MEG1542+1543'
        'MEG1612'  'MEG1613'  'MEG1611'  'MEG1612+1613'
        'MEG1622'  'MEG1623'  'MEG1621'  'MEG1622+1623'
        'MEG1632'  'MEG1633'  'MEG1631'  'MEG1632+1633'
        'MEG1642'  'MEG1643'  'MEG1641'  'MEG1642+1643'
        'MEG1712'  'MEG1713'  'MEG1711'  'MEG1712+1713'
        'MEG1722'  'MEG1723'  'MEG1721'  'MEG1722+1723'
        'MEG1732'  'MEG1733'  'MEG1731'  'MEG1732+1733'
        'MEG1742'  'MEG1743'  'MEG1741'  'MEG1742+1743'
        'MEG1812'  'MEG1813'  'MEG1811'  'MEG1812+1813'
        'MEG1822'  'MEG1823'  'MEG1821'  'MEG1822+1823'
        'MEG1832'  'MEG1833'  'MEG1831'  'MEG1832+1833'
        'MEG1842'  'MEG1843'  'MEG1841'  'MEG1842+1843'
        'MEG1912'  'MEG1913'  'MEG1911'  'MEG1912+1913'
        'MEG1922'  'MEG1923'  'MEG1921'  'MEG1922+1923'
        'MEG1932'  'MEG1933'  'MEG1931'  'MEG1932+1933'
        'MEG1942'  'MEG1943'  'MEG1941'  'MEG1942+1943'
        'MEG2012'  'MEG2013'  'MEG2011'  'MEG2012+2013'
        'MEG2022'  'MEG2023'  'MEG2021'  'MEG2022+2023'
        'MEG2032'  'MEG2033'  'MEG2031'  'MEG2032+2033'
        'MEG2042'  'MEG2043'  'MEG2041'  'MEG2042+2043'
        'MEG2112'  'MEG2113'  'MEG2111'  'MEG2112+2113'
        'MEG2122'  'MEG2123'  'MEG2121'  'MEG2122+2123'
        'MEG2132'  'MEG2133'  'MEG2131'  'MEG2132+2133'
        'MEG2142'  'MEG2143'  'MEG2141'  'MEG2142+2143'
        'MEG2212'  'MEG2213'  'MEG2211'  'MEG2212+2213'
        'MEG2222'  'MEG2223'  'MEG2221'  'MEG2222+2223'
        'MEG2232'  'MEG2233'  'MEG2231'  'MEG2232+2233'
        'MEG2242'  'MEG2243'  'MEG2241'  'MEG2242+2243'
        'MEG2312'  'MEG2313'  'MEG2311'  'MEG2312+2313'
        'MEG2322'  'MEG2323'  'MEG2321'  'MEG2322+2323'
        'MEG2332'  'MEG2333'  'MEG2331'  'MEG2332+2333'
        'MEG2342'  'MEG2343'  'MEG2341'  'MEG2342+2343'
        'MEG2412'  'MEG2413'  'MEG2411'  'MEG2412+2413'
        'MEG2422'  'MEG2423'  'MEG2421'  'MEG2422+2423'
        'MEG2432'  'MEG2433'  'MEG2431'  'MEG2432+2433'
        'MEG2442'  'MEG2443'  'MEG2441'  'MEG2442+2443'
        'MEG2512'  'MEG2513'  'MEG2511'  'MEG2512+2513'
        'MEG2522'  'MEG2523'  'MEG2521'  'MEG2522+2523'
        'MEG2532'  'MEG2533'  'MEG2531'  'MEG2532+2533'
        'MEG2542'  'MEG2543'  'MEG2541'  'MEG2542+2543'
        'MEG2612'  'MEG2613'  'MEG2611'  'MEG2612+2613'
        'MEG2622'  'MEG2623'  'MEG2621'  'MEG2622+2623'
        'MEG2632'  'MEG2633'  'MEG2631'  'MEG2632+2633'
        'MEG2642'  'MEG2643'  'MEG2641'  'MEG2642+2643'
        };
      neuromag306_mag      = label(:,3);
      neuromag306_planar   = label(:,[1 2]);
      neuromag306_combined = label(:,[3 4]); % magnetometers and combined channels
      label                = label(:,1:3);
      
    case 'eeg1020'
      label = {
        'Fp1'
        'Fpz'
        'Fp2'
        'F7'
        'F3'
        'Fz'
        'F4'
        'F8'
        'T7'
        'C3'
        'Cz'
        'C4'
        'T8'
        'P7'
        'P3'
        'Pz'
        'P4'
        'P8'
        'O1'
        'Oz'
        'O2'};
      
      % Add also reference and some alternative labels that might be used
      label = cat(1, label, {'A1' 'A2' 'M1' 'M2' 'T3' 'T4' 'T5' 'T6'}');
      
    case 'eeg1010'
      label = {
        'Fp1'
        'Fpz'
        'Fp2'
        'AF9'
        'AF7'
        'AF5'
        'AF3'
        'AF1'
        'AFz'
        'AF2'
        'AF4'
        'AF6'
        'AF8'
        'AF10'
        'F9'
        'F7'
        'F5'
        'F3'
        'F1'
        'Fz'
        'F2'
        'F4'
        'F6'
        'F8'
        'F10'
        'FT9'
        'FT7'
        'FC5'
        'FC3'
        'FC1'
        'FCz'
        'FC2'
        'FC4'
        'FC6'
        'FT8'
        'FT10'
        'T9'
        'T7'
        'C5'
        'C3'
        'C1'
        'Cz'
        'C2'
        'C4'
        'C6'
        'T8'
        'T10'
        'TP9'
        'TP7'
        'CP5'
        'CP3'
        'CP1'
        'CPz'
        'CP2'
        'CP4'
        'CP6'
        'TP8'
        'TP10'
        'P9'
        'P7'
        'P5'
        'P3'
        'P1'
        'Pz'
        'P2'
        'P4'
        'P6'
        'P8'
        'P10'
        'PO9'
        'PO7'
        'PO5'
        'PO3'
        'PO1'
        'POz'
        'PO2'
        'PO4'
        'PO6'
        'PO8'
        'PO10'
        'O1'
        'Oz'
        'O2'
        'I1'
        'Iz'
        'I2'
        };

      % Add also reference and some alternative labels that might be used
      label = cat(1, label, {'A1' 'A2' 'M1' 'M2' 'T3' 'T4' 'T5' 'T6'}');

    case 'eeg1005'
      label = {
        'Fp1'
        'Fpz'
        'Fp2'
        'AF9'
        'AF7'
        'AF5'
        'AF3'
        'AF1'
        'AFz'
        'AF2'
        'AF4'
        'AF6'
        'AF8'
        'AF10'
        'F9'
        'F7'
        'F5'
        'F3'
        'F1'
        'Fz'
        'F2'
        'F4'
        'F6'
        'F8'
        'F10'
        'FT9'
        'FT7'
        'FC5'
        'FC3'
        'FC1'
        'FCz'
        'FC2'
        'FC4'
        'FC6'
        'FT8'
        'FT10'
        'T9'
        'T7'
        'C5'
        'C3'
        'C1'
        'Cz'
        'C2'
        'C4'
        'C6'
        'T8'
        'T10'
        'TP9'
        'TP7'
        'CP5'
        'CP3'
        'CP1'
        'CPz'
        'CP2'
        'CP4'
        'CP6'
        'TP8'
        'TP10'
        'P9'
        'P7'
        'P5'
        'P3'
        'P1'
        'Pz'
        'P2'
        'P4'
        'P6'
        'P8'
        'P10'
        'PO9'
        'PO7'
        'PO5'
        'PO3'
        'PO1'
        'POz'
        'PO2'
        'PO4'
        'PO6'
        'PO8'
        'PO10'
        'O1'
        'Oz'
        'O2'
        'I1'
        'Iz'
        'I2'
        'AFp9h'
        'AFp7h'
        'AFp5h'
        'AFp3h'
        'AFp1h'
        'AFp2h'
        'AFp4h'
        'AFp6h'
        'AFp8h'
        'AFp10h'
        'AFF9h'
        'AFF7h'
        'AFF5h'
        'AFF3h'
        'AFF1h'
        'AFF2h'
        'AFF4h'
        'AFF6h'
        'AFF8h'
        'AFF10h'
        'FFT9h'
        'FFT7h'
        'FFC5h'
        'FFC3h'
        'FFC1h'
        'FFC2h'
        'FFC4h'
        'FFC6h'
        'FFT8h'
        'FFT10h'
        'FTT9h'
        'FTT7h'
        'FCC5h'
        'FCC3h'
        'FCC1h'
        'FCC2h'
        'FCC4h'
        'FCC6h'
        'FTT8h'
        'FTT10h'
        'TTP9h'
        'TTP7h'
        'CCP5h'
        'CCP3h'
        'CCP1h'
        'CCP2h'
        'CCP4h'
        'CCP6h'
        'TTP8h'
        'TTP10h'
        'TPP9h'
        'TPP7h'
        'CPP5h'
        'CPP3h'
        'CPP1h'
        'CPP2h'
        'CPP4h'
        'CPP6h'
        'TPP8h'
        'TPP10h'
        'PPO9h'
        'PPO7h'
        'PPO5h'
        'PPO3h'
        'PPO1h'
        'PPO2h'
        'PPO4h'
        'PPO6h'
        'PPO8h'
        'PPO10h'
        'POO9h'
        'POO7h'
        'POO5h'
        'POO3h'
        'POO1h'
        'POO2h'
        'POO4h'
        'POO6h'
        'POO8h'
        'POO10h'
        'OI1h'
        'OI2h'
        'Fp1h'
        'Fp2h'
        'AF9h'
        'AF7h'
        'AF5h'
        'AF3h'
        'AF1h'
        'AF2h'
        'AF4h'
        'AF6h'
        'AF8h'
        'AF10h'
        'F9h'
        'F7h'
        'F5h'
        'F3h'
        'F1h'
        'F2h'
        'F4h'
        'F6h'
        'F8h'
        'F10h'
        'FT9h'
        'FT7h'
        'FC5h'
        'FC3h'
        'FC1h'
        'FC2h'
        'FC4h'
        'FC6h'
        'FT8h'
        'FT10h'
        'T9h'
        'T7h'
        'C5h'
        'C3h'
        'C1h'
        'C2h'
        'C4h'
        'C6h'
        'T8h'
        'T10h'
        'TP9h'
        'TP7h'
        'CP5h'
        'CP3h'
        'CP1h'
        'CP2h'
        'CP4h'
        'CP6h'
        'TP8h'
        'TP10h'
        'P9h'
        'P7h'
        'P5h'
        'P3h'
        'P1h'
        'P2h'
        'P4h'
        'P6h'
        'P8h'
        'P10h'
        'PO9h'
        'PO7h'
        'PO5h'
        'PO3h'
        'PO1h'
        'PO2h'
        'PO4h'
        'PO6h'
        'PO8h'
        'PO10h'
        'O1h'
        'O2h'
        'I1h'
        'I2h'
        'AFp9'
        'AFp7'
        'AFp5'
        'AFp3'
        'AFp1'
        'AFpz'
        'AFp2'
        'AFp4'
        'AFp6'
        'AFp8'
        'AFp10'
        'AFF9'
        'AFF7'
        'AFF5'
        'AFF3'
        'AFF1'
        'AFFz'
        'AFF2'
        'AFF4'
        'AFF6'
        'AFF8'
        'AFF10'
        'FFT9'
        'FFT7'
        'FFC5'
        'FFC3'
        'FFC1'
        'FFCz'
        'FFC2'
        'FFC4'
        'FFC6'
        'FFT8'
        'FFT10'
        'FTT9'
        'FTT7'
        'FCC5'
        'FCC3'
        'FCC1'
        'FCCz'
        'FCC2'
        'FCC4'
        'FCC6'
        'FTT8'
        'FTT10'
        'TTP9'
        'TTP7'
        'CCP5'
        'CCP3'
        'CCP1'
        'CCPz'
        'CCP2'
        'CCP4'
        'CCP6'
        'TTP8'
        'TTP10'
        'TPP9'
        'TPP7'
        'CPP5'
        'CPP3'
        'CPP1'
        'CPPz'
        'CPP2'
        'CPP4'
        'CPP6'
        'TPP8'
        'TPP10'
        'PPO9'
        'PPO7'
        'PPO5'
        'PPO3'
        'PPO1'
        'PPOz'
        'PPO2'
        'PPO4'
        'PPO6'
        'PPO8'
        'PPO10'
        'POO9'
        'POO7'
        'POO5'
        'POO3'
        'POO1'
        'POOz'
        'POO2'
        'POO4'
        'POO6'
        'POO8'
        'POO10'
        'OI1'
        'OIz'
        'OI2'
        };

      % Add also reference and some alternative labels that might be used
      label = cat(1, label, {'A1' 'A2' 'M1' 'M2' 'T3' 'T4' 'T5' 'T6'}');
      
    case 'ext1020'
      % start with the eeg1005 list
      label = {
        'Fp1'
        'Fpz'
        'Fp2'
        'AF9'
        'AF7'
        'AF5'
        'AF3'
        'AF1'
        'AFz'
        'AF2'
        'AF4'
        'AF6'
        'AF8'
        'AF10'
        'F9'
        'F7'
        'F5'
        'F3'
        'F1'
        'Fz'
        'F2'
        'F4'
        'F6'
        'F8'
        'F10'
        'FT9'
        'FT7'
        'FC5'
        'FC3'
        'FC1'
        'FCz'
        'FC2'
        'FC4'
        'FC6'
        'FT8'
        'FT10'
        'T9'
        'T7'
        'C5'
        'C3'
        'C1'
        'Cz'
        'C2'
        'C4'
        'C6'
        'T8'
        'T10'
        'TP9'
        'TP7'
        'CP5'
        'CP3'
        'CP1'
        'CPz'
        'CP2'
        'CP4'
        'CP6'
        'TP8'
        'TP10'
        'P9'
        'P7'
        'P5'
        'P3'
        'P1'
        'Pz'
        'P2'
        'P4'
        'P6'
        'P8'
        'P10'
        'PO9'
        'PO7'
        'PO5'
        'PO3'
        'PO1'
        'POz'
        'PO2'
        'PO4'
        'PO6'
        'PO8'
        'PO10'
        'O1'
        'Oz'
        'O2'
        'I1'
        'Iz'
        'I2'
        'AFp9h'
        'AFp7h'
        'AFp5h'
        'AFp3h'
        'AFp1h'
        'AFp2h'
        'AFp4h'
        'AFp6h'
        'AFp8h'
        'AFp10h'
        'AFF9h'
        'AFF7h'
        'AFF5h'
        'AFF3h'
        'AFF1h'
        'AFF2h'
        'AFF4h'
        'AFF6h'
        'AFF8h'
        'AFF10h'
        'FFT9h'
        'FFT7h'
        'FFC5h'
        'FFC3h'
        'FFC1h'
        'FFC2h'
        'FFC4h'
        'FFC6h'
        'FFT8h'
        'FFT10h'
        'FTT9h'
        'FTT7h'
        'FCC5h'
        'FCC3h'
        'FCC1h'
        'FCC2h'
        'FCC4h'
        'FCC6h'
        'FTT8h'
        'FTT10h'
        'TTP9h'
        'TTP7h'
        'CCP5h'
        'CCP3h'
        'CCP1h'
        'CCP2h'
        'CCP4h'
        'CCP6h'
        'TTP8h'
        'TTP10h'
        'TPP9h'
        'TPP7h'
        'CPP5h'
        'CPP3h'
        'CPP1h'
        'CPP2h'
        'CPP4h'
        'CPP6h'
        'TPP8h'
        'TPP10h'
        'PPO9h'
        'PPO7h'
        'PPO5h'
        'PPO3h'
        'PPO1h'
        'PPO2h'
        'PPO4h'
        'PPO6h'
        'PPO8h'
        'PPO10h'
        'POO9h'
        'POO7h'
        'POO5h'
        'POO3h'
        'POO1h'
        'POO2h'
        'POO4h'
        'POO6h'
        'POO8h'
        'POO10h'
        'OI1h'
        'OI2h'
        'Fp1h'
        'Fp2h'
        'AF9h'
        'AF7h'
        'AF5h'
        'AF3h'
        'AF1h'
        'AF2h'
        'AF4h'
        'AF6h'
        'AF8h'
        'AF10h'
        'F9h'
        'F7h'
        'F5h'
        'F3h'
        'F1h'
        'F2h'
        'F4h'
        'F6h'
        'F8h'
        'F10h'
        'FT9h'
        'FT7h'
        'FC5h'
        'FC3h'
        'FC1h'
        'FC2h'
        'FC4h'
        'FC6h'
        'FT8h'
        'FT10h'
        'T9h'
        'T7h'
        'C5h'
        'C3h'
        'C1h'
        'C2h'
        'C4h'
        'C6h'
        'T8h'
        'T10h'
        'TP9h'
        'TP7h'
        'CP5h'
        'CP3h'
        'CP1h'
        'CP2h'
        'CP4h'
        'CP6h'
        'TP8h'
        'TP10h'
        'P9h'
        'P7h'
        'P5h'
        'P3h'
        'P1h'
        'P2h'
        'P4h'
        'P6h'
        'P8h'
        'P10h'
        'PO9h'
        'PO7h'
        'PO5h'
        'PO3h'
        'PO1h'
        'PO2h'
        'PO4h'
        'PO6h'
        'PO8h'
        'PO10h'
        'O1h'
        'O2h'
        'I1h'
        'I2h'
        'AFp9'
        'AFp7'
        'AFp5'
        'AFp3'
        'AFp1'
        'AFpz'
        'AFp2'
        'AFp4'
        'AFp6'
        'AFp8'
        'AFp10'
        'AFF9'
        'AFF7'
        'AFF5'
        'AFF3'
        'AFF1'
        'AFFz'
        'AFF2'
        'AFF4'
        'AFF6'
        'AFF8'
        'AFF10'
        'FFT9'
        'FFT7'
        'FFC5'
        'FFC3'
        'FFC1'
        'FFCz'
        'FFC2'
        'FFC4'
        'FFC6'
        'FFT8'
        'FFT10'
        'FTT9'
        'FTT7'
        'FCC5'
        'FCC3'
        'FCC1'
        'FCCz'
        'FCC2'
        'FCC4'
        'FCC6'
        'FTT8'
        'FTT10'
        'TTP9'
        'TTP7'
        'CCP5'
        'CCP3'
        'CCP1'
        'CCPz'
        'CCP2'
        'CCP4'
        'CCP6'
        'TTP8'
        'TTP10'
        'TPP9'
        'TPP7'
        'CPP5'
        'CPP3'
        'CPP1'
        'CPPz'
        'CPP2'
        'CPP4'
        'CPP6'
        'TPP8'
        'TPP10'
        'PPO9'
        'PPO7'
        'PPO5'
        'PPO3'
        'PPO1'
        'PPOz'
        'PPO2'
        'PPO4'
        'PPO6'
        'PPO8'
        'PPO10'
        'POO9'
        'POO7'
        'POO5'
        'POO3'
        'POO1'
        'POOz'
        'POO2'
        'POO4'
        'POO6'
        'POO8'
        'POO10'
        'OI1'
        'OIz'
        'OI2'
        };
      
      % Add also reference and some alternative labels that might be used
      label = cat(1, label, {'A1' 'A2' 'M1' 'M2' 'T3' 'T4' 'T5' 'T6'}');
      
      % This is to account for all variants of case in 1020 systems
      label = unique(cat(1, label, upper(label), lower(label)));
      
    case 'biosemi64'
      label = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
        'A16'
        'A17'
        'A18'
        'A19'
        'A20'
        'A21'
        'A22'
        'A23'
        'A24'
        'A25'
        'A26'
        'A27'
        'A28'
        'A29'
        'A30'
        'A31'
        'A32'
        'B1'
        'B2'
        'B3'
        'B4'
        'B5'
        'B6'
        'B7'
        'B8'
        'B9'
        'B10'
        'B11'
        'B12'
        'B13'
        'B14'
        'B15'
        'B16'
        'B17'
        'B18'
        'B19'
        'B20'
        'B21'
        'B22'
        'B23'
        'B24'
        'B25'
        'B26'
        'B27'
        'B28'
        'B29'
        'B30'
        'B31'
        'B32'
        };
      
    case 'biosemi128'
      label = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
        'A16'
        'A17'
        'A18'
        'A19'
        'A20'
        'A21'
        'A22'
        'A23'
        'A24'
        'A25'
        'A26'
        'A27'
        'A28'
        'A29'
        'A30'
        'A31'
        'A32'
        'B1'
        'B2'
        'B3'
        'B4'
        'B5'
        'B6'
        'B7'
        'B8'
        'B9'
        'B10'
        'B11'
        'B12'
        'B13'
        'B14'
        'B15'
        'B16'
        'B17'
        'B18'
        'B19'
        'B20'
        'B21'
        'B22'
        'B23'
        'B24'
        'B25'
        'B26'
        'B27'
        'B28'
        'B29'
        'B30'
        'B31'
        'B32'
        'C1'
        'C2'
        'C3'
        'C4'
        'C5'
        'C6'
        'C7'
        'C8'
        'C9'
        'C10'
        'C11'
        'C12'
        'C13'
        'C14'
        'C15'
        'C16'
        'C17'
        'C18'
        'C19'
        'C20'
        'C21'
        'C22'
        'C23'
        'C24'
        'C25'
        'C26'
        'C27'
        'C28'
        'C29'
        'C30'
        'C31'
        'C32'
        'D1'
        'D2'
        'D3'
        'D4'
        'D5'
        'D6'
        'D7'
        'D8'
        'D9'
        'D10'
        'D11'
        'D12'
        'D13'
        'D14'
        'D15'
        'D16'
        'D17'
        'D18'
        'D19'
        'D20'
        'D21'
        'D22'
        'D23'
        'D24'
        'D25'
        'D26'
        'D27'
        'D28'
        'D29'
        'D30'
        'D31'
        'D32'
        };
      
    case 'biosemi256'
      label = {
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'A8'
        'A9'
        'A10'
        'A11'
        'A12'
        'A13'
        'A14'
        'A15'
     