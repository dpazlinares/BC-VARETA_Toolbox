function [timelock] = ft_datatype_timelock(timelock, varargin)

% FT_DATATYPE_TIMELOCK describes the FieldTrip MATLAB structure for timelock data
%
% The timelock data structure represents averaged or non-averaged event-releted
% potentials (ERPs, in case of EEG) or ERFs (in case of MEG). This data structure is
% usually generated with the FT_TIMELOCKANALYSIS or FT_TIMELOCKGRANDAVERAGE function.
%
% An example of a timelock structure containing the ERF for 151 channels MEG data is
%
%     dimord: 'chan_time'       defines how the numeric data should be interpreted
%        avg: [151x600 double]  the average values of the activity for 151 channels x 600 timepoints
%        var: [151x600 double]  the variance of the activity for 151 channels x 600 timepoints
%      label: {151x1 cell}      the channel labels (e.g. 'MRC13')
%       time: [1x600 double]    the timepoints in seconds
%       grad: [1x1 struct]      information about the sensor array (for EEG data it is called elec)
%        cfg: [1x1 struct]      the configuration used by the function that generated this data structure
%
% Required fields:
%   - label, dimord, time
%
% Optional fields:
%   - avg, var, dof, cov, trial, trialinfo, sampleinfo, grad, elec, opto, cfg
%
% Deprecated fields:
%   - <none>
%
% Obsoleted fields:
%   - fsample
%
% Revision history:
%
% (2017/latest) The data structure cannot contain an average and simultaneously single
% trial information any more, i.e. avg/var/dof and trial/individual are mutually exclusive.
%
% (2011v2) The description of the sensors has changed, see FT_DATATYPE_SENS
% for further information.
%
% (2011) The field 'fsample' was removed, as it was redundant.
%
% (2003) The initial version was defined.
%
% See also FT_DATATYPE, FT_DATATYPE_COMP, FT_DATATYPE_FREQ, FT_DATATYPE_RAW

% Copyright (C) 2011, Robert Oostenveld
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

% get the optional input arguments, which should be specified as key-value pairs
version       = ft_getopt(varargin, 'version', 'latest');
hassampleinfo = ft_getopt(varargin, 'hassampleinfo', 'ifmakessense'); % can be yes/no/ifmakessense
hastrialinfo  = ft_getopt(varargin, 'hastrialinfo',  'ifmakessense'); % can be yes/no/ifmakessense

% convert it into true/false
if isequal(hassampleinfo, 'ifmakessense')
  hassampleinfo = makessense(timelock, 'sampleinfo');
else
  hassampleinfo = istrue(hassampleinfo);
end
if isequal(hastrialinfo, 'ifmakessense')
  hastrialinfo = makessense(timelock, 'trialinfo');
else
  hastrialinfo = istrue(hastrialinfo);
end

if strcmp(version, 'latest')
  version = '2017';
end

if isempty(timelock)
  return;
end

% ensure consistency between the dimord string and the axes that describe the data dimensions
timelock = fixdimord(timelock);

% remove these very obsolete fields, it is unclear when they were precisely used
if isfield(timelock, 'numsamples'),       timelock = rmfield(timelock, 'numsamples');       end
if isfield(timelock, 'numcovsamples'),    timelock = rmfield(timelock, 'numcovsamples');    end
if isfield(timelock, 'numblcovsamples'),  timelock = rmfield(timelock, 'numblcovsamples');  end

if ~iscolumn(timelock.label)
  timelock.label = timelock.label';
end
if ~isrow(timelock.time)
  timelock.time = timelock.time';
end
if ~isfield(timelock, 'label')
  ft_warning('data structure is incorrect since it has no channel labels');
end

switch version
  case '2017'
    % ensure that the sensor structures are up to date
    if isfield(timelock, 'grad')
      timelock.grad = ft_datatype_sens(timelock.grad);
    end
    if isfield(timelock, 'elec')
      timelock.elec = ft_datatype_sens(timelock.elec);
    end
    if isfield(timelock, 'opto')
      timelock.opto = ft_datatype_sens(timelock.opto);
    end
    
    fn = fieldnames(timelock);
    fn = setdiff(fn, ignorefields('appendtimelock'));
    fn = fn(~endsWith(fn, 'dimord'));
    dimord = cell(size(fn));
    hasrpt = false(size(fn));
    for i=1:numel(fn)
      dimord{i} = getdimord(timelock, fn{i});
      hasrpt(i) = ~isempty(strfind(dimord{i}, 'rpt')) || ~isempty(strfind(dimord{i}, 'subj'));
    end
    if any(hasrpt) && ~all(hasrpt)
      ft_warning('timelock structure contains field with and without repetitions');
      str = sprintf('%s, ', fn{hasrpt});
      str = str(1:end-2);
      ft_notice('selecting these fields that have repetitions: %s', str);
      str = sprintf('%s, ', fn{~hasrpt});
      str = str(1:end-2);
      ft_notice('removing these fields that do not have repetitions: %s', str);
      timelock = removefields(timelock, fn(~hasrpt));
      if isfield(timelock, 'dimord') && ~ismember(timelock.dimord, dimord(hasrpt))
        % the dimord does not apply to any of the existing fields any more
        timelock = rmfield(timelock, 'dimord');
      end
    end
    
    if (hassampleinfo && ~isfield(timelock, 'sampleinfo')) || (hastrialinfo && ~isfield(timelock, 'trialinfo'))
      % try to reconstruct the sampleinfo and trialinfo
      timelock = fixsampleinfo(timelock);
    end
    
    if ~hassampleinfo && isfield(timelock, 'sampleinfo')
      timelock = rmfield(timelock, 'sampleinfo');
    end
    
    if ~hastrialinfo && isfield(timelock, 'trialinfo')
      timelock = rmfield(timelock, 'trialinfo');
    end
    
    % this field can be present in raw data, but is not desired in timelock data
    timelock = removefields(timelock, {'fsample'});
    
  case '2011v2'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ensure that the sensor structures are up to date
    if isfield(timelock, 'grad')
      timelock.grad = ft_datatype_sens(timelock.grad);
    end
    if isfield(timelock, 'elec')
      timelock.elec = ft_datatype_sens(timelock.elec);
    end
    if isfield(timelock, 'opto')
      timelock.opto = ft_datatype_sens(timelock.opto);
    end
    
    % these fields can be present in raw data, but are not desired in timelock data
    timelock = removefields(timelock, {'sampleinfo', 'fsample'});
    
  case '2003'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % there are no known conversions for backward or forward compatibility support
    
  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ft_error('unsupported version "%s" for timelock datatype', version);
