function str = print_tim(tim)

% SUBFUNCTION for pretty-printing time in hours, minutes, ...

% Copyright (C) 2012, Robert Oostenveld
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

% partition the time in seconds into years, months, etc.
year   = 60*60*24*7*365.25;
month  = 60*60*24*365.25/12;
week   = 60*60*24*7;
day    = 60*60*24;
hour   = 60*60;
minute = 60;
org = tim; % remember the original time in seconds
Y = floor(tim/year  ); tim = tim - Y*year;
M = floor(tim/month ); tim = tim - M*month;   % note capital M
w = floor(tim/week  ); tim = tim - w*week;
d = floor(tim/day   ); tim = tim - d*day;
h = floor(tim/hour  ); tim = tim - h*hour;
m = floor(tim/minute); tim = tim - m*minute;  % note small m
s = tim;
if Y>=1
  str = sprintf('%.1f years', org/year);
elseif M>=1
  str = sprintf('%.1f months', org/month);
elseif w>=1
  str = sprintf('%.1f weeks', org/week);
elseif d>=1
  str = sprintf('%.1f days', org/day);
elseif h>=1
  str = sprintf('%.1f hours', org/hour);
elseif m>=1
  str = sprintf('%.1f minutes', org/minute);
else
  % note that timreq and timavail are implemented as integers
  str = sprintf('%.0f seconds', org);
end

                                                                                                                                                                             or 'yes'  highpass filter
%   cfg.bpfilter      = 'no' or 'yes'  bandpass filter
%   cfg.bsfilter      = 'no' or 'yes'  bandstop filter
%   cfg.dftfilter     = 'no' or 'yes'  line noise removal using discrete fourier transform
%   cfg.medianfilter  = 'no' or 'yes'  jump preserving median filter
%   cfg.lpfreq        = lowpass  frequency in Hz
%   cfg.hpfreq        = highpass frequency in Hz
%   cfg.bpfreq        = bandpass frequency range, specified as [low high] in Hz
%   cfg.bsfreq        = bandstop frequency range, specified as [low high] in Hz
%   cfg.dftfreq       = line noise frequencies for DFT filter, default [50 100 150] Hz
%   cfg.lpfiltord     = lowpass  filter order (default set in low-level function)
%   cfg.hpfiltord     = highpass filter order (default set in low-level function)
%   cfg.bpfiltord     = bandpass filter order (default set in low-level function)
%   cfg.bsfiltord     = bandstop filter order (default set in low-level function)
%   cfg.medianfiltord = length of median filter
%   cfg.lpfilttype    = digital filter type, 'but' (default) or 'firws' or 'fir' or 'firls'
%   cfg.hpfilttype    = digital filter type, 'but' (default) or 'firws' or 'fir' or 'firls'
%   cfg.bpfilttype    = digital filter type, 'but' (default) or 'firws' or 'fir' or 'firls'
%   cfg.bsfilttype    = digital filter type, 'but' (default) or 'firws' or 'fir' or 'firls'
%   cfg.lpfiltdir     = filter direction, 'twopass' (default), 'onepass' or 'onepass-reverse' or 'onepass-zerophase' (default for firws) or 'onepass-minphase' (firws, non-linear!)
%   cfg.hpfiltdir     = filter direction, 'twopass' (default), 'onepass' or 'onepass-reverse' or 'onepass-zerophase' (default for firws) or 'onepass-minphase' (firws, non-linear!)
%   cfg.bpfiltdir     = filter direction, 'twopass' (default), 'onepass' or 'onepass-reverse' or 'onepass-zerophase' (default for firws) or 'onepass-minphase' (firws, non-linear!)
%   cfg.bsfiltdir     = filter direction, 'twopass' (default), 'onepass' or 'onepass-reverse' or 'onepass-zerophase' (default for firws) or 'onepass-minphase' (firws, non-linear!)
%   cfg.lpinstabilityfix = deal with filter instability, 'no', 'reduce', 'split' (default  = 'no')
%   cfg.hpinstabilityfix = deal with filter instability, 'no', 'reduce', 'split' (default  = 'no')
%   cfg.bpinstabilityfix = deal with filter instability, 'no', 'reduce', 'split' (default  = 'no')
%   cfg.bsinstabilityfix = deal with filter instability, 'no', 'reduce', 'split' (default  = 'no')
%   cfg.lpfiltdf      = lowpass transition width (firws, overrides order, default set in low-level function)
%   cfg.hpfiltdf      = highpass transition width (firws, overrides order, default set in low-level function)
%   cfg.bpfiltdf      = bandpass transition width (firws, overrides order, default set in low-level function)
%   cfg.bsfiltdf      = bandstop transition width (firws, overrides order, default set in low-level function)
%   cfg.lpfiltwintype = lowpass window type, 'hann' or 'hamming' (default) or 'blackman' or 'kaiser' (firws)
%   cfg.hpfiltwintype = highpass window type, 'hann' or 'hamming' (default) or 'blackman' or 'kaiser' (firws)
%   cfg.bpfiltwintype = bandpass window type, 'hann' or 'hamming' (default) or 'blackman' or 'kaiser' (firws)
%   cfg.bsfiltwintype = bandstop window type, 'hann' or 'hamming' (default) or 'blackman' or 'kaiser' (firws)
%   cfg.lpfiltdev     = lowpass max passband deviation (firws with 'kaiser' window, default 0.001 set in low-level function)
%   cfg.hpfiltdev     = highpass max passband deviation (firws with 'kaiser' window, default 0.001 set in low-level function)
%   cfg.bpfiltdev     = bandpass max passband deviation (firws with 'kaiser' window, default 0.001 set in low-level function)
%   cfg.bsfiltdev     = bandstop max passband deviation (firws with 'kaiser' window, default 0.001 set in low-level function)
%   cfg.dftreplace    = 'zero' or 'neighbour', method used to reduce line noise, 'zero' implies DFT filter, 'neighbour' implies spectrum interpolation (default = 'zero')
%   cfg.dftbandwidth  = bandwidth of line noise frequencies, applies to spectrum interpolation, in Hz (default = [1 2 3])
%   cfg.dftneighbourwidth = bandwidth of frequencies neighbouring line noise frequencies, applies to spectrum interpolation, in Hz (default = [2 2 2])
%   cfg.plotfiltresp  = 'no' or 'yes', plot filter responses (firws, default = 'no')
%   cfg.usefftfilt    = 'no' or 'yes', use fftfilt instead of filter (firws, default = 'no')
%   cfg.demean        = 'no' or 'yes'
%   cfg.baselinewindow = [begin end] in seconds, the default is the complete trial
%   cfg.detrend       = 'no' or 'yes', this is done on the complete trial
%   cfg.polyremoval   = 'no' or 'yes', this is done on the complete trial
%   cfg.polyorder     = polynome order (default = 2)
%   cfg.derivative    = 'no' (default) or 'yes', computes the first order derivative of the data
%   cfg.hilbert       = 'no', 'abs', 'complex', 'real', 'imag', 'absreal', 'absimag' or 'angle' (default = 'no')
%   cfg.rectify       = 'no' or 'yes'
%   cfg.precision     = 'single' or 'double' (default = 'double')
%   cfg.absdiff       = 'no' or 'yes', computes absolute derivative (i.e.first derivative then rectify)
%
% Preprocessing options that you should only use for EEG data are
%   cfg.reref         = 'no' or 'yes' (default = 'no')
%   cfg.refchannel    = cell-array with new EEG reference channel(s)
%   cfg.refmethod     = 'avg', 'median', or 'bipolar' (default = 'avg')
%   cfg.implicitref   = 'label' or empty, add the implicit EEG reference as zeros (default = [])
%   cfg.montage       = 'no' or a montage structure (default = 'no')
%
% See also FT_READ_DATA, FT_READ_HEADER

