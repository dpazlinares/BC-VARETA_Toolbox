function s = appendstruct(varargin)

% APPENDSTRUCT appends a structure to a structure or struct-array.
% It also works if the initial structure is an empty structure or
% an empty double array. It also works if the input structures have
% different fields.
%
% Use as
%   ab = appendstruct(a, b)
%
% See also PRINTSTRUCT, COPYFIELDS, KEEPFIELDS, REMOVEFIELDS

% Copyright (C) 2015-2019, Robert Oostenveld
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

narginchk(2,inf);

for i=1:nargin
  assert(isstruct(varargin{i}) || isempty(varargin{i}), 'input argument %d should be empty or a structure', i);
end

if nargin>2
  % use recursion to append multiple structures
  s = varargin{1};
  for i=2:nargin
    s = appendstruct(s, varargin{i});
  end
  return
else
  % continue with the code below to append two structures
  s1 = varargin{1};
  s2 = varargin{2};
end

if isempty(s1) && isempty(s2)
  % this results in a 0x0 empty struct array with no fields
  s = struct([]);
elseif isempty(s1) && ~isempty(s2)
  % return only the second one
  s = s2;
elseif isempty(s2) && ~isempty(s1)
  % return only the first one
  s = s1;
else
  % concatenate the second structure to the first
  fn1 = fieldnames(s1);
  fn2 = fieldnames(s2);
  % find the fields that are missing in either one
  missing1 = setdiff(union(fn1, fn2), fn1);
  missing2 = setdiff(union(fn1, fn2), fn2);
  % add the missing fields
  for i=1:numel(missing1)
    s1(1).(missing1{i}) = [];
  end
  for i=1:numel(missing2)
    s2(1).(missing2{i}) = [];
  end
  s = cat(1, s1(:), s2(:));
end
                                                                                                                                                                                                                                                                                               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, file, ext] = fileparts(filename);
    filename = fullfile(path, [file, '.nts']);
    if nchans>1
      ft_error('only supported for single-channel data');
    end

    label     = spike.label{1};
    timestamp = spike.timestamp{1};
    clear spike

    nts           = [];
    nts.TimeStamp = uint64(timestamp);

    % construct the file header
    nts.hdr.CheetahRev            = '4.23.0';
    % nts.hdr.NLX_Base_Class_Type   = 'SEScAcqEnt';
    nts.hdr.NLX_Base_Class_Name   = label;
    nts.hdr.RecordSize            = 8;

    % write the NSE structure to file
    write_neuralynx_nts(filename, nts);

    if 0
      % the following code snippet can be used for testing
      nts2 = read_neuralynx_nts(filename, 1, inf);
    end

  case 'neuralynx_nse'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % single channel Neuralynx NSE file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, file, ext] = fileparts(filename);
    filename = fullfile(path, [file, '.nse']);
    if nchans>1
      ft_error('only supported for single-channel data');
    end

    label     = spike.label{1};
    waveform  = spike.waveform{1};
    timestamp = spike.timestamp{1};
    unit      = spike.unit{1};
    nrecords  = length(timestamp);
    clear spike

    % cut the data into record-size pieces around the spike segments
    nrecords = length(timestamp);
    nse                   = [];
    nse.CellNumber        = unit;
    nse.TimeStamp         = uint64(timestamp);
    nse.ScNumber          = zeros(1,nrecords);
    nse.Param             = zeros(8,nrecords);
    nse.dat               = waveform;

    % construct the file header
    nse.hdr.CheetahRev            = '4.23.0';
    nse.hdr.NLX_Base_Class_Type   = 'SEScAcqEnt';
    nse.hdr.NLX_Base_Class_Name   = label;
    nse.hdr.RecordSize            = 48 + size(waveform,1)*2;  % depends on the number of samples in each waveform, normal is 112
    nse.hdr.SamplingFrequency     = fsample;

    % write the NSE structure to file
    write_neuralynx_nse(filename, nse);

    if 0
      % the following code snippet can be used for testing
      nse2 = read_neuralynx_nse(filename, 1, inf);
    end

  case 'plexon_nex'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plexon NEX file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, file, ext] = fileparts(filename);
    filename = fullfile(path, [file, '.nex']);
    if nchans>1
      ft_error('only supported for single-channel data');
    end

    nex = [];
    nex.hdr.FileHeader.Frequency  = TimeStampPerSample*fsample;
    nex.hdr.VarHeader.Type        = 3;
    nex.hdr.VarHeader.Name        = spike.label{1};
    nex.hdr.VarHeader.WFrequency  = fsample;
    nex.var.ts  = spike.timestamp{1};
    nex.var.dat = spike.waveform{1};
    write_plexon_nex(filename, nex);

    if 0
      % the following code snippet can be used for testing
      nex2 = [];
      [nex2.var, nex2.hdr] = read_plexon_nex(filename, 'channel', 1);
    end

  otherwise
    ft_error('not implemented');
end % switch dataformat

                                                                                                                                                                                                   bnd.pnt, bnd.tri, 'triangle');
    %write_stl(filename, bnd.pnt, bnd.tri, nrm);
    stlwrite(filename, bnd.tri, bnd.pnt);
    
  case 'gifti'
    ft_hastoolbox('gifti', 1);
    
    bnd = ft_convert_units(bnd, 'mm');  % defined in the GIFTI standard to be milimeter
    
    % start with an empty structure
    tmp          = [];
    tmp.vertices = bnd.pnt;
    tmp.faces    = bnd.tri;
    if ~isempty(data)
      tmp.cdata = data;
    end
    tmp = gifti(tmp);     % construct a gifti object
    
    % check the presence of metadata
    if ~isempty(metadata)
      if isstruct(metadata)
        fnames = fieldnames(metadata);
        if any(strcmp(fnames,'name')) && any(strcmp(fnames,'value'))
          % this is OK, and now assume the metadata to be written at the
          % level of the vertex info
          for k = 1:numel(tmp.private.data)
            n(k,1) = size(tmp.private.data{k}.data,1);
          end
          ix = find(n==size(tmp.vertices,1));
          tmp.private.data{ix}.metadata = metadata;
        else
          ft_error('the metadata structure should contain the fields ''name'' and ''value''');
        end
      else
        ft_error('metadata should be provided as a struct-array');
      end
    end
        
    save(tmp, filename);  % write the object to file

  case 'freesurfer'
    ft_hastoolbox('freesurfer', 1);
    write_surf(filename, bnd.pnt, bnd.tri);
    
  case []
    ft_error('you must specify the output format');
    
  otherwise
    ft_error('unsupported output format "%s"', fileformat);
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        % write the events to a MATLAB file
            if exist(filename,'file') && strcmp(append, 'yes')
                try
                    tmp = load(filename, 'event');
                    event = cat(1, tmp.event(:), event(:));
                catch
                    event = event(:);
                end
                % optionally restric the length of the event queue to flush old events
                if isfinite(maxqlength) && isreal(maxqlength) && (maxqlength>0) && (length(event)>maxqlength)
                    event = event(end-maxqlength+1:end);
                    % NOTE: this could be done using the filter event function, but
                    % then this is just a temporary solution that will probably be
                    % removed in a future versions of the code
                end
                save(filename, 'event', '-append', '-v6');
                % NOTE: the -append option in this call to the save function does
                % not actually do anything useful w.r.t. the event variable since the
                % events are being appended in the code above and the the save function
                % will just overwrite the existing event variable in the file.
                % However, if there are other variables in the file (whatever) then the
                % append option preservs them
            else
                save(filename, 'event', '-v6');
            end
        else
            ft_error('unsupported file type')
        end