end
                                                                        1});
        tsmin = nanmin(spike.time{1});
        tsmax = nanmax(spike.time{1});
        spike.trialtime = [tsmin*ones(tmax,1) tsmax*ones(tmax,1)];
      end
      spike.lfplabel = spike.label; % in the old format, these were the lfp channels
      try
        spike.label    = spike.cfg.spikechannel;
      catch
        try
          spike.label = spike.spikechannel;
        catch
          spike.label = {'unit1'}; %default
        end
      end
      spike.dimord = '{chan}_spike_lfpchan_freq';
    end
    
    % fix the waveform dimensions
    if isfield(spike,'waveform')
      nUnits = length(spike.waveform);
      hasdat = false(1,nUnits);
      for iUnit = 1:nUnits
        hasdat(iUnit) = ~isempty(spike.waveform{iUnit});
      end
      
      if any(hasdat) %otherwise, ignore
        if ~isfield(spike, 'dimord')
          spike.dimord = '{chan}_lead_time_spike';
        end
        % fix the dimensions of the waveform dimord.
        for iUnit = 1:nUnits
          dim = size(spike.waveform{iUnit});
          if length(dim)==2 && ~isempty(spike.waveform{iUnit})
            nSpikes = length(spike.timestamp{iUnit}); % check what's the spike dimension from the timestamps            
            spikedim = dim==nSpikes;
            if isempty(spikedim)
              ft_error('waveforms contains data but number of waveforms does not match number of spikes');
            end
            if spikedim==1
              spike.waveform{iUnit} = permute(spike.waveform{iUnit},[3 2 1]);
            else
              spike.waveform{iUnit} = permute(spike.waveform{iUnit},[3 1 2]);
            end    
            
          elseif length(dim)==3 && ~isempty(spike.waveform{iUnit})
            nSpikes = length(spike.timestamp{iUnit}); % check what's the spike dimension from the timestamps                                      
            spikedim = dim==nSpikes;
            % determine from the remaining dimensions which is the lead
            leaddim  = dim<6 & dim~=nSpikes;
            sampdim  = dim>=6 & dim~=nSpikes;
            if isempty(spikedim)
              ft_error('waveforms contains data but number of waveforms does not match number of spikes');
            end
            if sum(leaddim)~=1 || sum(sampdim)~=1, continue,end % in this case we do not know what to do                        
            if find(spikedim)~=3 && find(leaddim)~=1 && find(sampdim)~=2
                spike.waveform{iUnit} = permute(spike.waveform{iUnit}, [find(leaddim) find(sampdim) find(spikedim)]);
            end
          end                        
        end
        
      end
      
    end
    
    % ensure that we always deal with row vectors: for consistency of
    % representation
    if isfield(spike,'time')
      for iUnit = 1:length(spike.time)
        if size(spike.time{iUnit},2)==1
          spike.time{iUnit} = spike.time{iUnit}(:)';
        end
      end
    end
    
    if isfield(spike,'time')
      for iUnit = 1:length(spike.trial)
        if size(spike.trial{iUnit},2)==1
          spike.trial{iUnit} = spike.trial{iUnit}(:)';
        end
      end
    end
        
    if isfield(spike,'timestamp')
      for iUnit = 1:length(spike.timestamp)
        if size(spike.timestamp{iUnit},2)==1
          spike.timestamp{iUnit} = spike.timestamp{iUnit}(:)';
        end
      end
    end
    
     if isfield(spike,'unit')
      for iUnit = 1:length(spike.unit)
        if size(spike.unit{iUnit},2)==1
          spike.unit{iUnit} = spike.unit{iUnit}(:)';
        end
      end
    end
        
  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ft_error('unsupported version "%s" for spike datatype', version);
end



                                                                                                                                                                                                                                                                                                                                                                                               axx, source.dim(1));
        source.ygrid = linspace(miny, maxy, source.dim(2));
        source.zgrid = linspace(minz, maxz, source.dim(3));
      end
    end

  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ft_error('unsupported version "%s" for source datatype', version);
end

function pos = grid2pos(xgrid, ygrid, zgrid)
[X, Y, Z] = ndgrid(xgrid, ygrid, zgrid);
pos = [X(:) Y(:) Z(:)];