% TODO implement decimation and/or resampling

% Copyright (C) 2004-2012, Robert Oostenveld
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

% compute fsample
fsample = 1./nanmean(diff(time));

if nargin<5 || isempty(begpadding)
  begpadding = 0;
end
if nargin<6 || isempty(endpadding)
  endpadding = 0;
end

if iscell(cfg)
  % recurse over the subsequent preprocessing stages
  if begpadding>0 || endpadding>0
    ft_error('multiple preprocessing stages are not supported in combination with filter padding');
  end
  for i=1:length(cfg)
    tmpcfg = cfg{i};
    if nargout==1
      [dat                     ] = preproc(dat, label, time, tmpcfg, begpadding, endpadding);
    elseif nargout==2
      [dat, label              ] = preproc(dat, label, time, tmpcfg, begpadding, endpadding);
    elseif nargout==3
      [dat, label, time        ] = preproc(dat, label, time, tmpcfg, begpadding, endpadding);
    elseif nargout==4
      [dat, label, time, tmpcfg] = preproc(dat, label, time, tmpcfg, begpadding, endpadding);
      cfg{i} = tmpcfg;
    end
  end
  % ready with recursing over the subsequent preprocessing stages
  return
end

% set the defaults for the rereferencing options
cfg.reref =                ft_getopt(cfg, 'reref', 'no');
cfg.refchannel =           ft_getopt(cfg, 'refchannel', {});
cfg.refmethod =            ft_getopt(cfg, 'refmethod', 'avg');
cfg.implicitref =          ft_getopt(cfg, 'implicitref', []);
% set the defaults for the signal processing options
cfg.polyremoval =          ft_getopt(cfg, 'polyremoval', 'no');
cfg.polyorder =            ft_getopt(cfg, 'polyorder', 2);
cfg.detrend =              ft_getopt(cfg, 'detrend', 'no');
cfg.demean =               ft_getopt(cfg, 'demean', 'no');
cfg.baselinewindow =       ft_getopt(cfg, 'baselinewindow', 'all');
cfg.dftfilter =            ft_getopt(cfg, 'dftfilter', 'no');
cfg.lpfilter =             ft_getopt(cfg, 'lpfilter', 'no');
cfg.hpfilter =             ft_getopt(cfg, 'hpfilter', 'no');
cfg.bpfilter =             ft_getopt(cfg, 'bpfilter', 'no');
cfg.bsfilter =             ft_getopt(cfg, 'bsfilter', 'no');
cfg.lpfiltord =            ft_getopt(cfg, 'lpfiltord', []);
cfg.hpfiltord =            ft_getopt(cfg, 'hpfiltord', []);
cfg.bpfiltord =            ft_getopt(cfg, 'bpfiltord', []);
cfg.bsfiltord =            ft_getopt(cfg, 'bsfiltord', []);
cfg.lpfilttype =           ft_getopt(cfg, 'lpfilttype', 'but');
cfg.hpfilttype =           ft_getopt(cfg, 'hpfilttype', 'but');
cfg.bpfilttype =           ft_getopt(cfg, 'bpfilttype', 'but');
cfg.bsfilttype =           ft_getopt(cfg, 'bsfilttype', 'but');
if strcmp(cfg.lpfilttype, 'firws'), cfg.lpfiltdir = ft_getopt(cfg, 'lpfiltdir', 'onepass-zerophase'); else, cfg.lpfiltdir = ft_getopt(cfg, 'lpfiltdir', 'twopass'); end
if strcmp(cfg.hpfilttype, 'firws'), cfg.hpfiltdir = ft_getopt(cfg, 'hpfiltdir', 'onepass-zerophase'); else, cfg.hpfiltdir = ft_getopt(cfg, 'hpfiltdir', 'twopass'); end
if strcmp(cfg.bpfilttype, 'firws'), cfg.bpfiltdir = ft_getopt(cfg, 'bpfiltdir', 'onepass-zerophase'); else, cfg.bpfiltdir = ft_getopt(cfg, 'bpfiltdir', 'twopass'); end
if strcmp(cfg.bsfilttype, 'firws'), cfg.bsfiltdir = ft_getopt(cfg, 'bsfiltdir', 'onepass-zerophase'); else, cfg.bsfiltdir = ft_getopt(cfg, 'bsfiltdir', 'twopass'); end
cfg.lpinstabilityfix =     ft_getopt(cfg, 'lpinstabilityfix', 'no');
cfg.hpinstabilityfix =     ft_getopt(cfg, 'hpinstabilityfix', 'no');
cfg.bpinstabilityfix =     ft_getopt(cfg, 'bpinstabilityfix', 'no');
cfg.bsinstabilityfix =     ft_getopt(cfg, 'bsinstabilityfix', 'no');
cfg.lpfiltdf =             ft_getopt(cfg, 'lpfiltdf',  []);
cfg.hpfiltdf =             ft_getopt(cfg, 'hpfiltdf', []);
cfg.bpfiltdf =             ft_getopt(cfg, 'bpfiltdf', []);
cfg.bsfiltdf =             ft_getopt(cfg, 'bsfiltdf', []);
cfg.lpfiltwintype =        ft_getopt(cfg, 'lpfiltwintype', 'hamming');
cfg.hpfiltwintype =        ft_getopt(cfg, 'hpfiltwintype', 'hamming');
cfg.bpfiltwintype =        ft_getopt(cfg, 'bpfiltwintype', 'hamming');
cfg.bsfiltwintype =        ft_getopt(cfg, 'bsfiltwintype', 'hamming');
cfg.lpfiltdev =            ft_getopt(cfg, 'lpfiltdev', []);
cfg.hpfiltdev =            ft_getopt(cfg, 'hpfiltdev', []);
cfg.bpfiltdev =            ft_getopt(cfg, 'bpfiltdev', []);
cfg.bsfiltdev =            ft_getopt(cfg, 'bsfiltdev', []);
cfg.plotfiltresp =         ft_getopt(cfg, 'plotfiltresp', 'no');
cfg.usefftfilt =           ft_getopt(cfg, 'usefftfilt', 'no');
cfg.medianfilter =         ft_getopt(cfg, 'medianfilter ', 'no');
cfg.medianfiltord =        ft_getopt(cfg, 'medianfiltord', 9);
cfg.dftfreq =              ft_getopt(cfg, 'dftfreq', [50 100 150]);
cfg.hilbert =              ft_getopt(cfg, 'hilbert', 'no');
cfg.derivative =           ft_getopt(cfg, 'derivative', 'no');
cfg.rectify =              ft_getopt(cfg, 'rectify', 'no');
cfg.boxcar =               ft_getopt(cfg, 'boxcar', 'no');
cfg.absdiff =              ft_getopt(cfg, 'absdiff', 'no');
cfg.precision =            ft_getopt(cfg, 'precision', []);
cfg.conv =                 ft_getopt(cfg, 'conv', 'no');
cfg.montage =              ft_getopt(cfg, 'montage', 'no');
cfg.dftinvert =            ft_getopt(cfg, 'dftinvert', 'no');
cfg.standardize =          ft_getopt(cfg, 'standardize', 'no');
cfg.denoise =              ft_getopt(cfg, 'denoise', '');
cfg.subspace =             ft_getopt(cfg, 'subspace', []);
cfg.custom =               ft_getopt(cfg, 'custom', '');
cfg.resample =             ft_getopt(cfg, 'resample', '');

