function segmentation = convert_segmentationstyle(segmentation, fn, dim, style)

% CONVERT_SEGMENTATIONSTYLE is a helper function for converting between probabilistic
% and indexed representations. It is used by ft_datatype_segmentation and
% ft_datatype_parcellation.
%
% See also FIXSEGMENTATION, DETERMINE_SEGMENTATIONSTYLE

switch style
  case 'indexed'
    
    % convert the probabilistic representation to an indexed representation
    threshold = 0.5;
    seg       = zeros(dim);
    seglabel  = cell(1,numel(fn));
    
    for i=1:length(fn)
      tmp = segmentation.(fn{i})>threshold;
      if any(seg(tmp(:)))
        ft_error('overlapping tissue probability maps cannot be converted to an indexed representation');
        % FIXME in principle it is possible to represent two tissue types at one voxel
      else
        seg(tmp) = i;
        seglabel{i} = fn{i};
      end
    end
    segmentation          = rmfield(segmentation, fn);
    segmentation.seg      = seg;
    segmentation.seglabel = seglabel;
    
  case 'probabilistic'
    % convert the indexed representation to a probabilistic one
    for i=1:length(fn)
      fprintf('converting %s\n', fn{i});
      seg      = segmentation.(fn{i});
      seglabel = segmentation.([fn{i} 'label']);
      for j=i:length(seglabel)
        fprintf('creating probabilistic representation for %s\n', seglabel{j});
        tmp.(fixname(seglabel{j})) = (seg==j);  % avoid overwriting the existing segmentation
      end % for j
      segmentation = rmfield(segmentation,  fn{i}         );
      segmentation = rmfield(segmentation, [fn{i} 'label']);
      for j=i:length(seglabel)
        segmentation.(fixname(seglabel{j})) = tmp.(fixname(seglabel{j})); % avoid overwriting the existing segmentation
      end
    end % for i
    
  otherwise
    ft_error('unsupported style "%s"', style);
end
                                                                                                                                                                                                  ));
end