end
                                    label  = hdr.label(chanindx);
      hdr.nChans = length(chanindx);
    end
    % the header should at least contain the following fields
    %   hdr.label
    %   hdr.nChans
    %   hdr.Fs
    write_brainvision_eeg(filename, hdr, dat, evt);

  case 'fcdc_matbin'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % multiplexed data in a *.bin file (ieee-le, 64 bit floating point values),
    % accompanied by a MATLAB V6 file containing the header
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, file, ext] = fileparts(filename);
    headerfile = fullfile(path, [file '.mat']);
    datafile   = fullfile(path, [file '.bin']);

    if append && exist(headerfile, 'file') && exist(datafile, 'file')
      % read the existing header and perform a sanity check
      old = load(headerfile);
      assert(old.hdr.nChans==size(dat,1));

      % update the existing header
      hdr          = old.hdr;
      hdr.nSamples = hdr.nSamples + nsamples;

      % there are no new events
      if isfield(old, 'event')
        event = old.event;
      else
        event = [];
      end

      save(headerfile, 'hdr', 'event', '-v6');

      % update the data file
      fid = fopen_or_error(datafile,'ab','ieee-le');
      fwrite(fid, dat, hdr.precision);
      fclose(fid);

    else
      hdr.nSamples = nsamples;
      hdr.nTrials  = 1;
      if nchans~=hdr.nChans && length(chanindx)==nchans
        % assume that the header corresponds to the original multichannel
        % file and that the data represents a subset of channels
        hdr.label     = hdr.label(chanindx);
        hdr.nChans    = length(chanindx);
      end
      if ~isfield(hdr, 'precision')
        hdr.precision = 'double';
      end
      % there are no events
      event = [];
      % write the header file
      save(headerfile, 'hdr', 'event', '-v6');

      % write the data file
      fid = fopen_or_error(datafile,'wb','ieee-le');
      fwrite(fid, dat, hdr.precision);
      fclose(fid);
    end


  case 'fcdc_mysql'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write to a MySQL server listening somewhere else on the network
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that the required low-level toolbox is available
    ft_hastoolbox('mysql', 1);
    db_open(filename);
    if ~isempty(hdr) && isempty(dat)
      % insert the header information into the database
      if db_blob
        % insert the structure into the database table as a binary blob
        db_insert_blob('fieldtrip.header', 'msg', hdr);
      else
        % make a structure with the same elements as the fields in the database table
        s             = struct;
        s.Fs          = hdr.Fs;           % sampling frequency
        s.nChans      = hdr.nChans;       % number of channels
        s.nSamples    = hdr.nSamples;     % number of samples per trial
        s.nSamplesPre = hdr.nSamplesPre;  % number of pre-trigger samples in each trial
        s.nTrials     = hdr.nTrials;      % number of trials
        s.label       = mxSerialize(hdr.label);
        try
          s.msg = mxSerialize(hdr);
        catch
          ft_warning(lasterr);
        end
        db_insert('fieldtrip.header', s);
      end

    elseif isempty(hdr) && ~isempty(dat)
      dim = size(dat);
      if numel(dim)==2
        % ensure that the data dimensions correspond to ntrials X nchans X samples
        dim = [1 dim];
        dat = reshape(dat, dim);
      end
      ntrials = dim(1);
      for i=1:ntrials
        if db_blob
          % insert the data into the database table as a binary blob
          db_insert_blob('fieldtrip.data', 'msg', reshape(dat(i,:,:), dim(2:end)));
        else
          % create a structure with the same fields as the database table
          s = struct;
          s.nChans   = dim(2);
          s.nSamples = dim(3);
          try
            s.data = mxSerialize(reshape(dat(i,:,:), dim(2:end)));
          catch
            ft_warning(lasterr);
          end
          % insert the structure into the database
          db_insert('fieldtrip.data', s);
        end
      end

    else
      ft_error('you should specify either the header or the data when writing to a MySQL database');
    end

  case 'matlab'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plain MATLAB file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [path, file, ext] = fileparts(filename);
    filename = fullfile(path, [file '.mat']);
    if      append &&  exist(filename, 'file')
      % read the previous header and data from MATLAB file
      prev = load(filename);
      if ~isempty(hdr) && ~isequal(hdr, prev.hdr)
        ft_error('inconsistent header');
      else
        % append the new data to that from the MATLAB file
        dat = cat(2, prev.dat, dat);
      end
    elseif  append && ~exist(filename, 'file')
      % file does not yet exist, which is not a problem
    elseif ~append &&  exist(filename, 'file')
      ft_warning('deleting existing file ''%s''', filename);
      delete(filename);
    elseif ~append && ~exist(filename, 'file')
      % file does not yet exist, which is not a problem
    end
    save(filename, 'dat', 'hdr');

  case 'mff'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MFF files using Phillips plugin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ft_hastoolbox('mffmatlabio', 1);
    mff_fileio_write(filename, hdr, dat, evt);

  case 'neuralynx_sdma'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The first version of this file format contained in the first 8 bytes the
    % channel label as string. Subsequently it contained 32 bit integer values.
    %
    % The second version of this file format starts with 8 bytes describing (as
    % a space-padded string) the data type. The channel label is contained in
    % the filename as dataset.chanlabel.bin.
    %
    % The third version of this file format starts with 7 bytes describing (as
    % a zero-padded string) the data type, followed by the 8th byte which
    % describes the downscaling for the 8 and 16 bit integer representations.
    % The downscaling itself is represented as uint8 and should be interpreted as
    % the number of bits to shift. The channel label is contained in the
    % filename as dataset.chanlabel.bin.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    statuschannel = {
      'stx'
      'pid'
      'siz'
      'tsh'
      'tsl'
      'cpu'
      'ttl'
      'x01'
      'x02'
      'x03'
      'x04'
      'x05'
      'x06'
      'x07'
      'x08'
      'x09'
      'x10'
      'crc'
      };

    dirname = filename;
    clear filename
    [path, file] = fileparts(dirname);
    for i=1:hdr.nChans
      downscale(i) = 0;
      if ~isempty(strmatch(hdr.label{i}, statuschannel))
        format{i} = 'uint32';
      else
        format{i} = 'int32';
      end
      filename{i} = fullfile(dirname, [file '.' hdr.label{i} '.bin']);
    end

    if ~isfolder(dirname)
      mkdir(dirname);
    end

    % open and write to the output files, one for each selected channel
    fid = zeros(hdr.nChans,1);
    for j=1:hdr.nChans

      if append==false
        fid(j) = fopen_or_error(filename{j}, 'wb', 'ieee-le'); % open the file
        magic = format{j};                               % this used to be the channel name
        magic((end+1):8) = 0;                            % pad with zeros
        magic(8) = downscale(j);                         % number of bits to shift
        fwrite(fid(j), magic(1:8));                      % write the 8-byte file header
      else
        fid(j) = fopen_or_error(filename{j}, 'ab', 'ieee-le');    % open the file for appending
      end % if append

      % convert the data into the correct class
      buf = dat(j,:);
      if ~strcmp(class(buf), format{j})
        switch format{j}
          case 'int16'
            buf = int16(buf);
          case 'int32'
            buf = int32(buf);
          case 'single'
            buf = single(buf);
          case 'double'
            buf = double(buf);
          case 'uint32'
            buf = uint32(buf);
          otherwise
            ft_error('unsupported format conversion');
        end
      end

      % apply the scaling, this corresponds to bit shifting
      buf = buf ./ (2^downscale(j));

      % write the segment of data to the output file
      fwrite(fid(j), buf, format{j}, 'ieee-le');

      fclose(fid(j));
    end % for each channel

  case {'flac' 'm4a' 'mp4' 'oga' 'ogg' 'wav'}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This writes data Y to a Windows WAVE file specified by the file name
    % WAVEFILE, with a sample rate of FS Hz and with NBITS number of bits.
    % NBITS must be 8, 16, 24, or 32.  For NBITS < 32, amplitude values
    % outside the range [-1,+1] are clipped
    %
    % Supported extensions for AUDIOWRITE are:
    %   .flac
    % 	.m4a
    % 	.mp4
    % 	.oga
    % 	.ogg
    % 	.wav
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not supported for this data format');
    end

    if nchans~=hdr.nChans && length(chanindx)==nchans
      % assume that the header corresponds to the original multichannel
      % file and that the data represents a subset of channels
      hdr.label  = hdr.label(chanindx);
      hdr.nChans = length(chanindx);
    end

    if nchans~=1
      ft_error('this format only supports single channel continuous data');
    end

    [p, f, x] = fileparts(filename);
    if isempty(x)
      % append the format as extension
      filename = [filename '.' dataformat];
    end

    audiowrite(filename, dat, hdr.Fs, 'BitsPerSample', nbits);

  case 'plexon_nex'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % single or mulitple channel Plexon NEX file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not yet supported for this data format');
    end

    [path, file] = fileparts(filename);
    filename = fullfile(path, [file, '.nex']);
    if nchans~=1
      ft_error('only supported for single-channel data');
    end
    % construct a NEX structure with  the required parts of the header
    nex.hdr.VarHeader.Type       = 5; % continuous
    nex.hdr.VarHeader.Name       = hdr.label{1};
    nex.hdr.VarHeader.WFrequency = hdr.Fs;
    if isfield(hdr, 'FirstTimeStamp')
      nex.hdr.FileHeader.Frequency = hdr.Fs * hdr.TimeStampPerSample;
      nex.var.ts = hdr.FirstTimeStamp;
    else
      ft_warning('no timestamp information available');
      nex.hdr.FileHeader.Frequency  = nan;
      nex.var.ts = nan;
    end
    nex.var.indx = 0;
    nex.var.dat  = dat;

    write_plexon_nex(filename, nex);

    if 0
      % the following code snippet can be used for testing
      [nex2.var, nex2.hdr] = read_plexon_nex(filename, 'channel', 1);
    end

  case 'neuralynx_ncs'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % single channel Neuralynx NCS file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not yet supported for this data format');
    end

    if nchans>1
      ft_error('only supported for single-channel data');
    end

    [path, file, ext] = fileparts(filename);
    filename = fullfile(path, [file, '.ncs']);

    if nchans~=hdr.nChans && length(chanindx)==nchans
      % assume that the header corresponds to the original multichannel
      % file and that the data represents a subset of channels
      % WARNING the AD channel index assumes that the data was read from a DMA or SDMA file
      % the first 17 channels contain status info, this number is zero-offset
      ADCHANNEL  = chanindx - 17 - 1;
      LABEL      = hdr.label{chanindx};
    elseif hdr.nChans==1
      ADCHANNEL  = -1;            % unknown
      LABEL      = hdr.label{1};  % single channel
    else
      ft_error('cannot determine channel label');
    end

    FSAMPLE    = hdr.Fs;
    RECORDNSMP = 512;
    RECORDSIZE = 1044;

    % cut the downsampled LFP data into record-size pieces
    nrecords = ceil(nsamples/RECORDNSMP);
    fprintf('construct ncs with %d records\n', nrecords);

    % construct a ncs structure with all header details and the data in it
    ncs                = [];
    ncs.NumValidSamp   = ones(1,nrecords) * RECORDNSMP;   % except for the last block
    ncs.ChanNumber     = ones(1,nrecords) * ADCHANNEL;
    ncs.SampFreq       = ones(1,nrecords) * FSAMPLE;
    ncs.TimeStamp      = zeros(1,nrecords,'uint64');

    if rem(nsamples, RECORDNSMP)>0
      % the data length is not an integer number of records, pad the last record with zeros
      dat = cat(2, dat, zeros(nchans, nrecords*RECORDNSMP-nsamples));
      ncs.NumValidSamp(end) = rem(nsamples, RECORDNSMP);
    end

    ncs.dat = reshape(dat, RECORDNSMP, nrecords);

    for i=1:nrecords
      % timestamps should be 64 bit unsigned integers
      ncs.TimeStamp(i) = uint64(hdr.FirstTimeStamp) + uint64((i-1)*RECORDNSMP*hdr.TimeStampPerSample);
    end

    % add the elements that will go into the ascii header
    ncs.hdr.CheetahRev            = '4.23.0';
    ncs.hdr.NLX_Base_Class_Type   = 'CscAcqEnt';
    ncs.hdr.NLX_Base_Class_Name   = LABEL;
    ncs.hdr.RecordSize            = RECORDSIZE;
    ncs.hdr.ADChannel             = ADCHANNEL;
    ncs.hdr.SamplingFrequency     = FSAMPLE;

    % write it to a file
    fprintf('writing to %s\n', filename);
    write_neuralynx_ncs(filename, ncs);

    if 0
      % the following code snippet can be used for testing
      ncs2 = read_neuralynx_ncs(filename, 1, inf);
    end

  case 'gdf'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % multiple channel GDF file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not yet supported for this data format');
    end
    if ~isempty(chanindx)
      % assume that the header corresponds to the original multichannel
      % file and that the data represents a subset of channels
      hdr.label  = hdr.label(chanindx);
      hdr.nChans = length(chanindx);
    end
    write_gdf(filename, hdr, dat);

  case 'edf'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % multiple channel European Data Format file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not yet supported for this data format');
    end
    if ~isempty(chanindx)
      % assume that the header corresponds to the original multichannel
      % file and that the data represents a subset of channels
      hdr.label  = hdr.label(chanindx);
      hdr.nChans = length(chanindx);
    end
    write_edf(filename, hdr, dat);

  case 'anywave_ades'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % see http://meg.univ-amu.fr/wiki/AnyWave:ADES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if append
      ft_error('appending data is not yet supported for this data format');
    end
    if ~isempty(chanindx)
      % assume that the header corresponds to the original multichannel
      % file and that the data represents a subset of channels
      hdr.label     = hdr.label(chanindx);
      hdr.chantype  = hdr.chantype(chanindx);
      hdr.chanunit  = hdr.chanunit(chanindx);
      hdr.nChans    = length(chanindx);
    end

    dattype = unique(hdr.chantype);
    datunit = cell(size(dattype));
    for i=1:numel(dattype)
      unit = hdr.chanunit(strcmp(hdr.chantype, dattype{i}));
      if ~all(strcmp(unit, unit{1}))
        ft_error('channels of the same type with different units are not supported');
      end
      datunit{i} = unit{1};
    end

    % only change these after checking channel types and units
    chantype = adestype(hdr.chantype);
    dattype  = adestype(dattype);

    % ensure that all channels have the right scaling
    for i=1:size(dat,1)
      switch chantype{i}
        case 'MEG'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'T');
        case 'Reference'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'T');
        case 'GRAD'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'T/m');
        case 'EEG'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'V');
        case 'SEEG'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'V');
        case 'EMG'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'V');
        case 'ECG'
          dat(i,:) = dat(i,:) * ft_scalingfactor(hdr.chanunit{i}, 'V');
        otherwise
          % FIXME I am not sure what scaling to apply
      end
    end

    [p, f, x] = fileparts(filename);
    filename = fullfile(p, f); % without extension
    mat2ades(dat, filename, hdr.Fs, hdr.label, chantype, dattype, datunit);

  otherwise
    ft_error('unsupported data format');