% test whether the MATLAB signal processing toolbox is available
if strcmp(cfg.medianfilter, 'yes') && ~ft_hastoolbox('signal')
  ft_error('median filtering requires the MATLAB signal processing toolbox');
end

% do a sanity check on the filter configuration
if strcmp(cfg.bpfilter, 'yes') && ...
    (strcmp(cfg.hpfilter, 'yes') || strcmp(cfg.lpfilter,'yes'))
  ft_error('you should not apply both a bandpass AND a lowpass/highpass filter');
end

% do a sanity check on the hilbert transform configuration
if strcmp(cfg.hilbert, 'yes') && ~strcmp(cfg.bpfilter, 'yes')
  ft_warning('Hilbert transform should be applied in conjunction with bandpass filter')
end

% do a sanity check on hilbert and rectification
if strcmp(cfg.hilbert, 'yes') && strcmp(cfg.rectify, 'yes')
  ft_error('Hilbert transform and rectification should not be applied both')
end

% do a sanity check on the rereferencing/montage
if ~strcmp(cfg.reref, 'no') && ~strcmp(cfg.montage, 'no')
  ft_error('cfg.reref and cfg.montage are mutually exclusive')
end

% lnfilter is no longer used
if isfield(cfg, 'lnfilter') && strcmp(cfg.lnfilter, 'yes')
  ft_error('line noise filtering using the option cfg.lnfilter is not supported any more, use cfg.bsfilter instead')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do the rereferencing in case of EEG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(cfg.implicitref) && ~any(match_str(cfg.implicitref,label))
  label = {label{:} cfg.implicitref}';
  dat(end+1,:) = 0;