switch ft_senstype(sens)
  case {'ctf64', 'ctf151', 'ctf275' 'bti148', 'bti248', 'bti248grad', 'itab28', 'itab153', 'yokogawa64', 'yokogawa160', 'babysquid74'}
    % the following code applies to systems with only axial gradiometers or magnetometers

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % do the MEG sensors first
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    sensorig   = sens;
    sel        = ft_chantype(sens, 'meg');
    sens.label = sens.label(sel);
    sens.tra   = sens.tra(sel,:);

    % subsequently remove the unused coils
    used = any(abs(sens.tra)>0.0001, 1);  % allow a little bit of rounding-off error
    sens.coilpos = sens.coilpos(used,:);
    sens.coilori = sens.coilori(used,:);
    sens.tra     = sens.tra(:,used);

    % compute distances from the center of the helmet
    center = mean(sens.coilpos);
    dist   = sqrt(sum((sens.coilpos - repmat(center, size(sens.coilpos, 1), 1)).^2, 2));

    % put the corresponding distances instead of non-zero tra entries
    maxval = repmat(max(abs(sens.tra),[],2), [1 size(sens.tra,2)]);
    maxval = min(maxval, ones(size(maxval))); %a value > 1 sometimes leads to problems; this is an empirical fix
    dist = (abs(sens.tra)>0.7.*maxval).*repmat(dist', size(sens.tra, 1), 1);

    % for the occasional case where there are nans: -> 0's will be
    % converted to inf anyhow
    dist(isnan(dist)) = 0;

    % put infs instead of the zero entries
    dist(~dist) = inf;

    % use the matrix to find coils with minimal distance to the center,
    % i.e. the bottom coil in the case of axial gradiometers
    % this only works for a full-rank unbalanced tra-matrix

    numcoils = sum(isfinite(dist),2);

    if all(numcoils==numcoils(1))
      % add the additional constraint that coils cannot be used twice,
      % i.e. for the position of 2 channels. A row of the dist matrix can end
      % up with more than 1 (magnetometer array) or 2 (axial gradiometer array)
      % non-zero entries when the input grad structure is rank-reduced
      % FIXME: I don't know whether this works for a vector-gradiometer
      % system. It also does not work when the system has mixed gradiometers
      % and magnetometers

      % use the magic that Jan-Mathijs implemented
      tmp      = mode(numcoils);
      niter    = 0;
      while ~all(numcoils==tmp)
        niter    = niter + 1;
        selmode  = find(numcoils==tmp);
        selrest  = setdiff((1:size(dist,1))', selmode);
        dist(selrest,sum(~isinf(dist(selmode,:)))>0) = inf;
        numcoils = sum(isfinite(dist),2);
        if niter>500
          ft_error('Failed to extract the positions of the channels. This is most likely due to the balancing matrix being rank deficient. Please replace data.grad with the original grad-structure obtained after reading the header.');
        end
      end
    else
      % assume that the solution is not so hard and just determine the bottom coil
    end

    [junk, ind] = min(dist, [], 2);

    lab(sel)   = sens.label;
    pnt(sel,:) = sens.coilpos(ind, :);
    ori(sel,:) = sens.coilori(ind, :);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % then do the references
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sens = sensorig;
    sel  = ft_chantype(sens, 'ref');

    sens.label = sens.label(sel);
    sens.tra   = sens.tra(sel,:);

    % subsequently remove the unused coils
    used = any(abs(sens.tra)>0.0001, 1);  % allow a little bit of rounding-off error
    sens.coilpos = sens.coilpos(used,:);
    sens.coilori = sens.coilori(used,:);
    sens.tra = sens.tra(:,used);

    [nchan, ncoil] = size(sens.tra);
    refpnt = zeros(nchan,3);
    refori = zeros(nchan,3); % FIXME not sure whether this will work
    for i=1:nchan
      weight = abs(sens.tra(i,:));
      weight = weight ./ sum(weight);
      refpnt(i,:) = weight * sens.coilpos;
      refori(i,:) = weight * sens.coilori;
    end
    reflab = sens.label;

    lab(sel)   = reflab;
    pnt(sel,:) = refpnt;
    ori(sel,:) = refori;

    sens = sensorig;

  case {'ctf64_planar', 'ctf151_planar', 'ctf275_planar', 'bti148_planar', 'bti248_planar', 'bti248grad_planar', 'itab28_planar', 'itab153_planar', 'yokogawa64_planar', 'yokogawa160_planar'}
    % create a list with planar channel names
    chan = {};
    for i=1:length(sens.label)
      if endsWith(sens.label{i}, '_dH') || endsWith(sens.label{i}, '_dV')
        chan{i} = sens.label{i}(1:(end-3));
      end
    end
    chan = unique(chan);
    % find the matching channel-duplets
    ind = false(size(chan));
    lab = cell(length(chan),2);
    pnt = nan(length(chan),3);
    ori = nan(length(chan),3);
    for i=1:length(chan)
      ch1 =  [chan{i} '_dH'];
      ch2 =  [chan{i} '_dV'];
      sel = match_str(sens.label, {ch1, ch2});
      if length(sel)==2
        ind(i)   = true;
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(sens.coilpos(abs(sens.tra(sel(1),:))>0.5, :), 1);
        meanpnt2 = mean(sens.coilpos(abs(sens.tra(sel(2),:))>0.5, :), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
        meanori1 = mean(sens.coilori(abs(sens.tra(sel(1),:))>0.5, :), 1);
        meanori2 = mean(sens.coilori(abs(sens.tra(sel(2),:))>0.5, :), 1);
        ori(i,:) = mean([meanori1; meanori2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    ori = ori(ind,:);

  case 'neuromag122'
    % find the matching channel-duplets
    ind = [];
    lab = {};
    for i=1:2:140
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d', i);
      ch2 = sprintf('MEG %03d', i+1);
      sel = match_str(sens.label, {ch1, ch2});
      % then try MEG channel labels without a space
      if (length(sel)~=2)
        ch1 = sprintf('MEG%03d', i);
        ch2 = sprintf('MEG%03d', i+1);
        sel = match_str(sens.label, {ch1, ch2});
      end
      % then try to determine the channel locations
      if (length(sel)==2)
        ind = [ind; i];
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(sens.coilpos(abs(sens.tra(sel(1),:))>0.5,:), 1);
        meanpnt2 = mean(sens.coilpos(abs(sens.tra(sel(2),:))>0.5,:), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
        meanori1 = mean(sens.coilori(abs(sens.tra(sel(1),:))>0.5,:), 1);
        meanori2 = mean(sens.coilori(abs(sens.tra(sel(2),:))>0.5,:), 1);
        ori(i,:) = mean([meanori1; meanori2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    ori = ori(ind,:);

  case 'neuromag306'
    % find the matching channel-triplets
    ind = [];
    lab = {};
    for i=1:300
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d1', i);
      ch2 = sprintf('MEG %03d2', i);
      ch3 = sprintf('MEG %03d3', i);
      [sel1, sel2] = match_str(sens.label, {ch1, ch2, ch3});
      % the try MEG channels without a space
      if isempty(sel1)
        ch1 = sprintf('MEG%03d1', i);
        ch2 = sprintf('MEG%03d2', i);
        ch3 = sprintf('MEG%03d3', i);
        [sel1, sel2] = match_str(sens.label, {ch1, ch2, ch3});
      end
      % then try to determine the channel locations
      if (~isempty(sel1) && length(sel1)<=3)
        ind = [ind; i];
        lab(i,sel2) = sens.label(sel1)';
        meanpnt  = [];
        meanori  = [];
        for j = 1:length(sel1)
          meanpnt  = [meanpnt; mean(sens.coilpos(abs(sens.tra(sel1(j),:))>0.5,:), 1)];
          meanori  = [meanori; mean(sens.coilori(abs(sens.tra(sel1(j),:))>0.5,:), 1)];
        end
        pnt(i,:) = mean(meanpnt, 1);
        ori(i,:) = mean(meanori, 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);
    ori = ori(ind,:);

  otherwise
    % compute the position for each gradiometer or electrode
    nchan = length(sens.label);
    if isfield(sens, 'elecpos')
      nelec = size(sens.elecpos,1); % these are the electrodes
    elseif isfield(sens, 'coilpos')
      ncoil = size(sens.coilpos,1); % these are the coils
    elseif isfield(sens, 'optopos')
      nopto = size(sens.optopos,1); % these are the optodes
    end

    if ~isfield(sens, 'tra') && isfield(sens, 'elecpos') && nchan==nelec
      % there is one electrode per channel, which means that the channel position is identical to the electrode position
      pnt = sens.elecpos;
      if isfield(sens, 'elecori')
        ori = sens.elecori;
      else
        ori = nan(size(pnt));
      end
      lab = sens.label;

    elseif isfield(sens, 'tra') && isfield(sens, 'elecpos') && isequal(sens.tra, eye(nelec))
      % there is one electrode per channel, which means that the channel position is identical to the electrode position
      pnt = sens.elecpos;
      if isfield(sens, 'elecori')
        ori = sens.elecori;
      else
        ori = nan(size(pnt));
      end
      lab = sens.label;

    elseif isfield(sens, 'tra') && isfield(sens, 'elecpos') && isequal(sens.tra, eye(nelec)-1/nelec)
      % there is one electrode per channel, channels are average referenced
      pnt = sens.elecpos;
      if isfield(sens, 'elecori')
        ori = sens.elecori;
      else
        ori = nan(size(pnt));
      end
      lab = sens.label;

    elseif ~isfield(sens, 'tra') && isfield(sens, 'coilpos') && nchan==ncoil
      % there is one coil per channel, which means that the channel position is identical to the coil position
      pnt = sens.coilpos;
      ori = sens.coilori;
      lab = sens.label;

    elseif ~isfield(sens, 'tra') && isfield(sens, 'optopos') && nchan==nopto
      % there is one optode per channel, which means that the channel position is identical to the optode position
      pnt = sens.optopos;
      if isfield(sens, 'optoori')
        ori = sens.optoori;
      else
        ori = nan(size(pnt));
      end
      lab = sens.label;

    elseif isfield(sens, 'tra')
      % each channel depends on multiple sensors (electrodes or coils), compute a weighted position for the channel
      % for MEG gradiometer channels this means that the position is in between the two coils
      % for bipolar EEG channels this means that the position is in between the two electrodes
      % for NIRS channels this means that the position is in between the transmit and receive optode
      pnt = nan(nchan,3);
      ori = nan(nchan,3);
      if isfield(sens, 'coilpos')
        for i=1:nchan
          weight = abs(sens.tra(i,:));
          weight = weight ./ sum(weight);
          pnt(i,:) = weight * sens.coilpos;
          ori(i,:) = weight * sens.coilori;
        end
      elseif isfield(sens, 'elecpos')
        for i=1:nchan
          weight = abs(sens.tra(i,:));
          weight = weight ./ sum(weight);
          pnt(i,:) = weight * sens.elecpos;
        end
      elseif isfield(sens, 'optopos')
        for i=1:nchan
          weight = abs(sens.tra(i,:));
          weight = weight ./ sum(weight);
          pnt(i,:) = weight * sens.optopos;
        end
      end
      lab = sens.label;
    end
    
end % switch senstype

n = size(lab,2);
% this is to fix the planar layouts, which cannot be plotted anyway
if n>1 && size(lab, 1)>1 % this is to prevent confusion when lab happens to be a row array
  pnt = repmat(pnt, n, 1);
  ori = repmat(ori, n, 1);
end

% ensure that the channel order is the same as in sens
[sel1, sel2] = match_str(sens.label, lab);
lab = lab(sel2);
pnt = pnt(sel2, :);
ori = ori(sel2, :);

% ensure that it is a row vector
lab = lab(:);

% do a sanity check on the number of positions
nchan = numel(sens.label);
if length(lab)~=nchan || size(pnt,1)~=nchan || size(ori,1)~=nchan
  ft_warning('the positions were not determined for all channels');
end
                                                                                                                                                                                                                                                                                         e kept, selrpt~=selrpttap, otherwise selrpt==selrpttap
    [selrpt{i}, dum, rptdim{i}, selrpttap{i}] = getselection_rpt(cfg, varargin{i}, dimord{j});
    
    % check for the presence of each dimension in each datafield
    fieldhasspike   = ismember('spike',   dimtok);
    fieldhaspos     = ismember('pos',     dimtok) || ismember('{pos}', dimtok);
    fieldhaschan    = (ismember('chan',    dimtok) || ismember('{chan}', dimtok)) && isfield(varargin{1}, 'label');
    fieldhaschancmb = ismember('chancmb', dimtok);
    fieldhastime    = ismember('time',    dimtok) && ~hasspike;
    fieldhasfreq    = ismember('freq',    dimtok);
    fieldhasrpt     = ismember('rpt',     dimtok) | ismember('subj', dimtok) | ismember('{rpt}', dimtok);
    fieldhasrpttap  = ismember('rpttap',  dimtok);
    
    % cfg.latency is used to select individual spikes, not to select from a continuously sampled time axis
    
    if fieldhasspike,   varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(strcmp(dimtok,'spike')),             selspike{i},   false,           'intersect', average); end
    if fieldhaspos,     varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(ismember(dimtok, {'pos', '{pos}'})), selpos{i},     avgoverpos,      cfg.select, average);  end
    if fieldhaschan,    varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(ismember(dimtok,{'chan' '{chan}'})), selchan{i},    avgoverchan,     cfg.select, average);  end
    if fieldhaschancmb, varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(strcmp(dimtok,'chancmb')),           selchancmb{i}, avgoverchancmb,  cfg.select, average);  end
    if fieldhastime,    varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(strcmp(dimtok,'time')),              seltime{i},    avgovertime,     cfg.select, average);  end
    if fieldhasfreq,    varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, find(strcmp(dimtok,'freq')),              selfreq{i},    avgoverfreq,     cfg.select, average);  end
    if fieldhasrpt,     varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, rptdim{i},                                selrpt{i},     avgoverrpt,      'intersect', average); end
    if fieldhasrpttap,  varargin{i} = makeselection(varargin{i}, datfield{j}, dimtok, rptdim{i},                                selrpttap{i},  avgoverrpt,      'intersect', average); end
    
    % update the fields that should be kept in the structure as a whole
    % and update the dimord for this specific datfield
    keepdim = true(size(dimtok));
    
    if avgoverchan && ~keepchandim
      keepdim(strcmp(dimtok, 'chan')) = false;
      keepfield = setdiff(keepfield, 'label');
    else
      keepfield = [keepfield 'label'];
    end
    
    if avgoverchancmb && ~keepchancmbdim
      keepdim(strcmp(dimtok, 'chancmb')) = false;
      keepfield = setdiff(keepfield, 'labelcmb');
    else
      keepfield = [keepfield 'labelcmb'];
    end
    
    if avgoverfreq && ~keepfreqdim
      keepdim(strcmp(dimtok, 'freq')) = false;
      keepfield = setdiff(keepfield, 'freq');
    else
      keepfield = [keepfield 'freq'];
    end
    
    if avgovertime && ~keeptimedim
      keepdim(strcmp(dimtok, 'time')) = false;
      keepfield = setdiff(keepfield, 'time');
    else
      keepfield = [keepfield 'time'];
    end
    
    if avgoverpos && ~keepposdim
      keepdim(strcmp(dimtok, 'pos'))   = false;
      keepdim(strcmp(dimtok, '{pos}')) = false;
      keepdim(strcmp(dimtok, 'dim'))   = false;
      keepfield = setdiff(keepfield, {'pos' '{pos}' 'dim'});
    elseif avgoverpos && keepposdim
      keepfield = setdiff(keepfield, {'dim'}); % this should be removed anyway
    else
      keepfield = [keepfield {'pos' '{pos}' 'dim'}];
    end
    
    if avgoverrpt && ~keeprptdim
      keepdim(strcmp(dimtok, 'rpt'))    = false;
      keepdim(strcmp(dimtok, 'rpttap')) = false;
      keepdim(strcmp(dimtok, 'subj'))   = false;
    end
    
    % update the sampleinfo, if possible, and needed
    if strcmp(datfield{j}, 'sampleinfo') && ~isequal(cfg.latency, 'all')
      if iscell(seltime{i}) && numel(seltime{i})==size(varargin{i}.sampleinfo,1)
        for k = 1:numel(seltime{i})
          varargin{i}.sampleinfo(k,:) = varargin{i}.sampleinfo(k,1) - 1 + seltime{i}{k}([1 end]);
        end
      elseif ~iscell(seltime{i}) && ~isempty(seltime{i}) && ~all(isnan(seltime{i}))
        nrpt       = size(varargin{i}.sampleinfo,1);
        seltime{i} = seltime{i}(:)';
        varargin{i}.sampleinfo = varargin{i}.sampleinfo(:,[1 1]) - 1 + repmat(seltime{i}([1 end]),nrpt,1);
      end
    end
    
    varargin{i}.(datfield{j}) = squeezedim(varargin{i}.(datfield{j}), ~keepdim);
    
  end % for datfield
  
  % also update the fields that describe the dimensions, time/freq/pos have been dealt with as data
  if haschan,    varargin{i} = makeselection_chan   (varargin{i}, selchan{i}, avgoverchan); end % update the label field
  if haschancmb, varargin{i} = makeselection_chancmb(varargin{i}, selchancmb{i}, avgoverchancmb); end % update the labelcmb field
  
end % for varargin

if strcmp(cfg.select, 'union')
  % create the union of the descriptive axes
  if haspos,      varargin = makeunion(varargin, 'pos'); end
  if haschan,     varargin = makeunion(varargin, 'label'); end
  if haschancmb,  varargin = makeunion(varargin, 'labelcmb'); end
  if hastime,     varargin = makeunion(varargin, 'time'); end
  if hasfreq,     varargin = makeunion(varargin, 'freq'); end
end

% remove all fields from the data structure that do not pertain to the selection
sel = strcmp(keepfield, '{pos}'); if any(sel), keepfield(sel) = {'pos'}; end
sel = strcmp(keepfield, 'chan');  if any(sel), keepfield(sel) = {'label'}; end
sel = strcmp(keepfield, 'chancmb');  if any(sel), keepfield(sel) = {'labelcmb'}; end

if avgoverrpt
  % these are invalid after averaging
  keepfield = setdiff(keepfield, {'cumsumcnt' 'cumtapcnt' 'trialinfo' 'sampleinfo'});
end

if avgovertime
  % these are invalid after averaging or making a latency selection
  keepfield = setdiff(keepfield, {'sampleinfo'});
end

for i=1:numel(varargin)
  varargin{i} = keepfields(varargin{i}, [keepfield ignorefields('selectdata')']);
end

% restore the original dimord fields in the data
for i=1:length(orgdim1)
  dimtok = tokenize(orgdim2{i}, '_');
  
  % using a setdiff may result in double occurrences of chan and pos to
  % disappear, so this causes problems as per bug 2962
  % if ~keeprptdim, dimtok = setdiff(dimtok, {'rpt' 'rpttap' 'subj'}); end
  % if ~keepposdim, dimtok = setdiff(dimtok, {'pos' '{pos}'}); end
  % if ~keepchandim, dimtok = setdiff(dimtok, {'chan'}); end
  % if ~keepfreqdim, dimtok = setdiff(dimtok, {'freq'}); end
  % if ~keeptimedim, dimtok = setdiff(dimtok, {'time'}); end
  if ~keeprptdim, dimtok = dimtok(~ismember(dimtok, {'rpt' 'rpttap' 'subj'})); end
  if ~keepposdim, dimtok = dimtok(~ismember(dimtok, {'pos' '{pos}'}));         end
  if ~keepchandim, dimtok = dimtok(~ismember(dimtok, {'chan'})); end
  if ~keepfreqdim, dimtok = dimtok(~ismember(dimtok, {'freq'})); end
  if ~keeptimedim, dimtok = dimtok(~ismember(dimtok, {'time'})); end
  
  dimord = sprintf('%s_', dimtok{:});
  dimord = dimord(1:end-1); % remove the trailing _
  for j=1:length(varargin)
    varargin{j}.(orgdim1{i}) = dimord;
  end
end

% restore the source.avg field, this keeps the output reasonably consistent with the
% old-style source representation of the input
if strcmp(dtype, 'source') && ~isempty(restoreavg)
  for i=1:length(varargin)
    varargin{i}.avg = keepfields(varargin{i}, restoreavg);
    varargin{i}     = removefields(varargin{i}, restoreavg);
  end
end

varargout = varargin;

ft_postamble debug
ft_postamble trackconfig
ft_postamble previous varargin
ft_postamble provenance varargout
ft_postamble history varargout
ft_postamble savevar varargout

% the varargout variable can be cleared when written to outputfile
if exist('varargout', 'var') && ft_nargout>numel(varargout)
  % also return the input cfg with the combined selection over all input data structures
  varargout{end+1} = cfg;
end

end % function ft_selectdata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = makeselection(data, datfield, dimtok, seldim, selindx, avgoverdim, selmode, average)

if numel(seldim) > 1
  for k = 1:numel(seldim)
    data = makeselection(data, datfield, dimtok, seldim(k), selindx, avgoverdim, selmode, average);
  end
  return;
end

if isnumeric(data.(datfield))
  if isrow(data.(datfield)) && seldim==1
    if length(dimtok)==1
      seldim = 2; % switch row and column
    end
  elseif iscolumn(data.(datfield)) && seldim==2
    if length(dimtok)==1
      seldim = 1; % switch row and column
    end
  end
elseif iscell(data.(datfield))
  if isrow(data.(datfield){1}) && seldim==2
    if length(dimtok)==2
      seldim = 3; % switch row and column
    end
  elseif iscolumn(data.(datfield){1}) && seldim==3
    if length(dimtok)==2
      seldim = 2; % switch row and column
    end
  end
end

% an empty selindx means that nothing(!) should be selected and hence everything should be removed, which is different than keeping everything
% the selindx value of NaN indicates that it is not needed to make a selection

switch selmode
  case 'intersect'
    if iscell(selindx)
      % there are multiple selections in multipe vectors, the selection is in the matrices contained within the cell-array
      for j=1:numel(selindx)
        if ~isempty(selindx{j}) && all(isnan(selindx{j}))
          % no selection needs to be made
        else
          data.(datfield){j} = cellmatselect(data.(datfield){j}, seldim-1, selindx{j}, numel(dimtok)==1);
        end
      end
      
    else
      % there is a single selection in a single vector
      if ~isempty(selindx) && all(isnan(selindx))
        % no selection needs to be made
      else
        data.(datfield) = cellmatselect(data.(datfield), seldim, selindx, numel(dimtok)==1);
      end
    end
    
    if avgoverdim
      data.(datfield) = cellmatmean(data.(datfield), seldim, average);
    end
    
  case 'union'
    if ~isempty(selindx) && all(isnan(selindx))
      % no selection needs to be made
    else
      tmp = data.(datfield);
      siz = size(tmp);
      siz(seldim) = numel(selindx);
      data.(datfield) = nan(siz);
      sel = isfinite(selindx);
      switch seldim
        case 1
          data.(datfield)(sel,:,:,:,:,:) = tmp(selindx(sel),:,:,:,:,:);
        case 2
          data.(datfield)(:,sel,:,:,:,:) = tmp(:,selindx(sel),:,:,:,:);
        case 3
          data.(datfield)(:,:,sel,:,:,:) = tmp(:,:,selindx(sel),:,:,:);
        case 4
          data.(datfield)(:,:,:,sel,:,:) = tmp(:,:,:,selindx(sel),:,:);
        case 5
          data.(datfield)(:,:,:,:,sel,:) = tmp(:,:,:,:,selindx(sel),:);
        case 6
          data.(datfield)(:,:,:,:,:,sel) = tmp(:,:,:,:,:,selindx(sel));
        otherwise
          ft_error('unsupported dimension (%d) for making a selection for %s', seldim, datfield);
      end
    end
    
    if avgoverdim
      data.(datfield) = average(data.(datfield), seldim);
    end
end % switch

end % function makeselection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = makeselection_chan(data, selchan, avgoverchan)
if isempty(selchan)
  %error('no channels were selected');
  data.label = {};
elseif avgoverchan && all(isnan(selchan))
  str = sprintf('%s, ', data.label{:});
  str = str(1:end-2);
  str = sprintf('mean(%s)', str);
  data.label = {str};
elseif avgoverchan && ~any(isnan(selchan))
  str = sprintf('%s, ', data.label{selchan});
  str = str(1:end-2);
  str = sprintf('mean(%s)', str);
  data.label = {str};                 % remove the last '+'
elseif all(isfinite(selchan))
  data.label = data.label(selchan);
  data.label = data.label(:);
elseif numel(selchan)==1 && any(~isfinite(selchan))
  % do nothing
elseif numel(selchan)>1  && any(~isfinite(selchan))
  tmp = cell(numel(selchan),1);
  for k = 1:numel(tmp)
    if isfinite(selchan(k))
      tmp{k} = data.label{selchan(k)};
    end
  end
  data.label = tmp;
else
  % this should never happen
  ft_error('cannot figure out how to select channels');
end
end % function makeselection_chan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = makeselection_chancmb(data, selchancmb, avgoverchancmb)
if isempty(selchancmb)
  ft_error('no channel combinations were selected');
elseif avgoverchancmb && all(isnan(selchancmb))
  % naming the channel combinations becomes ambiguous, but should not
  % suggest that the mean was computed prior to combining
  str1 = sprintf('%s, ', data.labelcmb{:,1});
  str1 = str1(1:end-2);
  % str1 = sprintf('mean(%s)', str1);
  str2 = sprintf('%s, ', data.labelcmb{:,2});
  str2 = str2(1:end-2);
  % str2 = sprintf('mean(%s)', str2);
  data.label = {str1, str2};
elseif avgoverchancmb && ~any(isnan(selchancmb))
  % naming the channel combinations becomes ambiguous, but should not
  % suggest that the mean was computed prior to combining
  str1 = sprintf('%s, ', data.labelcmb{selchancmb,1});
  str1 = str1(1:end-2);
  % str1 = sprintf('mean(%s)', str1);
  str2 = sprintf('%s, ', data.labelcmb{selchancmb,2});
  str2 = str2(1:end-2);
  % str2 = sprintf('mean(%s)', str2);
  data.label = {str1, str2};
elseif all(isfinite(selchancmb))
  data.labelcmb = data.labelcmb(selchancmb,:);
elseif numel(selchancmb)==1 && any(~isfinite(selchancmb))
  % do nothing
elseif numel(selchancmb)>1  && any(~isfinite(selchancmb))
  tmp = cell(numel(selchancmb),2);
  for k = 1:size(tmp,1)
    if isfinite(selchan(k))
      tmp{k,1} = data.labelcmb{selchan(k),1};
      tmp{k,2} = data.labelcmb{selchan(k),2};
    end
  end
  data.labelcmb = tmp;
else
  % this should never happen
  ft_error('cannot figure out how to select channelcombinations');
end
end % function makeselection_chancmb

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chanindx, cfg] = getselection_chan(cfg, varargin)

selmode  = varargin{end};
ndata    = numel(varargin)-1;
varargin = varargin(1:ndata);

% loop over data once to initialize
chanindx = cell(ndata,1);
label    = cell(1,0);

for k = 1:ndata
  if isfield(varargin{k}, 'grad') && isfield(varargin{k}.grad, 'type')
    % this makes channel selection more robust
    selchannel = ft_channelselection(cfg.channel, varargin{k}.label, varargin{k}.grad.type);
  elseif isfield(varargin{k}, 'elec') && isfield(varargin{k}.elec, 'type')
    % this makes channel selection more robust
    selchannel = ft_channelselection(cfg.channel, varargin{k}.label, varargin{k}.elec.type);
  else
    selchannel = ft_channelselection(cfg.channel, varargin{k}.label);
  end
  label      = union(label, selchannel);
end
label = label(:);   % ensure column array

% this call to match_str ensures that that labels are always in the
% order of the first input argument see bug_2917, but also temporarily keep
% the labels from the other data structures not present in the first one
% (in case selmode = 'union')
[ix, iy] = match_str(varargin{1}.label, label);
label1   = varargin{1}.label(:); % ensure column array
label    = [label1(ix); label(setdiff(1:numel(label),iy))];

indx = nan+zeros(numel(label), ndata);
for k = 1:ndata
  [ix, iy] = match_str(label, varargin{k}.label);
  indx(ix,k) = iy;
end

switch selmode
  case 'intersect'
    sel      = sum(isfinite(indx),2)==ndata;
    indx     = indx(sel,:);
    label    = varargin{1}.label(indx(:,1));
  case 'union'
    % don't do a subselection
  otherwise
    ft_error('invalid value for cfg.select');
end % switch

ok = false(size(indx,1),1);
for k = 1:ndata
  % loop through the columns to preserve the order of the channels, where
  % the order of the input arguments determines the final order
  ix = find(~ok);
  [srt,srtix] = sort(indx(ix,k));
  indx(ix,:)  = indx(ix(srtix),:);
  ok = ok | isfinite(indx(:,k));
end

for k = 1:ndata
  % do a sanity check on double occurrences
  if numel(unique(indx(isfinite(indx(:,k)),k)))<sum(isfinite(indx(:,k)))
    ft_error('the selection of channels across input arguments leads to double occurrences');
  end
  chanindx{k} = indx(:,k);
end

for k = 1:ndata
  if isequal(chanindx{k}, (1:numel(varargin{k}.label))')
    % no actual selection is needed for this data structure
    chanindx{k} = nan;
  end
end

cfg.channel = label;

end % function getselection_chan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chancmbindx, cfg] = getselection_chancmb(cfg, varargin)

selmode  = varargin{end};
ndata    = numel(varargin)-1;
varargin = varargin(1:ndata);

chancmbindx = cell(ndata,1);

if ~isfield(cfg, 'channelcmb')
  for k=1:ndata
    % the nan return value specifies that no selection was specified
    chancmbindx{k} = nan;
  end
  
else
  
  switch selmode
    case 'intersect'
      for k=1:ndata
        if ~isfield(varargin{k}, 'label')
          cfg.channelcmb = ft_channelcombination(cfg.channelcmb, unique(varargin{k}.labelcmb(:)));
        else
          cfg.channelcmb = ft_channelcombination(cfg.channelcmb, varargin{k}.label);
        end
      end
      
      ncfgcmb = size(cfg.channelcmb,1);
      cfgcmb  = cell(ncfgcmb, 1);
      for i=1:ncfgcmb
        cfgcmb{i} = sprintf('%s&%s', cfg.channelcmb{i,1}, cfg.channelcmb{i,2});
      end
      
      for k=1:ndata
        ndatcmb = size(varargin{k}.labelcmb,1);
        datcmb = cell(ndatcmb, 1);
        for i=1:ndatcmb
          datcmb{i} = sprintf('%s&%s', varargin{k}.labelcmb{i,1}, varargin{k}.labelcmb{i,2});
        end
        
        % return the order according to the (joint) configuration, not according to the (individual) data
        % FIXME this should adhere to the general code guidelines, where
        % the order returned will be according to the first data argument!
        [dum, chancmbindx{k}] = match_str(cfgcmb, datcmb);
      end
      
    case 'union'
      % FIXME this is not yet implemented
      ft_error('union of channel combination is not yet supported');
      
    otherwise
      ft_error('invalid value for cfg.select');
  end % switch
  
  
end

end % function getselection_chancmb

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spikeindx, cfg] = getselection_spike(cfg, varargin)
% possible specifications are
% cfg.latency = string -> 'all'
% cfg.latency = [beg end]
% cfg.trials  = string -> 'all'
% cfg.trials  = vector with indices

ndata    = numel(varargin);
varargin = varargin(1:ndata);

if isequal(cfg.latency, 'all') && isequal(cfg.trials, 'all')
  spikeindx = cell(1,ndata);
  for i=1:ndata
    spikeindx{i} = num2cell(nan(1, length(varargin{i}.time)));
  end
  return
end

trialbeg = varargin{1}.trialtime(:,1);
trialend = varargin{1}.trialtime(:,2);
for i=2:ndata
  trialbeg = cat(1, trialbeg, varargin{1}.trialtime(:,1));
  trialend = cat(1, trialend, varargin{1}.trialtime(:,2));
end

% convert string into a numeric selection
if ischar(cfg.latency)
  switch cfg.latency
    case 'all'
      cfg.latency = [-inf inf];
    case 'maxperiod'
      cfg.latency = [min(trialbeg) max(trialend)];
    case 'minperiod'
      cfg.latency = [max(trialbeg) min(trialend)];
    case 'prestim'
      cfg.latency = [min(trialbeg) 0];
    case 'poststim'
      cfg.latency = [0 max(trialend)];
    otherwise
      ft_error('incorrect specification of cfg.latency');
  end % switch
end

spikeindx = cell(1,ndata);
for i=1:ndata
  nchan = length(varargin{i}.time);
  spikeindx{i} = cell(1,nchan);
  for j=1:nchan
    selbegtime = varargin{i}.time{j}>=cfg.latency(1);
    selendtime = varargin{i}.time{j}<=cfg.latency(2);
    if isequal(cfg.trials, 'all')
      seltrial = true(size(varargin{i}.trial{j}));
    else
      seltrial = ismember(varargin{i}.trial{j}, cfg.trials);
    end
    spikeindx{i}{j} = find(selbegtime & selendtime & seltrial);
  end
end

end % function getselection_spiketime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [timeindx, cfg] = getselection_time(cfg, varargin)
% possible specifications are
% cfg.latency = value     -> can be 'all'
% cfg.latency = [beg end]

if ft_datatype(varargin{1}, 'spike')
  ft_error('latency selection in spike data is not supported')
end

selmode  = varargin{end};
tol      = varargin{end-1};
ndata    = numel(varargin)-2;
varargin = varargin(1:ndata);

if isequal(cfg.latency, 'all') && iscell(varargin{1}.time)
  % for raw data this means that all trials should be selected as they are
  % for timelock/freq data it is still needed to make the intersection between data arguments
  timeindx = cell(1,ndata);
  for i=1:ndata
    % the nan return value specifies that no selection was specified
    timeindx{i} = num2cell(nan(1, length(varargin{i}.time)));
  end
  return
end

% if there is a single timelock/freq input, there is one time vector
% if there are multiple timelock/freq inputs, there are multiple time vectors
% if there is a single raw input, there are multiple time vectors
% if there are multiple raw inputs, there are multiple time vectors

% collect all time axes in one large cell-array
alltimecell = {};
if iscell(varargin{1}.time)
  for k = 1:ndata
    alltimecell = [alltimecell varargin{k}.time{:}];
  end
else
  for k = 1:ndata
    alltimecell = [alltimecell {varargin{k}.time}];
  end
end

% the nan return value specifies that no selection was specified
timeindx = repmat({nan}, size(alltimecell));

% loop over data once to determine the union of all time axes
alltimevec = zeros(1,0);
for k = 1:length(alltimecell)
  alltimevec = union(alltimevec, round(alltimecell{k}/tol)*tol);
end

indx = nan(numel(alltimevec), numel(alltimecell));
for k = 1:numel(alltimecell)
  [dum, ix, iy] = intersect(alltimevec, round(alltimecell{k}/tol)*tol);
  indx(ix,k) = iy;
end

if iscell(varargin{1}.time) && ischar(cfg.latency)&& ~strcmp(cfg.latency, 'minperiod')
  % if the input data arguments are of type 'raw', temporarily set the
  % selmode to union, otherwise the potentially different length trials
  % will be truncated to the shorted epoch, prior to latency selection.
  selmode = 'union';
elseif ischar(cfg.latency) && strcmp(cfg.latency, 'minperiod')
  % enforce intersect
  selmode = 'intersect';
end
switch selmode
  case 'intersect'
    sel        = sum(isfinite(indx),2)==numel(alltimecell);
    indx       = indx(sel,:);
    alltimevec = alltimevec(sel);
  case 'union'
    % don't do a subselection
  otherwise
    ft_error('invalid value for cfg.select');
end

% Note that cfg.toilim handling has been removed, as it was renamed to cfg.latency

% convert a string selection into a numeric selection
if ischar(cfg.latency)
  switch cfg.latency
    case {'all' 'maxperlen' 'maxperiod'}
      cfg.latency = [min(alltimevec) max(alltimevec)];
    case 'prestim'
      cfg.latency = [min(alltimevec) 0];
    case 'poststim'
      cfg.latency = [0 max(alltimevec)];
    case 'minperiod'
      % the time vector has been pruned above
      cfg.latency = [min(alltimevec) max(alltimevec)];
    otherwise
      ft_error('incorrect specification of cfg.latency');
  end % switch
end

% deal with numeric selection
if isempty(cfg.latency)
  for k = 1:numel(alltimecell)
    % FIXME I do not understand this
    % this signifies that all time bins are deselected and should be removed
    timeindx{k} = [];
  end
  
elseif numel(cfg.latency)==1
  % this single value should be within the time axis of each input data structure
  if numel(alltimevec)>1
    tbin = nearest(alltimevec, cfg.latency, true, true); % determine the numerical tolerance
  else
    tbin = nearest(alltimevec, cfg.latency, true, false); % don't consider tolerance
  end
  cfg.latency = alltimevec(tbin);
  
  for k = 1:ndata
    timeindx{k} = indx(tbin, k);
  end
  
elseif numel(cfg.latency)==2
  % the [min max] range can be specifed with +inf or -inf, but should
  % at least partially overlap with the time axis of the input data
  mintime = min(alltimevec);
  maxtime = max(alltimevec);
  if all(cfg.latency<mintime) || all(cfg.latency>maxtime)
    ft_error('the selected time range falls outside the time axis in the data');
  end
  tbeg = nearest(alltimevec, cfg.latency(1), false, false);
  tend = nearest(alltimevec, cfg.latency(2), false, false);
  cfg.latency = alltimevec([tbeg tend]);
  
  for k = 1:numel(alltimecell)
    timeindx{k} = indx(tbeg:tend, k);
    % if the input data arguments are of type 'raw', the non-finite values
    % need to be removed from the individual cells to ensure correct
    % behavior
    if iscell(varargin{1}.time)
      timeindx{k} = timeindx{k}(isfinite(timeindx{k}));
    end
  end
  
elseif size(cfg.latency,2)==2
  % this may be used for specification of the computation, not for data selection
  
else
  ft_error('incorrect specification of cfg.latency');
end

for k = 1:numel(alltimecell)
  if ~iscell(varargin{1}.time)
    if isequal(timeindx{k}(:)', 1:length(alltimecell{k}))
      % no actual selection is needed for this data structure
      timeindx{k} = nan;
    end
  else
    % if the input data arguments are of type 'raw', they need to be
    % handled differently, because the individual trials can be of
    % different length
  end
end

if iscell(varargin{1}.time)
  % split all time axes again over the different input raw data structures
  dum = cell(1,ndata);
  for k = 1:ndata
    sel = 1:length(varargin{k}.time);
    dum{k} = timeindx(sel); % get the first selection
    timeindx(sel) = []; % remove the first selection
  end
  timeindx = dum;
else
  % no splitting is needed, each input data structure has one selection
end

end % function getselection_time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [freqindx, cfg] = getselection_freq(cfg, varargin)
% possible specifications are
% cfg.frequency = value     -> can be 'all'
% cfg.frequency = [beg end]

selmode  = varargin{end};
tol      = varargin{end-1};
ndata    = numel(varargin)-2;
varargin = varargin(1:ndata);

% loop over data once to initialize
freqindx = cell(ndata,1);
freqaxis = zeros(1,0);
for k = 1:ndata
  % the nan return value specifies that no selection was specified
  freqindx{k} = nan;
  
  % update the axis along which the frequencies are defined
  freqaxis = union(freqaxis, round(varargin{k}.freq(:)/tol)*tol);
end

indx = nan+zeros(numel(freqaxis), ndata);
for k = 1:ndata
  [dum, ix, iy] = intersect(freqaxis, round(varargin{k}.freq(:)/tol)*tol);
  indx(ix,k) = iy;
end

switch selmode
  case 'intersect'
    sel      = sum(isfinite(indx),2)==ndata;
    indx     = indx(sel,:);
    freqaxis = varargin{1}.freq(indx(:,1));
  case 'union'
    % don't do a subselection
  otherwise
    ft_error('invalid value for cfg.select');
end

if isfield(cfg, 'frequency')
  % deal with string selection
  % some of these do not make sense, but are here for consistency with ft_multiplotER
  if ischar(cfg.frequency)
    if strcmp(cfg.frequency, 'all')
      cfg.frequency = [min(freqaxis) max(freqaxis)];
    elseif strcmp(cfg.frequency, 'maxmin')
      cfg.frequency = [min(freqaxis) max(freqaxis)]; % the same as 'all'
    elseif strcmp(cfg.frequency, 'minzero')
      cfg.frequency = [min(freqaxis) 0];
    elseif strcmp(cfg.frequency, 'maxabs')
      cfg.frequency = [-max(abs(freqaxis)) max(abs(freqaxis))];
    elseif strcmp(cfg.frequency, 'zeromax')
      cfg.frequency = [0 max(freqaxis)];
    elseif strcmp(cfg.frequency, 'zeromax')
      cfg.frequency = [0 max(freqaxis)];
    else
      ft_error('incorrect specification of cfg.frequency');
    end
  end
  
  % deal with numeric selection
  if isempty(cfg.frequency)
    for k = 1:ndata
      % FIXME I do not understand this
      % this signifies that all frequency bins are deselected and should be removed
      freqindx{k} = [];
    end
    
  elseif numel(cfg.frequency)==1
    % this single value should be within the frequency axis of each input data structure
    if numel(freqaxis)>1
      fbin = nearest(freqaxis, cfg.frequency, true, true); % determine the numerical tolerance
    else
      fbin = nearest(freqaxis, cfg.frequency, true, false); % don't consider tolerance
    end
    cfg.frequency = freqaxis(fbin);
    
    for k = 1:ndata
      freqindx{k} = indx(fbin,k);
    end
    
  elseif numel(cfg.frequency)==2
    % the [min max] range can be specifed with +inf or -inf, but should
    % at least partially overlap with the freq axis of the input data
    minfreq = min(freqaxis);
    maxfreq = max(freqaxis);
    if all(cfg.frequency<minfreq) || all(cfg.frequency>maxfreq)
      ft_error('the selected range falls outside the frequency axis in the data');
    end
    fbeg = nearest(freqaxis, cfg.frequency(1), false, false);
    fend = nearest(freqaxis, cfg.frequency(2), false, false);
    cfg.frequency = freqaxis([fbeg fend]);
    
    for k = 1:ndata
      freqindx{k} = indx(fbeg:fend,k);
    end
    
  elseif size(cfg.frequency,2)==2
    % this may be used for specification of the computation, not for data selection
    
  else
    ft_error('incorrect specification of cfg.frequency');
  end
end % if cfg.frequency

for k = 1:ndata
  if isequal(freqindx{k}, 1:length(varargin{k}.freq))
    % the cfg was updated, but no selection is needed for the data
    freqindx{k} = nan;
  end
end

end % function getselection_freq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rptindx, cfg, rptdim, rpttapindx] = getselection_rpt(cfg, varargin)
% this should deal with cfg.trials

dimord   = varargin{end};
ndata    = numel(varargin)-1;
data     = varargin{1:ndata}; % this syntax ensures that it will only work on a single data input

dimtok = tokenize(dimord, '_');
rptdim = find(strcmp(dimtok, '{rpt}') | strcmp(dimtok, 'rpt') | strcmp(dimtok, 'rpttap') | strcmp(dimtok, 'subj'));

if isequal(cfg.trials, 'all')
  rptindx    = nan; % the nan return value specifies that no selection was specified
  rpttapindx = nan; % the nan return value specifies that no selection was specified
  
elseif isempty(rptdim)
  % FIXME should [] not mean that none of the trials is to be selected?
  rptindx    = nan; % the nan return value specifies that no selection was specified
  rpttapindx = nan; % the nan return value specifies that no selection was specified
  
else
  rptindx = ft_getopt(cfg, 'trials');
  
  if islogical(rptindx)
    % convert from booleans to indices
    rptindx = find(rptindx);
  end
  
  rptindx = unique(sort(rptindx));
  
  if strcmp(dimtok{rptdim}, 'rpttap') && isfield(data, 'cumtapcnt')
    % there are tapers in the data
    
    % determine for each taper to which trial it belongs
    nrpt = size(data.cumtapcnt, 1);
    taper = zeros(nrpt, 1);
    sumtapcnt = cumsum([0; data.cumtapcnt(:)]);
    begtapcnt = sumtapcnt(1:end-1)+1;
    endtapcnt = sumtapcnt(2:end);
    for i=1:nrpt
      taper(begtapcnt(i):endtapcnt(i)) = i;
    end
    rpttapindx = find(ismember(taper, rptindx));
    
  else
    % there are no tapers in the data
    rpttapindx = rptindx;
  end
end

end % function getselection_rpt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [posindx, cfg] = getselection_pos(cfg, varargin)
% possible specifications are <none>

ndata   = numel(varargin)-2;
tol     = varargin{end-1}; % FIXME this is still ignored
selmode = varargin{end};   % FIXME this is still ignored
data    = varargin(1:ndata);

for i=1:ndata
  if ~isequal(varargin{i}.pos, varargin{1}.pos)
    % FIXME it would be possible here to make a selection based on intersect or union
    ft_error('not yet implemented');
  end
end

if strcmp(cfg.select, 'union')
  % FIXME it would be possible here to make a selection based on intersect or union
  ft_error('not yet implemented');
end

for i=1:ndata
  posindx{i} = nan;    % the nan return value specifies that no selection was specified
end
end % function getselection_pos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = squeezedim(x, dim)
siz = size(x);
for i=(numel(siz)+1):numel(dim)
  % all trailing singleton dimensions have length 1
  siz(i) = 1;
end
if isvector(x) && ~(isrow(x) && dim(1) && numel(x)>1)
  % there is no harm to keep it as it is, unless the data matrix is 1xNx1x1
elseif istable(x)
  % there is no harm to keep it as it is
else
  x = reshape(x, [siz(~dim) 1]);
end
end % function squeezedim

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = makeunion(x, field)
old = cellfun(@getfield, x, repmat({field}, size(x)), 'uniformoutput', false);
if iscell(old{1})
  % empty is indicated to represent missing value for a cell-array (label, labelcmb)
  new = old{1};
  for i=2:length(old)
    sel = ~cellfun(@isempty, old{i});
    new(sel) = old{i}(sel);
  end
else
  % nan is indicated to represent missing value for a numeric array (time, freq, pos)
  new = old{1};
  for i=2:length(old)
    sel = ~isnan(old{i});
    new(sel) = old{i}(sel);
  end
end
x = cellfun(@setfield, x, repmat({field}, size(x)), repmat({new}, size(x)), 'uniformoutput', false);
end % function makeunion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to make a selextion in data representations like {pos}_ori_time
% FIXME this will fail for {xxx_yyy}_zzz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = cellmatselect(x, seldim, selindx, maybevector)
if nargin<4
  % some fields are a vector with an unspecified singleton dimension, these can be transposed
  % if the singleton dimension represents something explicit, they should not be transposed
  % they might for example represent a single trial, or a single channel
  maybevector = true;
end
if iscell(x)
  if seldim==1
    x = x(selindx);
  else
    for i=1:numel(x)
      if isempty(x{i})
        continue
      end
      switch seldim
        case 2
          if maybevector && isvector(x{i})
            % sometimes the data is 1xN, whereas the dimord describes only the first dimension
            % in this case a row and column vector can be interpreted as equivalent
            x{i} = x{i}(selindx);
          elseif istable(x)
            % multidimensional indexing is not supported
            x{i} = x{i}(selindx,:);
          else
            x{i} = x{i}(selindx,:,:,:,:);
          end
        case 3
          x{i} = x{i}(:,selindx,:,:,:);
        case 4
          x{i} = x{i}(:,:,selindx,:,:);
        case 5
          x{i} = x{i}(:,:,:,selindx,:);
        case 6
          x{i} = x{i}(:,:,:,:,selindx);
        otherwise
          ft_error('unsupported dimension (%d) for making a selection', seldim);
      end % switch
    end % for
  end
else
  switch seldim
    case 1
      if maybevector && isvector(x)
        % sometimes the data is 1xN, whereas the dimord describes only the first dimension
        % in this case a row and column vector can be interpreted as equivalent
        x = x(selindx);
      elseif istable(x)
        % multidimensional indexing is not supported
        x = x(selindx,:);
      else
        x = x(selindx,:,:,:,:,:);
      end
    case 2
      x = x(:,selindx,:,:,:,:);
    case 3
      x = x(:,:,selindx,:,:,:);
    case 4
      x = x(:,:,:,selindx,:,:);
    case 5
      x = x(:,:,:,:,selindx,:);
    case 6
      x = x(:,:,:,:,:,selindx);
    otherwise
      ft_error('unsupported dimension (%d) for making a selection', seldim);
  end
end
end % function cellmatselect

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to take an average in data representations like {pos}_ori_time
% FIXME this will fail for {xxx_yyy}_zzz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = cellmatmean(x, seldim, average)
if iscell(x)
  if seldim==1
    for i=2:numel(x)
      x{1} = x{1} + x{i};
    end
    x = {x{1}/numel(x)};
  else
    for i=1:numel(x)
      x{i} = average(x{i}, seldim-1);
    end % for
  end
else
  x = average(x, seldim);
end
end % function cellmatmean
                                                                                                                                                                                             n = fieldnames(data);
fd = nan(size(fn));
for i=1:numel(fn)
  fd(i) = ndims(data.(fn{i}));
end

if ~isfield(data, 'dim')
  % this part depends on the assumption that the list of positions is describing a full 3D volume in
  % an ordered way which allows for the extraction of a transformation matrix, i.e. slice by slice
  data.dim = pos2dim(data.pos);
  try
    % if the dim is correct, it should be possible to obtain the transform
    ws = warning('off', 'MATLAB:rankDeficientMatrix');
    pos2transform(data.pos, data.dim);
    warning(ws);
  catch
    % remove the incorrect dim
    data = rmfield(data, 'dim');
  end
end

if isfield(data, 'dim')
  data.transform = pos2transform(data.pos, data.dim);
end

% remove the unwanted fields
data = removefields(data, {'pos', 'xgrid', 'ygrid', 'zgrid', 'tri', 'tet', 'hex'});

% make inside a volume
data = fixinside(data, 'logical');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = freq2raw(freq)

if isfield(freq, 'powspctrm')
  param = 'powspctrm';
elseif isfield(freq, 'fourierspctrm')
  param = 'fourierspctrm';
else
  ft_error('not supported for this data representation');
end

if strcmp(freq.dimord, 'rpt_chan_freq_time') || strcmp(freq.dimord, 'rpttap_chan_freq_time')
  dat = freq.(param);
elseif strcmp(freq.dimord, 'chan_freq_time')
  dat = freq.(param);
  dat = reshape(dat, [1 size(dat)]); % add a singleton dimension
else
  ft_error('not supported for dimord %s', freq.dimord);
end

nrpt  = size(dat,1);
nchan = size(dat,2);
nfreq = size(dat,3);
ntime = size(dat,4);
data = [];
% create the channel labels like "MLP11@12Hz""
k = 0;
for i=1:nfreq
  for j=1:nchan
    k = k+1;
    data.label{k} = sprintf('%s@%dHz', freq.label{j}, freq.freq(i));
  end
end
% reshape and copy the data as if it were timecourses only
for i=1:nrpt
  data.time{i}  = freq.time;
  data.trial{i} = reshape(dat(i,:,:,:), nchan*nfreq, ntime);
  if any(sum(isnan(data.trial{i}),1)==size(data.trial{i},1))
    tmp = sum(~isfinite(data.trial{i}),1)==size(data.trial{i},1);
    begsmp = find(~tmp,1, 'first');
    endsmp = find(~tmp,1, 'last' );
    data.trial{i} = data.trial{i}(:, begsmp:endsmp);
    data.time{i}  = data.time{i}(begsmp:endsmp);
  end
end

if isfield(freq, 'trialinfo'), data.trialinfo = freq.trialinfo; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tlck] = raw2timelock(data)

