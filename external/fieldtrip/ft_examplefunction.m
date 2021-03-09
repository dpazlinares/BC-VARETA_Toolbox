function [dataout] = ft_examplefunction(cfg, datain)

% FT_EXAMPLEFUNCTION demonstrates to new developers how a FieldTrip function should look like
%
% Use as
%   outdata = ft_examplefunction(cfg, indata)
% where indata is <<describe the type of data or where it comes from>>
% and cfg is a configuration structure that should contain
%
% <<note that the cfg list should be indented with two spaces
%
%  cfg.option1    = value, explain the value here (default = something)
%  cfg.option2    = value, describe the value here and if needed
%                   continue here to allow automatic parsing of the help
%
% The configuration can optionally contain
%   cfg.option3   = value, explain it here (default is automatic)
%
% To facilitate data-handling and distributed computing you can use
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%
% See also <<give a list of function names, all in capitals>>

% Here come the Copyrights
%
% Here comes the Revision tag, which is auto-updated by the version control system
% $Id$

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the initial part deals with parsing the input options and data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these are used by the ft_preamble/ft_postamble function and scripts
ft_revision = '$Id$';
ft_nargin   = nargin;
ft_nargout  = nargout;

% do the general setup of the function

% the ft_preamble function works by calling a number of scripts from
% fieldtrip/utility/private that are able to modify the local workspace

ft_defaults                   % this ensures that the path is correct and that the ft_defaults global variable is available
ft_preamble init              % this will reset ft_warning and show the function help if nargin==0 and return an error
ft_preamble debug             % this allows for displaying or saving the function name and input arguments upon an error
ft_preamble loadvar    datain % this reads the input data in case the user specified the cfg.inputfile option
ft_preamble provenance datain % this records the time and memory usage at the beginning of the function
ft_preamble trackconfig       % this converts the cfg structure in a config object, which tracks the cfg options that are being used

% the ft_abort variable is set to true or false in ft_preamble_init
if ft_abort
  % do not continue function execution in case the outputfile is present and the user indicated to keep it
  return
end

% ensure that the input data is valid for this function, this will also do
% backward-compatibility conversions of old data that for example was
% read from an old *.mat file
datain = ft_checkdata(datain, 'datatype', {'raw+comp', 'raw'}, 'feedback', 'yes', 'hassampleinfo', 'yes');

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'deprecated',  {'normalizecov', 'normalizevar'});
cfg = ft_checkconfig(cfg, 'renamed',     {'blc', 'demean'});
cfg = ft_checkconfig(cfg, 'renamed',     {'blcwindow', 'baselinewindow'});

% ensure that the required options are present
cfg = ft_checkconfig(cfg, 'required', {'method', 'foi', 'tapsmofrq'});

% ensure that the options are valid
cfg = ft_checkopt(cfg, 'vartrllen', 'double', {0, 1, 2});
cfg = ft_checkopt(cfg, 'method', 'char', {'mtm', 'convol'});

% get the options
method    = ft_getopt(cfg, 'method');        % there is no default
vartrllen = ft_getopt(cfg, 'vartrllen', 2);  % the default is 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the actual computation is done in the middle part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% do your stuff...
dataout = [];

% this might involve more active checking of whether the input options
% are consistent with the data and with each other

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deal with the output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% do the general cleanup and bookkeeping at the end of the function

% the ft_postamble function works by calling a number of scripts from
% fieldtrip/utility/private that are able to modify the local workspace

ft_postamble debug               % this clears the onCleanup function used for debugging in case of an error
ft_postamble trackconfig         % this converts the config object back into a struct and can report on the unused fields
ft_postamble previous   datain   % this copies the datain.cfg structure into the cfg.previous field. You can also use it for multiple inputs, or for "varargin"
ft_postamble provenance dataout  % this records the time and memory at the end of the function, prints them on screen and adds this information together with the function name and MATLAB version etc. to the output cfg
ft_postamble history    dataout  % this adds the local cfg structure to the output data structure, i.e. dataout.cfg = cfg
ft_postamble savevar    dataout  % this saves the output data structure to disk in case the user specified the cfg.outputfile option
                                                                                                                                                                                                                                                                                                                                               leinfo', 'yes');