end

if strcmp(cfg.reref, 'yes')
  if strcmp(cfg.refmethod, 'bipolar')
    % this is implemented as a montage that the user does not get to see
    tmpcfg = keepfields(cfg, {'refmethod', 'implicitref', 'refchannel', 'channel'});
    tmpcfg.showcallinfo = 'no';
    montage = ft_prepare_montage(tmpcfg);
    % convert the data temporarily to a raw structure
    tmpdata.trial = {dat};
    tmpdata.time  = {time};
    tmpdata.label = label;
    % apply the montage to the data
    tmpdata = ft_apply_montage(tmpdata, montage, 'feedback', 'none');
    dat   = tmpdata.trial{1}; % the number of channels can have changed
    label = tmpdata.label;    % the output channels can be different than the input channels
    clear tmpdata
  else
    % mean or median based derivation of specified or all channels
    cfg.refchannel = ft_channelselection(cfg.refchannel, label);
    refindx = match_str(label, cfg.refchannel);
    if isempty(refindx)
      ft_error('reference channel was not found')
    end
    dat = ft_preproc_rereference(dat, refindx, cfg.refmethod);
  end
end

if ~strcmp(cfg.montage, 'no') && ~isempty(cfg.montage)
  % convert the data temporarily to a raw structure
  tmpdata.trial = {dat};
  tmpdata.time  = {time};
  tmpdata.label = label;
  % apply the montage to the data
  tmpdata = ft_apply_montage(tmpdata, cfg.montage, 'feedback', 'none');
  dat   = tmpdata.trial{1}; % the number of channels can have changed
  label = tmpdata.label;    % the output channels can be different than the input channels
  clear tmpdata
end

if any(any(isnan(dat)))
  % filtering is not possible for at least a selection of the data
  ft_warning('data contains NaNs, no filtering or preprocessing applied');
  