data   = ft_checkdata(data, 'hassampleinfo', 'yes');
ntrial = numel(data.trial);
nchan  = numel(data.label);

if ntrial==1
  tlck.time   = data.time{1};
  tlck.avg    = data.trial{1};
  tlck.label  = data.label;
  tlck.dimord = 'chan_time';
  tlck        = copyfields(data, tlck, {'grad', 'elec', 'opto', 'cfg', 'trialinfo', 'topo', 'topodimord', 'topolabel', 'unmixing', 'unmixingdimord'});
  
else
  % the code below tries to construct a general time-axis where samples of all trials can fall on
  % find the earliest beginning and latest ending
  begtime = min(cellfun(@min, data.time));
  endtime = max(cellfun(@max, data.time));
  % find 'common' sampling rate
  fsample = 1./nanmean(cellfun(@mean, cellfun(@diff,data.time, 'uniformoutput', false)));
  % estimate number of samples
  nsmp = round((endtime-begtime)*fsample) + 1; % numerical round-off issues should be dealt with by this round, as they will/should never cause an extra sample to appear
  % construct general time-axis
  time = linspace(begtime,endtime,nsmp);
  
  % concatenate all trials
  tmptrial = nan(ntrial, nchan, length(time));
  
  begsmp = nan(ntrial, 1);
  endsmp = nan(ntrial, 1);
  for i=1:ntrial
    begsmp(i) = nearest(time, data.time{i}(1));
    endsmp(i) = nearest(time, data.time{i}(end));
    tmptrial(i,:,begsmp(i):endsmp(i)) = data.trial{i};
  end
  
  % construct the output timelocked data
  tlck.trial   = tmptrial;
  tlck.time    = time;
  tlck.dimord  = 'rpt_chan_time';
  tlck.label   = data.label;
  tlck         = copyfields(data, tlck, {'grad', 'elec', 'opto', 'cfg', 'trialinfo', 'sampleinfo', 'topo', 'topodimord', 'topolabel', 'unmixing', 'unmixingdimord'});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = timelock2raw(data)