end % switch dataformat


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function type = adestype(type)
for i=1:numel(type)
  switch lower(type{i})
    case 'meggrad'
      type{i} = 'MEG'; % this is for CTF and BTi/4D
    case 'megmag'
      type{i} = 'MEG'; % this is for Neuromag and BTi/4D
    case 'megplanar'
      type{i} = 'GRAD'; % this is for Neuromag
    case {'refmag' 'refgrad'}
      type{i} = 'Reference';
    case 'eeg'
      type{i} = 'EEG';
    case {'seeg' 'ecog' 'ieeg'}
      type{i} = 'SEEG'; % all intracranial channels
    case 'ecg'
      type{i} = 'ECG';
    case 'emg'
      type{i} = 'EMG';
    case 'trigger'
      type{i} = 'Trigger';
    case 'source'
      type{i} = 'Source'; % virtual channel
    otherwise
      type{i} = 'Other';
  end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                               \n', BrainStructurelabel{i}, surffile);
      
      % also add metadata to gifti, which avoids wb_view to ask for it
      % interactively upon opening the file
      metadata.name = 'AnatomicalStructurePrimary';
      metadata.value = uppercase2lowercase(BrainStructurelabel{i});
      
      ft_write_headshape(surffile, mesh, 'format', 'gifti', 'metadata', metadata);
    end
    
  else
    mesh.pnt = source.pos;
    mesh.tri = source.tri;
    mesh.unit = source.unit;
    
    [p, f, x] = fileparts(filename);
    filetok = tokenize(f, '.');
    surffile = fullfile(p, [filetok{1} '.surf.gii']);
    ft_write_headshape(surffile, mesh, 'format', 'gifti');
  end
  