else
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % do the filtering on the padded data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isempty(cfg.denoise)
    hflag    = isfield(cfg.denoise, 'hilbert') && strcmp(cfg.denoise.hilbert, 'yes');
    datlabel = match_str(label, cfg.denoise.channel);
    reflabel = match_str(label, cfg.denoise.refchannel);
    tmpdat   = ft_preproc_denoise(dat(datlabel,:), dat(reflabel,:), hflag);
    dat(datlabel,:) = tmpdat;
  end
  
  % The filtering should in principle be done prior to the demeaning to
  % ensure that the resulting mean over the baseline window will be
  % guaranteed to be zero (even if there are filter artifacts).
  % However, the filtering benefits from the data being pulled towards zero,
  % causing less edge artifacts. That is why we start by removing the slow
  % drift, then filter, and then repeat the demean/detrend/polyremove.
  if strcmp(cfg.polyremoval, 'yes')
    nsamples  = size(dat,2);
    begsample = 1        + begpadding;
    endsample = nsamples - endpadding;
    dat = ft_preproc_polyremoval(dat, cfg.polyorder, begsample, endsample); % this will also demean and detrend
  elseif strcmp(cfg.detrend, 'yes')
    nsamples  = size(dat,2);
    begsample = 1        + begpadding;
    endsample = nsamples - endpadding;
    dat = ft_preproc_polyremoval(dat, 1, begsample, endsample); % this will also demean
  elseif strcmp(cfg.demean, 'yes')
    nsamples  = size(dat,2);
    begsample = 1        + begpadding;
    endsample = nsamples - endpadding;
    dat = ft_preproc_polyremoval(dat, 0, begsample, endsample);
  end
  
  if strcmp(cfg.medianfilter, 'yes'), dat = ft_preproc_medianfilter(dat, cfg.medianfiltord); end
  if strcmp(cfg.lpfilter, 'yes'),     dat = ft_preproc_lowpassfilter(dat, fsample, cfg.lpfreq, cfg.lpfiltord, cfg.lpfilttype, cfg.lpfiltdir, cfg.lpinstabilityfix, cfg.lpfiltdf, cfg.lpfiltwintype, cfg.lpfiltdev, cfg.plotfiltresp, cfg.usefftfilt); end
  if strcmp(cfg.hpfilter, 'yes'),     dat = ft_preproc_highpassfilter(dat, fsample, cfg.hpfreq, cfg.hpfiltord, cfg.hpfilttype, cfg.hpfiltdir, cfg.hpinstabilityfix, cfg.hpfiltdf, cfg.hpfiltwintype, cfg.hpfiltdev, cfg.plotfiltresp, cfg.usefftfilt); end
  if strcmp(cfg.bpfilter, 'yes'),     dat = ft_preproc_bandpassfilter(dat, fsample, cfg.bpfreq, cfg.bpfiltord, cfg.bpfilttype, cfg.bpfiltdir, cfg.bpinstabilityfix, cfg.bpfiltdf, cfg.bpfiltwintype, cfg.bpfiltdev, cfg.plotfiltresp, cfg.usefftfilt); end
  if strcmp(cfg.bsfilter, 'yes')
    for i=1:size(cfg.bsfreq,1)
      % apply a bandstop filter for each of the specified bands, i.e. cfg.bsfreq should be Nx2
      dat = ft_preproc_bandstopfilter(dat, fsample, cfg.bsfreq(i,:), cfg.bsfiltord, cfg.bsfilttype, cfg.bsfiltdir, cfg.bsinstabilityfix, cfg.bsfiltdf, cfg.bsfiltwintype, cfg.bsfiltdev, cfg.plotfiltresp, cfg.usefftfilt);
    end
  end
  if strcmp(cfg.polyremoval, 'yes')
    % the begin and endsample of the polyremoval period correspond to the complete data minus padding
    nsamples  = size(dat,2);
    begsample = 1        + begpadding;
    endsample = nsamples - endpadding;
    dat = ft_preproc_polyremoval(dat, cfg.polyorder, begsample, endsample);
  end
  if strcmp(cfg.detrend, 'yes')
    % the begin and endsample of the detrend period correspond to the complete data minus padding
    nsamples  = size(dat,2);
    begsample = 1        + begpadding;
    endsample = nsamples - endpadding;
    dat = ft_preproc_detrend(dat, begsample, endsample);
  end
  if strcmp(cfg.demean, 'yes')
    if ischar(cfg.baselinewindow) && strcmp(cfg.baselinewindow, 'all')
      % the begin and endsample of the baseline period correspond to the complete data minus padding
      nsamples  = size(dat,2);
      begsample = 1        + begpadding;
      endsample = nsamples - endpadding;
      dat       = ft_preproc_baselinecorrect(dat, begsample, endsample);
    else
      % determine the begin and endsample of the baseline period and baseline correct for it
      begsample = nearest(time, cfg.baselinewindow(1));
      endsample = nearest(time, cfg.baselinewindow(2));
      dat       = ft_preproc_baselinecorrect(dat, begsample, endsample);
    end
  end
  if strcmp(cfg.dftfilter, 'yes')
    datorig = dat;
    optarg = {};
    if isfield(cfg, 'dftreplace')
      optarg = cat(2, optarg, {'dftreplace', cfg.dftreplace});
      if strcmp(cfg.dftreplace, 'neighbour') && (begpadding>0 || endpadding>0)
        ft_error('Padding by data mirroring is not supported for spectrum interpolation.');
      end
    end
    if isfield(cfg, 'dftbandwidth')
      optarg = cat(2, optarg, {'dftbandwidth', cfg.dftbandwidth});
    end
    if isfield(cfg, 'dftneighbourwidth')
      optarg = cat(2, optarg, {'dftneighbourwidth', cfg.dftneighbourwidth});
    end
    dat     = ft_preproc_dftfilter(dat, fsample, cfg.dftfreq, optarg{:});
    if strcmp(cfg.dftinvert, 'yes')
      dat = datorig - dat;
    end
  end
  if ~strcmp(cfg.hilbert, 'no')
    dat = ft_preproc_hilbert(dat, cfg.hilbert);
  end
  if strcmp(cfg.rectify, 'yes')
    dat = ft_preproc_rectify(dat);
  end
  if isnumeric(cfg.boxcar)
    numsmp = round(cfg.boxcar*fsample);
    if ~rem(numsmp,2)
      % the kernel should have an odd number of samples
      numsmp = numsmp+1;
    end
    % kernel = ones(1,numsmp) ./ numsmp;
    % dat    = convn(dat, kernel, 'same');
    dat = ft_preproc_smooth(dat, numsmp); % better edge behavior
  end
  if isnumeric(cfg.conv)
    kernel = (cfg.conv(:)'./sum(cfg.conv));
    if ~rem(length(kernel),2)
      kernel = [kernel 0];
    end
    dat = convn(dat, kernel, 'same');
  end
  if strcmp(cfg.derivative, 'yes')
    dat = ft_preproc_derivative(dat, 1);
  end
  if strcmp(cfg.absdiff, 'yes')
    % this implements abs(diff(data), which is required for jump detection
    dat = abs([diff(dat, 1, 2) zeros(size(dat,1),1)]);
  end
  if strcmp(cfg.standardize, 'yes')
    dat = ft_preproc_standardize(dat, 1, size(dat,2));
  end
  if ~isempty(cfg.subspace)
    dat = ft_preproc_subspace(dat, cfg.subspace);
  end
  if ~isempty(cfg.custom)
    if ~isfield(cfg.custom, 'nargout')
      cfg.custom.nargout = 1;
    end
    if cfg.custom.nargout==1
      dat = feval(cfg.custom.funhandle, dat, cfg.custom.varargin);
    elseif cfg.custom.nargout==2
      [dat, time] = feval(cfg.custom.funhandle, dat, cfg.custom.varargin);
    end
  end
  if strcmp(cfg.resample, 'yes')
    if ~isfield(cfg, 'resamplefs')
      cfg.resamplefs = fsample./2;
    end
    if ~isfield(cfg, 'resamplemethod')
      cfg.resamplemethod = 'resample';
    end
    [dat               ] = ft_preproc_resample(dat,  fsample, cfg.resamplefs, cfg.resamplemethod);
    [time, dum, fsample] = ft_preproc_resample(time, fsample, cfg.resamplefs, cfg.resamplemethod);
  end
  if ~isempty(cfg.precision)
    % convert the data to another numeric precision, i.e. double, single or int32
    dat = cast(dat, cfg.precision);
  end
end % if any(isnan)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove the filter padding and do the preprocessing on the remaining trial data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if begpadding~=0 || endpadding~=0
  dat = ft_preproc_padding(dat, 'remove', begpadding, endpadding);
  if strcmp(cfg.demean, 'yes') || nargout>2
    time = ft_preproc_padding(time, 'remove', begpadding, endpadding);
  end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                         nge_panel
% affect panel visualization
w1 = get(findobj('string','View'),'value');
w2 = get(findobj('string','Ins'), 'value');
w3 = get(findobj('string','Del'), 'value');

if w1
  set(findobj('tag','slice'),'string','slice');
  set(findobj('tag','min'),'string','<');
  set(findobj('tag','max'),'string','>');
  set(findobj('tag','min'),'style','pushbutton');
  set(findobj('tag','max'),'style','pushbutton');
  set(findobj('tag','min'),'callback',@cb_btn);
  set(findobj('tag','max'),'callback',@cb_btn);
  set(findobj('tag','mesh'),'visible','on');
  set(findobj('tag','openm'),'visible','on');
  set(findobj('tag','viewm'),'visible','on');
  set(findobj('tag','brightness'),'visible','on');
  set(findobj('tag','plus'),'visible','on');
  set(findobj('tag','minus'),'visible','on');
  set(findobj('tag','toggle axes'),'visible','on');
  set(findobj('tag','plane'),'visible','on');
  set(findobj('tag','one'),'visible','on');
  set(findobj('tag','two'),'visible','on');
  set(findobj('tag','three'),'visible','on');
elseif w2
  set(findobj('tag','slice'),'string','select points');
  set(findobj('tag','min'),'string','close');
  set(findobj('tag','max'),'string','next');
  set(findobj('tag','min'),'style','pushbutton');
  set(findobj('tag','max'),'style','pushbutton');
  set(findobj('tag','min'),'callback',@tins_close);
  set(findobj('tag','max'),'callback',@tins_next);
  set(findobj('tag','mesh'),'visible','off');
  set(findobj('tag','openm'),'visible','off');
  set(findobj('tag','viewm'),'visible','off');
  set(findobj('tag','brightness'),'visible','off');
  set(findobj('tag','plus'),'visible','off');
  set(findobj('tag','minus'),'visible','off');
  set(findobj('tag','toggle axes'),'visible','off');
  set(findobj('tag','plane'),'visible','off');
  set(findobj('tag','one'),'visible','off');
  set(findobj('tag','two'),'visible','off');
  set(findobj('tag','three'),'visible','off');
elseif w3
  set(findobj('tag','slice'),'string','select points');
  set(findobj('tag','min'),'string','box');
  set(findobj('tag','max'),'string','point');
  set(findobj('tag','min'),'style','pushbutton');
  set(findobj('tag','max'),'style','pushbutton');
  set(findobj('tag','min'),'callback',@tdel_box);
  set(findobj('tag','max'),'callback',@tdel_single);
  set(findobj('tag','mesh'),'visible','off');
  set(findobj('tag','openm'),'visible','off');
  set(findobj('tag','viewm'),'visible','off');
  set(findobj('tag','brightness'),'visible','off');
  set(findobj('tag','plus'),'visible','off');
  set(findobj('tag','minus'),'visible','off');
  set(findobj('tag','toggle axes'),'visible','off');
  set(findobj('tag','plane'),'visible','off');
  set(findobj('tag','one'),'visible','off');
  set(findobj('tag','two'),'visible','off');
  set(findobj('tag','three'),'visible','off');
end

function tins_close(hObject, eventdata, handles)
set(gcf,'WindowButtonDownFcn','');

function tins_next(hObject, eventdata, handles)
set(gcf,'WindowButtonDownFcn','');


function tdel_box(hObject, eventdata, handles)
global obj
obj = gco;
set(gcf,'WindowButtonDownFcn',@cb_btn_dwn2);

function tdel_single(hObject, eventdata, handles)
global obj
obj = gco;
set(gcf,'WindowButtonDownFcn',@cb_btn_dwn2);

% accessory functions:
function [pnts] = slicedata2pnts(proj,slice)
fig       = get(gca, 'parent');
slicedata = getappdata(fig,'slicedata');
pnts = [];
for i=1:length(slicedata)
  if slicedata(i).slice==slice && slicedata(i).proj == proj
    for j=1:length(slicedata(i).polygon)
      if ~isempty(slicedata(i).polygon{j})
        tmp = slicedata(i).polygon{j};
        xs = tmp(:,1); ys = tmp(:,2);
        pnts = [pnts;[unique([xs,ys],'rows')]];
      end
    end
  end
end

function h = ispolygon(x)
h = length(x.XData)>1;

function h = ispoint(x)
h = length(x.XData)==1;

function [T,P] = points2param(pnt)
x = pnt(:,1); y = pnt(:,2); z = pnt(:,3);
[phi,theta,R] = cart2sph(x,y,z);
theta = theta + pi/2;
phi   = phi + pi;
T     = theta(:);
P     = phi(:);

function [bnd2,a,Or] = spherical_harmonic_mesh(bnd, nl)

% SPHERICAL_HARMONIC_MESH realizes the smoothed version of a mesh contained in the first
% argument bnd. The boundary argument (bnd) contains typically 2 fields
% called .pnt and .tri referring to vertices and triangulation of a mesh.
% The degree of smoothing is given by the order in the second input: nl
%
% Use as
%   bnd2 = spherical_harmonic_mesh(bnd, nl);

% nl    = 12; % from van 't Ent paper

bnd2 = [];

% calculate midpoint
Or = mean(bnd.pnt);
% rescale all points
x = bnd.pnt(:,1) - Or(1);
y = bnd.pnt(:,2) - Or(2);
z = bnd.pnt(:,3) - Or(3);
X = [x(:), y(:), z(:)];

% convert points to parameters
[T,P] = points2param(X);

% basis function
B     = shlib_B(nl, T, P);
Y     = B'*X;

% solve the linear system
a     = pinv(B'*B)*Y;

% build the surface
Xs = zeros(size(X));
for l = 0:nl-1
  for m = -l:l
    if m<0
      Yml = shlib_Yml(l, abs(m), T, P);
      Yml = (-1)^m*conj(Yml);
    else
      Yml = shlib_Yml(l, m, T, P);
    end
    indx = l^2 + l + m+1;
    Xs = Xs + Yml*a(indx,:);
  end
  fprintf('%d of %d\n', l, nl);
end
% Just take the real part
Xs = real(Xs);
% reconstruct the matrices for plotting.
xs = reshape(Xs(:,1), size(x,1), size(x,2));
ys = reshape(Xs(:,2), size(x,1), size(x,2));
zs = reshape(Xs(:,3), size(x,1), size(x,2));

bnd2.pnt = [xs(:)+Or(1) ys(:)+Or(2) zs(:)+Or(3)];
[bnd2.tri] = projecttri(bnd.pnt);

function B = shlib_B(nl, theta, phi)
% function B = shlib_B(nl, theta, phi)
%
% Constructs the matrix of basis functions
% where b(i,l^2 + l + m) = Yml(theta, phi)
%
% See also: shlib_Yml.m, shlib_decomp.m, shlib_gen_shfnc.m
%
% Dr. A. I. Hanna (2006).
B = zeros(length(theta), nl^2+2*nl+1);
for l = 0:nl-1
  for m = -l:l
    if m<0
      Yml = shlib_Yml(l, abs(m), theta, phi);
      Yml = (-1)^m*conj(Yml);
    else
      Yml = shlib_Yml(l, m, theta, phi);
    end
    indx = l^2 + l + m+1;
    B(:, indx) = Yml;
  end
end
return;

function Yml = shlib_Yml(l, m, theta, phi)
% function Yml = shlib_Yml(l, m, theta, phi)
%
% MATLAB function that takes a given order and degree, and the matrix of
% theta and phi and constructs a spherical harmonic from these. The
% analogue in the 1D case would be to give a particular frequency.
%
% Inputs:
%  m - order of the spherical harmonic
%  l - degree of the spherical harmonic
%  theta - matrix of polar coordinates \theta \in [0, \pi]
%  phi - matrix of azimuthal cooridinates \phi \in [0, 2\pi)
%
% Example:
%
% [x, y] = meshgrid(-1:.1:1);
% z = x.^2 + y.^2;
% [phi,theta,R] = cart2sph(x,y,z);
% Yml = spharm_aih(2,2, theta(:), phi(:));
%
% See also: shlib_B.m, shlib_decomp.m, shlib_gen_shfnc.m
%
% Dr. A. I. Hanna (2006)
Pml=legendre(l,cos(theta));
if l~=0
  Pml=squeeze(Pml(m+1,:,:));
end
Pml = Pml(:);
% Yml = sqrt(((2*l+1)/4).*(factorial(l-m)/factorial(l+m))).*Pml.*exp(sqrt(-1).*m.*phi);
% new:
Yml = sqrt(((2*l+1)/(4*pi)).*(factorial(l-m)/factorial(l+m))).*Pml.*exp(sqrt(-1).*m.*phi);
return;
                                                                                                                                                                                                                                                                          r = false;
  decr = false;
else
  incr = strcmp(get(h, 'String'), '+');
  decr = strcmp(get(h, 'String'), '-');
  lower = strfind(get(h, 'Tag'), 'Lower')>0;
  while ~strcmp(get(h, 'Tag'), 'mainFigure')
    h = get(h, 'Parent');
  end
end

opt =  guidata(h);
if (~incr&&~decr&&exist('eventdata', 'var')&&~isempty(eventdata)) % init call
  caxis(opt.handles.axes.movie, eventdata);
end
zmin = inf;
zmax = -inf;
for i=1:numel(opt.dat)
  [tmpmin tmpmax] = caxis(opt.handles.axes.movie_subplot{i});
  zmin = min(tmpmin, zmin);
  zmax = max(tmpmax, zmax);
end
yLim = get(opt.handles.colorbar, 'YLim');

if incr
  yTick = linspace(zmin, zmax, yLim(end));
  if get(opt.handles.checkbox.symmetric, 'Value')
    zmin = zmin - mean(diff(yTick));
    zmax = zmax + mean(diff(yTick));
  elseif (lower)
    zmin = zmin + mean(diff(yTick));
  else
    zmax = zmax + mean(diff(yTick));
  end
elseif decr
  yTick = linspace(zmin, zmax, yLim(end));
  if get(opt.handles.checkbox.symmetric, 'Value')
    zmin = zmin + mean(diff(yTick));
    zmax = zmax - mean(diff(yTick));
  elseif (lower)
    zmin = zmin - mean(diff(yTick));
  else
    zmax = zmax - mean(diff(yTick));
  end
elseif get(opt.handles.checkbox.automatic, 'Value') % if automatic
  set(opt.handles.lines.upperColor, 'Visible', 'off');
  set(opt.handles.lines.lowerColor, 'Visible', 'off');
  set(opt.handles.lines.upperColor, 'YData', [yLim(end)/2 yLim(end)/2]);
  set(opt.handles.lines.lowerColor, 'YData', [yLim(end)/2 yLim(end)/2]);
  set(opt.handles.button.incrLowerColor, 'Enable', 'off');
  set(opt.handles.button.decrUpperColor, 'Enable', 'off');
  set(opt.handles.button.incrUpperColor, 'Enable', 'off');
  set(opt.handles.button.decrLowerColor, 'Enable', 'off');
    
  if get(opt.handles.checkbox.symmetric, 'Value') % maxabs
    zmax = -inf;
    for i=1:numel(opt.dat)
      tmpmax = max(max(abs(opt.dat{i}(:,:,opt.valy))));
      zmax = max(tmpmax, zmax);
    end
    zmin = -zmax;
  else   % maxmin
    zmax = -inf;
    zmin = inf;
    for i=1:numel(opt.dat)
      tmpmin = min(min(opt.dat{i}(:,:,opt.valy)));
      tmpmax = max(max(opt.dat{i}(:,:,opt.valy)));
      zmax = max(tmpmax, zmax);
      zmin = min(tmpmin, zmin);
    end
    
  end
else
  set(opt.handles.lines.upperColor, 'Visible', 'on');
  set(opt.handles.lines.lowerColor, 'Visible', 'on')
  if get(opt.handles.checkbox.symmetric, 'Value') % maxabs
    set(opt.handles.button.incrLowerColor, 'Enable', 'off');
    set(opt.handles.button.decrUpperColor, 'Enable', 'off');
    set(opt.handles.button.incrUpperColor, 'Enable', 'on');
    set(opt.handles.button.decrLowerColor, 'Enable', 'on');
    for i=1:numel(opt.dat)
      [tmpmin tmpmax] = caxis(opt.handles.axes.movie_subplot{i});
      zmax = max(tmpmax, zmax);
    end
    zmin = -zmax;
  else
    set(opt.handles.button.incrLowerColor, 'Enable', 'on');
    set(opt.handles.button.decrUpperColor, 'Enable', 'on');
    set(opt.handles.button.incrUpperColor, 'Enable', 'on');
    set(opt.handles.button.decrLowerColor, 'Enable', 'on');
    for i=1:numel(opt.dat)
      [tmpmin tmpmax] = caxis(opt.handles.axes.movie_subplot{i});
      zmin = min(tmpmin, zmin);
      zmax = max(tmpmax, zmax);
    end
  end
end % incr, decr, automatic, else

maps = get(opt.handles.menu.colormap, 'String');
cmap = feval(maps{get(opt.handles.menu.colormap, 'Value')}, size(colormap, 1));
for i=1:numel(opt.dat)
  colormap(opt.handles.axes.movie_subplot{i}, cmap);
end

adjust_colorbar(opt);

if (gcf~=opt.handles.figure)
  close gcf; % sometimes there is a new window that opens up
end
for i=1:numel(opt.dat)
  caxis(opt.handles.axes.movie_subplot{i}, [zmin zmax]);
end

nColors = size(colormap, 1);
%yTick = (zmax-zmin)*(get(opt.handles.colorbar, 'YTick')/nColors)+zmin
yTick = (zmax-zmin)*[0 .25 .5 .75 1]+zmin;

%yTick = linspace(zmin, zmax, yLim(end));
% truncate intelligently/-ish
%yTick = get(opt.handles.colorbar, 'YTick')/nColors;
yTick = num2str(yTick', 5);
set(opt.handles.colorbar, 'YTickLabel', yTick, 'FontSize', 8);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
     