function pos = dim2pos(dim, transform)
[X, Y, Z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
pos = [X(:) Y(:) Z(:)];
pos = ft_warp_apply(transform, pos, 'homogenous');
                                                                                                                                                                                                                                                                                                                                                                                                                                 input gradiometer');
      end

      if ~strcmp(amplitude, 'unknown') && ~strcmp(distance, 'unknown')

        % the default should be "amplitude/distance" for neuromag and "amplitude" for all others
        if isempty(scaling)
          if ft_senstype(sens, 'neuromag') && ~any(contains(sens.chanunit, '/'))
            ft_warning('assuming that the default scaling should be amplitude/distance rather than amplitude');
            scaling = 'amplitude/distance';
          elseif ft_senstype(sens, 'yokogawa440') && any(contains(sens.chanunit, '/'))
            ft_warning('assuming that the default scaling should be amplitude rather than amplitude/distance');
            scaling = 'amplitude';
          end
        end

        % update the gradiometer scaling
        if strcmp(scaling, 'amplitude') && isfield(sens, 'tra')
          for i=1:nchan
            if strcmp(sens.chanunit{i}, [amplitude '/' distance])
              % this channel is expressed as amplitude per distance
              coil = find(abs(sens.tra(i,:))~=0);
              if length(coil)~=2
                ft_error('unexpected number of coils contributing to channel %d', i);
              end
              baseline         = norm(sens.coilpos(coil(1),:) - sens.coilpos(coil(2),:));
              sens.tra(i,:)    = sens.tra(i,:)*baseline;  % scale with the baseline distance
              sens.chanunit{i} = amplitude;
            elseif strcmp(sens.chanunit{i}, amplitude)
              % no conversion needed
            elseif isfield(sens, 'balance') && strcmp(sens.balance.current, 'comp')
              % no conversion needed
            elseif isfield(sens, 'balance') && strcmp(sens.balance.current, 'planar')
              % no conversion needed
            else
              % see http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=3144
              ft_warning('unexpected channel unit "%s" in channel %d', sens.chanunit{i}, i);
            end % if
          end % for nchan

        elseif strcmp(scaling, 'amplitude/distance') && isfield(sens, 'tra')
          for i=1:nchan
            if strcmp(sens.chanunit{i}, amplitude)
              % this channel is expressed as amplitude
              coil = find(abs(sens.tra(i,:))~=0);
              if length(coil)==1 || strcmp(sens.chantype{i}, 'megmag')
                % this is a magnetometer channel, no conversion needed
                continue
              elseif length(coil)~=2
                ft_error('unexpected number of coils (%d) contributing to channel %s (%d)', length(coil), sens.label{i}, i);
              end
              baseline         = norm(sens.coilpos(coil(1),:) - sens.coilpos(coil(2),:));
              sens.tra(i,:)    = sens.tra(i,:)/baseline; % scale with the baseline distance
              sens.chanunit{i} = [amplitude '/' distance];
            elseif strcmp(sens.chanunit{i}, [amplitude '/' distance])
              % no conversion needed
            else
              % see http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=3144
              ft_warning('unexpected channel unit "%s" in channel %d', sens.chanunit{i}, i);
            end % if
          end % for nchan

        end % if strcmp scaling
      end % if amplitude and scaling are not unknown

    else
      sel_m  = ~cellfun(@isempty, regexp(sens.chanunit, '/m$'));
      sel_dm = ~cellfun(@isempty, regexp(sens.chanunit, '/dm$'));
      sel_cm = ~cellfun(@isempty, regexp(sens.chanunit, '/cm$'));
      sel_mm = ~cellfun(@isempty, regexp(sens.chanunit, '/mm$'));
      if any(sel_m | sel_dm | sel_cm | sel_mm)
        ft_error('scaling of amplitude/distance has not been considered yet for EEG');
      end

    end % if iseeg or ismeg

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case '2011v2'

    % rename from old to org (reverse = true)
    sens = fixoldorg(sens, true);

    if ~isempty(amplitude) || ~isempty(distance) || ~isempty(scaling)
      ft_warning('amplitude, distance and scaling are not supported for version "%s"', version);
    end

    % This speeds up subsequent calls to ft_senstype and channelposition.
    % However, if it is not more precise than MEG or EEG, don't keep it in
    % the output (see further down).
    if ~isfield(sens, 'type')
      sens.type = ft_senstype(sens);
    end

    if isfield(sens, 'pnt')
      if ismeg
        % sensor description is a MEG sensor-array, containing oriented coils
        sens.coilpos = sens.pnt; sens = rmfield(sens, 'pnt');
        sens.coilori = sens.ori; sens = rmfield(sens, 'ori');
      else
        % sensor description is something else, EEG/ECoG etc
        sens.elecpos = sens.pnt; sens = rmfield(sens, 'pnt');
      end
    end

    if ~isfield(sens, 'chanpos')
      if ismeg
        % sensor description is a MEG sensor-array, containing oriented coils
        [chanpos, chanori, lab] = channelposition(sens);
        % the channel order can be different in the two representations
        [selsens, selpos] = match_str(sens.label, lab);
        sens.chanpos = nan(length(sens.label), 3);
        sens.chanori = nan(length(sens.label), 3);
        % insert the determined position/orientation on the appropriate rows
        sens.chanpos(selsens,:) = chanpos(selpos,:);
        sens.chanori(selsens,:) = chanori(selpos,:);
        if length(selsens)~=length(sens.label)
          ft_warning('cannot determine the position and orientation for all channels');
        end
      else
        % sensor description is something else, EEG/ECoG etc
        % note that chanori will be all NaNs
        [chanpos, chanori, lab] = channelposition(sens);
        % the channel order can be different in the two representations
        [selsens, selpos] = match_str(sens.label, lab);
        sens.chanpos = nan(length(sens.label), 3);
        % insert the determined position/orientation on the appropriate rows
        sens.chanpos(selsens,:) = chanpos(selpos,:);
        if length(selsens)~=length(sens.label)
          ft_warning('cannot determine the position and orientation for all channels');
        end
      end
    end

    if ~isfield(sens, 'chantype') || all(strcmp(sens.chantype, 'unknown'))
      if ismeg
        sens.chantype = ft_chantype(sens);
      else
        % for EEG it is not required
      end
    end

    if ~isfield(sens, 'unit')
      % this should be done prior to calling ft_chanunit, since ft_chanunit uses this for planar neuromag channels
      sens = ft_determine_units(sens);
    end

    if ~isfield(sens, 'chanunit') || all(strcmp(sens.chanunit, 'unknown'))
      if ismeg
        sens.chanunit = ft_chanunit(sens);
      else
        % for EEG it is not required
      end
    end

    if any(strcmp(sens.type, {'meg', 'eeg', 'magnetometer', 'electrode', 'unknown'}))
      % this is not sufficiently informative, so better remove it
      % see also http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=1806
      sens = rmfield(sens, 'type');
    end

    if size(sens.chanpos,1)~=length(sens.label) || ...
        isfield(sens, 'tra') && size(sens.tra,1)~=length(sens.label) || ...
        isfield(sens, 'tra') && isfield(sens, 'elecpos') && size(sens.tra,2)~=size(sens.elecpos,1) || ...
        isfield(sens, 'tra') && isfield(sens, 'coilpos') && size(sens.tra,2)~=size(sens.coilpos,1) || ...
        isfield(sens, 'tra') && isfield(sens, 'coilori') && size(sens.tra,2)~=size(sens.coilori,1) || ...
        isfield(sens, 'chanpos') && size(sens.chanpos,1)~=length(sens.label) || ...
        isfield(sens, 'chanori') && size(sens.chanori,1)~=length(sens.label)
      ft_error('inconsistent number of channels in sensor description');
    end

    if ismeg
      % ensure that the magnetometer/gradiometer balancing is specified
      if ~isfield(sens, 'balance') || ~isfield(sens.balance, 'current')
        sens.balance.current = 'none';
      end

      % try to add the chantype and chanunit to the CTF G1BR montage
      if isfield(sens, 'balance') && isfield(sens.balance, 'G1BR') && ~isfield(sens.balance.G1BR, 'chantype')
        sens.balance.G1BR.chantypeorg = repmat({'unknown'}, size(sens.balance.G1BR.labelorg));
        sens.balance.G1BR.chanunitorg = repmat({'unknown'}, size(sens.balance.G1BR.labelorg));
        sens.balance.G1BR.chantypenew = repmat({'unknown'}, size(sens.balance.G1BR.labelnew));
        sens.balance.G1BR.chanunitnew = repmat({'unknown'}, size(sens.balance.G1BR.labelnew));
        % the synthetic gradient montage does not fundamentally change the chantype or chanunit
        [sel1, sel2] = match_str(sens.balance.G1BR.labelorg, sens.label);
        sens.balance.G1BR.chantypeorg(sel1) = sens.chantype(sel2);
        sens.balance.G1BR.chanunitorg(sel1) = sens.chanunit(sel2);
        [sel1, sel2] = match_str(sens.balance.G1BR.labelnew, sens.label);
        sens.balance.G1BR.chantypenew(sel1) = sens.chantype(sel2);
        sens.balance.G1BR.chanunitnew(sel1) = sens.chanunit(sel2);
      end

      % idem for G2BR
      if isfield(sens, 'balance') && isfield(sens.balance, 'G2BR') && ~isfield(sens.balance.G2BR, 'chantype')
        sens.balance.G2BR.chantypeorg = repmat({'unknown'}, size(sens.balance.G2BR.labelorg));
        sens.balance.G2BR.chanunitorg = repmat({'unknown'}, size(sens.balance.G2BR.labelorg));
        sens.balance.G2BR.chantypenew = repmat({'unknown'}, size(sens.balance.G2BR.labelnew));
        sens.balance.G2BR.chanunitnew = repmat({'unknown'}, size(sens.balance.G2BR.labelnew));
        % the synthetic gradient montage does not fundamentally change the chantype or chanunit
        [sel1, sel2] = match_str(sens.balance.G2BR.labelorg, sens.label);
        sens.balance.G2BR.chantypeorg(sel1) = sens.chantype(sel2);
        sens.balance.G2BR.chanunitorg(sel1) = sens.chanunit(sel2);
        [sel1, sel2] = match_str(sens.balance.G2BR.labelnew, sens.label);
        sens.balance.G2BR.chantypenew(sel1) = sens.chantype(sel2);
        sens.balance.G2BR.chanunitnew(sel1) = sens.chanunit(sel2);
      end

      % idem for G3BR
      if isfield(sens, 'balance') && isfield(sens.balance, 'G3BR') && ~isfield(sens.balance.G3BR, 'chantype')
        sens.balance.G3BR.chantypeorg = repmat({'unknown'}, size(sens.balance.G3BR.labelorg));
        sens.balance.G3BR.chanunitorg = repmat({'unknown'}, size(sens.balance.G3BR.labelorg));
        sens.balance.G3BR.chantypenew = repmat({'unknown'}, size(sens.balance.G3BR.labelnew));
        sens.balance.G3BR.chanunitnew = repmat({'unknown'}, size(sens.balance.G3BR.labelnew));
        % the synthetic gradient montage does not fundamentally change the chantype or chanunit
        [sel1, sel2] = match_str(sens.balance.G3BR.labelorg, sens.label);
        sens.balance.G3BR.chantypeorg(sel1) = sens.chantype(sel2);
        sens.balance.G3BR.chanunitorg(sel1) = sens.chanunit(sel2);
        [sel1, sel2] = match_str(sens.balance.G3BR.labelnew, sens.label);
        sens.balance.G3BR.chantypenew(sel1) = sens.chantype(sel2);
        sens.balance.G3BR.chanunitnew(sel1) = sens.chanunit(sel2);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  otherwise
    ft_error('converting to version %s is not supported', version);

end % switch

% this makes the display with the "disp" command look better
sens = sortfieldnames(sens);

% remember the current input and output arguments, so that they can be
% reused on a subsequent call in case the same input argument is given
current_argout = {sens};
previous_argin  = current_argin;
previous_argout = current_argout;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function b = sortfieldnames(a)
fn = sort(fieldnames(a));
for i=1:numel(fn)
  b.(fn{i}) = a.(fn{i});
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             t
    ft_error('This function requires data with a ''trial'' field');
  end % if hasrpt
elseif isequal(hastrials, 'no') && istimelock
  if ~isfield(data, 'avg') && (isfield(data, 'trial') || isfield(data, 'individual'))
    % average on the fly
    tmpcfg = [];
    tmpcfg.keeptrials = 'no';
    data = ft_timelockanalysis(tmpcfg, data);
  end
end

if strcmp(hasdim, 'yes') && ~isfield(data, 'dim')
  data.dim = pos2dim(data.pos);
elseif strcmp(hasdim, 'no') && isfield(data, 'dim')
  data = rmfield(data, 'dim');
end % if hasdim

if strcmp(hascumtapcnt, 'yes') && ~isfield(data, 'cumtapcnt')
  ft_error('This function requires data with a ''cumtapcnt'' field');
elseif strcmp(hascumtapcnt, 'no') && isfield(data, 'cumtapcnt')
  data = rmfield(data, 'cumtapcnt');
end % if hascumtapcnt

if strcmp(hasdof, 'yes') && ~isfield(data, 'dof')
  ft_error('This function requires data with a ''dof'' field');
elseif strcmp(hasdof, 'no') && isfield(data, 'dof')
  data = rmfield(data, 'dof');
end % if hasdof

if ~isempty(cmbrepresentation)
  if istimelock
    data = fixcov(data, cmbrepresentation);
  elseif isfreq
    data = fixcsd(data, cmbrepresentation, channelcmb);
  elseif isfreqmvar
    data = fixcsd(data, cmbrepresentation, channelcmb);
  else
    ft_error('This function requires data with a covariance, coherence or cross-spectrum');
  end
end % cmbrepresentation

if isfield(data, 'grad')
  % ensure that the gradiometer structure is up to date
  data.grad = ft_datatype_sens(data.grad);
end

if isfield(data, 'elec')
  % ensure that the electrode structure is up to date
  data.elec = ft_datatype_sens(data.elec);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% represent the covariance matrix in a particular manner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = fixcov(data, desired)
if any(isfield(data, {'cov', 'corr'}))
  if ~isfield(data, 'labelcmb')
    current = 'full';
  else
    current = 'sparse';
  end
else
  ft_error('Could not determine the current representation of the covariance matrix');
end
if isequal(current, desired)
  % nothing to do
elseif strcmp(current, 'full') && strcmp(desired, 'sparse')
  % FIXME should be implemented
  ft_error('not yet implemented');
elseif strcmp(current, 'sparse') && strcmp(desired, 'full')
  % FIXME should be implemented
  ft_error('not yet implemented');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% represent the cross-spectral density matrix in a particular manner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = fixcsd(data, desired, channelcmb)

% FIXCSD converts univariate frequency domain data (fourierspctrm) into a bivariate
% representation (crsspctrm), or changes the representation of bivariate frequency
% domain data (sparse/full/sparsewithpow, sparsewithpow only works for crsspctrm or
% fourierspctrm)

% Copyright (C) 2010, Jan-Mathijs Schoffelen, Robert Oostenveld

if isfield(data, 'crsspctrm') && isfield(data, 'powspctrm')
  current = 'sparsewithpow';
elseif isfield(data, 'powspctrm')
  current = 'sparsewithpow';
elseif isfield(data, 'fourierspctrm') && ~isfield(data, 'labelcmb')
  current = 'fourier';
elseif ~isfield(data, 'labelcmb')
  current = 'full';
elseif isfield(data, 'labelcmb')
  current = 'sparse';
else
  ft_error('Could not determine the current representation of the %s matrix', param);
end

% first go from univariate fourier to the required bivariate representation
if isequal(current, desired)
  % nothing to do
  
elseif strcmp(current, 'fourier') && strcmp(desired, 'sparsewithpow')
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpttap',   dimtok))
    nrpt = size(data.cumtapcnt,1);
    flag = 0;
  else
    nrpt = 1;
  end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=length(data.freq);      else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=length(data.time);      else ntim = 1; end
  
  fastflag = all(data.cumtapcnt(:)==data.cumtapcnt(1));
  flag     = nrpt==1; % needed to truncate the singleton dimension upfront
  
  %create auto-spectra
  nchan     = length(data.label);
  if fastflag
    % all trials have the same amount of tapers
    powspctrm = zeros(nrpt,nchan,nfrq,ntim);
    ntap      = data.cumtapcnt(1);
    for p = 1:ntap
      powspctrm = powspctrm + abs(data.fourierspctrm(p:ntap:end,:,:,:,:)).^2;
    end
    powspctrm = powspctrm./ntap;
  else
    % different amount of tapers
    powspctrm = zeros(nrpt,nchan,nfrq,ntim) + zeros(nrpt,nchan,nfrq,ntim)*1i;
    sumtapcnt = [0;cumsum(data.cumtapcnt(:))];
    for p = 1:nrpt
      indx   = (sumtapcnt(p)+1):sumtapcnt(p+1);
      tmpdat = data.fourierspctrm(indx,:,:,:);
      powspctrm(p,:,:,:) = (sum(tmpdat.*conj(tmpdat),1))./data.cumtapcnt(p);
    end
  end
  
  %create cross-spectra
  if ~isempty(channelcmb)
    ncmb      = size(channelcmb,1);
    cmbindx   = zeros(ncmb,2);
    labelcmb  = cell(ncmb,2);
    for k = 1:ncmb
      ch1 = find(strcmp(data.label, channelcmb(k,1)));
      ch2 = find(strcmp(data.label, channelcmb(k,2)));
      if ~isempty(ch1) && ~isempty(ch2)
        cmbindx(k,:)  = [ch1 ch2];
        labelcmb(k,:) = data.label([ch1 ch2])';
      end
    end
    
    crsspctrm = zeros(nrpt,ncmb,nfrq,ntim)+i.*zeros(nrpt,ncmb,nfrq,ntim);
    if fastflag
      for p = 1:ntap
        tmpdat1   = data.fourierspctrm(p:ntap:end,cmbindx(:,1),:,:,:);
        tmpdat2   = data.fourierspctrm(p:ntap:end,cmbindx(:,2),:,:,:);
        crsspctrm = crsspctrm + tmpdat1.*conj(tmpdat2);
      end
      crsspctrm = crsspctrm./ntap;
    else
      for p = 1:nrpt
        indx    = (sumtapcnt(p)+1):sumtapcnt(p+1);
        tmpdat1 = data.fourierspctrm(indx,cmbindx(:,1),:,:);
        tmpdat2 = data.fourierspctrm(indx,cmbindx(:,2),:,:);
        crsspctrm(p,:,:,:) = (sum(tmpdat1.*conj(tmpdat2),1))./data.cumtapcnt(p);
      end
    end
    data.crsspctrm = crsspctrm;
    data.labelcmb  = labelcmb;
  end
  data.powspctrm = powspctrm;
  data           = rmfield(data, 'fourierspctrm');
  if ntim>1
    data.dimord = 'chan_freq_time';
  else
    data.dimord = 'chan_freq';
  end
  
  if nrpt>1
    data.dimord = ['rpt_',data.dimord];
  end
  
  if flag
    siz = size(data.powspctrm);
    data.powspctrm = reshape(data.powspctrm, [siz(2:end) 1]);
    if isfield(data, 'crsspctrm')
      siz = size(data.crsspctrm);
      data.crsspctrm = reshape(data.crsspctrm, [siz(2:end) 1]);
    end
  end
elseif strcmp(current, 'fourier') && strcmp(desired, 'sparse')
  
  if isempty(channelcmb), ft_error('no channel combinations are specified'); end
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpttap',   dimtok))
    nrpt = size(data.cumtapcnt,1);
    flag = 0;
  else
    nrpt = 1;
  end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=length(data.freq); else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=length(data.time); else ntim = 1; end
  
  flag      = nrpt==1; % flag needed to squeeze first dimension if singleton
  ncmb      = size(channelcmb,1);
  cmbindx   = zeros(ncmb,2);
  labelcmb  = cell(ncmb,2);
  for k = 1:ncmb
    ch1 = find(strcmp(data.label, channelcmb(k,1)));
    ch2 = find(strcmp(data.label, channelcmb(k,2)));
    if ~isempty(ch1) && ~isempty(ch2)
      cmbindx(k,:)  = [ch1 ch2];
      labelcmb(k,:) = data.label([ch1 ch2])';
    end
  end
  
  sumtapcnt = [0;cumsum(data.cumtapcnt(:))];
  fastflag  = all(data.cumtapcnt(:)==data.cumtapcnt(1));
  
  if fastflag && nrpt>1
    ntap = data.cumtapcnt(1);
    
    % compute running sum across tapers
    siz = [size(data.fourierspctrm) 1];
    
    for p = 1:ntap
      indx      = p:ntap:nrpt*ntap;
      
      if p==1.
        
        tmpc = zeros(numel(indx), size(cmbindx,1), siz(3), siz(4)) + ...
          1i.*zeros(numel(indx), size(cmbindx,1), siz(3), siz(4));
      end
      
      for k = 1:size(cmbindx,1)
        tmpc(:,k,:,:) = data.fourierspctrm(indx,cmbindx(k,1),:,:).*  ...
          conj(data.fourierspctrm(indx,cmbindx(k,2),:,:));
      end
      
      if p==1
        crsspctrm = tmpc;
      else
        crsspctrm = tmpc + crsspctrm;
      end
    end
    crsspctrm = crsspctrm./ntap;
  else
    crsspctrm = zeros(nrpt, ncmb, nfrq, ntim);
    for p = 1:nrpt
      indx    = (sumtapcnt(p)+1):sumtapcnt(p+1);
      tmpdat1 = data.fourierspctrm(indx,cmbindx(:,1),:,:);
      tmpdat2 = data.fourierspctrm(indx,cmbindx(:,2),:,:);
      crsspctrm(p,:,:,:) = (sum(tmpdat1.*conj(tmpdat2),1))./data.cumtapcnt(p);
    end
  end
  data.crsspctrm = crsspctrm;
  data.labelcmb  = labelcmb;
  data           = rmfield(data, 'fourierspctrm');
  data           = rmfield(data, 'label');
  if ntim>1
    data.dimord = 'chancmb_freq_time';
  else
    data.dimord = 'chancmb_freq';
  end
  
  if nrpt>1
    data.dimord = ['rpt_',data.dimord];
  end
  
  if flag
    if isfield(data,'powspctrm')
      % deal with the singleton 'rpt', i.e. remove it
      siz = size(data.powspctrm);
      data.powspctrm = reshape(data.powspctrm, [siz(2:end) 1]);
    end
    if isfield(data,'crsspctrm')
      % this conditional statement is needed in case there's a single channel
      siz            = size(data.crsspctrm);
      data.crsspctrm = reshape(data.crsspctrm, [siz(2:end) 1]);
    end
  end
elseif strcmp(current, 'fourier') && strcmp(desired, 'full')
  
  % this is how it is currently and the desired functionality of prepare_freq_matrices
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpttap',   dimtok))
    nrpt = size(data.cumtapcnt, 1);
    flag = 0;
  else
    nrpt = 1;
    flag = 1;
  end
  if ~isempty(strmatch('rpttap',dimtok)), nrpt=size(data.cumtapcnt, 1); else nrpt = 1; end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=length(data.freq);       else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=length(data.time);       else ntim = 1; end
  if any(data.cumtapcnt(1,:) ~= data.cumtapcnt(1,1)), ft_error('this only works when all frequencies have the same number of tapers'); end
  nchan     = length(data.label);
  crsspctrm = zeros(nrpt,nchan,nchan,nfrq,ntim);
  sumtapcnt = [0;cumsum(data.cumtapcnt(:,1))];
  for k = 1:ntim
    for m = 1:nfrq
      for p = 1:nrpt
        %FIXME speed this up in the case that all trials have equal number of tapers
        indx   = (sumtapcnt(p)+1):sumtapcnt(p+1);
        tmpdat = transpose(data.fourierspctrm(indx,:,m,k));
        crsspctrm(p,:,:,m,k) = (tmpdat*tmpdat')./data.cumtapcnt(p);
        clear tmpdat;
      end
    end
  end
  data.crsspctrm = crsspctrm;
  data           = rmfield(data, 'fourierspctrm');
  
  if ntim>1,
    data.dimord = 'chan_chan_freq_time';
  else
    data.dimord = 'chan_chan_freq';
  end
  
  if nrpt>1,
    data.dimord = ['rpt_',data.dimord];
  end
  
  % remove first singleton dimension
  if flag || nrpt==1, siz = size(data.crsspctrm); data.crsspctrm = reshape(data.crsspctrm, siz(2:end)); end
  
elseif strcmp(current, 'fourier') && strcmp(desired, 'fullfast'),
  
  dimtok = tokenize(data.dimord, '_');
  nrpt = size(data.fourierspctrm, 1);
  nchn = numel(data.label);
  nfrq = numel(data.freq);
  if ~isempty(strmatch('time',  dimtok)), ntim=numel(data.time); else ntim = 1; end
  
  data.fourierspctrm = reshape(data.fourierspctrm, [nrpt nchn nfrq*ntim]);
  data.fourierspctrm(~isfinite(data.fourierspctrm)) = 0;
  crsspctrm = complex(zeros(nchn,nchn,nfrq*ntim));
  for k = 1:nfrq*ntim
    tmp = transpose(data.fourierspctrm(:,:,k));
    n   = sum(tmp~=0,2);
    crsspctrm(:,:,k) = tmp*tmp'./n(1);
  end
  data           = rmfield(data, 'fourierspctrm');
  data.crsspctrm = reshape(crsspctrm, [nchn nchn nfrq ntim]);
  if isfield(data, 'time'),
    data.dimord = 'chan_chan_freq_time';
  else
    data.dimord = 'chan_chan_freq';
  end
  
  if isfield(data, 'trialinfo'),  data = rmfield(data, 'trialinfo'); end
  if isfield(data, 'sampleinfo'), data = rmfield(data, 'sampleinfo'); end
  if isfield(data, 'cumsumcnt'),  data = rmfield(data, 'cumsumcnt');  end
  if isfield(data, 'cumtapcnt'),  data = rmfield(data, 'cumtapcnt');  end
  
end % convert to the requested bivariate representation

% from one bivariate representation to another
if isequal(current, desired)
  % nothing to do
  
elseif (strcmp(current, 'full')       && strcmp(desired, 'fourier')) || ...
    (strcmp(current, 'sparse')        && strcmp(desired, 'fourier')) || ...
    (strcmp(current, 'sparsewithpow') && strcmp(desired, 'fourier'))
  % this is not possible
  ft_error('converting the cross-spectrum into a Fourier representation is not possible');
  
elseif strcmp(current, 'full') && strcmp(desired, 'sparsewithpow')
  ft_error('not yet implemented');
  
elseif strcmp(current, 'sparse') && strcmp(desired, 'sparsewithpow')
  % convert back to crsspctrm/powspctrm representation: useful for plotting functions etc
  indx     = labelcmb2indx(data.labelcmb);
  autoindx = indx(indx(:,1)==indx(:,2), 1);
  cmbindx  = setdiff([1:size(indx,1)]', autoindx);
  
  if strcmp(data.dimord(1:3), 'rpt')
    data.powspctrm = data.crsspctrm(:, autoindx, :, :);
    data.crsspctrm = data.crsspctrm(:, cmbindx,  :, :);
  else
    data.powspctrm = data.crsspctrm(autoindx, :, :);
    data.crsspctrm = data.crsspctrm(cmbindx,  :, :);
  end
  data.label    = data.labelcmb(autoindx,1);
  data.labelcmb = data.labelcmb(cmbindx, :);
  
  if isempty(cmbindx)
    data = rmfield(data, 'crsspctrm');
    data = rmfield(data, 'labelcmb');
  end
  
elseif strcmp(current, 'full') && strcmp(desired, 'sparse')
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpt',   dimtok)), nrpt=size(data.cumtapcnt,1); else nrpt = 1; end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=numel(data.freq);      else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=numel(data.time);      else ntim = 1; end
  nchan    = length(data.label);
  ncmb     = nchan*nchan;
  labelcmb = cell(ncmb, 2);
  cmbindx  = zeros(nchan, nchan);
  k = 1;
  for j=1:nchan
    for m=1:nchan
      labelcmb{k, 1} = data.label{m};
      labelcmb{k, 2} = data.label{j};
      cmbindx(m,j)   = k;
      k = k+1;
    end
  end
  
  % reshape all possible fields
  fn = fieldnames(data);
  for ii=1:numel(fn)
    if numel(data.(fn{ii})) == nrpt*ncmb*nfrq*ntim
      if nrpt>1
        data.(fn{ii}) = reshape(data.(fn{ii}), nrpt, ncmb, nfrq, ntim);
      else
        data.(fn{ii}) = reshape(data.(fn{ii}), ncmb, nfrq, ntim);
      end
    end
  end
  % remove obsolete fields
  data           = rmfield(data, 'label');
  try data      = rmfield(data, 'dof'); end
  % replace updated fields
  data.labelcmb  = labelcmb;
  if ntim>1
    data.dimord = 'chancmb_freq_time';
  else
    data.dimord = 'chancmb_freq';
  end
  
  if nrpt>1
    data.dimord = ['rpt_',data.dimord];
  end
  
elseif strcmp(current, 'sparsewithpow') && strcmp(desired, 'sparse')
  % this representation for sparse data contains autospectra as e.g. {'A' 'A'} in labelcmb
  if isfield(data, 'crsspctrm')
    dimtok         = tokenize(data.dimord, '_');
    catdim         = match_str(dimtok, {'chan' 'chancmb'});
    data.crsspctrm = cat(catdim, data.powspctrm, data.crsspctrm);
    data.labelcmb  = [data.label(:) data.label(:); data.labelcmb];
    data           = rmfield(data, 'powspctrm');
    data.dimord    = strrep(data.dimord, 'chan_', 'chancmb_');
  else
    data.crsspctrm = data.powspctrm;
    data.labelcmb  = [data.label(:) data.label(:)];
    data           = rmfield(data, 'powspctrm');
    data.dimord    = strrep(data.dimord, 'chan_', 'chancmb_');
  end
  data = rmfield(data, 'label');
  
elseif strcmp(current, 'sparse') && strcmp(desired, 'full')
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpt',   dimtok)), nrpt=size(data.cumtapcnt,1); else nrpt = 1; end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=numel(data.freq);      else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=numel(data.time);      else ntim = 1; end
  
  if ~isfield(data, 'label')
    % ensure that the bivariate spectral factorization results can be
    % processed. FIXME this is experimental and will not work if the user
    % did something weird before
    for k = 1:numel(data.labelcmb)
      tmp = tokenize(data.labelcmb{k}, '[');
      data.labelcmb{k} = tmp{1};
    end
    data.label = unique(data.labelcmb(:));
  end
  
  nchan     = length(data.label);
  ncmb      = size(data.labelcmb,1);
  cmbindx   = zeros(nchan,nchan);
  
  for k = 1:size(data.labelcmb,1)
    ch1 = find(strcmp(data.label, data.labelcmb(k,1)));
    ch2 = find(strcmp(data.label, data.labelcmb(k,2)));
    if ~isempty(ch1) && ~isempty(ch2)
      cmbindx(ch1,ch2) = k;
    end
  end
  
  complete = all(cmbindx(:)~=0);
  
  % remove obsolete fields
  try data      = rmfield(data, 'powspctrm');  end
  try data      = rmfield(data, 'labelcmb');   end
  try data      = rmfield(data, 'dof');        end
  
  fn = fieldnames(data);
  for ii=1:numel(fn)
    if numel(data.(fn{ii})) == nrpt*ncmb*nfrq*ntim
      if nrpt==1
        data.(fn{ii}) = reshape(data.(fn{ii}), [nrpt ncmb nfrq ntim]);
      end
      
      tmpall = nan(nrpt,nchan,nchan,nfrq,ntim);
      
      for j = 1:nrpt
        for k = 1:ntim
          for m = 1:nfrq
            tmpdat = nan(nchan,nchan);
            indx   = find(cmbindx);
            if ~complete
              % this realizes the missing combinations to be represented as the
              % conjugate of the corresponding combination across the diagonal
              tmpdat(indx) = reshape(data.(fn{ii})(j,cmbindx(indx),m,k),[numel(indx) 1]);
              tmpdat       = ctranspose(tmpdat);
            end
            tmpdat(indx)    = reshape(data.(fn{ii})(j,cmbindx(indx),m,k),[numel(indx) 1]);
            tmpall(j,:,:,m,k) = tmpdat;
          end % for m
        end % for k
      end % for j
      
      % replace the data in the old representation with the new representation
      if nrpt>1
        data.(fn{ii}) = tmpall;
      else
        data.(fn{ii}) = reshape(tmpall, [nchan nchan nfrq ntim]);
      end
    end % if numel
  end % for ii
  
  if ntim>1
    data.dimord = 'chan_chan_freq_time';
  else
    data.dimord = 'chan_chan_freq';
  end
  
  if nrpt>1
    data.dimord = ['rpt_',data.dimord];
  end
  
elseif strcmp(current, 'sparse') && strcmp(desired, 'fullfast')
  dimtok = tokenize(data.dimord, '_');
  if ~isempty(strmatch('rpt',   dimtok)), nrpt=size(data.cumtapcnt,1); else nrpt = 1; end
  if ~isempty(strmatch('freq',  dimtok)), nfrq=numel(data.freq);      else nfrq = 1; end
  if ~isempty(strmatch('time',  dimtok)), ntim=numel(data.time);      else ntim = 1; end
  
  if ~isfield(data, 'label')
    data.label = unique(data.labelcmb(:));
  end
  
  nchan     = length(data.label);
  ncmb      = size(data.labelcmb,1);
  cmbindx   = zeros(nchan,nchan);
  
  for k = 1:size(data.labelcmb,1)
    ch1 = find(strcmp(data.label, data.labelcmb(k,1)));
    ch2 = find(strcmp(data.label, data.labelcmb(k,2)));
    if ~isempty(ch1) && ~isempty(ch2)
      cmbindx(ch1,ch2) = k;
    end
  end
  
  complete = all(cmbindx(:)~=0);
  
  fn = fieldnames(data);
  for ii=1:numel(fn)
    if numel(data.(fn{ii})) == nrpt*ncmb*nfrq*ntim
      if nrpt==1
        data.(fn{ii}) = reshape(data.(fn{ii}), [nrpt ncmb nfrq ntim]);
      end
      
      tmpall = nan(nchan,nchan,nfrq,ntim);
      
      for k = 1:ntim
        for m = 1:nfrq
          tmpdat = nan(nchan,nchan);
          indx   = find(cmbindx);
          if ~complete
            % this realizes the missing combinations to be represented as the
            % conjugate of the corresponding combination across the diagonal
            tmpdat(indx) = reshape(nanmean(data.(fn{ii})(:,cmbindx(indx),m,k)),[numel(indx) 1]);
            tmpdat       = ctranspose(tmpdat);
          end
          tmpdat(indx)    = reshape(nanmean(data.(fn{ii})(:,cmbindx(indx),m,k)),[numel(indx) 1]);
          tmpall(:,:,m,k) = tmpdat;
        end % for m
      end % for k
      
      % replace the data in the old representation with the new representation
      if nrpt>1
        data.(fn{ii}) = tmpall;
      else
        data.(fn{ii}) = reshape(tmpall, [nchan nchan nfrq ntim]);
      end
    end % if numel
  end % for ii
  
  % remove obsolete fields
  try data      = rmfield(data, 'powspctrm');  end
  try data      = rmfield(data, 'labelcmb');   end
  try data      = rmfield(data, 'dof');        end
  
  if ntim>1
    data.dimord = 'chan_chan_freq_time';
  else
    data.dimord = 'chan_chan_freq';
  end
  
elseif strcmp(current, 'sparsewithpow') && any(strcmp(desired, {'full', 'fullfast'}))
  % recursively call ft_checkdata, but ensure channel order to be the same as the original input.
  origlabelorder = data.label; % keep track of the original order of the channels
  data       = ft_checkdata(data, 'cmbrepresentation', 'sparse');
  data.label = origlabelorder; % this avoids the labels to be alphabetized in the next call
  data       = ft_checkdata(data, 'cmbrepresentation', 'full');
  
end % convert from one to another bivariate representation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [source] = chan2source(data)
chanpos = zeros(0,3);
chanlab = cell(0,1);
posunit = [];
if isfield(data, 'elec')
  chanpos = cat(1, chanpos, data.elec.chanpos);
  chanlab = cat(1, chanlab, data.elec.label);
  if isfield(data.elec, 'unit')
    posunit = data.elec.unit;
  end
end
if isfield(data, 'grad')
  chanpos = cat(1, chanpos, data.grad.chanpos);
  chanlab = cat(1, chanlab, data.grad.label);
  if isfield(data.grad, 'unit')
    posunit = data.grad.unit;
  end
end
if isfield(data, 'opto')
  chanpos = cat(1, chanpos, data.opto.chanpos);
  chanlab = cat(1, chanlab, data.opto.label);
  if isfield(data.opto, 'unit')
    posunit = data.opto.unit;
  end
end

fn = fieldnames(data);
fn = setdiff(fn, {'label', 'time', 'freq', 'hdr', 'cfg', 'grad', 'elec', 'dimord', 'unit'}); % remove irrelevant fields
fn(~cellfun(@isempty, regexp(fn, 'dimord$'))) = []; % remove irrelevant (dimord) fields
sel = false(size(fn));
for i=1:numel(fn)
  try
    sel(i) = ismember(getdimord(data, fn{i}), {'chan', 'chan_time', 'chan_freq', 'chan_freq_time', 'chan_chan'});
  end
end
parameter = fn(sel);

% determine the channel indices for which the position is known
[datsel, possel] = match_str(data.label, chanlab);

source = [];
source.pos = chanpos(possel, :);
if ~isempty(posunit)
  source.unit = posunit;
end
for i=1:numel(parameter)
  dat = data.(parameter{i});
  dimord = getdimord(data, parameter{i});
  dimtok = tokenize(dimord, '_');
  for dim=1:numel(dimtok)
    if strcmp(dimtok{dim}, 'chan')
      dat = dimindex(dat, dim, {datsel});
      dimtok{dim} = 'pos';
    end
  end
  dimord = sprintf('%s_', dimtok{:});
  dimord = dimord(1:end-1); % remove the last '_'
  % copy the data to the source representation
  source.(parameter{i})            = dat;
  source.([parameter{i} 'dimord']) = dimord;
end
% copy the descriptive fields, these are necessary for visualising the data in ft_sourceplot
source = copyfields(data, source, {'time', 'freq'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [source] = parcellated2source(data)
if ~isfield(data, 'brainordinate')
  ft_error('projecting parcellated data onto the full brain model geometry requires the specification of brainordinates');
end
% the main structure contains the functional data on the parcels
% the brainordinate sub-structure contains the original geometrical model
source = ft_checkdata(data.brainordinate, 'datatype', 'source');
data   = rmfield(data, 'brainordinate');
if isfield(data, 'cfg')
  source.cfg = data.cfg;
end

fn = fieldnames(data);
fn = setdiff(fn, {'label', 'time', 'freq', 'hdr', 'cfg', 'grad', 'elec', 'dimord', 'unit'}); % remove irrelevant fields
fn(~cellfun(@isempty, regexp(fn, 'dimord$'))) = []; % remove irrelevant (dimord) fields
sel = false(size(fn));
for i=1:numel(fn)
  try
    sel(i) = ismember(getdimord(data, fn{i}), {'chan', 'chan_time', 'chan_freq', 'chan_freq_time', 'chan_chan'});
  end
end
parameter = fn(sel);

fn = fieldnames(source);
sel = false(size(fn));
for i=1:numel(fn)
  tmp = source.(fn{i});
  sel(i) = iscell(tmp) && isequal(tmp(:), data.label(:));
end
parcelparam = fn(sel);
if numel(parcelparam)~=1
  ft_error('cannot determine which parcellation to use');
else
  parcelparam = parcelparam{1}(1:(end-5)); % minus the 'label'
end

for i=1:numel(parameter)
  source.(parameter{i}) = unparcellate(data, source, parameter{i}, parcelparam);
end

% copy the descriptive fields, these are necessary for visualising the data in ft_sourceplot
source = copyfields(data, source, {'time', 'freq'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = volume2source(data)
if isfield(data, 'dimord')
  % it is a modern source description
else
  % it is an old-fashioned source description
  xgrid = 1:data.dim(1);
  ygrid = 1:data.dim(2);
  zgrid = 1:data.dim(3);
  [x y z] = ndgrid(xgrid, ygrid, zgrid);
  data.pos = ft_warp_apply(data.transform, [x(:) y(:) z(:)]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert between datatypes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = source2volume(data)

fn = fieldnames(data);
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
     