fn = getdatfield(data);
if any(ismember(fn, {'trial', 'individual', 'avg'}))
  % trial, individual and avg (in that order) should be preferred over all other data fields
  % see http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=2965#c12
  fn = fn(ismember(fn, {'trial', 'individual', 'avg'}));
end
dimord = cell(size(fn));
for i=1:numel(fn)
  % determine the dimensions of each of the data fields
  dimord{i} = getdimord(data, fn{i});
end
% the fields trial, individual and avg (with their corresponding default dimord) are preferred
if sum(strcmp(dimord, 'rpt_chan_time'))==1
  fn = fn{strcmp(dimord, 'rpt_chan_time')};
  ft_info('constructing trials from "%s"\n', fn);
  dimsiz = getdimsiz(data, fn);
  ntrial = dimsiz(1);
  nchan  = dimsiz(2);
  ntime  = dimsiz(3);
  tmptrial = {};
  tmptime  = {};
  for j=1:ntrial
    tmptrial{j} = reshape(data.(fn)(j,:,:), [nchan, ntime]);
    tmptime{j}  = data.time;
  end
  data       = rmfield(data, fn);
  data.trial = tmptrial;
  data.time  = tmptime;
elseif sum(strcmp(dimord, 'subj_chan_time'))==1
  fn = fn{strcmp(dimord, 'subj_chan_time')};
  ft_info('constructing trials from "%s"\n', fn);
  dimsiz = getdimsiz(data, fn);
  nsubj = dimsiz(1);
  nchan  = dimsiz(2);
  ntime  = dimsiz(3);
  tmptrial = {};
  tmptime  = {};
  for j=1:nsubj
    tmptrial{j} = reshape(data.(fn)(j,:,:), [nchan, ntime]);
    tmptime{j}  = data.time;
  end
  data       = rmfield(data, fn);
  data.trial = tmptrial;
  data.time  = tmptime;
