function data = read_asa_msr(fn)

% READ_ASA_MSR reads EEG or MEG data from an ASA data file
% converting the units to uV or fT

% Copyright (C) 2002, Robert Oostenveld
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

Npnt      = read_asa(fn, 'NumberPositions=', '%d');
Ntime     = read_asa(fn, 'NumberTimesteps=', '%d');
UnitT     = read_asa(fn, 'UnitTime', '%s');
UnitM     = read_asa(fn, 'UnitMeas', '%s');
Timesteps = read_asa(fn, 'Timesteps', '%s');
lab       = read_asa(fn, 'Labels', '%s', Npnt);

val = read_asa(fn, 'Values', '%f');
if any(size(val)~=[Npnt,Ntime])
  msm_file = read_asa(fn, 'Values', '%s');
  [path, name, ext] = fileparts(fn);
  fid = fopen_or_error(fullfile(path, msm_file), 'rb', 'ieee-le');
  val = fread(fid, [Ntime, Npnt], 'float32')';
  fclose(fid);
end

tmp = sscanf(Timesteps, '%f(%f)%f');
time = linspace(tmp(1), tmp(3), Ntime);

if strcmpi(UnitT,'ms')
  time = 1*time;
elseif strcmpi(UnitT,'s')
  time = 1000*time;
elseif ~isempty(UnitT)
  ft_error(sprintf('Unknown unit of time (%s)', UnitT));
end

if strcmpi(UnitM,'uv')
  val = 1*val;
elseif strcmpi(UnitM,'?v')
  val = 1*val;
elseif strcmpi(UnitM,'mv')
  val = 1000*val;
elseif strcmpi(UnitM,'v')
  val = 1000000*val;
elseif strcmpi(UnitM,'ft')
  val = 1*val;
elseif strcmpi(UnitM,'pt')
  val = 1000*val;
elseif ~isempty(UnitM)
  ft_error(sprintf('Unknown unit of measurement (%s)', UnitM));
end

if length(size(lab))==2
  lab = tokenize(lab{1});
end

data.time  = time;
data.data  = val;
data.label = lab;


                                                                                                                                                                                                                                                                                                                                               
end

% this temporary needs 8x as much storage!!!
if ~isempty(hdr.segfile)
  segfile = fullfile(path, hdr.segfile);
  seg = zeros(dim);
  fid = fopen_or_error(segfile, 'rb', 'ieee-le');
  seg(:) = fread(fid, prod(dim), 'uint8');
  seg = uint8(seg);
  fclose(fid);
end

% flip the orientation of the MRI data, the result should be
% 'coronal(occipital-frontal)'
% 'horizontal(inferior-superior)'
% 'sagittal(right-left)'

if strcmp(hdr.columns, 'coronal(frontal-occipital)')
  hdr.columns = 'coronal(occipital-frontal)';
  mri = flipdim(mri, 1);
  seg = flipdim(seg, 1);
elseif strcmp(hdr.columns, 'horizontal(superior-inferior)')
  hdr.columns = 'horizontal(inferior-superior)';
  mri = flipdim(mri, 1);
  seg = flipdim(seg, 1);
elseif strcmp(hdr.columns, 'sagittal(left-right)')
  hdr.columns = 'sagittal(right-left)';
  mri = flipdim(mri, 1);
  seg = flipdim(seg, 1);
end

if strcmp(hdr.rows, 'coronal(frontal-occipital)')
  hdr.rows = 'coronal(occipital-frontal)';
  mri = flipdim(mri, 2);
  seg = flipdim(seg, 2);
elseif strcmp(hdr.rows, 'horizontal(superior-inferior)')
  hdr.rows = 'horizontal(inferior-superior)';
  mri = flipdim(mri, 2);
  seg = flipdim(seg, 2);
elseif strcmp(hdr.rows, 'sagittal(left-right)')
  hdr.rows = 'sagittal(right-left)';
  mri = flipdim(mri, 2);
  seg = flipdim(seg, 2);
end

if strcmp(hdr.slices, 'coronal(frontal-occipital)')
  hdr.slices = 'coronal(occipital-frontal)';
  mri = flipdim(mri, 3);
  seg = flipdim(seg, 3);
elseif strcmp(hdr.slices, 'horizontal(superior-inferior)')
  hdr.slices = 'horizontal(inferior-superior)';
  mri = flipdim(mri, 3);
  seg = flipdim(seg, 3);