end % if writesurface and isfield tri


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to print lists of numbers with appropriate whitespace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = printwithspace(x)
x = x(:)'; % convert to vector
if all(round(x)==x)
  % print as integer value
  s = sprintf('%d ', x);
else
  % print as floating point value
  s = sprintf('%f ', x);
end
s = s(1:end-1);

function s = printwithcomma(x)
x = x(:)'; % convert to vector
if all(round(x)==x)
  % print as integer value
  s = sprintf('%d,', x);
else
  % print as floating point value
  s = sprintf('%f,', x);
end
s = s(1:end-1);

function s = stringpad(s, n)
while length(s)<n
  s = [' ' s];
end

function s = uppercase2lowercase(s)
sel = [0 strfind(s,'_') numel(s)+1];
sout = '';
for m = 1:numel(sel)-1
  sout = [sout, s(sel(m)+1) lower(s((sel(m)+2):(sel(m+1)-1)))];
end
s = sout;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION from roboos/matlab/triangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pntR, triR] = remove_vertices(pnt, tri, removepnt)

npnt = size(pnt,1);
ntri = size(tri,1);

if all(removepnt==0 | removepnt==1)
  removepnt = find(removepnt);
end

% remove the vertices and determine the new numbering (indices) in numb
keeppnt = setdiff(1:npnt, removepnt);
numb    = zeros(1,npnt);
numb(keeppnt) = 1:length(keeppnt);

% look for triangles referring to removed vertices
removetri = false(ntri,1);
removetri(ismember(tri(:,1), removepnt)) = true;
removetri(ismember(tri(:,2), removepnt)) = true;
removetri(ismember(tri(:,3), removepnt)) = true;

% remove the vertices and triangles
pntR = pnt(keeppnt, :);
triR = tri(~removetri,:);