elseif sum(strcmp(dimord, 'chan_time'))==1
  fn = fn{strcmp(dimord, 'chan_time')};
  ft_info('constructing single trial from "%s"\n', fn);
  data.time  = {data.time};
  data.trial = {data.(fn)};
  data = rmfield(data, fn);
else
  ft_error('unsupported data structure');
end
% remove unwanted fields
data = removefields(data, {'avg', 'var', 'cov', 'dimord', 'numsamples' ,'dof'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = chan2freq(data)
data.dimord = [data.dimord '_freq'];
data.freq   = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = chan2timelock(data)
data.dimord = [data.dimord '_time'];
data.time   = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spike] = raw2spike(data)
ft_info('converting raw data into spike data\n');
nTrials 	 = length(data.trial);
[spikelabel] = detectspikechan(data);
spikesel     = match_str(data.label, spikelabel);
nUnits       = length(spikesel);
if nUnits==0
  ft_error('cannot convert raw data to spike format since the raw data structure does not contain spike channels');
end

trialTimes  = zeros(nTrials,2);
for iUnit = 1:nUnits
  unitIndx = spikesel(iUnit);
  spikeTimes  = []; % we dont know how large it will be, so use concatenation inside loop
  trialInds   = [];
  for iTrial = 1:nTrials
    
    % read in the spike times
    [spikeTimesTrial]    = getspiketimes(data, iTrial, unitIndx);
    nSpikes              = length(spikeTimesTrial);
    spikeTimes           = [spikeTimes; spikeTimesTrial(:)];
    trialInds            = [trialInds; ones(nSpikes,1)*iTrial];
    
    % get the begs and ends of trials
    hasNum = find(~isnan(data.time{iTrial}));
    if iUnit==1, trialTimes(iTrial,:) = data.time{iTrial}([hasNum(1) hasNum(end)]); end
  end
  
  spike.label{iUnit}     = data.label{unitIndx};
  spike.waveform{iUnit}  = [];
  spike.time{iUnit}      = spikeTimes(:)';
  spike.trial{iUnit}     = trialInds(:)';
  
  if iUnit==1, spike.trialtime             = trialTimes; end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = spike2raw(spike, fsample)

if nargin<2 || isempty(fsample)
  timeDiff = abs(diff(sort([spike.time{:}])));
  fsample  = 1/min(timeDiff(timeDiff>0));
  ft_warning('Desired sampling rate for spike data not specified, automatically resampled to %f', fsample);
end

% get some sizes
nUnits  = length(spike.label);
nTrials = size(spike.trialtime,1);

% preallocate
data.trial(1:nTrials) = {[]};
data.time(1:nTrials)  = {[]};
for iTrial = 1:nTrials
  
  % make bins: note that the spike.time is already within spike.trialtime
  x = [spike.trialtime(iTrial,1):(1/fsample):spike.trialtime(iTrial,2)];
  timeBins   = [x x(end)+1/fsample] - (0.5/fsample);
  time       = (spike.trialtime(iTrial,1):(1/fsample):spike.trialtime(iTrial,2));
  
  % convert to continuous
  trialData = zeros(nUnits,length(time));
  for iUnit = 1:nUnits
    
    % get the timestamps and only select those timestamps that are in the trial
    ts       = spike.time{iUnit};
    hasTrial = spike.trial{iUnit}==iTrial;
    ts       = ts(hasTrial);
    
    N = histc(ts,timeBins);
    if isempty(N)
      N = zeros(1,length(timeBins)-1);
    else
      N(end) = [];
    end
    
    % store it in a matrix
    trialData(iUnit,:) = N;
  end
  
  data.trial{iTrial} = trialData;
  data.time{iTrial}  = time;
  
end % for all trials

% create the associated labels and other aspects of data such as the header
data.label = spike.label;
data.fsample = fsample;
if isfield(spike,'hdr'), data.hdr = spike.hdr; end
if isfield(spike,'cfg'), data.cfg = spike.cfg; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = source2raw(source)

fn = fieldnames(source);
fn = setdiff(fn, {'pos', 'dim', 'transform', 'time', 'freq', 'cfg'});
for i=1:length(fn)
  dimord{i} = getdimord(source, fn{i});
end
sel = strcmp(dimord, 'pos_time');
assert(sum(sel)>0, 'the source structure does not contain a suitable field to represent as raw channel-level data');
assert(sum(sel)<2, 'the source structure contains multiple fields that can be represented as raw channel-level data');
fn     = fn{sel};
dimord = dimord{sel};

switch dimord
  case 'pos_time'
    % add fake raw channel data to the original data structure
    data.trial{1} = source.(fn);
    data.time{1}  = source.time;
    % add fake channel labels
    data.label = {};
    for i=1:size(source.pos,1)
      data.label{i} = sprintf('source%d', i);
    end
    data.label = data.label(:);
    data.cfg = source.cfg;
  otherwise
    % FIXME other formats could be implemented as well
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for detection of channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spikelabel, eeglabel] = detectspikechan(data)