elseif strcmp(hdr.slices, 'sagittal(left-right)')
  hdr.slices = 'sagittal(right-left)';
  mri = flipdim(mri, 3);
  seg = flipdim(seg, 3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% swap the orientations of the MRI data, the result should be fixed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1st dimension corresponds to columns, which should be 'coronal(occipital-frontal)'
% 2st dimension corresponds to rows,    which should be 'sagittal(right-left)'
% 3rd dimension corresponds to slices,  which should be 'horizontal(inferior-superior)'

if     strcmp(hdr.columns, 'coronal(occipital-frontal)')
  orientation(1) = 1;
elseif strcmp(hdr.columns, 'sagittal(right-left)')
  orientation(1) = 2;
elseif strcmp(hdr.columns, 'horizontal(inferior-superior)')
  orientation(1) = 3;
end

if     strcmp(hdr.rows, 'coronal(occipital-frontal)')
  orientation(2) = 1;
elseif strcmp(hdr.rows, 'sagittal(right-left)')
  orientation(2) = 2;
elseif strcmp(hdr.rows, 'horizontal(inferior-superior)')
  orientation(2) = 3;
end

if     strcmp(hdr.slices, 'coronal(occipital-frontal)')
  orientation(3) = 1;
elseif strcmp(hdr.slices, 'sagittal(right-left)')
  orientation(3) = 2;
elseif strcmp(hdr.slices, 'horizontal(inferior-superior)')
  orientation(3) = 3;
end

mri = ipermute(mri, orientation);
seg = ipermute(seg, orientation);
hdr.rows    = 'sagittal(right-left)';
hdr.columns = 'coronal(occipital-frontal)';
hdr.slices  = 'horizontal(inferior-superior)';

% recompute the dimensions after all the swapping
hdr.Nrows    = size(mri, 1);
hdr.Ncolumns = size(mri, 2);
hdr.Nslices  = size(mri, 3);
dim = size(mri);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if possible, create the accompanying homogenous coordinate transformation matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In case of PointOn..., ASA counts voxels from the center of the MRI
% and in case of VoxelOn..., ASA counts voxels from the corner of the MRI
% In both cases, ASA starts counting at [0 0 0], which is C convention
% whereas I want to count from the 1st voxel and number that with [1 1 1]
if ~isempty(hdr.posx) && ~isempty(hdr.negy) && ~isempty(hdr.posy)
  offset = (dim + [1 1 1])/2;
  hdr.fiducial.mri.nas = hdr.posx + offset;
  hdr.fiducial.mri.lpa = hdr.posy + offset;
  hdr.fiducial.mri.rpa = hdr.negy + offset;
else
  offset = [1 1 1];
  hdr.fiducial.mri.nas = hdr.voxposx + offset;
  hdr.fiducial.mri.lpa = hdr.voxposy + offset;
  hdr.fiducial.mri.rpa = hdr.voxnegy + offset;
end

% use the headcoordinates function (roboos/misc) to compute the transformaton matrix
hdr.transformMRI2Head = ft_headcoordinates(hdr.fiducial.mri.nas, hdr.fiducial.mri.lpa, hdr.fiducial.mri.rpa, 'asa');
hdr.transformHead2MRI = inv(hdr.transformMRI2Head);

% compute the fiducials in head coordinates
hdr.fiducial.head.nas = ft_warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.nas, 'homogenous');
hdr.fiducial.head.lpa = ft_warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.lpa, 'homogenous');
hdr.fiducial.head.rpa = ft_warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.rpa, 'homogenous');


                                                                                                                                                                                                                                                                                                               = ftell(fid);
    header.process(np).hdr.nbytes   = nbytes;
    type                            = char(fread(fid, 20, 'uchar'))';
    header.process(np).hdr.type     = type(type>0);
    header.process(np).hdr.checksum = fread(fid, 1,  'int32=>int32'); 
    user                            = char(fread(fid, 32, 'uchar'))';
    header.process(np).user         = user(user>0);
    header.process(np).timestamp    = fread(fid, 1,  'uint32=>uint32');
    fname                           = char(fread(fid, 32, 'uchar'))';
    header.process(np).filename     = fname(fname>0);
    fseek(fid, 28*8, 'cof'); %dont know
    header.process(np).totalsteps   = fread(fid, 1,  'uint32=>uint32');
    header.process(np).checksum     = fread(fid, 1,  'int32=>int32');
    header.process(np).reserved     = fread(fid, 32, 'uchar')'; 
    for ns = 1:header.process(np).totalsteps
      align_file_pointer(fid)
      nbytes2                                   = fread(fid, 1, 'uint32=>uint32');
      header.process(np).step(ns).hdr.nbytes    = nbytes2;
      type                                      = char(fread(fid, 20, 'uchar'))';
      header.process(np).step(ns).hdr.type      = type(type>0); %dont know how to interpret the first two
      header.process(np).step(ns).hdr.checksum  = fread(fid, 1, 'int32=>int32');
      userblocksize                             = fread(fid, 1, 'int32=>int32'); %we are at 32 bytes here
      header.process(np).step(ns).userblocksize = userblocksize;
      fseek(fid, nbytes2 - 32, 'cof');
      
      if strcmp(header.process(np).step(ns).hdr.type, 'PDF_Weight_Table'),
        ft_warning('reading in weight table: no warranty that this is correct. it seems to work for the Glasgow 248-magnetometer system. if you have some code yourself, and/or would like to test it on your own data, please contact Jan-Mathijs');
        tmpfp = ftell(fid);
        tmp   = fread(fid, 1, 'uint8');
        Nchan = fread(fid, 1, 'uint32');
        Nref  = fread(fid, 1, 'uint32');
        for k = 1:Nref
          name = fread(fid, 17, 'uchar'); %strange number, but seems to be true
          header.process(np).step(ns).RefChan{k,1} = char(name(name>0))';
        end
        fseek(fid, 152, 'cof');
        for k = 1:Nchan
          name = fread(fid, 17, 'uchar');
          header.process(np).step(ns).Chan{k,1}   = char(name(name>0))';
        end
        %fseek(fid, 20, 'cof');
        %fseek(fid, 4216, 'cof');
        header.process(np).step(ns).stuff1  = fread(fid, 4236, 'uint8');
        name                                = fread(fid, 16, 'uchar');
        header.process(np).step(ns).Creator = char(name(name>0))';
        %some stuff I don't understand yet
        %fseek(fid, 136, 'cof');
        header.process(np).step(ns).stuff2  = fread(fid, 136, 'uint8');
        %now something strange is going to happen: the weights are probably little-endian encoded.
        %here we go: check whether this applies to the whole PDF weight table
        fp = ftell(fid);
        fclose(fid);
        fid = fopen_or_error(datafile, 'r', 'l');
        fseek(fid, fp, 'bof');
        for k = 1:Nchan
          header.process(np).step(ns).Weights(k,:) = fread(fid, 23, 'float32=>float32')';
          fseek(fid, 36, 'cof');
        end
      else
        if userblocksize < 1e6,
          %for one reason or another userblocksize can assume strangely high values
          fseek(fid, userblocksize, 'cof');
        end
      end    
    end
  end
  fclose(fid);
end 
%end read header

%read config file
fid = fopen_or_error(configfile, 'r', 'b');

header.config_data.version           = fread(fid, 1, 'uint16=>uint16');
site_name                            = char(fread(fid, 32, 'uchar'))';
header.config_data.site_name         = site_name(site_name>0);
dap_hostname                         = char(fread(fid, 16, 'uchar'))';
header.config_data.dap_hostname      = dap_hostname(dap_hostname>0);
header.config_data.sys_type          = fread(fid, 1, 'uint16=>uint16');
header.config_data.sys_options       = fread(fid, 1, 'uint32=>uint32');
header.config_data.supply_freq       = fread(fid, 1, 'uint16=>uint16');
header.config_data.total_chans       = fread(fid, 1, 'uint16=>uint16');
header.config_data.system_fixed_gain = fread(fid, 1, 'float32=>float32');
header.config_data.volts_per_bit     = fread(fid, 1, 'float32=>float32');
header.config_data.total_sensors     = fread(fid, 1, 'uint16=>uint16');
header.config_data.total_user_blocks = fread(fid, 1, 'uint16=>uint16');
header.config_data.next_derived_channel_number = fread(fid, 1, 'uint16=>uint16');
fseek(fid, 2, 'cof');
header.config_data.checksum          = fread(fid, 1, 'int32=>int32');
header.config_data.reserved          = fread(fid, 32, 'uchar=>uchar')';

header.config.Xfm = fread(fid, [4 4], 'double');