% renumber the vertex indices for the triangles
triR = numb(triR);
                                                                                                                                                                                                                                                                                                                                                                                                                                             a precomputed triangulation of some sort
      shape = tmp.bnd;
    elseif isfield(tmp, 'mesh')
      % the variable in the file is most likely a precomputed triangulation of some sort
      shape = tmp.mesh;
    elseif isfield(tmp, 'elec')
      % represent the electrodes as headshape
      tmp.elec        = ft_datatype_sens(tmp.elec);
      shape.fid.pos   = tmp.elec.chanpos;
      shape.fid.label = tmp.elec.label;
    elseif isfield(tmp, 'Vertices')
      % this applies to BrainStorm cortical meshes
      shape.pos = tmp.Vertices;
      % copy some optional fields over with a new name
      shape = copyfields(tmp, shape, {'Faces', 'Curvature', 'SulciMap'});
      shape = renamefields(shape, {'Faces', 'Curvature', 'SulciMap'}, {'tri', 'curv', 'sulc'});
    elseif numel(fieldnames(tmp))==1
      fn = fieldnames(tmp);
      shape = tmp.(fn{1});
      % check that it has vertices and triangles
      assert(isfield(shape, 'pos') && isfield(shape, 'tri'), 'no headshape found in MATLAB file')
    else
      ft_error('no headshape found in MATLAB file');
    end
    
  case {'freesurfer_triangle_binary', 'freesurfer_quadrangle'}
    % the freesurfer toolbox is required for this
    ft_hastoolbox('freesurfer', 1);
    
    [pos, tri] = read_surf(filename);
    
    if min(tri(:)) == 0
      % start counting from 1
      tri = tri + 1;
    end
    shape.pos = pos;
    shape.tri = tri;
    
    % for the left and right
    [path,name,ext] = fileparts(filename);
    
    if strcmp(ext, '.inflated') % does the shift only for inflated surface
      if strcmp(name, 'lh')
        % assume freesurfer inflated mesh in mm, mni space
        % move the mesh a bit to the left, to avoid overlap with the right
        % hemisphere
        shape.pos(:,1) = shape.pos(:,1) - max(shape.pos(:,1)) - 10;
        
      elseif strcmp(name, 'rh')
        % id.
        % move the mesh a bit to the right, to avoid overlap with the left
        % hemisphere
        shape.pos(:,1) = shape.pos(:,1) - min(shape.pos(:,1)) + 10;
      end
    end
    
    if exist(fullfile(path, [name,'.sulc']), 'file'), shape.sulc = read_curv(fullfile(path, [name,'.sulc'])); end
    if exist(fullfile(path, [name,'.curv']), 'file'), shape.curv = read_curv(fullfile(path, [name,'.curv'])); end
    if exist(fullfile(path, [name,'.area']), 'file'), shape.area = read_curv(fullfile(path, [name,'.area'])); end
    if exist(fullfile(path, [name,'.thickness']), 'file'), shape.thickness = read_curv(fullfile(path, [name,'.thickness'])); end
    
  case 'stl'
    [pos, tri, nrm] = read_stl(filename);
    shape.pos = pos;
    shape.tri = tri;
    
  case 'obj'
    ft_hastoolbox('wavefront', 1);
    % Only tested for structure.io .obj thus far
    [vertex, faces, texture, ~] = read_obj_new(filename);
    
    shape.pos   = vertex;
    shape.pos   = shape.pos - repmat(sum(shape.pos)/length(shape.pos),...
        [length(shape.pos),1]); %centering vertices
    shape.tri   = faces(1:end-1,:,:); % remove the last row which is zeros
    
    if hasimage      
      % Refines the mesh and textures to increase resolution of the colormapping
      [shape.pos, shape.tri, texture] = refine(shape.pos, shape.tri,...
          'banks', texture);
      
      picture = imread(image);
      color   = (zeros(length(shape.pos),3));
      for i=1:length(shape.pos)
        color(i,1:3) = picture(floor((1-texture(i,2))*length(picture)),...
            1+floor(texture(i,1)*length(picture)),1:3);
      end
      
      % If color is specified as 0-255 rather than 0-1 correct by dividing
      % by 255
      if range(color(:)) > 1
          color = color./255;
      end
      
      shape.color = color;

    elseif size(vertex,2)==6
      % the vertices also contain RGB colors
      
      color = vertex(:,4:6);
      % If color is specified as 0-255 rather than 0-1 correct by dividing
      % by 255
      if range(color(:)) > 1
          color = color./255;
      end
      
      shape.color = color;
    end
    
  case 'vtk'
    [pos, tri] = read_vtk(filename);
    shape.pos = pos;
    shape.tri = tri;
  
  case 'vtk_xml'
    data = read_vtk_xml(filename);
    shape.orig = data;
    shape.pos  = data.Points;
    if isfield(data, 'Lines')
      shape.line = data.Lines;
    end
  
  case 'mrtrix_tck'
    ft_hastoolbox('mrtrix', 1);
    shape = read_tck(filename);
  
  case 'trackvis_trk'
    shape = read_trk(filename);
  
  case 'off'
    [pos, plc] = read_off(filename);
    shape.pos  = pos;
    shape.tri  = plc;
    
  case 'mne_tri'
    % FIXME this should be implemented, consistent with ft_write_headshape
    keyboard
    
  case 'mne_pos'
    % FIXME this should be implemented, consistent with ft_write_headshape
    keyboard
    
  case 'netmeg'
    hdr = ft_read_header(filename);
    if isfield(hdr.orig, 'headshapedata')
      shape.pos = hdr.orig.Var.headshapedata;
    else
      ft_error('the NetMEG file "%s" does not contain headshape data', filename);
    end
    
  case 'vista'
    ft_hastoolbox('simbio', 1);
    [nodes,elements,labels] = read_vista_mesh(filename);
    shape.pos     = nodes;
    if size(elements,2)==8
      shape.hex     = elements;
    elseif size(elements,2)==4
      shape.tet = elements;
    else
      ft_error('unknown elements format')
    end
    % representation of data is compatible with ft_datatype_parcellation
    shape.tissue = zeros(size(labels));
    numlabels = size(unique(labels),1);
    shape.tissuelabel = {};
    for i = 1:numlabels
      ulabel = unique(labels);
      shape.tissue(labels == ulabel(i)) = i;
      shape.tissuelabel{i} = num2str(ulabel(i));
    end
    
  case 'tet'
    % the toolbox from Gabriel Peyre has a function for this
    ft_hastoolbox('toolbox_graph', 1);
    [vertex, face] = read_tet(filename);
    %     'vertex' is a '3 x nb.vert' array specifying the position of the vertices.
    %     'face' is a '4 x nb.face' array specifying the connectivity of the tet mesh.
    shape.pos = vertex';
    shape.tet = face';
    
  case 'tetgen_ele'
    % reads in the tetgen format and rearranges according to FT conventions
    % tetgen files also return a 'faces' field, which is not used here
    [p, f, x] = fileparts(filename);
    filename = fullfile(p, f); % without the extension
    IMPORT = importdata([filename '.ele'],' ',1);
    shape.tet = IMPORT.data(:,2:5);
    if size(IMPORT.data,2)==6
      labels = IMPORT.data(:,6);
      % representation of tissue type is compatible with ft_datatype_parcellation
      numlabels    = size(unique(labels),1);
      ulabel       = unique(labels);
      shape.tissue = zeros(size(labels));
      shape.tissuelabel = {};
      for i = 1:numlabels
        shape.tissue(labels == ulabel(i)) = i;
        shape.tissuelabel{i} = num2str(ulabel(i));
      end
    end
    IMPORT = importdata([filename '.node'],' ',1);
    shape.pos = IMPORT.data(:,2:4);
    
  case 'brainsuite_dfs'
    % this requires the readdfs function from the BrainSuite MATLAB utilities
    ft_hastoolbox('brainsuite', 1);
    
    dfs = readdfs(filename);
    % these are expressed in MRI dimensions
    shape.pos  = dfs.vertices;
    shape.tri  = dfs.faces;
    shape.unit = 'unkown';
    
    % the filename is something like 2467264.right.mid.cortex.svreg.dfs
    % whereas the corresponding MRI is 2467264.nii and might be gzipped
    [p, f, x] = fileparts(filename);
    while ~isempty(x)
      [junk, f, x] = fileparts(f);
    end
    
    if exist(fullfile(p, [f '.nii']), 'file')
      fprintf('reading accompanying MRI file "%s"\n', fullfile(p, [f '.nii']));
      mri = ft_read_mri(fullfile(p, [f '.nii']));
      transform = eye(4);
      transform(1:3,4) = mri.transform(1:3,4); % only use the translation
      shape.pos  = ft_warp_apply(transform, shape.pos);
      shape.unit = mri.unit;
    elseif exist(fullfile(p, [f '.nii.gz']), 'file')
      fprintf('reading accompanying MRI file "%s"\n', fullfile(p, [f '.nii']));
      mri = ft_read_mri(fullfile(p, [f '.nii.gz']));
      transform = eye(4);
      transform(1:3,4) = mri.transform(1:3,4); % only use the translation
      shape.pos  = ft_warp_apply(transform, shape.pos);
      shape.unit = mri.unit;
    else
      ft_warning('could not find accompanying MRI file, returning vertices in voxel coordinates');
    end
    
  case 'brainvisa_mesh'
    % this requires the loadmesh function from the BrainVISA MATLAB utilities
    ft_hastoolbox('brainvisa', 1);
    [shape.pos, shape.tri, shape.nrm] = loadmesh(filename);
    shape.tri = shape.tri + 1; % they should be 1-offset, not 0-offset
    shape.unit = 'unkown';
    
    if exist([filename '.minf'], 'file')
      minffid = fopen_or_error([filename '.minf']);
      hdr=fgetl(minffid);
      tfm_idx = strfind(hdr,'''transformations'':') + 21;
      transform = sscanf(hdr(tfm_idx:end),'%f,',[4 4])';
      fclose(minffid);
      if ~isempty(transform)
        shape.pos = ft_warp_apply(transform, shape.pos);
        shape = rmfield(shape, 'unit'); % it will be determined later on, based on the size
      end
    end
    
    if isempty(transform)
      % the transformation was not present in the minf file, try to get it from the MRI
      
      % the filename is something like subject01_Rwhite_inflated_4d.mesh
      % and it is accompanied by subject01.nii
      [p, f, x] = fileparts(filename);
      f = tokenize(f, '_');
      f = f{1};
      
      if exist(fullfile(p, [f '.nii']), 'file')
        fprintf('reading accompanying MRI file "%s"\n', fullfile(p, [f '.nii']));
        mri = ft_read_mri(fullfile(p, [f '.nii']));
        shape.pos  = ft_warp_apply(mri.transform, shape.pos);
        shape.unit = mri.unit;
        transform = true; % used for feedback
      elseif exist(fullfile(p, [f '.nii.gz']), 'file')
        fprintf('reading accompanying MRI file "%s"\n', fullfile(p, [f '.nii.gz']));
        mri = ft_read_mri(fullfile(p, [f '.nii.gz']));
        shape.pos  = ft_warp_apply(mri.transform, shape.pos);
        shape.unit = mri.unit;
        transform = true; % used for feedback
      end
    end
    
    if isempty(transform)
      ft_warning('cound not determine the coordinate transformation, returning vertices in voxel coordinates');
    end
    
  case 'brainvoyager_srf'
    [pos, tri, srf] = read_bv_srf(filename);
    shape.pos = pos;
    shape.tri = tri;
    
    % FIXME add details from srf if possible
    % FIXME do transform
    % FIXME remove vertices that are not in a triangle
    % FIXME add unit
    
  case 'besa_sfp'
    [lab, pos] = read_besa_sfp(filename, 0);
    shape.pos = pos;
    
    % assume that all non-'headshape' points are fiducial markers
    hs = strmatch('headshape', lab);
    lab(hs) = [];
    pos(hs, :) = [];
    shape.fid.label = lab;
    shape.fid.pos = pos;
    
  case 'asa_elc'
    elec = ft_read_sens(filename);
    
    shape.fid.pos   = elec.chanpos;
    shape.fid.label = elec.label;
    
    npos = read_asa(filename, 'NumberHeadShapePoints=', '%d');
    if ~isempty(npos) && npos>0
      origunit = read_asa(filename, 'UnitHeadShapePoints', '%s', 1);
      pos = read_asa(filename, 'HeadShapePoints', '%f', npos, ':');
      pos = ft_scalingfactor(origunit, 'mm')*pos;
      
      shape.pos = pos;
    end
    
  case 'neuromag_mesh'
    fid = fopen_or_error(filename, 'rt');
    npos = fscanf(fid, '%d', 1);
    pos = fscanf(fid, '%f', [6 npos])';
    ntri = fscanf(fid, '%d', 1);
    tri = fscanf(fid, '%d', [3 ntri])';
    fclose(fid);
    
    shape.pos = pos(:,1:3); % vertex positions
    shape.nrm = pos(:,4:6); % vertex normals
    shape.tri = tri;
    
  otherwise
    % try reading it from an electrode of volume conduction model file
    success = false;
    
    if ~success
      % try reading it as electrode positions
      % and treat those as fiducials
      try
        elec = ft_read_sens(filename);
        if ~ft_senstype(elec, 'eeg')
          ft_error('headshape information can not be read from MEG gradiometer file');
        else
          shape.fid.pos   = elec.chanpos;
          shape.fid.label = elec.label;
          success = 1;
        end
      catch
        success = false;
      end % try
    end
    
    if ~success
      % try reading it as volume conductor
      % and treat the skin surface as headshape
      try
        headmodel = ft_read_headmodel(filename);
        if ~ft_headmodeltype(headmodel, 'bem')
          ft_error('skin surface can only be extracted from boundary element model');
        else
          if ~isfield(headmodel, 'skin')
            headmodel.skin = find_outermost_boundary(headmodel.bnd);
          end
          shape.pos = headmodel.bnd(headmodel.skin).pos;
          shape.tri = headmodel.bnd(headmodel.skin).tri; % also return the triangulation
          success = 1;
        end
      catch
        success = false;
      end % try
    end
    
    if ~success
      ft_error('unknown fileformat "%s" for head shape information', fileformat);
    end
end % switch fileformat

if isfield(shape, 'label')
  % ensure that it is a column
  shape.label = shape.label(:);
end

if isfield(shape, 'fid') && isfield(shape.fid, 'label')
  % ensure that it is a column
  shape.fid.label = shape.fid.label(:);
end

% this will add the units to the head shape and optionally convert
if ~isempty(unit)
  shape = ft_convert_units(shape, unit);
else
  try
    % ft_determine_units will fail for triangle-only gifties.
    shape = ft_determine_units(shape);
  end
end

% ensure that vertex positions are given in pos, not in pnt
shape = fixpos(shape);

% ensure that the numerical arrays are represented in double precision and not as integers
shape = ft_struct2double(shape);
end
                                                                                                                                                                     )
            for iSens = length(hdr.label)+1 : orig.signal(1).blockhdr(1).nsignals + orig.signal(2).blockhdr(1).nsignals
              hdr.label{iSens} = ['s2_unknown', num2str(iSens)];
            end
          else
            ft_warning('found more lables in xml.pnsSet than channels in signal 2, thus can not use info in pnsSet, and labeling with s2_eN instead')
            for iSens = orig.signal(1).blockhdr(1).nsignals+1 : orig.signal(1).blockhdr(1).nsignals + orig.signal(2).blockhdr(1).nsignals
              hdr.label{iSens} = ['s2_E', num2str(iSens)];
            end
          end
        else % signal2 is not PIBbox
          ft_warning('creating channel labels for signal 2 on the fly')
          for iSens = 1:orig.signal(2).blockhdr(1).nsignals
            hdr.label{end+1} = ['s2_E', num2str(iSens)];
          end
        end
      elseif length(orig.signal) > 2
        % loop over signals and label channels accordingly
        ft_warning('creating channel labels for signal 2 to signal N on the fly')
        for iSig = 2:length(orig.signal)
          for iSens = 1:orig.signal(iSig).blockhdr(1).nsignals
            if iSig == 1 && iSens == 1
              hdr.label{1} = ['s',num2str(iSig),'_E', num2str(iSens)];
            else
              hdr.label{end+1} = ['s',num2str(iSig),'_E', num2str(iSens)];
            end
          end
        end
      end
    else % no xml.sensorLayout present
      ft_warning('no sensorLayout found in xml files, creating channel labels on the fly')
      for iSig = 1:length(orig.signal)
        for iSens = 1:orig.signal(iSig).blockhdr(1).nsignals
          if iSig == 1 && iSens == 1
            hdr.label{1} = ['s',num2str(iSig),'_E', num2str(iSens)];
          else
            hdr.label{end+1} = ['s',num2str(iSig),'_E', num2str(iSens)];
          end
        end
      end
    end
    
    % check if multiple epochs are present
    if isfield(orig.xml,'epochs')
      % add info to header about which sample correspond to which epochs, becasue this is quite hard for user to get...
      epochdef = zeros(length(orig.xml.epochs),3);
      for iEpoch = 1:length(orig.xml.epochs)
        if iEpoch == 1
          epochdef(iEpoch,1) = round(str2double(orig.xml.epochs(iEpoch).epoch.beginTime)./(1000000./hdr.Fs))+1;
          epochdef(iEpoch,2) = round(str2double(orig.xml.epochs(iEpoch).epoch.endTime  )./(1000000./hdr.Fs));
          epochdef(iEpoch,3) = round(str2double(orig.xml.epochs(iEpoch).epoch.beginTime)./(1000000./hdr.Fs)); % offset corresponds to timing
        else
          NbSampEpoch = round(str2double(orig.xml.epochs(iEpoch).epoch.endTime)./(1000000./hdr.Fs) - str2double(orig.xml.epochs(iEpoch).epoch.beginTime)./(1000000./hdr.Fs));
          epochdef(iEpoch,1) = epochdef(iEpoch-1,2) + 1;
          epochdef(iEpoch,2) = epochdef(iEpoch-1,2) + NbSampEpoch;
          epochdef(iEpoch,3) = round(str2double(orig.xml.epochs(iEpoch).epoch.beginTime)./(1000000./hdr.Fs)); % offset corresponds to timing
        end
      end
      
      if epochdef(end,2) ~= hdr.nSamples
        % check for NS 4.5.4 picosecond timing
        if (epochdef(end,2)/1000) == hdr.nSamples
          for iEpoch=1:size(epochdef,1)
            epochdef(iEpoch,1) = ((epochdef(iEpoch,1)-1)/1000)+1;
            epochdef(iEpoch,2) = epochdef(iEpoch,2)/1000;
            epochdef(iEpoch,3) = epochdef(iEpoch,3)/1000;
          end
          ft_warning('mff apparently generated by NetStation 4.5.4.  Adjusting time scale to microseconds from nanoseconds.');
        else
          ft_error('number of samples in all epochs do not add up to total number of samples')
        end
      end
      
      epochLengths = epochdef(:,2)-epochdef(:,1)+1;
      if ~any(diff(epochLengths))
        hdr.nSamples = epochLengths(1);
        hdr.nTrials  = length(epochLengths);
        
      else
        ft_warning('the data contains multiple epochs with variable length, possibly causing discontinuities in the data')
        % sanity check
        if epochdef(end,2) ~= hdr.nSamples
          % check for NS 4.5.4 picosecond timing
          if (epochdef(end,2)/1000) == hdr.nSamples
            for iEpoch=1:size(epochdef,1)
              epochdef(iEpoch,1)=((epochdef(iEpoch,1)-1)/1000)+1;
              epochdef(iEpoch,2)=epochdef(iEpoch,2)/1000;
              epochdef(iEpoch,3)=epochdef(iEpoch,3)/1000;
            end
            disp('mff apparently generated by NetStation 4.5.4.  Adjusting time scale to microseconds from nanoseconds.');
          else
            ft_error('number of samples in all epochs do not add up to total number of samples')
          end
        end
      end
      orig.epochdef = epochdef;
    end
    hdr.orig = orig;
    
  case 'egi_mff_v2'
    % ensure that the EGI_MFF_V2 toolbox is on the path
    ft_hastoolbox('egi_mff_v2', 1);
    
    %%%%%%%%%%%%%%%%%%%%%%
    %workaround for MATLAB bug resulting in global variables being cleared
    globalTemp=cell(0);
    globalList=whos('global');
    varList=whos;
    for i=1:length(globalList)
      eval(['global ' globalList(i).name ';']);
      eval(['globalTemp{end+1}=' globalList(i).name ';']);
    end
    %%%%%%%%%%%%%%%%%%%%%%
    
    % ensure that the JVM is running and the jar file is on the path
    mff_setup;
    
    %%%%%%%%%%%%%%%%%%%%%%
    %workaround for MATLAB bug resulting in global variables being cleared
    varNames={varList.name};
    for i=1:length(globalList)
      eval(['global ' globalList(i).name ';']);
      eval([globalList(i).name '=globalTemp{i};']);
      if ~any(strcmp(globalList(i).name,varNames)) %was global variable originally out of scope?
        eval(['clear ' globalList(i).name ';']); %clears link to global variable without affecting it
      end
    end
    clear globalTemp globalList varNames varList;
    %%%%%%%%%%%%%%%%%%%%%%
    
    if isunix && filename(1)~=filesep
      % add the full path to the dataset directory
      filename = fullfile(pwd, filename);
    elseif ispc && ~any(strcmp(filename(2),{':','\'}))
      % add the full path, including drive letter or slashes as needed.
      filename = fullfile(pwd, filename);
    end
    
    hdr = read_mff_header(filename);
    
  case {'egi_mff_v3' 'egi_mff'} % this is the default
    ft_hastoolbox('mffmatlabio', 1);
    hdr = mff_fileio_read_header(filename);
    
  case 'fcdc_buffer'
    % read from a networked buffer for realtime analysis
    [host, port] = filetype_check_uri(filename);
    
    if retry
      orig = [];
      while isempty(orig)
        try
          % try reading the header, catch the error and retry
          orig = buffer('get_hdr', [], host, port);
        catch
          ft_warning('could not read header from %s, retrying in 1 second', filename);
          pause(1);
        end
      end % while
    else
      % try reading the header only once, give error if it fails
      orig = buffer('get_hdr', [], host, port);
    end % if retry
    
    % construct the standard header elements
    hdr.Fs          = orig.fsample;
    hdr.nChans      = orig.nchans;
    hdr.nSamples    = orig.nsamples;
    hdr.nSamplesPre = 0;  % since continuous
    hdr.nTrials     = 1;  % since continuous
    hdr.orig        = []; % this will contain the chunks (if present)
    
    % add the contents of attached NEUROMAG_HEADER chunk after decoding to MATLAB structure
    if isfield(orig, 'neuromag_header')
      if isempty(cachechunk)
        % this only needs to be decoded once
        cachechunk = decode_fif(orig);
      end
      
      % convert to FieldTrip format header
      hdr.label       = cachechunk.ch_names(:);
      hdr.nChans      = cachechunk.nchan;
      hdr.Fs          = cachechunk.sfreq;
      
      % add a gradiometer structure for forward and inverse modelling
      try
        [grad, elec] = mne2grad(cachechunk, true, coilaccuracy); % the coordsys is 'dewar'
        if ~isempty(grad)
          hdr.grad = grad;
        end
        if ~isempty(elec)
          hdr.elec = elec;
        end
      catch
        disp(lasterr);
      end
      
      % store the original details
      hdr.orig = cachechunk;
    end
    
    % add the contents of attached CTF_RES4 chunk after decoding to MATLAB structure
    if isfield(orig, 'ctf_res4')
      if isempty(cachechunk)
        % this only needs to be decoded once
        cachechunk = decode_res4(orig.ctf_res4);
      end
      % copy the gradiometer details
      hdr.grad = cachechunk.grad;
      hdr.orig = cachechunk.orig;
      if isfield(orig, 'channel_names')
        % get the same selection of channels from the two chunks
        [selbuf, selres4] = match_str(orig.channel_names, cachechunk.label);
        if length(selres4)<length(orig.channel_names)
          ft_error('the res4 chunk did not contain all channels')
        end
        % copy some of the channel details
        hdr.label     = cachechunk.label(selres4);
        hdr.chantype  = cachechunk.chantype(selres4);
        hdr.chanunit  = cachechunk.chanunit(selres4);
        % add the channel names chunk as well
        hdr.orig.channel_names = orig.channel_names;
      end
      % add the raw chunk as well
      hdr.orig.ctf_res4 = orig.ctf_res4;
    end
    
    % add the contents of attached NIFTI_1 chunk after decoding to MATLAB structure
    if isfield(orig, 'nifti_1')
      hdr.nifti_1 = decode_nifti1(orig.nifti_1);
      % add the raw chunk as well
      hdr.orig.nifti_1 = orig.nifti_1;
    end
    
    % add the contents of attached SiemensAP chunk after decoding to MATLAB structure
    if isfield(orig, 'siemensap') && exist('sap2matlab')==3 % only run this if MEX file is present
      hdr.siemensap = sap2matlab(orig.siemensap);
      % add the raw chunk as well
      hdr.orig.siemensap = orig.siemensap;
    end
    
    if ~isfield(hdr, 'label')
      % prevent overwriting the labels that we might have gotten from a RES4 chunk
      if isfield(orig, 'channel_names')
        hdr.label = orig.channel_names;
      else
        hdr.label = cell(hdr.nChans,1);
        if hdr.nChans < 2000 % don't do this for fMRI etc.
          ft_warning('creating fake channel names');        % give this warning only once
          for i=1:hdr.nChans
            hdr.label{i} = sprintf('%d', i);
          end
        else
          ft_warning('skipping fake channel names');        % give this warning only once
          checkUniqueLabels = false;
        end
      end
    end
    
    if ~isfield(hdr, 'chantype')
      % prevent overwriting the chantypes that we might have gotten from a RES4 chunk
      hdr.chantype = cell(hdr.nChans,1);
      if hdr.nChans < 2000 % don't do this for fMRI etc.
        hdr.chantype = repmat({'unknown'}, 1, hdr.nChans);
      end
    end
    
    if ~isfield(hdr, 'chanunit')
      % prevent overwriting the chanunits that we might have gotten from a RES4 chunk
      hdr.chanunit = cell(hdr.nChans,1);
      if hdr.nChans < 2000 % don't do this for fMRI etc.
        hdr.chanunit = repmat({'unknown'}, 1, hdr.nChans);
      end
    end
    
    hdr.orig.bufsize = orig.bufsize;
    
    
  case 'fcdc_buffer_offline'
    [hdr, nameFlag] = read_buffer_offline_header(headerfile);
    switch nameFlag
      case 0
        % no labels generated (fMRI etc)
        checkUniqueLabels = false; % no need to check these
      case 1
        % has generated fake channels
        % give this warning only once
        ft_warning('creating fake channel names');
        checkUniqueLabels = false; % no need to check these
      case 2
        % got labels from chunk, check those
        checkUniqueLabels = true;
    end
    
  case 'fcdc_matbin'
    % this is multiplexed data in a *.bin file, accompanied by a MATLAB file containing the header
    load(headerfile, 'hdr');
    
  case 'fcdc_mysql'
    % check that the required low-level toolbox is available
    ft_hastoolbox('mysql', 1);
    % read from a MySQL server listening somewhere else on the network
    db_open(filename);
    if db_blob
      hdr = db_select_blob('fieldtrip.header', 'msg', 1);
    else
      hdr = db_select('fieldtrip.header', {'nChans', 'nSamples', 'nSamplesPre', 'Fs', 'label'}, 1);
      hdr.label = mxDeserialize(hdr.label);
    end
    
  case 'gtec_hdf5'
    % check that the required low-level toolbox is available
    ft_hastoolbox('gtec', 1);
    % there is only a precompiled *.p reader that reads the whole file at once
    orig = ghdf5read(filename);
    for i=1:numel(orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties)
      lab = orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties(i).ChannelName;
      typ = orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties(1).ChannelType;
      if isnumeric(lab)
        hdr.label{i} = num2str(lab);
      else
        hdr.label{i} = lab;
      end
      if ischar(typ)
        hdr.chantype{i} = lower(typ);
      else
        hdr.chantype{i} = 'unknown';
      end
    end
    hdr.Fs          = orig.RawData.AcquisitionTaskDescription.SamplingFrequency;
    hdr.nChans      = size(orig.RawData.Samples, 1);
    hdr.nSamples    = size(orig.RawData.Samples, 2);
    hdr.nSamplesPre = 0;
    hdr.nTrials     = 1; % assume continuous data, not epoched
    assert(orig.RawData.AcquisitionTaskDescription.NumberOfAcquiredChannels==hdr.nChans, 'inconsistent number of channels');
    % remember the complete data upon request
    if cache
      hdr.orig = orig;
    end
    
  case 'gtec_mat'
    % this is a simple MATLAB format, it contains a log and a names variable
    tmp = load(headerfile);
    log   = tmp.log;
    names = tmp.names;
    
    hdr.label = cellstr(names);
    hdr.nChans = size(log,1);
    hdr.nSamples = size(log,2);
    hdr.nSamplesPre = 0;
    hdr.nTrials = 1; % assume continuous data, not epoched
    
    % compute the sampling frequency from the time channel
    sel = strcmp(hdr.label, 'Time');
    time = log(sel,:);
    
    hdr.Fs = 1./(time(2)-time(1));
    
    % also remember the complete data upon request
    if cache
      hdr.orig.log = log;
      hdr.orig.names = names;
    end
    
  case 'gdf'
    % this requires the biosig toolbox
    ft_hastoolbox('BIOSIG', 1);
    % In the case that the gdf files are written by one of the FieldTrip
    % realtime applications, such as biosig2ft, the gdf recording can be
    % split over multiple 1GB files. The sequence of files is then
    %   filename.gdf   <- this is the one that should be specified as the filename/dataset
    %   filename_1.gdf
    %   filename_2.gdf
    %   ...
    
    [p, f, x] = fileparts(filename);
    if exist(sprintf('%s_%d%s', fullfile(p, f), 1, x), 'file')
      % there are multiple files, count the number of additional files (excluding the first one)
      count = 0;
      while exist(sprintf('%s_%d%s', fullfile(p, f), count+1, x), 'file')
        count = count+1;
      end
      hdr = read_biosig_header(filename);
      for i=1:count
        hdr(i+1) = read_biosig_header(sprintf('%s_%d%s', fullfile(p, f), i, x));
        % do some sanity checks
        if hdr(i+1).nChans~=hdr(1).nChans
          ft_error('multiple GDF files detected that should be appended, but the channel count is inconsistent');
        elseif hdr(i+1).Fs~=hdr(1).Fs
          ft_error('multiple GDF files detected that should be appended, but the sampling frequency is inconsistent');
        elseif ~isequal(hdr(i+1).label, hdr(1).label)
          ft_error('multiple GDF files detected that should be appended, but the channel names are inconsistent');
        end
      end % for count
      % combine all headers into one
      combinedhdr             = [];
      combinedhdr.Fs          = hdr(1).Fs;
      combinedhdr.nChans      = hdr(1).nChans;
      combinedhdr.nSamples    = sum([hdr.nSamples].*[hdr.nTrials]);
      combinedhdr.nSamplesPre = 0;
      combinedhdr.nTrials     = 1;
      combinedhdr.label       = hdr(1).label;
      combinedhdr.orig        = hdr; % include all individual file details
      hdr = combinedhdr;
      
    else
      % there is only a single file
      hdr = read_biosig_header(filename);
      % the GDF format is always continuous
      hdr.nSamples = hdr.nSamples * hdr.nTrials;
      hdr.nTrials = 1;
      hdr.nSamplesPre = 0;
    end % if single or multiple gdf files
    
  case {'homer_nirs'}
    % Homer files are MATLAB files in disguise
    orig = load(filename, '-mat');
    
    hdr.label       = {};
    hdr.nChans      = size(orig.d,2);
    hdr.nSamples    = size(orig.d,1);
    hdr.nSamplesPre = 0;
    hdr.nTrials     = 1; % assume continuous data, not epoched
    hdr.Fs          = 1/median(diff(orig.t));
    
    % number of wavelengths times sources times detectors
    assert(numel(orig.SD.Lambda)*orig.SD.nSrcs*orig.SD.nDets >= hdr.nChans);
    
    for i=1:hdr.nChans
      hdr.label{i} = num2str(i);
    end
    
    hdr.chantype = repmat({'nirs'}, hdr.nChans, 1);
    hdr.chanunit = repmat({'unknown'}, hdr.nChans, 1);
    
    % convert the measurement configuration details to an optode structure
    try
    end
    hdr.opto = homer2opto(orig.SD);
    
    % keep the header details
    hdr.orig.SD = orig.SD;
    
  case {'itab_raw' 'itab_mhd'}
    % read the full header information frtom the binary header structure
    header_info = read_itab_mhd(headerfile);
    
    % these are the channels that are visible to FieldTrip
    chansel = 1:header_info.nchan;
    
    % convert the header information into a FieldTrip compatible format
    hdr.nChans      = length(chansel);
    hdr.label       = {header_info.ch(chansel).label};
    hdr.label       = hdr.label(:);  % should be column vector
    hdr.Fs          = header_info.smpfq;
    % it will always be continuous data
    hdr.nSamples    = header_info.ntpdata;
    hdr.nSamplesPre = 0; % it is a single continuous trial
    hdr.nTrials     = 1; % it is a single continuous trial
    % keep the original details AND the list of channels as used by FieldTrip
    hdr.orig         = header_info;
    hdr.orig.chansel = chansel;
    % add the gradiometer definition
    hdr.grad         = itab2grad(header_info);
    
  case 'jaga16'
    % this is hard-coded for the Jinga-Hi JAGA16 system with 16 channels
    packetsize = (4*2 + 6*2 + 16*43*2); % in bytes
    % read the first packet
    fid  = fopen_or_error(filename, 'r');
    buf  = fread(fid, packetsize/2, 'uint16');
    fclose(fid);
    
    if buf(1)==0
      % it does not have timestamps, i.e. it is the raw UDP stream
      packetsize = packetsize - 8; % in bytes
      packet     = jaga16_packet(buf(1:(packetsize/2)), false);
    else
      % each packet starts with a timestamp
      packet = jaga16_packet(buf, true);
    end
    
    % determine the number of packets from the file size
    info     = dir(filename);
    npackets = floor((info.bytes)/packetsize/2);
    
    hdr             = [];
    hdr.Fs          = packet.fsample;
    hdr.nChans      = packet.nchan;
    hdr.nSamples    = 43;
    hdr.nSamplesPre = 0;
    hdr.nTrials     = npackets;
    hdr.label       = cell(hdr.nChans,1);
    hdr.chantype    = cell(hdr.nChans,1);
    hdr.chanunit    = cell(hdr.nChans,1);
    for i=1:hdr.nChans
      hdr.label{i} = sprintf('%d', i);
      hdr.chantype{i} = 'eeg';
      hdr.chanunit{i} = 'uV';
    end
    
    % store some low-level details
    hdr.orig.offset     = 0;
    hdr.orig.packetsize = packetsize;
    hdr.orig.packet     = packet;
    hdr.orig.info      