maxRate = 2000; % default on what we still consider a neuronal signal: this firing rate should never be exceeded

% autodetect the spike channels
ntrial = length(data.trial);
nchans  = length(data.label);
spikechan = zeros(nchans,1);
for i=1:ntrial
  for j=1:nchans
    hasAllInts    = all(isnan(data.trial{i}(j,:)) | data.trial{i}(j,:) == round(data.trial{i}(j,:)));
    hasAllPosInts = all(isnan(data.trial{i}(j,:)) | data.trial{i}(j,:)>=0);
    T = nansum(diff(data.time{i}),2); % total time
    fr            = nansum(data.trial{i}(j,:),2) ./ T;
    spikechan(j)  = spikechan(j) + double(hasAllInts & hasAllPosInts & fr<=maxRate);
  end
end
spikechan = (spikechan==ntrial);

spikelabel = data.label(spikechan);
eeglabel   = data.label(~spikechan);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spikeTimes] = getspiketimes(data, trial, unit)
spikeIndx       = logical(data.trial{trial}(unit,:));
spikeCount      = data.trial{trial}(unit,spikeIndx);
spikeTimes      = data.time{trial}(spikeIndx);
if isempty(spikeTimes), return; end
multiSpikes     = find(spikeCount>1);
% get the additional samples and spike times, we need only loop through the bins
[addSamples, addTimes]   = deal([]);
for iBin = multiSpikes(:)' % looping over row vector
  addTimes     = [addTimes ones(1,spikeCount(iBin))*spikeTimes(iBin)];
  addSamples   = [addSamples ones(1,spikeCount(iBin))*spikeIndx(iBin)];
end
% before adding these times, first remove the old ones
spikeTimes(multiSpikes) = [];
spikeTimes              = sort([spikeTimes(:); addTimes(:)]);
                                                                                                                    'biosemi128'
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
     