%user blocks
for ub = 1:header.config_data.total_user_blocks
  align_file_pointer(fid)
  header.user_block_data{ub}.hdr.nbytes   = fread(fid, 1, 'uint32=>uint32');
  type                                    = char(fread(fid, 20, 'uchar'))';
  header.user_block_data{ub}.hdr.type     = type(type>0);
  header.user_block_data{ub}.hdr.checksum = fread(fid, 1, 'int32=>int32');
  user                                    = char(fread(fid, 32, 'uchar'))';
  header.user_block_data{ub}.user         = user(user>0);
  header.user_block_data{ub}.timestamp    = fread(fid, 1, 'uint32=>uint32');
  header.user_block_data{ub}.user_space_size = fread(fid, 1, 'uint32=>uint32');
  header.user_block_data{ub}.reserved     = fread(fid, 32, 'uchar=>uchar')';
  fseek(fid, 4, 'cof');
  user_space_size                         = double(header.user_block_data{ub}.user_space_size);
  if strcmp(type(type>0), 'B_weights_used'), 
    %warning('reading in weight table: no warranty that this is correct. it seems to work for the Glasgow 248-magnetometer system. if you have some code yourself, and/or would like to test it on your own data, please contact Jan-Mathijs');
    tmpfp = ftell(fid);
    %read user_block_data weights
    %there is information in the 4th and 8th byte, these might be related to the settings?
    version  = fread(fid, 1, 'uint32');
    header.user_block_data{ub}.version = version;
    if version==1,
      Nbytes   = fread(fid,1,'uint32');
      Nchan    = fread(fid,1,'uint32');
      Position = fread(fid, 32, 'uchar');
      header.user_block_data{ub}.position = char(Position(Position>0))';
      fseek(fid,tmpfp+user_space_size - Nbytes*Nchan, 'bof');
      Ndigital = floor((Nbytes - 4*2) / 4);
      Nanalog  = 3; %lucky guess?
      % how to know number of analog weights vs digital weights???
      for ch = 1:Nchan
        % for Konstanz -- comment for others?
        header.user_block_data{ub}.aweights(ch,:) = fread(fid, [1 Nanalog],  'int16')'; 
        fseek(fid,2,'cof'); % alignment
        header.user_block_data{ub}.dweights(ch,:) = fread(fid, [1 Ndigital], 'single=>double')';
      end
      fseek(fid, tmpfp, 'bof');
      %there is no information with respect to the channels here.
      %the best guess would be to assume the order identical to the order in header.config.channel_data
      %for the digital weights it would be the order of the references in that list
      %for the analog weights I would not know
    elseif version==2,
      unknown2 = fread(fid, 1, 'uint32');
      Nchan    = fread(fid, 1, 'uint32');
      Position = fread(fid, 32, 'uchar');
      header.user_block_data{ub}.position = char(Position(Position>0))';
      fseek(fid, tmpfp+124, 'bof');
      Nanalog  = fread(fid, 1, 'uint32');
      Ndigital = fread(fid, 1, 'uint32');
      fseek(fid, tmpfp+204, 'bof');
      for k = 1:Nchan
        Name     = fread(fid, 16, 'uchar');
        header.user_block_data{ub}.channames{k,1} = char(Name(Name>0))';
      end
      for k = 1:Nanalog
        Name     = fread(fid, 16, 'uchar');
        header.user_block_data{ub}.arefnames{k,1} = char(Name(Name>0))';
      end
      for k = 1:Ndigital
        Name     = fread(fid, 16, 'uchar');
        header.user_block_data{ub}.drefnames{k,1} = char(Name(Name>0))';
      end

      header.user_block_data{ub}.dweights = fread(fid, [Ndigital Nchan], 'single=>double')';
      header.user_block_data{ub}.aweights = fread(fid, [Nanalog  Nchan],  'int16')'; 
      fseek(fid, tmpfp, 'bof');
    end
  elseif strcmp(type(type>0), 'B_E_table_used'),
    %warning('reading in weight table: no warranty that this is correct');
    %tmpfp = ftell(fid);
    %fseek(fid, 4, 'cof'); %there's info here dont know how to interpret
    %Nx    = fread(fid, 1, 'uint32');
    %Nchan = fread(fid, 1, 'uint32');
    %type  = fread(fid, 32, 'uchar'); %don't know whether correct
    %header.user_block_data{ub}.type = char(type(type>0))';
    %fseek(fid, 16, 'cof');
    %for k = 1:Nchan
    %  name                                 = fread(fid, 16, 'uchar');
    %  header.user_block_data{ub}.name{k,1} = char(name(name>0))';
    %end
  elseif strcmp(type(type>0), 'B_COH_Points'),
    tmpfp = ftell(fid);
    Ncoil = fread(fid, 1,         'uint32');
    N     = fread(fid, 1,         'uint32');
    coils = fread(fid, [7 Ncoil], 'double');

    header.user_block_data{ub}.pnt   = coils(1:3,:)';
    header.user_block_data{ub}.ori   = coils(4:6,:)';
    header.user_block_data{ub}.Ncoil = Ncoil;
    header.user_block_data{ub}.N     = N;
    tmp = fread(fid, (904-288)/8, 'double');
    header.user_block_data{ub}.tmp   = tmp; %FIXME try to find out what these bytes mean
    fseek(fid, tmpfp, 'bof');
  elseif strcmp(type(type>0), 'b_ccp_xfm_block'),
    tmpfp = ftell(fid);
    tmp1 = fread(fid, 1, 'uint32');
    %tmp = fread(fid, [4 4], 'double');
    %tmp = fread(fid, [4 4], 'double');
    %the next part seems to be in little endian format (at least when I tried) 
    tmp = fread(fid, 128, 'uint8');
    tmp = uint8(reshape(tmp, [8 16])');
    xfm = zeros(4,4);
    for k = 1:size(tmp,1)
      xfm(k) = typecast(tmp(k,:), 'double');
      if abs(xfm(k))<1e-10 || abs(xfm(k))>1e10, xfm(k) = typecast(fliplr(tmp(k,:)), 'double');end
    end
    fseek(fid, tmpfp, 'bof'); %FIXME try to find out why this looks so strange
  elseif strcmp(type(type>0), 'b_eeg_elec_locs'),
    %this block contains the digitized coil and electrode positions
    tmpfp   = ftell(fid);
    Npoints = user_space_size./40;
    for k = 1:Npoints
      tmp      = fread(fid, 16, 'uchar');
      %tmplabel = char(tmp(tmp>47 & tmp<128)'); %stick to plain ASCII
      
      % store up until the first space
      tmplabel = char(tmp(1:max(1,(find(tmp==0,1,'first')-1)))'); %stick to plain ASCII
      
      %if strmatch('Coil', tmplabel), 
      %  label{k} = tmplabel(1:5);
      %elseif ismember(tmplabel(1), {'L' 'R' 'C' 'N' 'I'}),
      %  label{k} = tmplabel(1);
      %else
      %  label{k} = '';
      %end
      label{k} = tmplabel;
      tmp      = fread(fid, 3, 'double');
      pnt(k,:) = tmp(:)';
    end

    % post-processing of the labels
    % it seems the following can happen
    %  - a sequence of L R N C I, i.e. the coordinate system defining landmarks
    for k = 1:numel(label)
      firstletter(k) = label{k}(1);
    end
    sel = strfind(firstletter, 'LRNCI');
    if ~isempty(sel)
      label{sel}   = label{sel}(1);
      label{sel+1} = label{sel+1}(1);
      label{sel+2} = label{sel+2}(1);
      label{sel+3} = label{sel+3}(1);
      label{sel+4} = label{sel+4}(1);
    end
    %  - a sequence of coil1...coil5 i.e. the localization coils
    for k = 1:numel(label)
       if strncmpi(label{k},'coil',4)
         label{k} = label{k}(1:5);
       end
    end
    %  - something else: EEG electrodes?
    header.user_block_data{ub}.label = label(:);
    header.user_block_data{ub}.pnt   = pnt;
    fseek(fid, tmpfp, 'bof');
  end
  fseek(fid, user_space_size, 'cof');
end

%channels
for ch = 1:header.config_data.total_chans
  align_file_pointer(fid)
  name                                       = char(fread(fid, 16, 'uchar'))';
  header.config.channel_data(ch).name        = name(name>0);
  %FIXME this is a very dirty fix to get the reading in of continuous headlocalization
  %correct. At the moment, the numbering of the hmt related channels seems to start with 1000
  %which I don't understand, but seems rather nonsensical.
  chan_no                                    = fread(fid, 1, 'uint16=>uint16');
  if chan_no > header.config_data.total_chans,
    
    %FIXME fix the number in header.channel_data as well
    sel     = find([header.channel_data.chan_no]== chan_no);
    if ~isempty(sel),
      chan_no = ch;
      header.channel_data(sel).chan_no    = chan_no;
      header.channel_data(sel).chan_label = header.config.channel_data(ch).name;
    else
      %does not matter
    end
  end
  header.config.channel_data(ch).chan_no     = chan_no;
  header.config.channel_data(ch).type        = fread(fid, 1, 'uint16=>uint16');
  header.config.channel_data(ch).sensor_no   = fread(fid, 1, 'int16=>int16');
  fseek(fid, 2, 'cof');
  header.config.channel_data(ch).gain        = fread(fid, 1, 'float32=>float32');
  header.config.channel_data(ch).units_per_bit = fread(fid, 1, 'float32=>float32');
  yaxis_label                                = char(fread(fid, 16, 'uchar'))';
  header.config.channel_data(ch).yaxis_label = yaxis_label(yaxis_label>0);
  header.config.channel_data(ch).aar_val     = fread(fid, 1, 'double');
  header.config.channel_data(ch).checksum    = fread(fid, 1, 'int32=>int32');
  header.config.channel_data(ch).reserved    = fread(fid, 32, 'uchar=>uchar')';
  fseek(fid, 4, 'cof');

  align_file_pointer(fid)
  header.config.channel_data(ch).device_data.hdr.size     = fread(fid, 1, 'uint32=>uint32');
  header.config.channel_data(ch).device_data.hdr.checksum = fread(fid, 1, 'int32=>int32');
  header.config.channel_data(ch).device_data.hdr.reserved = fread(fid, 32, 'uchar=>uchar')';

  switch header.config.channel_data(ch).type
    case {1, 3}%meg/ref

      header.config.channel_data(ch).device_data.inductance  = fread(fid, 1, 'float32=>float32');
      fseek(fid, 4, 'cof');
      header.config.channel_data(ch).device_data.Xfm         = fread(fid, [4 4], 'double');
      header.config.channel_data(ch).device_data.xform_flag  = fread(fid, 1, 'uint16=>uint16');
      header.config.channel_data(ch).device_data.total_loops = fread(fid, 1, 'uint16=>uint16');
      header.config.channel_data(ch).device_data.reserved    = fread(fid, 32, 'uchar=>uchar')';
      fseek(fid, 4, 'cof');

      for loop = 1:header.config.channel_data(ch).device_data.total_loops
        align_file_pointer(fid)
        header.config.channel_data(ch).device_data.loop_data(loop).position    = fread(fid, 3, 'double');
        header.config.channel_data(ch).device_data.loop_data(loop).direction   = fread(fid, 3, 'double');
        header.config.channel_data(ch).device_data.loop_data(loop).radius      = fread(fid, 1, 'double');
        header.config.channel_data(ch).device_data.loop_data(loop).wire_radius = fread(fid, 1, 'double');
        header.config.channel_data(ch).device_data.loop_data(loop).turns       = fread(fid, 1, 'uint16=>uint16');
        fseek(fid, 2, 'cof');
        header.config.channel_data(ch).device_data.loop_data(loop).checksum    = fread(fid, 1, 'int32=>int32');
        header.config.channel_data(ch).device_data.loop_data(loop).reserved    = fread(fid, 32, 'uchar=>uchar')';
      end
    case 2%eeg
      header.config.channel_data(ch).device_data.impedance       = fread(fid, 1, 'float32=>float32');
      fseek(fid, 4, 'cof');
      header.config.channel_data(ch).device_data.Xfm             = fread(fid, [4 4], 'double');
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
    case 4%external
      header.config.channel_data(ch).device_data.user_space_size = fread(fid, 1, 'uint32=>uint32');
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
      fseek(fid, 4, 'cof');
    case 5%TRIGGER
      header.config.channel_data(ch).device_data.user_space_size = fread(fid, 1, 'uint32=>uint32');
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
      fseek(fid, 4, 'cof');
    case 6%utility
      header.config.channel_data(ch).device_data.user_space_size = fread(fid, 1, 'uint32=>uint32');
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
      fseek(fid, 4, 'cof');
    case 7%derived
      header.config.channel_data(ch).device_data.user_space_size = fread(fid, 1, 'uint32=>uint32');
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
      fseek(fid, 4, 'cof');
    case 8%shorted
      header.config.channel_data(ch).device_data.reserved        = fread(fid, 32, 'uchar=>uchar')';
    otherwise
      ft_error('Unknown device type: %d\n', header.config.channel_data(ch).type);
  end
end

fclose(fid);
%end read config file

header.header_data.FileDescriptor = 0; %no obvious field to take this from
header.header_data.Events         = 1; %no obvious field to take this from
header.header_data.EventCodes     = 0; %no obvious field to take this from

if isfield(header, 'channel_data'),
  header.ChannelGain        = double([header.config.channel_data([header.channel_data.chan_no]).gain]');
  header.ChannelUnitsPerBit = double([header.config.channel_data([header.channel_data.chan_no]).units_per_bit]');
  header.Channel            = {header.config.channel_data([header.channel_data.chan_no]).name}';
  header.ChannelType        = double([header.config.channel_data([header.channel_data.chan_no]).type]');
  %header.Channel            = {header.channel_data.chan_label}';
  %header.Channel            = {header.channel_data([header.channel_data.index]+1).chan_label}';
  header.Format             = header.header_data.Format;
  
  % take the EEG labels from the channel_data, and the rest of the labels
  % from the config.channel_data. Some systems have overloaded MEG channel
  % labels, which clash with the labels in the grad-structure. This will
  % lead to problems in forward/inverse modelling. Use the following
  % convention: keep the ones from the config.
  % Some systems have overloaded EEG channel
  % labels, rather than Exxx have a human interpretable form. Use these,
  % to prevent a clash with the elec-structure, if present. This is a
  % bit clunky (because EEG is treated different from MEG), but inherent is
  % inherent in how the header information is organised.
  header.Channel(header.ChannelType==2) = {header.channel_data(header.ChannelType==2).chan_label}';
  
end

function align_file_pointer(fid)
current_position = ftell(fid);
if mod(current_position, 8) ~= 0
    offset = 8 - mod(current_position,8);
    fseek(fid, offset, 'cof');
end
                                                                                                                                                                                              �o��   �ҩ���������   ���   �   ��F$���   �8"�=4"j�^j j S���P�H"P��P�D"��u_h ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"3�3��D$ ��R�@"�F,��VP贩�����l$ ��t�F4��u�F<���D$t�D$   ��D$    �L$,�D$Q�T$j RP��!�ȃ� �<  It-  _���^%����]L'  [��ËL$Q�0"����   �~0W�e������   �N;���   �FW�F4   試���5�����u�-X"�t$(�>�-X"�Ջ��#���R�T"��W�t$,�P"S�#��t�����   tj���"���5���tM�Ջ��#���Q�T"W���P"S�#��t$���t	�VR�Ѓ��F��PQ�R�����멋T$(j��@R��"W�ڥ����_^]�   [���_^]3�[��Ð���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������̋D$�L$PQ������Ð����������������������������Vh�3���!�L$����uVQ�.�������h��,"��^Ã��uh0Q�
�������h��,"��^Ã��uh4Q��������h��,"��^Å�u�   h��,"��^Ð����������������������������������������������������������̋D$U3�W��u_�   ]Ë|$��t���t�8u_�(   ]�Vjj��"������u�D$�   �0^��_]Å��    �F    t�?��t�G�3�j j j j �F�F    �"���FuV�   ��"��3��D$�0^��_]Ð�������������������������������������������������U���SVW�}3�������  �E��u�rzh���!�E����u�E�VP�`��������=���u�M�h0Q�F��������#���u�U�h4R�,��������	��u�   h��,"���u��V  �E��ء���]�tQR�M��   �    ���E�ZY�QR�M��   �    ��E�ZY�E����C�M  ���7  �   �{�5���tN�X"�E��#�E�P�T"�M���Q�P"�U�R�#��t�w�G�s�E�C��  �   苣�����U����   ���   �~$ω��   �8"j�~j j W��4"P�H"P�4"P�D"��ugh ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"�]�3�3��s�C�  �Q�@"�F,��VR�f������E�s�C��   ����   �5���t@�X"�E��#�E��P�T"�M��Q�P"�U�R�#��t�w��   �S���������tx���   �   ȉF$���   �8"j�^j j S��4"P�H"P�4"P�D"��uWV������3�3�����P�@"�F,��VQ胢�����]��C�K;�u	;�u�C��E�   �u�}����   �M��yu�A��tH�A�   _^[��]ÍU��    R�ȟ��������u8�E��HQ�"��u�U��   �_^[��]ËE�P��"����_^[��]ËM��Ɖ_^[��]�h���!�?�rh��    �,"��_^[��]�h��   �,"��_^[��]Ð������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Vjj3���"��;�u�T$�   ^���ËL$�0�p���^Ð����������������������������̋L$V3���t���tP�1��"����^ø   ^Ð����������������������̋D$��t� ��t�L$��t� �3�ø   Ð���������������������������̋D$��t���t�T$��t��u3��ø   Ð������������������������̋L$3���t�	��t�T$��|	���Qø   Ð�����������������������̋L$3���t�	��t�T$��t�I�
ø   Ð���������������������������U���SVW�}�E�    ���u�   _^[��]Ã��rth�3���!����uVW�ɞ�������7���uh0W貞������� ���uh4W蛞�������	��u�   h��,"���u�t	��_^[��]Ë�]�C����   ���tQ�M�   ��E�Y�QR�M�   ��u��E�ZY�E����g  �5"���tQ�M�������E�Y�QR�M�������u��E�ZY�E����&  �Cj�P�օ�t��E�   �E�_^[��]Ë=���t?�X"���#��E�Q�T"V���P"�U�R�#��t�G�w�E���   軜�����U�����   ���   �   ȉF$���   �8"j�~j j W��4"P�H"P�4"P�D"��uah ��!�N�V�M��#   3����V�U��VB�V�F   ���t�p��5h �5�,"3�������P�@"�F,��VQ藜�����}����tQR�M�   �    ���E�ZY�QR�M�   �    ��E�ZY�E�����   �C�K;�u,;�u(�{u�C@�C�E�_^[��]��E�$   �E�_^[��]á��tQ�M�������E�Y�QR�M�������u��E�ZY�E���t!�Sj�R�"��t��E�   �E�_^[��]ËE���u�s�C   �{�E�_^[��]Ð�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������U��� SV�uW�>�rqh�3���!����uWV袚�������7���uh0V苚������� ���uh4V�t��������	��u�   h��,"��t	��_^[��]Ë>�}�G���.  ���tQ�M�   ��E�Y�QR�M�   ��u��E�ZY�E�����  �]���tQ�M�������E�Y�QR�M�������u��E�ZY�E����H  �G���E��  ��u����   �Cj � � h@B �� RP�V  �����j �h�  RP�,V  ��E�P���"�E���j h�  RP�	V  �؋E�%��  �ʙ��;�|;�v+���u	������3��E��]�}VP�"���n  �����5���t@�X"�E��#��E�Q�T"�U���R�P"�E�P�#��t�s�[�   �������څ���   ���   �   ȉF$���   �8"j�~j j W��4"P�H"P�4"P�D"��uSV�ŗ���}��3����؉u��]��%�Q�@"�F,��VR�$����}���u��]����tQR�M�   �    ���E�ZY�QR�M�   �    ��E�ZY�E���u�w�G   �_3�_^[��]ËG�O;�u&;�u"�u�G@�G3�_^[��]ø$   _^[��]Ë]���tQ�M�������E�Y�QR�M�������u��E�ZY�E�����   �O�ɉM���   ��u����   �Cj � � h@B �� RP�%T  �����j �h�  RP��S  ��E�P���"�E����j h�  RP�S  �؋E�%��  �ʙ��;�|;�v+���u	������3��]�M��}�Ƌu�PQ�"��u�����   _^[��]�-  ���%����L'  _^[��]ËM�w�G   �O_^3�[��]Ð���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������U����ESVW��E�    ����]��  �C��uW���tQ�M�    ��E�Y�QR�M�    ��u��E�ZY�E���t��  �KQ�  �E�   �E�_^[��]Ë5���tC�X"�E��#��E�R�T"���E�P�P"�M�Q�#��t�W�w�U���   迓�����U����   ���   �   ��F$���   �8"�4"j�~j j W���P�H"P��P�D"��u^h ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"�]3�3��"�P�@"�F,��VQ蠓���]���E�K�S;������;�������{u	�CH�CuS�C    ���tQ�M�    ��E�Y�QR�M�    ��u��E�ZY�E���}�SR�"��u�E�   �E�_^[��]Ð����������������������������������������������������������������������������������������������������������������������������������������������������������U���SVW�}�E�    �?�rth�3���!����uVW�[��������7���uh0W�D�������� ���uh4W�-��������	��u�   h��,"���u�t	��_^[��]á����]tQR�M�   �    ���E�ZY�QR�M�   �    ��E�ZY�E����`  �C����  �   �{�5���tS�X"�E��#�E�P�T"�M���Q�P"�U�R�#��t�w�G�s�E�C�E�_^[��]ÿ   腐�����U����   ���   �~$߉��   �8"�4"j�~j j W���P�H"P��P�D"��ulh ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"�]3�3��s�C�E�_^[��]ËQ�@"�F,��VR�]����]���E�s�C�E�_^[��]ËC�   ;��B  �5���tG�X"���#�E�P�T"S���P"�M�Q�#��t�W�w�U���   �]�   �4������U����   ���   �~$߉��   �8"�4"j�~j j W���P�H"P��P�D"��u^h ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"�]3�3��"�P�@"�F,��VQ�������]�E�K�S;�u;�u�C@�C�E�_^[��]��E�   �E�_^[��]Ð�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������̋L$3���t�	��t�T$��|	���Qø   Ð�����������������������̋L$3���t�	��t�T$��t�I�
ø   Ð��������������������������̋D$�@Ð����������������������̋D$����SUVWu_^]�   [��Ë0���   �H���  ��3�P�͊���-4"����t�H�p�L$�   �A������T$��ts���   �   ȉF$���   �8"j�~j j W���P�H"P��P�D"��u�T$RV������3���D$�$�P�@"�F,��VQ�q������T$�T$��tS�F��uK�~0W荌���F4�   ��;�t*�F<P�0"�F   W�Ή��W�^4�ŉ��j�Ћ����W赉����j �<"��Q載������t�p�X�{�=������څ�tn���   �   ȉF$���   �8"j�~j j W���P�H"P��P�D"��uSV������3�3��D$��R�@"�F,��VP�t������\$���A  �F���5  �~0W茋���F4�   ��;�t*�N<Q�0"�F   W�͈��W�^4�Ĉ��j�ϊ����W贈����3�_^][��ËH���C��?B 3���������Ѝ��5��������ʉT$tB�X"���#�D$�P�T"U���P"�L$Q�#��t�W�w�T$�   �݉�����T$��tv���   �   ��F$���   �8"�=4"j�nj j U���P�H"P��P�D"��u�D$PV衉������3��!�M Q�@"�F,��VR�
������D$���D$u_^]�   [��ËF4�L$��Q��   �V<R�"����   �~0W��������   �N;�}`�FW�F4   �G�����P�Z���������t	���   tj���"��j�"�������tj��������u��@jV��"W�������   _^][���=  t_^]�   [����<"_^]3�[����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������̃��D$�L$ PQ�4"P�L"��t�T$ 3��   ��t@��u���ø   ��Ð���������������̡�����SUVWt
�   �|  ��"jj��   3��Ӌ-�!������u�   ��Ճ���uV�   ��"��3����5�uDjj�Ӌ�����u�   ��Ճ���uV�   ��"��3����5���   �5�������   ��tV�:�������    ����tP��������    h ��!���t�=�"�pP�׃�����u�h �,"�5("h���h���h`��h���h���h ����    �5$"h ��h���h���h`��h���h��֋-��D$�L$3�PQ���4"P�L"��t$�T$3ɸ   ��tA��u�3҃�����=�!h��׋5�!h�P����;Ë�!��u����x P����    �����h���3���;�thpP�֣���9=�u!;���� tP�Ӊ=�_��^][���hXP��;�t�Ѕ�u#����� Q�Ӊ=�_��^][���9=�t����_��^][��Ð��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������̡���   ��V��  �5�SU�-�!��W��   �X"���#�؋P�T"W���P"S�#����   �~$��   �^�N�ۉL$��   �#   ��|$h ��ՋS�s�#   3����S��B�s�S�C   ���t�X��h ��,"�D$T�5"��tP�֍T$HR�j����D$DP�`����D$$����tP�֋�j �R��!��3�;���   ��;�tP�)���������;�tP��������h �ա��t�=�"�pP�׃�����u�h �,"�5("h���h���h`��h���h���h �։����5�!;�th@P��!;�t�С�P�֡�_];�[tP�ָ   ^�Ĕ   Ð��������������������������������������������������������������������������������������������������������������������������������������������������������̸   Ð������������������������̡���   ��SVW�(  �5����  �X"���#�؋P�T"W���P"S�#����   �N�VQR��~���~0W�+����F   W�~���F$������   �^�F�ۉD$��   �#   ��|$h ���!�S�s�#   3����S��B�s�S�C   ���t�X��h ��,"�D$P�5"��tP�֍L$DQ腀���T$@R�{����D$ ����tP�֡�j �Q��!_^�   [�Ĕ   Ð�������������������������������������������������������������������������������������������������̋��D$#�3�;���Ð�������������������������QVh�3���!�����D$t$��u �D$jP�T����L$�����A���D$u�h��,"��^�����YÐ����������������������������������������Vh�3���!�L$����uVQ�~������h��,"��^Å�u�   h��,"��^Ð�����������������������������������V�t$�F�N��Q�F�F    �|��V�
|����^Ð����������������������̋D$V3���u�   ^ËD$S��Wt�8 t�L$�   ��_�1[^�jj��"������u�L$�   ��_�1[^�j V�F    �F    �F    ��}��������u8�^PS��}��������uP�FP��{��������t*S��}����V��}����V��"�L$��3���_�1[^ËL$3����F⭬_�1[^Ð�����������������������������������������������������������������������������̋D$SUVW3�3�3���%  �0���  �����   �~⭬�  V�}��������   �~W�}���؃���tV�^z������_^][ËF��m�F�N;�cW�F    �6z�����؅�Vt�'z������_^][��z��������   �L$�VR��{��W���|��V���|��V����"���FW��y��V����y�������   �,h���!�D$�8�u�     ��   h��,"��t_^��][Å���u_��^][ø   _^][Ð����������������������������������������������������������������������������������������������������������Vjj3���"����u�T$�   ^���ËL$�     ���^Ð���������������������������̋L$V3���t���tP�1��"����^ø   ^Ð����������������������̋D$��t� ��t�L$��t� �3�ø   Ð���������������������������̋D$��t���t�T$��t��u3��ø   Ð�������������������������SVW�|$����   �����   ���uEh�3���!����uVW��y�������	��u�   h��,"��t��t��_^[Ë7�~⭬u{V�"z������us�NA���N=���uQ�~W�z���؃���tV�Zw������_^[ËF�^+�W�^�F    �9w��������tV�*w������_^[�V�w����_^[ø   _^[Ð�����������������������������������������������������������������������������SVW�|$����   �����   ���uEh�3���!����uVW�x�������	��u�   h��,"��t��t��_^[Ë7�~⭬��   �\$SV�x������u�NA���N=���u]�~SW��w���؃���t��L'  u�FV�v������_^[ËF�^+�W�^�F    ��u��������tV��u������_^[�V��u����_^[ø   _^[Ð���������������������������������������������������������������������������������������̃�UVW�|$���  ����  ���uHh�3���!����uVW�Vw�������	��u�   h��,"��t��t	��_^]��Ë7�~⭬��   V�xw��������   �nU�dw��������tV�t������_^]��ËF��uh�F��~�N�F    +ȉN�F��~K��S�FV�D$hw P�uu�����^US�t��������u�F��|�3Ʌ���Q�Vt������[u�~�F��_^]��ø   _^]��Ð������������������������������������������������������������������������������������������̃�UVW�|$���!  ����  ���uHh�3���!����uVW��u�������	��u�   h��,"��t��t	��_^]��Ë7�~⭬��   �|$ WV� u��������   �nWU�u��������tV�&s������_^]��ËF��um�F��~�N�F    +ȉN�F��~P��S�FV�D$hw P��s�����^�L$$QUS��r��������u�F��|�3҅���R�r������[u�~�F��_^]��ø   _^]��Ð�������������������������������������������������������������������������������̋D$SVW��t}�0��tw���u_^3�[Á~⭬uc�F��u:�^S�t��������t_^[ËF@�Fu��j V�J�������S��q�����H�F�FP��q��V����q������t��_^[ø   _^[Ð��������������������������������������������������������������U���S�]VW����  �����  �=�!���uDh�3��׋���uVS�bs�������	��u�   h��,"��t��t	��_^[��]Ë�]�{⭬�G  �3�����u�rih��׋���uVS�>s�������7���uh0S�'s������� ���uh4S�s�������	��u�   h��,"���u��R  ��3���u�tQR�M��   �    ���E�ZY�QR�M��   �    ��E�ZY�E���F�
  ����  �F   �5���tK�X"�E��#�E��P�T"�M��Q�P"�U�R�#��t�w��M��ǉq�A�  �vq����������   ���   �   ȉF$���   �8"j�^j j S��4"P�H"P�4"P�D"��uWV�:q���M��]��3�3��q�A�#  �P�@"�F,��VQ�q���]���M��ǉq�A��   ����   �5���t@�X"�E��#��E�R�T"���E�P�P"�M�Q�#��t�w��   �}p��������tw���   �   ȉF$���   �8"j�^j j S��4"P�H"P�4"P�D"��uWV�Ep����3�3�����R�@"�F,��VP�p�����]�M��A�Q;�u	;�u�A��E�   �u���t	��_^[��]ËKA���K=���uW�sV�p��������tS��m������_^[��]ËK�{+�V�{�C    ��m��������tS��m������_^[��]�S�m����_^[��]�_^�   [��]Ð�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������U���SVW�}����  �����  ���uHh�3���!����uVW�n�������	��u�   h��,"��t��t	��_^[��]Ë?�}��⭬�*  ��E    ���roh�3���!����uVW�Xn�������7���uh0W�An������� ���uh4W�*n�������	��u�   h��,"���u�I  �����]�tQR�M��   �    ���E�ZY�QR�M��   �    ��E�ZY�E���C��   ����   �   �{��P�Ik������t�p�H�}��s�M�K�   �l�����U��t|���   �~$ω��   �8"j�~j j W��4"P�H"P�4"P�D"��u�U�RV�l���}�3�����3ɉs�K�N�P�@"�F,��VQ��l�����M�}��s�K�$��u��j���K�s;�u	;�u�C��E   �u��t	��_^[��]ËG�_3�����urmh���!����uVS�l�������7���uh0S�rl������� ���uh4S�[l�������	��u�   h��,"���u�P  �����]�tQR�M��   �    ���E�ZY�QR�M��   �    ��E�ZY�E����C��   ����   �C   ��R�zi������t�p�@�ȉs�E�K��   ��j�����U����   ���   �   ȉF$���   �8"j�~j j W��4"P�H"P�4"P�D"��u�M�QV�j���}�3�����3ɉs�K�M�R�@"�F,��VP�k���}����M�s�K�$��u��h���K�s;�u	;�u�C��E   �u��tW�nh��������   ��_^[��]ËG��uO�G��~�O�G    +ȉO�G��~@�GP�-h��������Wt�h������_^[��]��h��������u�   ��_^[��]��G   ��_^[��]ø   _^[��]Ð���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������̋D$��t� ��t�8����t�   ËD$�����0Ð����������������������̋D$��t$� ��t�8����u�D$��t��v	�     3�ø   Ð����������������������������̋D$��t(���t"�9����u�D$��t� ���|���A3�ø   Ð������������������������̋D$��t� ��t�8����u�L$��t�@�3�ø   Ð������������������̋D$��t� ��t�8����t�   ËL$��t��t�   ÉH3�Ð�������������������������̋D$��t� ��t�8����u�L$��t�@�3�ø   Ð�������������������SVh 3���!�\$��t�D$�K;�u�C��u�   h �,"��t��^[ËD$����   ����   ��t^�0   [ËL$U�1����|s��n���~���}��������}
��~�   ��(WS��f��������u4U�l$�UR��!��uS�   �&d������_]^[�S�u,�d������_]^[�]^�   [�^�   [Ð��������������������������������������������������������������������������S��"V�t$W�|$���|$|�����������    ���;���   ��|���   ����    ���;�x���~���}
�D$�������}��~�D$   �\$U�k(U�e��������u4�D$ �KPQ��!��uU�   ��b������]_^[�U�{,��b����]��_^[�_^�   [Ð�����������������������������������������������������������������������VWh 3���!�|$��t�D$�O;�u�G��u�   h �,"��t��_^ËL$��v�D$��t�    �O,�_3�^�_�   ^Ð�����������������������������������̋D$��|���   ���"�    ���Ð���������������������������̋D$��|����������"�    ���Ð����������������������������V�t$��t<��!;�t2Vj h   ��!��u �X"���������F��"�0���^ËD$��t��"� (   ���^�3�^Ð���������������������������������������������V�t$��t<��!;�t2Vj h   ��!��u �X"���������F��"�0���^�3�^Ð��������������������������������������j �<"3�Ð�������������������̋D$V��Wt�   ��"�8_���^Ë|$�����v�   ��"�8_���^�jj��"������u�   ��"�8_���^É>�~j W�_b������uPh���PP�"���Fu&W�jb����V�   ��"����"�8_���^ËD$_�03�^Ð���������������������������������������������������SU�l$V��WtS�] ��tL�sV��a��������u?�; }V�=_�����   ��"�8_^]���[ËCP�"��uV�_�����   ��"�8_^]���[��E     V������^���=<"��j ��V�qa������t�S��"��3�_^][Ð������������������������������������������������������������SU�l$VW�u ��u�   ��"�8_^]���[Í^S��`��������u@�}  uS�;^������"_^�    ]���[Ë��~H���   S�^������t��"�8_^]���[�_^]3�[Ð��������������������������������������������������V�t$W�~W�G`������u �> t�Fj P�"��t�W�]����_^Ð���������������������̋D$����S�UVWQ�r]������t�P�p�T$�   ��^�����T$��tu���   �   ��F$���   �8"�-4"j�~j j W���P�H"P��P�D"��u�D$PV�^����3�3�� �Q�@"�F,��VR�_�����D$���D$tS�F��uK�~0W�6_���F4�   ��;�t*�N<Q�0"�F   W�w\��W�n4�n\��j�y^����W�^\������u�   ��"�0_^]���[��Í{W��^��������uc�T$ �: u W�\������"_^�    ]���[��Ë3WN�3��[������};S�D$hp� P��\���KQ��\����V��[������t��"�0_^]���[���_^]3�[������������������������������������������������������������������������������������������������������������������̃��D$��SUVW�8Q�D$    �|$�6[������t�p�h�   �\�������t|���   �   ��F$���   �8"�4"j�~j j W���P�H"P��P�D"��uUV�~\���|$��3�3��D$ �#�R�@"�F,��VP��\���|$���l$ ��tW�F��uO�~0W��\���F4�   ��;�t*�N<Q�0"�F   W�>Z��W�^4�5Z��j�@\����W�%Z���|$���D$,��u�D$   ��"�T$_^�]���[��Ë\$0��u����   �Cj � � h@B �� RP�0  �����j �h�  RP��  ���T$R��"�D$ ���j h�  RP�  �؋D$ %��  �ʙ��;�|;�v+���u	������3��|$��wV��[�����D$��uz�D$,�8 u V�>Y������"_^�    ]���[��ËVK��Y������}7�T$�D$R�L$h0� P�|$ �L$$��Y���OUQ��Z��P�D$(��X�����D$��t��"�T$_^�]���[���_^]3�[��Ð������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������S�\$VW�3�~W�Z������u/P�FP�"��u�KW���W����_^[ËW@��W����_^[Ð�����������������������������������SU�l$VW�u ��u�   ��"�8_^]���[Í^S��Y��������uW�}  uS�KW�������_^][Ë=���}%@���#�Fj jP��!��u��   H���"   S�W������t��"�8_^]���[�_^]3�[Ð�����������������������������������������������������������SU�l$VW�u ����   �|$����   �FP�D$�Y���؃���un�}  u�D$P�hV�������_^][Ë����+�;�0����؅��~);�~��j P�FP��!��u��   +ǉ��"   �L$Q�V������t%��"_^�]���[û   ��"_^�]���[�_^]3�[Ð����������������������������������������������������������������SU�l$V��Wt0�} ��t)�D$��t!�wV�X���؃���u4�}  uV�dU������"_^�    ]���[Ë?V�EU���D$���8_^��][Ð�����������������������������������������"� (   ����������������������"� (   ����������������������"� (   ��������������������Vh�3���!�L$����uVQ�W������h��,"��^Å�u�   h��,"��^Ð����������������������������������̋D$��SU3�V��Wu_^]�   [��ÍD$�L$PQ�4"P�L"��t/�T$3ɸ   ��tA��u�����~�|$ u_^]�(   [��þ   ��"jj�Ӌ�����u_^]�   [��Ã�~�D$�w�   �8_��^][���jj3���3ۃ�;�u�   ���X;�D$��u#�T$ �O��D$PQ��U�����;�u�   �5�"�T$��t�D$;�t
P�\$�փ�;�u�D$�8_��^][���W�֋L$ ����_^�][��Ð��������������������������������������������������������������������������������������������������������������U��QSVW�}3ۅ���   �7����   ����u��   �>u/�FP��T���؃�����   V�    ��"����_^[��]á��tQR�M�    �   ���E�ZY�QR�M�    �   ��E�ZY�}�t��   ��_^[��]�h���!�?�uh��    �,"��_^[��]�h��   �,"��_^[��]�_^�   [��]Ð��������������������������������������������������������������������U��QVW�}����   �����   ���uBh�3���!����uVW�S�������	��u�   h��,"��t��_^��]Ë?�   �}���tQR�M�   �   ���E�ZY�QR�M�   �   ��E�ZY9u�t��;�u3�_^��]Ã�u��W�S����_^��]�_�   ^��]Ð��������������������������������������������������������������������U��Q�EV��tx� ��tr������uu
�   ^��]á��tQR�M�   �   ���E�ZY�QR�M�   �   ��E�ZY�E�Ht�HtHu��V�O����^��]�3�^��]ø   ^��]Ð�������������������������������������������������U���SVW�}����  �����  ��!���u?h�3��Ӌ���uVW�Q�������	��u�   h��,"��t	��_^[��]á�?3��};�tQR�M�   �   ���E�ZY�QR�M�   �   ��E�ZY�E�H��  H��  H��  �G������u�roh��Ӌ���uj W��P�������7���uh0W��P������� ���uh4W��P�������	��u�   h��,"���u�t	��_^[��]á����]tQR�M�   �    ���E�ZY�QR�M�   �    ��E�ZY�E����C�  ���  �C   �5���tM�X"�E��#�E�P�T"�M���Q�P"�U�R�#��t�w��ǉs�C�E�_^[��]��*O����������   ���   �   ȉF$���   �8"j�^j j S��4"P�H"P�4"P�D"��u!WV��N���]��3�3��s�C�E�_^[��]ËP�@"�F,��VQ�GO���]���ǉs�C�E�_^[��]Ã���   �5���t@�X"�E��#��E�R�T"���E�P�P"�M�Q�#��t�w��   �-N��������tw���   �   ȉF$���   �8"j�^j j S��4"P�H"P�4"P�D"��uWV��M����3�3�����R�@"�F,��VP�^N�����]�C�K;�u;�u�C@�C�E�_^[��]��E�   �E�_^[��]ø   _^[��]�3�_^[��]�_^�   [��]Ð���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������́�   SUVWh 3���!��$�   ��te��$�   �K;�uW�C$�   ;�u�   �t$�L�s0�D$    V��L������u(�C��tV�k$�-J�����9k$t��V�J������D$   �t$�-,"h �Յ���   ����   �Kj�Q�"����   �#   ��|$h ���!�S�s�#   3����S��B�s�S�C   ���t�X��h ��ՋD$P�5"��tP�֍T$DR��K���D$@P��K���D$ ����tP�֋D$_^][�Đ   Ë�_^][�Đ   Ð�������������������������������������������������������������������������������������������������������������̃�VWh ��!�|$��t�D$�O;�u�w$N���������   h �,"����  �5�S��Ut@�X"���#���Q�T"S���P"U�#��t�W�w�T$��   �|$��I�����T$����   ���   �   ��n$���   �8"�=4"j�^j j S���P�H"P��P�D"��uZh ��!�V�^�#   3����V��B�^�V�n�;�t�p��5h �5�,"�|$3�3��$�P�@"�F,��VQ�I�����|$�D$][��u_�   ^���;�u;D$u_�$   ^��ËGj�P袞������u!�D$��t�W��D$PW�7G����_^���_�   ^��Ë�_^��Ð��������������������������������������������������������������������������������������������������������������������������������������VWjj3���"������u�L$_�   �1^���!����uV�   ��"�T$��3����_^ËD$��t�F�D$�F�����0��_^ËL$��_�1^Ð�����������������������������������������S�\$����   �CUVW��t]�C��tV�kU�/H������uF�s��t6���t0�x(W�H������Vu�]E��W�fE������ME�����s��u�U�LE�����P�"�C��t)�sV��G������u�=<"j��V�G������t�S��"��3�_^][�3�[Ð����������������������������������������������������������������������������̃�SUV�5�W�|$;��,  ��t<�X"���#��P�T"S���P"U�#��t�w�o��   �|$�F���������   ���   �   ��F$���   �8"�=4"j�^j j S���P�H"P��P�D"��u_h ��!�V�^�#   3����V��B�^�V�F   ���t�p��5h �5�,"�|$3�3��"�Q�@"�F,��VR��E�����|$�Ņ��D$up_^]�   [��Å�t1�X"���#��P�T"S���P"U�#��u$�|$�D$ ��u_^]�   [��ËH�0�L$��W�w�|$�T$�D$ 3�3�;���   ;���   9o��   ;���   �GP�lE��������   �F(P�D$ �TE�����   ��;�t9xt	�@;�u��;�uKjj��"��;�u�   �3�0�x�h�O;͉Ht�A�G�h���   ;͉Ht�A���   3ۋD$P�GB�����GP�;B����;�u�D$ �PQ��!��u�   _^��][��Ð�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������S�\$��u3�[�VW�X"���#���P�T"V���P"W�#_��^[Ð������������������%�"�%�"�%�"�%�"�%�"�%�"�����������̋D$�L$ȋL$u	�D$��� S��؋D$�d$؋D$���[� ������������WVS3��D$�}G�T$���ڃ� �D$�T$�D$�}G�T$���ڃ� �D$�T$�u�L$�D$3���؋D$����A�؋L$�T$�D$���������u�����d$�ȋD$���r;T$wr;D$vN3ҋ�Ou���؃� [^_� �%�"�%�"�%�"�%�"�D$��u9~.���"���	��u?h�   ��"��Y�u3��f�  �hh ���   �YY�=��u9���t0�V�q�;�r���t�ѡ����P��"�% Y^jX� U��S�]V�uW�}��u	�= �&��t��u"���t	WVS�Ѕ�tWVS������u3��NWVS�I?�����Eu��u7WPS�������t��u&WVS�������u!E�} t���tWVS�ЉE�E_^[]� �%�"�=�u�t$��"Y�hh�t$�   ����t$��������Y��H��%�"�%#�%#�%"�%"�%"�%"�% "�%$"�%("�%,"�%�!�%�!�%�!�%<"�%@"�%D"�%H"�%4"�%8"�%P"�%T"�%X"�%L"�%\"�%0"�%"�% "�%�!�%�!�%�!�%�!�%�!�%�!�%�!�%�!�%�!�%�!�%"�%"����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          �/�E       6        P                                                                                                                                                                                                                                                                                         �/�E    ��     s   s   X�  $�  ��  5  "  �  }  �  X  S  �  �  �  �  �  �  F    �  m  �  �    T  �  i  ]    0    �  �  I  U  Z  �    �  n  _    d  �  h  �  �  K  �  @  	  �  E  �  �  �    J  -  (  �  �  �  �  �  �  P  
  '  �  b  �  6  �  �  l  �    O  <  N  �  �  �  �  q    �  2  �  �  �  �  +  �  ;    �  Y  c  D  7  ,  �  �  �  �  �  v  1  �  !  �    {  �  #  &    ��   �  �  +�  G�  d�  �  ��  ��  ��  ��  ��  �  0�  K�  g�  }�  ��  ��  ��  ��  ��  �  .�  G�  f�  u�  ��  ��  ��  ��  ��  ��  	�  %�  ;�  W�  f�  w�  ��  ��  ��  ��  ��  ��   �  �   �  3�  @�  V�  i�  |�  ��  ��  ��  ��  ��  �  -�  D�  a�  ~�  ��  ��  ��  ��  ��   �  �  6�  O�  h�  ~�  ��  ��  ��  ��  �  �  '�  =�  T�  j�  ~�  ��  ��  ��  ��  ��  ��  �  1�  Q�  p�  ��  ��  ��  ��  ��  �  #�  6�  I�  U�  _�  k�  x�  ��  ��  ��  ��  ��  ��  ��            	 
                        ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b c d e f g h i j k l m n o p q r pthreadVC2.dll pthreadCancelableTimedWait pthreadCancelableWait pthread_attr_destroy pthread_attr_getdetachstate pthread_attr_getinheritsched pthread_attr_getschedparam pthread_attr_getschedpolicy pthread_attr_getscope pthread_attr_getstackaddr pthread_attr_getstacksize pthread_attr_init pthread_attr_setdetachstate pthread_attr_setinheritsched pthread_attr_setschedparam pthread_attr_setschedpolicy pthread_attr_setscope pthread_attr_setstackaddr pthread_attr_setstacksize pthread_barrier_destroy pthread_barrier_init pthread_barrier_wait pthread_barrierattr_destroy pthread_barrierattr_getpshared pthread_barrierattr_init pthread_barrierattr_setpshared pthread_cancel pthread_cond_broadcast pthread_cond_destroy pthread_cond_init pthread_cond_signal pthread_cond_timedwait pthread_cond_wait pthread_condattr_destroy pthread_condattr_getpshared pthread_condattr_init pthread_condattr_setpshared pthread_create pthread_delay_np pthread_detach pthread_equal pthread_exit pthread_getconcurrency pthread_getschedparam pthread_getspecific pthread_getw32threadhandle_np pthread_join pthread_key_create pthread_key_delete pthread_kill pthread_mutex_destroy pthread_mutex_init pthread_mutex_lock pthread_mutex_timedlock pthread_mutex_trylock pthread_mutex_unlock pthread_mutexattr_destroy pthread_mutexattr_getkind_np pthread_mutexattr_getpshared pthread_mutexattr_gettype pthread_mutexattr_init pthread_mutexattr_setkind_np pthread_mutexattr_setpshared pthread_mutexattr_settype pthread_num_processors_np pthread_once pthread_rwlock_destroy pthread_rwlock_init pthread_rwlock_rdlock pthread_rwlock_timedrdlock pthread_rwlock_timedwrlock pthread_rwlock_tryrdlock pthread_rwlock_trywrlock pthread_rwlock_unlock pthread_rwlock_wrlock pthread_rwlockattr_destroy pthread_rwlockattr_getpshared pthread_rwlockattr_init pthread_rwlockattr_setpshared pthread_self pthread_setcancelstate pthread_setcanceltype pthread_setconcurrency pthread_setschedparam pthread_setspecific pthread_spin_destroy pthread_spin_init pthread_spin_lock pthread_spin_trylock pthread_spin_unlock pthread_testcancel pthread_timechange_handler_np pthread_win32_process_attach_np pthread_win32_process_detach_np pthread_win32_test_features_np pthread_win32_thread_attach_np pthread_win32_thread_detach_np ptw32_get_exception_services_code ptw32_pop_cleanup ptw32_push_cleanup sched_get_priority_max sched_get_priority_min sched_getscheduler sched_setscheduler sched_yield sem_close sem_destroy sem_getvalue sem_init sem_open sem_post sem_post_multiple sem_timedwait sem_trywait sem_unlink sem_wait                                              