% ensure that the required options are present
cfg         = ft_checkconfig(cfg, 'required', {'method'});
cfg.trials  = ft_getopt(cfg, 'trials',  'all', 1); % all trials as default
cfg.channel = ft_getopt(cfg, 'channel', 'all');
cfg.output  = ft_getopt(cfg, 'output',  'model');
% ensure that the options are valid
cfg = ft_checkopt(cfg, 'method', 'char', {'aseo' 'gbve'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the actual computation is done in the middle part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select trials of interest
tmpcfg = keepfields(cfg, {'trials' 'channel' 'showcallinfo'});
data   = ft_selectdata(tmpcfg, data);
% restore the provenance information
[cfg, data] = rollback_provenance(cfg, data);

% some error checks
if isfield(data, 'trial') && numel(data.trial)==0, ft_error('no trials were selected'); end
if numel(data.label)==0, ft_error('no channels were selected'); end

switch cfg.method  
  case 'aseo'
    % define general variables that are used locally
    fsample = data.fsample; % Sampling Frequency in Hz
    nchan   = numel(data.label);
    nsample = numel(data.time{1}); %FIXME ASSUMING FIXED TIME AXIS ACROSS ALL TRIALS

    % setting a bunch of options, to be passed on to the lower level function
    if ~isfield(cfg, 'aseo'), cfg.aseo = []; end 
    cfg.aseo.thresholdAmpH = ft_getopt(cfg.aseo, 'thresholdAmpH', 0.5);
    cfg.aseo.thresholdAmpL = ft_getopt(cfg.aseo, 'thresholdAmpL', 0.1);
    cfg.aseo.thresholdCorr = ft_getopt(cfg.aseo, 'thresholdCorr', 0.2);
    cfg.aseo.maxOrderAR    = ft_getopt(cfg.aseo, 'maxOrderAR',    5);
    cfg.aseo.noiseEstimate = ft_getopt(cfg.aseo, 'noiseEstimate', 'nonparametric');
    cfg.aseo.numiteration  = ft_getopt(cfg.aseo, 'numiteration',  1);
    cfg.aseo.tapsmofrq     = ft_getopt(cfg.aseo, 'tapsmofrq',     5);
    cfg.aseo.fsample       = fsample;
    cfg.aseo.nsample       = nsample;
    cfg.aseo.pad           = ft_getopt(cfg.aseo, 'pad', (2.*nsample)/fsample);    
    
    % deal with the different ways with which the initial waveforms can be defined
    initlatency      = ft_getopt(cfg.aseo, 'initlatency', {});
    initcomp         = ft_getopt(cfg.aseo, 'initcomp',    {});
    jitter           = ft_getopt(cfg.aseo, 'jitter',      0.050); % half temporal width of shift in s
        
    if isempty(initlatency) && isempty(initcomp)
      ft_error('for the ASEO method you should supply either an initial estimate of the waveform component, or a set of latencies');
    elseif ~isempty(initlatency)
      % this takes precedence, and should contain per channel the begin and
      % end points of the subwindows in time, based on which the initial
      % subcomponents are estimated
    
      % ensure it to be a cell-array if the input is a matrix
      if ~iscell(initlatency)
        initlatency = repmat({initlatency},[1 nchan]);
      end
      make_init = true;
    elseif ~isempty(initcomp)
      % ensure it to be a cell-array if the input is a matrix
      if ~iscell(initcomp)
        initcomp = repmat({initcomp}, [1 nchan]);
      end
      make_init = false;
    end
    
    if make_init
      assert(numel(initlatency)==nchan);
      for k = 1:nchan
        % preprocessing data
        tmp     = cellrowselect(data.trial,k);
        chandat = cat(1,tmp{:});
        chandat = ft_preproc_baselinecorrect(chandat, nearest(data.time{1}, -inf), nearest(data.time{1}, 0));
        avgdat  = nanmean(chandat, 1);
                
        % set the initial ERP waveforms according to the preset parameters
        ncomp       = size(initlatency{k},1);
        initcomp{k} = zeros(nsample, ncomp);
        for m = 1:ncomp
          begsmp = nearest(data.time{1},initlatency{k}(m, 1));
          endsmp = nearest(data.time{1},initlatency{k}(m, 2));
          if begsmp<1,       begsmp = 1;       end
          if endsmp>nsample, endsmp = nsample; end
                 
          tmp = avgdat(begsmp:endsmp)';
          initcomp{k}(begsmp:endsmp, m) = tmp;
        end
        initcomp{k} = initcomp{k} - repmat(mean(initcomp{k}),nsample,1);
      end     
    else
      assert(numel(initcomp)==nchan);
    end
    
    if ~iscell(jitter)
      jitter = repmat({jitter}, [1 nchan]);
    end
    
    for k = 1:numel(jitter)
      if ~isempty(jitter{k})
        if size(jitter{k},1)~=size(initcomp{k},2), jitter{k} = repmat(jitter{k}(1,:),[size(initcomp{k},2) 1]); end
      end
    end
    
    % initialize the output data
    dataout = removefields(data, 'cfg');
    for k = 1:numel(data.trial)
      dataout.trial{k}(:) = nan;
    end
        
    % initialize the struct that will contain the output parameters
    params = struct([]);
    
    % do the actual computations
    for k = 1:nchan
      % preprocessing data
      tmp     = cellrowselect(data.trial,k);
      chandat = cat(1,tmp{:});
            
      % baseline correction
      chandat = ft_preproc_baselinecorrect(chandat, nearest(data.time{1}, -inf), nearest(data.time{1}, 0));
      
      % do zero-padding and FFT to the signal and initial waveforms
      npad         = cfg.aseo.pad*fsample;    % length of data + zero-padding number
      nfft         = 2.^(ceil(log2(npad)))*2;
      initcomp_fft = fft(initcomp{k}, nfft);  % Fourier transform of the initial waveform
      chandat_fft  = fft(chandat', nfft);     % Fourier transform of the signal
      
      cfg.aseo.jitter = jitter{k};
      output       = ft_singletrialanalysis_aseo(cfg, chandat_fft, initcomp_fft);
      
      params(k).latency    = output(end).lat_est./fsample;
      params(k).amplitude  = output(end).amp_est;
      params(k).components = output(end).erp_est;
      params(k).rejectflag = output(end).rejectflag;
      params(k).noise      = output(end).noise;
      
      for m = 1:numel(data.trial)
        if output(end).rejectflag(m)==0
          switch cfg.output
            case 'model'
              dataout.trial{m}(k,:) = data.trial{m}(k,:)-output(end).residual(:,m)';
            case 'residual'
              dataout.trial{m}(k,:) = output(end).residual(:,m)';
          end
        end
      end
    end
    
case 'gbve'
  ft_hastoolbox('lagextraction', 1);
  ft_hastoolbox('eeglab',        1); % because the low-level code might use a specific moving average function from EEGLAB
  ft_hastoolbox('cellfunction',  1);
  
  if ~isfield(cfg, 'gbve'), cfg.gbve = []; end
  cfg.gbve.NORMALIZE_DATA    = ft_getopt(cfg.gbve, 'NORMALIZE_DATA',     true);
  cfg.gbve.CENTER_DATA       = ft_getopt(cfg.gbve, 'CENTER_DATA',        false);
  cfg.gbve.USE_ADAPTIVE_SIGMA= ft_getopt(cfg.gbve, 'USE_ADAPTIVE_SIGMA', false);
  cfg.gbve.sigma             = ft_getopt(cfg.gbve, 'sigma',    0.01:0.01:0.2);
  cfg.gbve.distance          = ft_getopt(cfg.gbve, 'distance', 'corr2');
  cfg.gbve.alpha             = ft_getopt(cfg.gbve, 'alpha',    [0 0.001 0.01 0.1]);
  cfg.gbve.exponent          = ft_getopt(cfg.gbve, 'exponent', 1);
  cfg.gbve.use_maximum       = ft_getopt(cfg.gbve, 'use_maximum', 1); % consider the positive going peak
  cfg.gbve.show_pca          = ft_getopt(cfg.gbve, 'show_pca',          false);
  cfg.gbve.show_trial_number = ft_getopt(cfg.gbve, 'show_trial_number', false);
  cfg.gbve.verbose           = ft_getopt(cfg.gbve, 'verbose',           true);
  cfg.gbve.disp_log          = ft_getopt(cfg.gbve, 'disp_log',          false);
  cfg.gbve.latency           = ft_getopt(cfg.gbve, 'latency',  [-inf inf]);
  cfg.gbve.xwin              = ft_getopt(cfg.gbve, 'xwin',     1); % default is a bit of smoothing
  
  nchan = numel(data.label);
  ntrl  = numel(data.trial);
  
  tmin  = nearest(data.time{1}, cfg.gbve.latency(1));
  tmax  = nearest(data.time{1}, cfg.gbve.latency(2));

  % initialize the struct that will contain the output parameters
  dataout = removefields(data, 'cfg');
  params  = struct([]);
  for k = 1:nchan
    % preprocessing data
    options = cfg.gbve;
  
    fprintf('--- Processing channel %d\n',k);
    
    tmp     = cellrowselect(data.trial,k);
    chandat = cat(1,tmp{:});
    points  = chandat(:,tmin:tmax);
    
    % perform a loop across alpha values, cross validation
    alphas = options.alpha;
    
    if length(alphas) > 1 % Use Cross validation error if multiple alphas are specified
      best_CVerr = -Inf;

      K = 5;
      disp(['--- Running K Cross Validation (K = ',num2str(K),')']);

      block_idx = fix(linspace(1, ntrl, K+1)); % K cross validation
      for jj=1:length(alphas)
        options.alpha = alphas(jj);

        CVerr = 0;
        for kk = 1:K
          bidx = block_idx(kk):block_idx(kk+1);
          idx = 1:ntrl;
          idx(bidx) = [];

          data_k       = chandat(idx,:);
          points_k     = points(idx,:);
          [order,lags] = extractlag(points_k,options);

          data_reordered = data_k(order,:);
          lags           = lags + tmin;
          [data_aligned, ~] = perform_realign(data_reordered, data.time{1}, lags);
          data_aligned(~isfinite(data_aligned)) = nan;
          ep_evoked = nanmean(data_aligned);
          ep_evoked = ep_evoked ./ norm(ep_evoked);

          data_k = chandat(bidx,:);
          data_norm = sqrt(sum(data_k.^2,2));
          data_k = diag(1./data_norm)*data_k;
          data_k(data_norm==0,:) = 0;
          
          for pp=1:length(bidx)
            c     = xcorr(ep_evoked,data_k(pp,:));
            CVerr = CVerr + max(c(:));
          end
        end

        CVerr = CVerr/ntrl;

        if CVerr > best_CVerr
          best_CVerr = CVerr;
          best_alpha = alphas(jj);
        end
      end
      options.alpha = best_alpha;
    end

    if options.use_maximum
      [order,lags] = extractlag( points, options );
    else
      [order,lags] = extractlag( -points, options );
    end
    disp(['---------- Using alpha = ',num2str(options.alpha)]);
    data_reordered = chandat(order,:);
    lags = lags + tmin;
    [data_aligned] = perform_realign(data_reordered, data.time{1}, lags );
    data_aligned(~isfinite(data_aligned)) = nan;
    
    [~,order_inv] = sort(order);
    lags_no_order = lags(order_inv);
    data_aligned  = data_aligned(order_inv,:);
      
    params(k).latency = data.time{1}(lags_no_order)';
    switch cfg.output
      case 'model'
        tmp = mat2cell(data_aligned, ones(1,size(data_aligned,1)), size(data_aligned,2))';
        dataout.trial = cellrowassign(dataout.trial, tmp, k);
      case 'residual'
        % to be done
        error('not yet implemented');
    end
  end
  
end

dataout.params = params;
dataout.cfg    = cfg;

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous   data
ft_postamble provenance dataout
ft_postamble history    dataout
ft_postamble savevar    dataout

                                                                                                                                                                                                                                                                                                                                                                                                                                                                        t(sum((average.elecpos - norm.elecpos).^2, 2)));
  fprintf('mean distance prior to warping %f, after warping %f\n', dpre, dpost);

  if strcmp(cfg.feedback, 'yes')
    % create an empty figure, continued below...
    figure
    axis equal
    axis vis3d
    hold on
    xlabel('x')
    ylabel('y')
    zlabel('z')

    % plot all electrodes before warping
    ft_plot_sens(elec, 'r*');

    % plot all electrodes after warping
    ft_plot_sens(norm, 'm.', 'label', 'label');

    % plot the template electrode locations
    ft_plot_sens(average, 'b.');

    % plot lines connecting the input and the realigned electrode locations with the template locations
    my_line3(elec.elecpos, average.elecpos, 'color', 'r');
    my_line3(norm.elecpos, average.elecpos, 'color', 'm');
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(cfg.method, 'headshape')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % determine electrode selection and overlapping subset for warping
  cfg.channel = ft_channelselection(cfg.channel, elec.label);
  [cfgsel, datsel] = match_str(cfg.channel, elec.label);
  elec.label   = elec.label(datsel);
  elec.elecpos = elec.elecpos(datsel,:);

  norm.label = elec.label;
  if strcmp(cfg.warp, 'dykstra2012')
    norm.elecpos = warp_dykstra2012(cfg, elec, headshape);
  elseif strcmp(cfg.warp, 'hermes2010')
    norm.elecpos = warp_hermes2010(cfg, elec, headshape);
  elseif strcmp(cfg.warp, 'fsaverage')
    norm.elecpos = warp_fsaverage(cfg, elec);
  elseif strcmp(cfg.warp, 'fsaverage_sym')
    norm.elecpos = warp_fsaverage_sym(cfg, elec);
  elseif strcmp(cfg.warp, 'fsinflated')
    norm.elecpos = warp_fsinflated(cfg, elec);
  else
    fprintf('warping electrodes to skin surface... '); % the newline comes later
    [norm.elecpos, norm.m] = ft_warp_optim(elec.elecpos, headshape, cfg.warp);

    dpre  = ft_warp_error([],     elec.elecpos, headshape, cfg.warp);
    dpost = ft_warp_error(norm.m, elec.elecpos, headshape, cfg.warp);
    fprintf('mean distance prior to warping %f, after warping %f\n', dpre, dpost);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(cfg.method, 'fiducial')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % the fiducials have to be present in the electrodes and in the template set
  label = intersect(lower(elec.label), lower(target.label));

  if ~isfield(cfg, 'fiducial') || isempty(cfg.fiducial)
    % try to determine the names of the fiducials automatically
    option1 = {'nasion' 'left' 'right'};
    option2 = {'nasion' 'lpa' 'rpa'};
    option3 = {'nz' 'left' 'right'};
    option4 = {'nz' 'lpa' 'rpa'};
    option5 = {'nas' 'left' 'right'};
    option6 = {'nas' 'lpa' 'rpa'};
    if length(match_str(label, option1))==3
      cfg.fiducial = option1;
    elseif length(match_str(label, option2))==3
      cfg.fiducial = option2;
    elseif length(match_str(label, option3))==3
      cfg.fiducial = option3;
    elseif length(match_str(label, option4))==3
      cfg.fiducial = option4;
    elseif length(match_str(label, option5))==3
      cfg.fiducial = option5;
    elseif length(match_str(label, option6))==3
      cfg.fiducial = option6;
    else
      ft_error('could not determine consistent fiducials in the input and the target, please specify cfg.fiducial or cfg.coordsys')
    end
  end
  fprintf('matching fiducials {''%s'', ''%s'', ''%s''}\n', cfg.fiducial{1}, cfg.fiducial{2}, cfg.fiducial{3});

  % determine electrode selection
  cfg.channel = ft_channelselection(cfg.channel, elec.label);
  [cfgsel, datsel] = match_str(cfg.channel, elec.label);
  elec.label     = elec.label(datsel);
  elec.elecpos   = elec.elecpos(datsel,:);

  if length(cfg.fiducial)~=3
    ft_error('you must specify exactly three fiducials');
  end

  % do case-insensitive search for fiducial locations
  nas_indx = match_str(lower(elec.label), lower(cfg.fiducial{1}));
  lpa_indx = match_str(lower(elec.label), lower(cfg.fiducial{2}));
  rpa_indx = match_str(lower(elec.label), lower(cfg.fiducial{3}));
  if length(nas_indx)~=1 || length(lpa_indx)~=1 || length(rpa_indx)~=1
    ft_error('not all fiducials were found in the electrode set');
  end
  elec_nas = elec.elecpos(nas_indx,:);
  elec_lpa = elec.elecpos(lpa_indx,:);
  elec_rpa = elec.elecpos(rpa_indx,:);

  % FIXME change the flow in the remainder
  % if one or more template electrode sets are specified, then align to the average of those
  % if no template is specified, then align so that the fiducials are along the axis

  % find the matching fiducials in the template and average them
  tmpl_nas = nan(Ntemplate,3);
  tmpl_lpa = nan(Ntemplate,3);
  tmpl_rpa = nan(Ntemplate,3);
  for i=1:Ntemplate
    nas_indx = match_str(lower(target(i).label), lower(cfg.fiducial{1}));
    lpa_indx = match_str(lower(target(i).label), lower(cfg.fiducial{2}));
    rpa_indx = match_str(lower(target(i).label), lower(cfg.fiducial{3}));
    if length(nas_indx)~=1 || length(lpa_indx)~=1 || length(rpa_indx)~=1
      ft_error('not all fiducials were found in template %d', i);
    end
    tmpl_nas(i,:) = target(i).elecpos(nas_indx,:);
    tmpl_lpa(i,:) = target(i).elecpos(lpa_indx,:);
    tmpl_rpa(i,:) = target(i).elecpos(rpa_indx,:);
  end
  tmpl_nas = mean(tmpl_nas,1);
  tmpl_lpa = mean(tmpl_lpa,1);
  tmpl_rpa = mean(tmpl_rpa,1);

  % realign both to a common coordinate system
  elec2common  = ft_headcoordinates(elec_nas, elec_lpa, elec_rpa);
  templ2common = ft_headcoordinates(tmpl_nas, tmpl_lpa, tmpl_rpa);

  % compute the combined transform
  norm         = [];
  norm.m       = templ2common \ elec2common;

  % apply the transformation to the fiducials as sanity check
  norm.elecpos(1,:) = ft_warp_apply(norm.m, elec_nas, 'homogeneous');
  norm.elecpos(2,:) = ft_warp_apply(norm.m, elec_lpa, 'homogeneous');
  norm.elecpos(3,:) = ft_warp_apply(norm.m, elec_rpa, 'homogeneous');
  norm.label        = cfg.fiducial;

  nas_indx = match_str(lower(elec.label), lower(cfg.fiducial{1}));
  lpa_indx = match_str(lower(elec.label), lower(cfg.fiducial{2}));
  rpa_indx = match_str(lower(elec.label), lower(cfg.fiducial{3}));
  dpre  = mean(sqrt(sum((elec.elecpos([nas_indx lpa_indx rpa_indx],:) - [tmpl_nas; tmpl_lpa; tmpl_rpa]).^2, 2)));
  nas_indx = match_str(lower(norm.label), lower(cfg.fiducial{1}));
  lpa_indx = match_str(lower(norm.label), lower(cfg.fiducial{2}));
  rpa_indx = match_str(lower(norm.label), lower(cfg.fiducial{3}));
  dpost = mean(sqrt(sum((norm.elecpos([nas_indx lpa_indx rpa_indx],:) - [tmpl_nas; tmpl_lpa; tmpl_rpa]).^2, 2)));
  fprintf('mean distance between fiducials prior to realignment %f, after realignment %f\n', dpre, dpost);

  if strcmp(cfg.feedback, 'yes')
    % create an empty figure, continued below...
    figure
    axis equal
    axis vis3d
    hold on
    xlabel('x')
    ylabel('y')
    zlabel('z')

    % plot the first three electrodes before transformation
    my_plot3(elec.elecpos(1,:), 'r*');
    my_plot3(elec.elecpos(2,:), 'r*');
    my_plot3(elec.elecpos(3,:), 'r*');
    my_text3(elec.elecpos(1,:), elec.label{1}, 'color', 'r');
    my_text3(elec.elecpos(2,:), elec.label{2}, 'color', 'r');
    my_text3(elec.elecpos(3,:), elec.label{3}, 'color', 'r');

    % plot the template fiducials
    my_plot3(tmpl_nas, 'b*');
    my_plot3(tmpl_lpa, 'b*');
    my_plot3(tmpl_rpa, 'b*');
    my_text3(tmpl_nas, ' nas', 'color', 'b');
    my_text3(tmpl_lpa, ' lpa', 'color', 'b');
    my_text3(tmpl_rpa, ' rpa', 'color', 'b');

    % plot all electrodes after transformation
    my_plot3(norm.elecpos, 'm.');
    my_plot3(norm.elecpos(1,:), 'm*');
    my_plot3(norm.elecpos(2,:), 'm*');
    my_plot3(norm.elecpos(3,:), 'm*');
    my_text3(norm.elecpos(1,:), norm.label{1}, 'color', 'm');
    my_text3(norm.elecpos(2,:), norm.label{2}, 'color', 'm');
    my_text3(norm.elecpos(3,:), norm.label{3}, 'color', 'm');
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(cfg.method, 'interactive')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  tmpcfg = [];
  tmpcfg.individual.elec = elec;
  if isfield(cfg, 'headshape') && ~isempty(cfg.headshape)
    tmpcfg.template.headshape = cfg.headshape;
  end
  if isfield(cfg, 'target') && ~isempty(cfg.target)
    if iscell(cfg.target)
      if numel(cfg.target)>1
        ft_notice('computing the average electrode positions');
        tmpcfg.template.elec = ft_average_sens(cfg.target);
      else
        tmpcfg.template.elec = cfg.target{1};
      end
    elseif isstruct(cfg.target)
      tmpcfg.template.elec = cfg.target;
    end
    tmpcfg.template.elecstyle = {'facecolor', 'blue'};
    ft_info('plotting the target electrodes in blue');
  end

  % use the more generic ft_interactiverealign for the actual work
  tmpcfg = ft_interactiverealign(tmpcfg);
  % only keep the transformation, it will be applied to the electrodes further down
  norm.m = tmpcfg.m;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(cfg.method, 'project')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % determine electrode selection
  cfg.channel = ft_channelselection(cfg.channel, elec.label);
  [cfgsel, datsel] = match_str(cfg.channel, elec.label);
  elec.label     = elec.label(datsel);
  elec.elecpos   = elec.elecpos(datsel,:);

  norm.label = elec.label;
  [dum, norm.elecpos] = project_elec(elec.elecpos, headshape.pos, headshape.tri);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(cfg.method, 'moveinward')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % determine electrode selection
  cfg.channel = ft_channelselection(cfg.channel, elec.label);
  [cfgsel, datsel] = match_str(cfg.channel, elec.label);
  elec.label     = elec.label(datsel);
  elec.elecpos   = elec.elecpos(datsel,:);

  norm.label = elec.label;
  norm.elecpos = moveinward(elec.elecpos, cfg.moveinward);

else
  ft_error('unknown method');
end % if method


% apply the spatial transformation to all electrodes, and replace the
% electrode labels by their case-sensitive original values
switch cfg.method
  case {'template', 'headshape'}
    if strcmpi(cfg.warp, 'dykstra2012') || strcmpi(cfg.warp, 'hermes2010') || ...
        strcmpi(cfg.warp, 'fsaverage') || strcmpi(cfg.warp, 'fsaverage_sym') || strcmpi(cfg.warp, 'fsinflated')
      elec_realigned = norm;
      elec_realigned.label = label_original;
    else
      % the transformation is a linear or non-linear warp, i.e. a vector
      try
        % convert the vector with fitted parameters into a 4x4 homogenous transformation
        % apply the transformation to the original complete set of sensors
        elec_realigned = ft_transform_geometry(feval(cfg.warp, norm.m), elec_original);
      catch
        % the previous section will fail for nonlinear transformations
        elec_realigned.label = label_original;
        try
          elec_realigned.elecpos = ft_warp_apply(norm.m, elec_original.elecpos, cfg.warp);
        end % FIXME why is an error here not dealt with?
      end
      % remember the transformation
      elec_realigned.(cfg.warp) = norm.m;
    end

  case  {'fiducial' 'interactive'}
    % the transformation is a 4x4 homogenous matrix
    % apply the transformation to the original complete set of sensors
    elec_realigned = ft_transform_geometry(norm.m, elec_original);
    % remember the transformation
    elec_realigned.homogeneous = norm.m;

  case {'project', 'moveinward'}
    % nothing to be done
    elec_realigned = norm;
    elec_realigned.label = label_original;

  otherwise
    ft_error('unknown method');
end

% the coordinate system is in general not defined after transformation
if isfield(elec_realigned, 'coordsys')
  elec_realigned = rmfield(elec_realigned, 'coordsys');
end

% in some cases the coordinate system matches that of the input target or headshape
switch cfg.method
  case 'template'
    if isfield(target, 'coordsys')
      elec_realigned.coordsys = target.coordsys;
    end
  case 'headshape'
    if isfield(headshape, 'coordsys')
      elec_realigned.coordsys = headshape.coordsys;
    end
    if isfield(elec_original, 'coordsys')
      if strcmp(cfg.warp, 'dykstra2012') || strcmp(cfg.warp, 'hermes2010')  % this warp simply moves the electrodes in the same coordinate space
        elec_realigned.coordsys = elec_original.coordsys;
      elseif strcmp(cfg.warp, 'fsaverage')
        elec_realigned.coordsys = 'fsaverage';
      elseif strcmp(cfg.warp, 'fsaverage_sym')
        elec_realigned.coordsys = 'fsaverage_sym';
      end
    end
  case 'fiducial'
    if isfield(target, 'coordsys')
      elec_realigned.coordsys = target.coordsys;
    end
  case 'interactive'
    % the coordinate system is not known
  case {'project', 'moveinward'}
    % the coordinate system remains the same
    if isfield(elec_original, 'coordsys')
      elec_realigned.coordsys = elec_original.coordsys;
    end
  otherwise
    ft_error('unknown method');
end

if istrue(cfg.keepchannel)
  % append the channels that are not realigned
  [dum, idx] = setdiff(elec_original.label, elec_realigned.label);
  idx = sort(idx);
  elec_realigned.label = [elec_realigned.label; elec_original.label(idx)];
  elec_realigned.elecpos = [elec_realigned.elecpos; elec_original.elecpos(idx,:)];
end

% channel positions are identical to the electrode positions (this was checked at the start)
elec_realigned.chanpos = elec_realigned.elecpos;
elec_realigned.tra = eye(numel(elec_realigned.label));

% copy over unit, chantype, chanunit, and tra information in case this was not already done
if ~isfield(elec_realigned, 'unit') && isfield(elec_original, 'unit')
  elec_realigned.unit = elec_original.unit;
end
if ~isfield(elec_realigned, 'chantype') && isfield(elec_original, 'chantype')
  idx = match_str(elec_original.label, elec_realigned.label);
  elec_realigned.chantype = elec_original.chantype(idx);
end
if ~isfield(elec_realigned, 'chanunit') && isfield(elec_original, 'chanunit')
  elec_realigned.chanunit = elec_original.chanunit;
  idx = match_str(elec_original.label, elec_realigned.label);
  elec_realigned.chanunit = elec_original.chanunit(idx);
end

% update it to the latest version
elec_realigned = ft_datatype_sens(elec_realigned);

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous   elec_original
ft_postamble provenance elec_realigned
ft_postamble history    elec_realigned

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some simple SUBFUNCTIONs that facilitate 3D plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = my_plot3(xyz, varargin)
h = plot3(xyz(:,1), xyz(:,2), xyz(:,3), varargin{:});
function h = my_text3(xyz, varargin)
h = text(xyz(:,1), xyz(:,2), xyz(:,3), varargin{:});
function my_line3(xyzB, xyzE, varargin)
for i=1:size(xyzB,1)
  line([xyzB(i,1) xyzE(i,1)], [xyzB(i,2) xyzE(i,2)], [xyzB(i,3) xyzE(i,3)], varargin{:})
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                     es(1);
h2 = opt.axes(2);
h3 = opt.axes(3);

if opt.init
  delete(findobj(opt.mainfig, 'Type', 'Surface')); % get rid of old orthos (to facilitate switching scans)
  ft_plot_ortho(opt.ana, 'transform', opt.mri{opt.currmri}.transform, 'location', opt.pos, 'style', 'subplot', 'parents', [h1 h2 h3], 'update', opt.update, 'doscale', false, 'clim', opt.clim, 'unit', opt.mri{opt.currmri}.unit);
  
  opt.anahandles = findobj(opt.mainfig, 'Type', 'Surface')';
  parenttag = get(opt.anahandles, 'parent');
  parenttag{1} = get(parenttag{1}, 'tag');
  parenttag{2} = get(parenttag{2}, 'tag');
  parenttag{3} = get(parenttag{3}, 'tag');
  [i1,i2,i3] = intersect(parenttag, {'ik';'jk';'ij'});
  opt.anahandles = opt.anahandles(i3(i2)); % seems like swapping the order
  opt.anahandles = opt.anahandles(:)';
  set(opt.anahandles, 'tag', 'ana');
  
  % for zooming purposes
  opt.axis = zeros(1,6);
  opt.axis = [opt.axes(1).XLim opt.axes(1).YLim opt.axes(1).ZLim];
  opt.redrawmarkers = true;
  opt.reinit = false;
elseif opt.reinit
  ft_plot_ortho(opt.ana, 'transform', opt.mri{opt.currmri}.transform, 'location', opt.pos, 'style', 'subplot', 'surfhandle', opt.anahandles, 'update', opt.update, 'doscale', false, 'clim', opt.clim, 'unit', opt.mri{opt.currmri}.unit);
  
  fprintf('==================================================================================\n');
  lab = 'crosshair';
  switch opt.mri{opt.currmri}.unit
    case 'mm'
      fprintf('%10s at [%.1f %.1f %.1f] %s\n', lab, opt.pos, opt.mri{opt.currmri}.unit);
    case 'cm'
      fprintf('%10s at [%.2f %.2f %.2f] %s\n', lab, opt.pos, opt.mri{opt.currmri}.unit);
    case 'm'
      fprintf('%10s at [%.4f %.4f %.4f] %s\n', lab, opt.pos, opt.mri{opt.currmri}.unit);
    otherwise
      fprintf('%10s at [%f %f %f] %s\n', lab, opt.pos, opt.mri{opt.currmri}.unit);
  end
  opt.reinit = false;
end

% zoom
xi = opt.pos(1);
yi = opt.pos(2);
zi = opt.pos(3);
xloadj = ((xi-opt.axis(1))-(xi-opt.axis(1))*opt.zoom);
xhiadj = ((opt.axis(2)-xi)-(opt.axis(2)-xi)*opt.zoom);
yloadj = ((yi-opt.axis(3))-(yi-opt.axis(3))*opt.zoom);
yhiadj = ((opt.axis(4)-yi)-(opt.axis(4)-yi)*opt.zoom);
zloadj = ((zi-opt.axis(5))-(zi-opt.axis(5))*opt.zoom);
zhiadj = ((opt.axis(6)-zi)-(opt.axis(6)-zi)*opt.zoom);
axis(h1, [xi-xloadj xi+xhiadj yi-yloadj yi+yhiadj zi-zloadj zi+zhiadj]);
axis(h2, [xi-xloadj xi+xhiadj yi-yloadj yi+yhiadj zi-zloadj zi+zhiadj]);
axis(h3, [xi-xloadj xi+xhiadj yi-yloadj yi+yhiadj]);

if opt.init
  % draw the crosshairs for the first time
  delete(findobj(opt.mainfig, 'Type', 'Line')); % get rid of old crosshairs (to facilitate switching scans)
  hch1 = ft_plot_crosshair([xi yi-yloadj zi], 'parent', h1, 'color', 'yellow'); % was [xi 1 zi], now corrected for zoom
  hch2 = ft_plot_crosshair([xi+xhiadj yi zi], 'parent', h2, 'color', 'yellow'); % was [opt.dim(1) yi zi], now corrected for zoom
  hch3 = ft_plot_crosshair([xi yi zi], 'parent', h3, 'color', 'yellow'); % was [xi yi opt.dim(3)], now corrected for zoom
  opt.handlescross  = [hch1(:)';hch2(:)';hch3(:)'];
else
  % update the existing crosshairs, don't change the handles
  ft_plot_crosshair([xi yi-yloadj zi], 'handle', opt.handlescross(1, :));
  ft_plot_crosshair([xi+xhiadj yi zi], 'handle', opt.handlescross(2, :));
  ft_plot_crosshair([xi yi zi], 'handle', opt.handlescross(3, :));
end

if opt.showcrosshair
  set(opt.handlescross, 'Visible', 'on');
else
  set(opt.handlescross, 'Visible', 'off');
end

% draw markers
if opt.showmarkers && opt.redrawmarkers
  delete(findobj(opt.mainfig, 'Type', 'Line', 'Marker', '+')); % remove previous markers
  delete(findobj(opt.mainfig, 'Type', 'text')); % remove previous labels
  idx = find(~cellfun(@isempty,opt.markerlab)); % non-empty markers
  if ~isempty(idx)
    for i=1:numel(idx)
      markerlab_sel{i,1} = opt.markerlab{idx(i),1};
      markerpos_sel(i,:) = opt.markerpos{idx(i),1};
    end
    
    tmp1 = markerpos_sel(:,1);
    tmp2 = markerpos_sel(:,2);
    tmp3 = markerpos_sel(:,3);
    
    subplot(opt.axes(1));
    if ~opt.global % filter markers distant to the current slice (N units and further)
      posj_idx = find( abs(tmp2 - repmat(yi,size(tmp2))) < opt.markerdist);
      posi = tmp1(posj_idx);
      posj = tmp2(posj_idx);
      posk = tmp3(posj_idx);
    else % plot all markers on the current slice
      posj_idx = 1:numel(tmp1);
      posi = tmp1;
      posj = tmp2;
      posk = tmp3;
    end
    if ~isempty(posi)
      hold on
      plot3(posi, repmat(yi-yloadj,size(posj)), posk, 'marker', '+', 'linestyle', 'none', 'color', 'r'); % [xi yi-yloadj zi]
      if opt.showlabels
        for i=1:numel(posj_idx)
          text(posi(i), yi-yloadj, posk(i), markerlab_sel{posj_idx(i),1}, 'color', [1 .5 0], 'clipping', 'on');
        end
      end
      hold off
    end
    
    subplot(opt.axes(2));
    if ~opt.global % filter markers distant to the current slice (N units and further)
      posi_idx = find( abs(tmp1 - repmat(xi,size(tmp1))) < opt.markerdist);
      posi = tmp1(posi_idx);
      posj = tmp2(posi_idx);
      posk = tmp3(posi_idx);
    else % plot all markers on the current slice
      posi_idx = 1:numel(tmp1);
      posi = tmp1;
      posj = tmp2;
      posk = tmp3;
    end
    if ~isempty(posj)
      hold on
      plot3(repmat(xi+xhiadj,size(posi)), posj, posk, 'marker', '+', 'linestyle', 'none', 'color', 'r'); % [xi+xhiadj yi zi]
      if opt.showlabels
        for i=1:numel(posi_idx)
          text(posi(i)+xhiadj, posj(i), posk(i), markerlab_sel{posi_idx(i),1}, 'color', [1 .5 0], 'clipping', 'on');
        end
      end
      hold off
    end
    
    subplot(opt.axes(3));
    if ~opt.global % filter markers distant to the current slice (N units and further)
      posk_idx = find( abs(tmp3 - repmat(zi,size(tmp3))) < opt.markerdist);
      posi = tmp1(posk_idx);
      posj = tmp2(posk_idx);
      posk = tmp3(posk_idx);
    else % plot all markers on the current slice
      posk_idx = 1:numel(tmp1);
      posi = tmp1;
      posj = tmp2;
      posk = tmp3;
    end
    if ~isempty(posk)
      hold on
      plot3(posi, posj, repmat(zi,size(posk)), 'marker', '+', 'linestyle', 'none', 'color', 'r'); % [xi yi zi]
      if opt.showlabels
        for i=1:numel(posk_idx)
          text(posi(i), posj(i), zi, markerlab_sel{posk_idx(i),1}, 'color', [1 .5 0], 'clipping', 'on');
        end
      end
      hold off
    end
    clear markerlab_sel markerpos_sel
    opt.redrawmarkers = false;
    opt.redrawscattermarkers = true;
  end % if idx
end % if showmarkers

% also update the scatter appendix
if opt.scatter
  cb_scatterredraw(h);
end

% make the last current axes current again
sel = findobj('type', 'axes', 'tag', tag);
if ~isempty(sel)
  set(opt.mainfig, 'currentaxes', sel(1));
end

% do not initialize on the next call
opt.init = false;
setappdata(h, 'opt', opt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_scatterredraw(h, eventdata)

h   = getparent(h);
opt = getappdata(h, 'opt');

if ~isfield(opt, 'scatterfig') % initiate in case the figure does not yet exist
  opt.scatterfig = figure(...
    'Name', [mfilename ' appendix'],...
    'Units', 'normalized', ...
    'Color', [1 1 1], ...
    'Visible', 'on');
  set(opt.scatterfig, 'CloseRequestFcn', @cb_scattercleanup);
  opt.scatterfig_h1 = axes('position', [0.02 0.02 0.96 0.96]);
  set(opt.scatterfig_h1, 'DataAspectRatio', get(opt.axes(1), 'DataAspectRatio'));
  axis square; axis tight; axis off; view([90 0]);
  xlabel('x'); ylabel('y'); zlabel('z');
  
  % scatter range sliders
  opt.scatterfig_h23text = uicontrol('Style', 'text',...
    'String', 'Intensity',...
    'Units', 'normalized', ...
    'Position', [.85+0.03 .26 .1 0.04],...
    'BackgroundColor', [1 1 1], ...
    'HandleVisibility', 'on');
  
  opt.scatterfig_h2 = uicontrol('Style', 'slider', ...
    'Parent', opt.scatterfig, ...
    'Min', 0, 'Max', 1, ...
    'Value', opt.slim(1), ...
    'Units', 'normalized', ...
    'Position', [.85+.02 .06 .05 .2], ...
    'Callback', @cb_scatterminslider);
  
  opt.scatterfig_h3 = uicontrol('Style', 'slider', ...
    'Parent', opt.scatterfig, ...
    'Min', 0, 'Max', 1, ...
    'Value', opt.slim(2), ...
    'Units', 'normalized', ...
    'Position', [.85+.07 .06 .05 .2], ...
    'Callback', @cb_scattermaxslider);
  
  hskullstrip = uicontrol('Style', 'togglebutton', ...
    'Parent', opt.scatterfig, ...
    'String', 'Skullstrip', ...
    'Value', 0, ...
    'Units', 'normalized', ...
    'Position', [.88 .88 .1 .1], ...
    'HandleVisibility', 'on', ...
    'Callback', @cb_skullstrip);
  
  % datacursor mode options
  opt.scatterfig_dcm = datacursormode(opt.scatterfig);
  set(opt.scatterfig_dcm, ...
    'DisplayStyle', 'datatip', ...
    'SnapToDataVertex', 'off', ...
    'Enable', 'on', ...
    'UpdateFcn', @cb_scatter_dcm);
  
  % draw the crosshair for the first time
  opt.handlescross2 = ft_plot_crosshair(opt.pos, 'parent', opt.scatterfig_h1, 'color', 'blue');
  
  % instructions to the user
  fprintf(strcat(...
    '5. Scatterplot viewing options:\n',...
    '   a. use the Data Cursor, Rotate 3D, Pan, and Zoom tools to navigate to electrodes in 3D space\n'));
  
  opt.redrawscatter = 1;
  opt.redrawscattermarkers = 1;
else
  set(0, 'CurrentFigure', opt.scatterfig) % make current figure (needed for ft_plot_crosshair)
end

if opt.redrawscatter
  delete(findobj(opt.scatterfig, 'type', 'scatter')); % remove previous scatters
  msize = round(2000/opt.mri{opt.currmri}.dim(3)); % headsize (20 cm) / z slices
  inc = abs(opt.slim(2)-opt.slim(1))/4; % color increments
  for r = 1:4 % 4 color layers to encode peaks
    lim1 = opt.slim(1) + r*inc - inc;
    lim2 = opt.slim(1) + r*inc;
    voxind = find(opt.ana>lim1 & opt.ana<lim2);
    [x,y,z] = ind2sub(opt.mri{opt.currmri}.dim, voxind);
    pos = ft_warp_apply(opt.mri{opt.currmri}.transform, [x,y,z]);
    hold on; scatter3(opt.scatterfig_h1, pos(:,1),pos(:,2),pos(:,3),msize, 'Marker', 's', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', [.8-(r*.2) .8-(r*.2) .8-(r*.2)]);
  end
  opt.redrawscatter = 0;
end

if opt.showmarkers && opt.redrawscattermarkers % plot the markers
  delete(findobj(opt.scatterfig, 'Type', 'line', 'Marker', '+')); % remove all scatterfig markers
  delete(findobj(opt.scatterfig, 'Type', 'text')); % remove all scatterfig labels
  idx = find(~cellfun(@isempty,opt.markerlab)); % non-empty markers
  if ~isempty(idx)
    for i=1:numel(idx)
      markerlab_sel{i,1} = opt.markerlab{idx(i),1};
      markerpos_sel(i,:) = opt.markerpos{idx(i),1};
    end
    plot3(opt.scatterfig_h1, markerpos_sel(:,1),markerpos_sel(:,2),markerpos_sel(:,3), 'marker', '+', 'linestyle', 'none', 'color', 'r'); % plot the markers
    if opt.showlabels
      for i=1:size(markerpos_sel,1)
        text(opt.scatterfig_h1, markerpos_sel(i,1), markerpos_sel(i,2), markerpos_sel(i,3), markerlab_sel{i,1}, 'color', [1 .5 0]);
      end
    end
    clear markerlab_sel markerpos_sel
  end % if idx
  opt.redrawscattermarkers = false;
end

% update the existing crosshairs, don't change the handles
ft_plot_crosshair(opt.pos, 'handle', opt.handlescross2);
if opt.showcrosshair
  set(opt.handlescross2, 'Visible', 'on');
else
  set(opt.handlescross2, 'Visible', 'off');
end

setappdata(h, 'opt', opt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_headshaperedraw(h, eventdata)

h   = getparent(h);
opt = getappdata(h, 'opt');

figure(h); % make current figure

delete(findobj(h, 'Type', 'line')); % remove all lines and markers
delete(findobj(h, 'Type', 'text')); % remove all labels
delete(findall(h, 'Type','light'))
delete(findobj(h, 'tag', 'headshape')); % remove the headshape

% plot the faces of the 2D or 3D triangulation
if ~opt.showsurface
  ft_plot_mesh(removefields(opt.headshape, 'color'), 'tag', 'headshape', 'facecolor', 'none', 'edgecolor', 'none', 'vertexcolor', 'none');
elseif isfield(opt.headshape, 'color') && opt.showcolors
  ft_plot_mesh(opt.headshape, 'tag', 'headshape', 'material', 'dull');
else
  ft_plot_mesh(removefields(opt.headshape, 'color'), 'tag', 'headshape', 'facecolor', 'skin', 'material', 'dull', 'edgecolor', 'none', 'facealpha', 1);
end
lighting gouraud
l = lightangle(0, 90);  set(l, 'Color', [1 1 1]/2)
l = lightangle(  0, 0); set(l, 'Color', [1 1 1]/3)
l = lightangle( 90, 0); set(l, 'Color', [1 1 1]/3)
l = lightangle(180, 0); set(l, 'Color', [1 1 1]/3)
l = lightangle(270, 0); set(l, 'Color', [1 1 1]/3)
alpha 0.9

if opt.showmarkers
  idx = find(~cellfun(@isempty,opt.markerlab)); % find the non-empty markers
  if ~isempty(idx)
    elec = keepfields(opt.headshape, {'unit', 'coordsys'});
    elec.elecpos = cat(1, opt.markerpos{idx});
    elec.label   = cat(1, opt.markerlab{idx});
    elec.elecori = elec.elecpos;
    elec.elecori(:,1) = elec.elecori(:,1) - mean(opt.headshape.pos(:,1));
    elec.elecori(:,2) = elec.elecori(:,2) - mean(opt.headshape.pos(:,2));
    elec.elecori(:,3) = elec.elecori(:,3) - mean(opt.headshape.pos(:,3));
    for i=1:numel(elec.label)
      elec.elecori(i,:) = elec.elecori(i,:) / norm(elec.elecori(i,:));
    end
    
    if opt.showlabels
      ft_plot_sens(elec, 'elecshape', 'sphere', 'label', 'label');
    else
      ft_plot_sens(elec, 'elecshape', 'sphere', 'label', 'off');
    end
  end % if not empty
end % if showmarkers

setappdata(h, 'opt', opt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_keyboard(h, eventdata)

if isempty(eventdata)
  % determine the key that corresponds to the uicontrol element that was activated
  key = get(h, 'userdata');
else
  % determine the key that was pressed on the keyboard
  key = parsekeyboardevent(eventdata);
end

% get focus back to figure
if ~strcmp(get(h, 'type'), 'figure')
  set(h, 'enable', 'off');
  drawnow;
  set(h, 'enable', 'on');
end

h   = getparent(h);
opt = getappdata(h, 'opt');

curr_ax = get(h, 'currentaxes');
tag     = get(curr_ax, 'tag');

if isempty(key)
  % this happens if you press the apple key
  key = '';
end

% the following code is largely shared by FT_SOURCEPLOT, FT_VOLUMEREALIGN, FT_INTERACTIVEREALIGN, FT_MESHREALIGN, FT_ELECTRODEPLACEMENT
switch key
  case {'' 'shift+shift' 'alt-alt' 'control+control' 'command-0'}
    % do nothing
    
  case '1'
    subplot(opt.axes(1));
    
  case '2'
    subplot(opt.axes(2));
    
  case '3'
    subplot(opt.axes(3));
    
  case 'q'
    setappdata(h, 'opt', opt);
    cb_quit(h);
    
  case 'g' % global/local elec view (h9) toggle
    if isequal(opt.global, 0)
      opt.global = 1;
      set(opt.axes(9), 'Value', 1);
    elseif isequal(opt.global, 1)
      opt.global = 0;
      set(opt.axes(9), 'Value', 0);
    end
    opt.redrawmarkers = true; % draw markers
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case 'l' % elec label view (h8) toggle
    if isequal(opt.showlabels, 0)
      opt.showlabels = 1;
      set(opt.axes(8), 'Value', 1);
    elseif isequal(opt.showlabels, 1)
      opt.showlabels = 0;
      set(opt.axes(8), 'Value', 0);
    end
    opt.redrawmarkers = true; % draw markers
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case 'm' % magnet (h7) toggle
    if isequal(opt.magnet, 0)
      opt.magnet = 1;
      set(opt.axes(7), 'Value', 1);
    elseif isequal(opt.magnet, 1)
      opt.magnet = 0;
      set(opt.axes(7), 'Value', 0);
    end
    setappdata(h, 'opt', opt);
    
  case {28 29 30 31 'leftarrow' 'rightarrow' 'uparrow' 'downarrow'}
    % update the view to a new position
    if     strcmp(tag, 'ik') && (strcmp(key, 'i') || strcmp(key, 'uparrow')    || isequal(key, 30)), opt.pos(3) = opt.pos(3)+1; opt.update = [1 1 1]; %[0 0 1];
    elseif strcmp(tag, 'ik') && (strcmp(key, 'j') || strcmp(key, 'leftarrow')  || isequal(key, 28)), opt.pos(1) = opt.pos(1)-1; opt.update = [1 1 1]; %[0 1 0];
    elseif strcmp(tag, 'ik') && (strcmp(key, 'k') || strcmp(key, 'rightarrow') || isequal(key, 29)), opt.pos(1) = opt.pos(1)+1; opt.update = [1 1 1]; %[0 1 0];
    elseif strcmp(tag, 'ik') && (strcmp(key, 'm') || strcmp(key, 'downarrow')  || isequal(key, 31)), opt.pos(3) = opt.pos(3)-1; opt.update = [1 1 1]; %[0 0 1];
    elseif strcmp(tag, 'ij') && (strcmp(key, 'i') || strcmp(key, 'uparrow')    || isequal(key, 30)), opt.pos(2) = opt.pos(2)+1; opt.update = [1 1 1]; %[1 0 0];
    elseif strcmp(tag, 'ij') && (strcmp(key, 'j') || strcmp(key, 'leftarrow')  || isequal(key, 28)), opt.pos(1) = opt.pos(1)-1; opt.update = [1 1 1]; %[0 1 0];
    elseif strcmp(tag, 'ij') && (strcmp(key, 'k') || strcmp(key, 'rightarrow') || isequal(key, 29)), opt.pos(1) = opt.pos(1)+1; opt.update = [1 1 1]; %[0 1 0];
    elseif strcmp(tag, 'ij') && (strcmp(key, 'm') || strcmp(key, 'downarrow')  || isequal(key, 31)), opt.pos(2) = opt.pos(2)-1; opt.update = [1 1 1]; %[1 0 0];
    elseif strcmp(tag, 'jk') && (strcmp(key, 'i') || strcmp(key, 'uparrow')    || isequal(key, 30)), opt.pos(3) = opt.pos(3)+1; opt.update = [1 1 1]; %[0 0 1];
    elseif strcmp(tag, 'jk') && (strcmp(key, 'j') || strcmp(key, 'leftarrow')  || isequal(key, 28)), opt.pos(2) = opt.pos(2)-1; opt.update = [1 1 1]; %[1 0 0];
    elseif strcmp(tag, 'jk') && (strcmp(key, 'k') || strcmp(key, 'rightarrow') || isequal(key, 29)), opt.pos(2) = opt.pos(2)+1; opt.update = [1 1 1]; %[1 0 0];
    elseif strcmp(tag, 'jk') && (strcmp(key, 'm') || strcmp(key, 'downarrow')  || isequal(key, 31)), opt.pos(3) = opt.pos(3)-1; opt.update = [1 1 1]; %[0 0 1];
    else
      % do nothing
    end
    opt.pos = min(opt.pos(:)', opt.axis([2 4 6])); % avoid out-of-bounds
    opt.pos = max(opt.pos(:)', opt.axis([1 3 5]));
    opt.reinit = true; % redraw orthoplots
    
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
    % contrast scaling
  case {43 'add' 'shift+equal'}  % + or numpad +
    if isempty(opt.clim)
      opt.clim = [min(opt.ana(:)) max(opt.ana(:))];
    end
    % reduce color scale range by 10%
    cscalefactor = (opt.clim(2)-opt.clim(1))/10;
    %opt.clim(1) = opt.clim(1)+cscalefactor;
    opt.clim(2) = opt.clim(2)-cscalefactor;
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case {45 'subtract' 'hyphen' 'shift+hyphen'} % - or numpad -
    if isempty(opt.clim)
      opt.clim = [min(opt.ana(:)) max(opt.ana(:))];
    end
    % increase color scale range by 10%
    cscalefactor = (opt.clim(2)-opt.clim(1))/10;
    %opt.clim(1) = opt.clim(1)-cscalefactor;
    opt.clim(2) = opt.clim(2)+cscalefactor;
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case 99  % 'c'
    opt.showcrosshair = ~opt.showcrosshair;
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case 102 % 'f' for fiducials
    opt.showmarkers = ~opt.showmarkers;
    setappdata(h, 'opt', opt);
    cb_redraw(h);
    
  case 'v' % camlight angle reset
    delete(findall(h,'Type','light')) % shut out the lights
    % add a new light from the current camera position
    lighting gouraud
    material shiny
    camlight
    
  case 3 % right mouse click
    % add point to a list
    l1 = get(get(gca, 'xlabel'), 'string');
    l2 = get(get(gca, 'ylabel'), 'string');
    switch l1
      case 'i'
        xc = d1;
      case 'j'
        yc = d1;
      case 'k'
        zc = d1;
    end
    switch l2
      case 'i'
        xc = d2;
      case 'j'
        yc = d2;
      case 'k'
        zc = d2;
    end
    pnt = [pnt; xc yc zc];
    
  case 2 % middle mouse click
    l1 = get(get(gca, 'xlabel'), 'string');
    l2 = get(get(gca, 'ylabel'), 'string');
    
    % remove the previous point
    if size(pnt,1)>0
      pnt(end,:) = [];
    end
    
    if l1=='i' && l2=='j'
      updatepanel = [1 2 3];
    elseif l1=='i' && l2=='k'
      updatepanel = [2 3 1];
    elseif l1=='j' && l2=='k'
      updatepanel = [3 1 2];
    end
    
  otherwise
    % do nothing
    
end % switch key

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_buttonpress(h, eventdata)

h = getparent(h);
cb_getposition(h);
opt = getappdata(h, 'opt');
if strcmp(opt.method, 'volume') % only redraw volume/orthoplot
  switch get(h, 'selectiontype')
    case 'normal'
      % just update to new position, nothing else to be done here
      cb_redraw(h);
    case 'alt'
      set(h, 'windowbuttonmotionfcn', @cb_tracemouse);
      cb_redraw(h);
    otherwise
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_buttonrelease(h, eventdata)

set(h, 'windowbuttonmotionfcn', '');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_tracemouse(h, eventdata)

h = getparent(h);
cb_getposition(h);
cb_redraw(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_getposition(h, eventdata)

h   = getparent(h);
opt = getappdata(h, 'opt');

if strcmp(opt.method, 'volume')
  curr_ax = get(h,       'currentaxes');
  tag = get(curr_ax, 'tag');
  if ~isempty(tag) && ~opt.init
    pos     = mean(get(curr_ax, 'currentpoint'));
    if strcmp(tag, 'ik')
      opt.pos([1 3])  = pos([1 3]);
      opt.update = [1 1 1];
    elseif strcmp(tag, 'ij')
      opt.pos([1 2])  = pos([1 2]);
      opt.update = [1 1 1];
    elseif strcmp(tag, 'jk')
      opt.pos([2 3])  = pos([2 3]);
      opt.update = [1 1 1];
    end
    opt.pos = min(opt.pos(:)', opt.axis([2 4 6])); % avoid out-of-bounds
    opt.pos = max(opt.pos(:)', opt.axis([1 3 5]));
  end
  if opt.magradius>0
    opt = magnetize(opt);
  end
  opt.reinit = true; % redraw orthoplots
  opt.redrawmarkers = true; % draw markers
elseif strcmp(opt.method, 'headshape')
  h2 = get(gca, 'children'); % get the object handles
  iscorrect = false(size(h2));
  for i=1:length(h2) % select the correct objects
    try
      pos = get(h2(i),'vertices');
      tri = get(h2(i),'faces');
      if ~isempty(opt.headshape) && isequal(opt.headshape.pos, pos) && isequal(opt.headshape.tri, tri)
        % it is the same object that the user has plotted before
        iscorrect(i) = true;
      elseif isempty(opt.headshape)
        % assume that it is the same object that the user has plotted before
        iscorrect(i) = true;
      end
    end
  end
  h2 = h2(iscorrect);
  opt.pos = select3d(h2)'; % enforce column direction
  if ~isempty(opt.pos)
    delete(findobj(h,'Type','Line','Marker','+','Color',[0 0 0])) % remove previous crosshairs
    hold on; plot3(opt.pos(:,1),opt.pos(:,2),opt.pos(:,3), 'marker', '+', 'linestyle', 'none', 'color', [0 0 0]); % plot the crosshair
  end
  %opt.pos = ft_select_point3d(opt.headshape, 'nearest', true, 'multiple', false, 'marker', '+'); % FIXME: this gets stuck in a loop waiting for any abritrary buttonpress
end
setappdata(h, 'opt', opt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_quit(h, eventdata)

opt = getappdata(h, 'opt');
if isfield(opt, 'scatterfig')
  cb_scattercleanup(opt.scatterfig);
end
opt.quit = true;
setappdata(h, 'opt', opt);
uiresume

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = getparent(h)
p = h;
while p~=0
  h = p;
  p = get(h, 'parent');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_minslider(h4, eventdata)

newlim = get(h4, 'value');
h = getparent(h4);
opt = getappdata(h, 'opt');
opt.clim(1) = newlim;
opt.reinit = true; % redraw orthoplots
fprintf('==================================================================================\n');
fprintf(' contrast limits updated to [%.03f %.03f]\n', opt.clim);
setappdata(h, 'opt', opt);
cb_redraw(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_maxslider(h5, eventdata)

newlim = get(h5, 'value');
h = getparent(h5);
opt = getappdata(h, 'opt');
opt.clim(2) = newlim;
opt.reinit = true; % redraw orthoplots
fprintf('==================================================================================\n');
fprintf(' contrast limits updated to [%.03f %.03f]\n', opt.clim);
setappdata(h, 'opt', opt);
cb_redraw(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_intensityslider(h4, eventdata) % java intensity range slider - not fully functional

loval = get(h4, 'value');
hival = get(h4, 'highvalue');
h = getparent(h4); % this fails: The name 'parent' is not an accessible property for an instance of class 'com.jidesoft.swing.RangeSlider'.
opt = getappdata(h, 'opt');
opt.clim = [loval hival];
setappdata(h, 'opt', opt);
cb_redraw(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_eleclistbox(h6, eventdata)

h = getparent(h6);
opt = getappdata(h, 'opt');

elecidx = get(h6, 'Value'); % chosen elec
listtopidx = get(h6, 'ListboxTop'); % ensure listbox does not move upon label selec
if ~isempty(elecidx)
  if numel(elecidx)>1
    fprintf('too many labels selected\n');
    return
  end
  if isempty(opt.pos)
    fprintf('no valid point was selected\n');
    return
  end
  eleclis = cellstr(get(h6, 'String')); % all labels
  eleclab = eleclis{elecidx}; % this elec's label
  
  % toggle electrode status and assign markers
  if contains(eleclab, 'silver') % not yet, check
    fprintf('==================================================================================\n');
    fprintf(' assigning marker %s\n', opt.label{elecidx,1});
    eleclab = regexprep(eleclab, '"silver"', '"black"'); % replace font color
    opt.markerlab{elecidx,1} = opt.label(elecidx,1); % assign marker label
    opt.markerpos{elecidx,1} = opt.pos; % assign marker position
    opt.redrawmarkers = true; % draw markers
  elseif contains(eleclab, 'black') % already chosen before, move cursor to marker or uncheck
    if strcmp(get(h, 'SelectionType'), 'normal') % single click to move cursor to
      fprintf('==================================================================================\n');
      fprintf(' moving cursor to marker %s\n', opt.label{elecidx,1});
      opt.pos = opt.markerpos{elecidx,1}; % move cursor to marker position
      opt.reinit = true; % redraw orthoplots
    elseif strcmp(get(h, 'SelectionType'), 'open') % double click to uncheck
      fprintf('==================================================================================\n');
      fprintf(' removing marker %s\n', opt.label{elecidx,1});
      eleclab = regexprep(eleclab, '"black"', '"silver"'); % replace font color
      opt.markerlab{elecidx,1} = {}; % assign marker label
      opt.markerpos{elecidx,1} = []; % assign marker position
      opt.redrawmarkers = true; % remove markers
    end
  end
  
  % update plot
  eleclis{elecidx} = eleclab;
  set(h6, 'String', eleclis);
  set(h6, 'ListboxTop', listtopidx); % ensure listbox does not move upon label selec
  setappdata(h, 'opt', opt);
  if strcmp(opt.method, 'volume')
    cb_redraw(h);
  elseif strcmp(opt.method, 'headshape')
    cb_headshaperedraw(h);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_magnetbutton(h7, eventdata)

h = getparent(h7);
opt = getappdata(h, 'opt');
radii = get(h7, 'String');
opt.magradius = str2double(radii{get(h7, 'value')});
fprintf('==================================================================================\n');
fprintf(' changed magnet radius to %.1f %s\n', opt.magradius, opt.mri{opt.currmri}.unit);
setappdata(h, 'opt', opt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opt = magnetize(opt)

try
  pos = opt.pos;
  vox = round(ft_warp_apply(inv(opt.mri{opt.currmri}.transform), pos)); % head to vox coord (for indexing within anatomy)
  xsel = vox(1)+(-opt.magradius:opt.magradius);
  ysel = vox(2)+(-opt.magradius:opt.magradius);
  zsel = vox(3)+(-opt.magradius:opt.magradius);
  cubic = opt.ana(xsel, ysel, zsel);
  if strcmp(opt.magtype, 'peak')
    % find the peak intensity voxel within the cube
    [val, idx] = max(cubic(:));
    [ix, iy, iz] = ind2sub(size(cubic), idx);
  elseif strcmp(opt.magtype, 'trough')
    % find the trough intensity voxel within the cube
    [val, idx] = min(cubic(:));
    [ix, iy, iz] = ind2sub(size(cubic), idx);
  elseif strcmp(opt.magtype, 'weighted')
    % find the weighted center of mass in the cube
    dim = size(cubic);
    [X, Y, Z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
    cubic = cubic./sum(cubic(:));
    ix = (X(:)' * cubic(:));
    iy = (Y(:)' * cubic(:));
    iz = (Z(:)' * cubic(:));
  elseif strcmp(opt.magtype, 'peakweighted')
    % find the peak intensity voxel and then the center of mass
    [val, idx] = max(cubic(:));
    [ix, iy, iz] = ind2sub(size(cubic), idx);
    vox = [ix, iy, iz] + vox - opt.magradius - 1; % move cursor to peak
    xsel = vox(1)+(-opt.magradius:opt.magradius);
    ysel = vox(2)+(-opt.magradius:opt.magradius);
    zsel = vox(3)+(-opt.magradius:opt.magradius);
    cubic = opt.ana(xsel, ysel, zsel);
    dim = size(cubic);
    [X, Y, Z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
    cubic = cubic./sum(cubic(:));
    ix = (X(:)' * cubic(:));
    iy = (Y(:)' * cubic(:));
    iz = (Z(:)' * cubic(:));
  elseif strcmp(opt.magtype, 'troughweighted'