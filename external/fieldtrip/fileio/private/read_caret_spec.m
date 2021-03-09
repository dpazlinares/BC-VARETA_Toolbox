function [spec, headerinfo] = read_caret_spec(specfile)

% READ_CARET_SPEC reads in a caret .spec file.
%
% Use as
%   [spec, headerinfo] = read_caret_spec(specfile)
%
% Output arguments:
%   spec       = structure containing per file type the files listed
%   headerinfo = structure containing the specfile header
%
% The file can be an xml-file or an ascii formatted file

% Copyright (C) 2013, Jan-Mathijs Schoffelen

try,
  % read xml-file that contains a description to a bunch of files
  % belonging together
  ft_hastoolbox('gifti', 1);
  g = xmltree(specfile);
  
  % convert into a structure
  s = convert(g);
  
  if isfield(s, 'FileHeader')
    headerinfo = s.FileHeader;
    spec       = rmfield(s, 'FileHeader');
  else
    headerinfo = [];
    spec       = s;
  end
  
  % process the headerinfo
  if ~isempty(headerinfo)
    if isfield(headerinfo, 'Element')
      tmp = headerinfo.Element;
      tmp2 = struct([]);
      for k = 1:numel(headerinfo.Element)
        tmp2(1).(strrep(headerinfo.Element{k}.Name, '-', '_')) = headerinfo.Element{k}.Value;
      end
      headerinfo = tmp2;
    end
  end
  
  % further process the fields in spec
  f = fieldnames(spec);

  for k = 1:numel(f)
    if isempty(strfind(f{k}, 'study_metadata'))
      if iscell(spec.(f{k}))
        tmp = spec.(f{k});
        tmp2 = {};
        for m = 1:numel(tmp)
          tmpx = tmp{m};
          if isstruct(tmpx)
            fn = fieldnames(tmpx)
            for i = 1:numel(fn)
              tmp2{end+1,1} = tmpx.(fn{i});
            end
          end
        end
        spec.(f{k}) = tmp2;
      elseif isstruct(spec.(f{k}))
        tmp = spec.(f{k});
        fn  = fieldnames(tmp);
        tmp2 = {};
        for m = 1:numel(fn)
          tmp2{end+1,1} = tmp.(fn{m});
        end
        spec.(f{k}) = tmp2;
      else
        % don't know what to do with it
        spec = rmfield(spec, f{k});
      end
    else
      % don't know what to do with it
      spec = rmfield(spec, f{k});
    end
  end
      
catch
  
  % process as ASCII-file
  fid  = fopen_or_error(specfile);
  line = 'some text';
  while isempty(strfind(line, 'EndHeader'))
    line = fgetl(fid);
    if isempty(strfind(line, 'BeginHeader')) && isempty(strfind(line, 'EndHeader'))
      tok = tokenize(line, ' ');
      headerinfo.(strrep(tok{1},'-','_')) = tok{2};
    end
  end
  line = fgetl(fid); % empty line
  
  spec = struct([]);
  while 1
    line = fgetl(fid);
    if ~ischar(line), break, end
    tok = tokenize(line, ' ');
    if ~isempty(tok{1})
    if isfield(spec, tok{1})
      spec(1).(tok{1}){end+1,1} = tok{2};
    else
      spec(1).(tok{1}){1} = tok{2};
    end
    end
  end
  fclose(fid);
end

                                                                                                                                                                                                                                                                                                                                                                                                  s
% NrOfStripElements*4 int  Sequence of strip elements (if NrOfStripElements > 0)


fid = fopen_or_error(filename, 'rb', 'ieee-le');

srf.version_number                                        = fread(fid, 1, 'float');
srf.reserved                                              = fread(fid, 1, 'int'  );
srf.NrOfVertices                                          = fread(fid, 1, 'int'  );
srf.NrOfTriangles                                         = fread(fid, 1, 'int'  );
NrOfVertices  = srf.NrOfVertices;
NrOfTriangles = srf.NrOfTriangles;
srf.MeshCenterX                                           = fread(fid, 1, 'float');
srf.MeshCenterY                                           = fread(fid, 1, 'float');
srf.MeshCenterZ                                           = fread(fid, 1, 'float');
srf.X_coordinates                                         = fread(fid, NrOfVertices, 'float');
srf.Y_coordinates                                         = fread(fid, NrOfVertices, 'float');
srf.Z_coordinates                                         = fread(fid, NrOfVertices, 'float');
srf.X_components                                          = fread(fid, NrOfVertices, 'float');
srf.Y_components                                          = fread(fid, NrOfVertices, 'float');
srf.Z_components                                          = fread(fid, NrOfVertices, 'float');
srf.R_component_of_convex_curvature_color                 = fread(fid, 1, 'float');
srf.G_component_of_convex_curvature_color                 = fread(fid, 1, 'float');
srf.B_component_of_convex_curvature_color                 = fread(fid, 1, 'float');
srf.Alpha_component_of_convex_curvature_color             = fread(fid, 1, 'float');
srf.R_component_of_concave_curvature_color                = fread(fid, 1, 'float');
srf.G_component_of_concave_curvature_color                = fread(fid, 1, 'float');
srf.B_component_of_concave_curvature_color                = fread(fid, 1, 'float');
srf.Alpha_component_of_concave_curvature_color            = fread(fid, 1, 'float');
srf.MeshColor                                             = fread(fid, NrOfVertices, 'int'  );
for i=1:NrOfVertices
  number           = fread(fid, 1, 'int'  );
  srf.neighbour{i} = fread(fid, number, 'int'  );
end
srf.Triangles                                             = fread(fid, [3 NrOfTriangles], 'int'  );
srf.NrOfTriangleStripElements                             = fread(fid, 1, 'int'  );
srf.sequence_of_strip_elements                            = fread(fid, srf.NrOfTriangleStripElements, 'int'  );

fclose(fid);

pnt = [srf.X_coordinates(:) srf.Y_coordinates(:) srf.Z_coordinates(:)];
tri = srf.Triangles' + 1;

                                                                                                                                                                                                                                                                                                                                                                                                                              n = fileSize / hdr.orig.wordsize / hdr.nChans;
  hdr.nSamples = floor(n);
  if hdr.nSamples ~= n
    ft_warning('Size of ''samples'' is not a multiple of the size of one sample');
  end
end

if nameFlag < 2 && hdr.nChans < 2000
  nameFlag = 1; % fake labels generated - these are unique
  for i=1:hdr.nChans
    hdr.label{i} = sprintf('%d', i);
  end
end

                                                                                                                                                           vhdr.NumberOfChannels && ~feof(fid)
      chan_info = fgetl(fid);
      if ~isempty(chan_info)
        impCounter = impCounter+1;
        [chanName,impedances] = strtok(chan_info,':');
        spaceList = strfind(chanName,' ');
        if ~isempty(spaceList)
          chanName = chanName(spaceList(end)+1:end);
        end
        if strfind(chanName,'REF_') == 1 %for situation where there is more than one reference
          refCounter = refCounter+1;
          vhdr.impedances.refChan(refCounter) = impCounter;
          if ~isempty(impedances)
            vhdr.impedances.reference(refCounter) = str2double(impedances(2:end));
          else
            vhdr.impedances.reference(refCounter) = NaN;
          end
        elseif strcmpi(chanName,'ref') %single reference
          refCounter = refCounter+1;
          vhdr.impedances.refChan(refCounter) = impCounter;
          if ~isempty(impedances)
            vhdr.impedances.reference(refCounter) = str2double(impedances(2:end));
          else
            vhdr.impedances.reference(refCounter) = NaN;
          end
        else
          chanCounter = chanCounter+1;
          if ~isempty(impedances)
            vhdr.impedances.channels(chanCounter,1) = str2double(impedances(2:end));
          else
            vhdr.impedances.channels(chanCounter,1) = NaN;
          end
        end
      end
    end
    if ~feof(fid)
      tline='';
      while ~feof(fid) && isempty(tline)
        tline = fgetl(fid);
      end
      if ~isempty(tline)
        if strcmp(tline(1:4),'Ref:')
          refCounter = refCounter+1;
          [chanName,impedances] = strtok(tline,':');
          if ~isempty(impedances)
            vhdr.impedances.reference(refCounter) = str2double(impedances(2:end));
          else
            vhdr.impedances.reference(refCounter) = NaN;
          end
        end
        if strcmpi(tline(1:4),'gnd:')
          [chanName,impedances] = strtok(tline,':');
          vhdr.impedances.ground = str2double(impedances(2:end));
        end
      end
    end
    if ~feof(fid)
      tline='';
      while ~feof(fid) && isempty(tline)
        tline = fgetl(fid);
      end
      if ~isempty(tline)
        if strcmpi(tline(1:4),'gnd:')
          [chanName,impedances] = strtok(tline,':');
          vhdr.impedances.ground = str2double(impedances(2:end));
        end
      end
    end
  end
end
fclose(fid);
                                                                                                                                                                                    t = EDF.HeadLen + (i-1)*epochlength*nchans*3;
    if length(chanindx)==1
      % this is more efficient if only one channel has to be read, e.g. the status channel
      offset = offset + (chanindx-1)*epochlength*3;
      buf = readLowLevel(filename, offset, epochlength); % see below in subfunction
      dat(:,((i-begepoch)*epochlength+1):((i-begepoch+1)*epochlength)) = buf;
    else
      % read the data from all channels and then select the desired channels
      buf = readLowLevel(filename, offset, epochlength*nchans); % see below in subfunction
      buf = reshape(buf, epochlength, nchans);
      dat(:,((i-begepoch)*epochlength+1):((i-begepoch+1)*epochlength)) = buf(:,chanindx)';
    end
  end

  % select the desired samples
  begsample = begsample - (begepoch-1)*epochlength;  % correct for the number of bytes that were skipped
  endsample = endsample - (begepoch-1)*epochlength;  % correct for the number of bytes that were skipped
  dat = dat(:, begsample:endsample);

  % convert from digital to physical values and apply the offset
  calib  = EDF.Cal(chanindx);
  offset = EDF.Off(chanindx);
  for i=1:numel(calib)
    dat(i,:) = calib(i)*dat(i,:) + offset(i);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for reading the 24 bit values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function buf = readLowLevel(filename, offset, numwords)
if offset < 2*1024^3
  % use the external mex file, only works for <2GB
  buf = read_24bit(filename, offset, numwords);
  % this would be the only difference between the bdf and edf implementation
  % buf = read_16bit(filename, offset, numwords);
else
  % use plain matlab, thanks to Philip van der Broek
  fp = fopen(filename,'r','ieee-le');
  status = fseek(fp, offset, 'bof');
  if status
    ft_error(['failed seeking ' filename]);
  end
  [buf,num] = fread(fp,numwords,'bit24=>double');
  fclose(fp);
  if (num<numwords)
    ft_error(['failed opening ' filename]);
    return
  end
end
       )
  data_comp = CONST_COMPRESSED;
else
  data_comp = CONST_UNCOMPRESSED;
end

% Determine number of samples in this block
read_tag_offset_pair(fid,'DATS');
n_samples = fread(fid,1,'*uint32');

% Read DATA tag and offset
[dum,data_block_length] = read_tag_offset_pair(fid,'DATA');
data_block_offset = double(ftell(fid));

% Read data
block_data = zeros(n_samples,n_channels,'double');
switch num2str([data_type data_comp])
  
  case num2str([CONST_INT16 CONST_UNCOMPRESSED])
    % Read int16s, reshape to [n_samples x n_channels], multiply each channel by LSB
    block_data = bsxfun(@times,lsbs', ...
      double(reshape(fread(fid,n_samples*n_channels,'*int16'),[n_samples,n_channels])));
    
  case num2str([CONST_FLOAT CONST_UNCOMPRESSED])
    % Read singles, reshape to [n_samples x n_channels]
    block_data = double(reshape(fread(fid,n_samples*n_channels,'*single'),[n_samples,n_channels]));
    
  case {num2str([CONST_FLOAT CONST_COMPRESSED]),num2str([CONST_INT16 CONST_COMPRESSED])}
    % Compressed data
    for channel_n = 1:n_channels
      prefix_val = fread(fid,1,'*uint8');
      switch prefix_val
        case CONST_NOCOMPRESSION
          % No zlib. No pre-compression. Yes double difference
          % First two elements are int16. Rest are int16.
          block_data(:,channel_n) = double(fread(fid,n_samples,'*int16'));
          % Integrate twice
          block_data(2:end,channel_n) = cumsum(block_data(2:end,channel_n),1);
          block_data(:,channel_n) = cumsum(block_data(:,channel_n),1);
        case CONST_FIRSTSCHEME
          % No zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, first scheme)
          first_2_vals = fread(fid,2,'*int16');
          block_data(:,channel_n) = double(decode_firstscheme(fid,fread(fid,data_block_length-4,'*uint8'), n_samples, first_2_vals));
        case CONST_SECONDSCHEME
          % No zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, second scheme)
          first_2_vals = fread(fid,2,'*int16');
          block_data(:,channel_n) = double(decode_secondscheme(fid,fread(fid,data_block_length-4,'*uint8'), n_samples, first_2_vals));
        case CONST_THIRDSCHEME
          % No zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, third scheme)
          first_2_vals = fread(fid,2,'*int16');
          block_data(:,channel_n) = double(decode_thirdscheme(fid,fread(fid,data_block_length-4,'*uint8'), n_samples, first_2_vals));
        case CONST_NOCOMPRESSION_FIRST2INT
          % No zlib. No pre-compression. Yes double difference
          % First two elements are int32. Rest are int16
          block_data(1:2,channel_n) = double(fread(fid,2,'*int32'));
          block_data(3:end,channel_n) = double(fread(fid,n_samples-2,'*int16'));
          % Integrate twice
          block_data(2:end,channel_n) = cumsum(block_data(2:end,channel_n),1);
          block_data(:,channel_n) = cumsum(block_data(:,channel_n),1);
        case CONST_FIRSTSCHEME_FIRST2INT
          % No zlib. Yes pre-compression. Yes double difference
          % First two elements are int32. Rest are int8 (pre-compressed, first scheme)
          first_2_vals = fread(fid,2,'*int32');
          block_data(:,channel_n) = double(decode_firstscheme(fid,fread(fid,data_block_length-8,'*uint8'), n_samples, first_2_vals));
        case CONST_NOCOMPRESSION_ALLINT
          % No zlib. No pre-compression. Yes double difference
          % First two elements are int32. Rest are int32
          block_data(:,channel_n) = double(fread(fid,n_samples,'*int32'));
          % Integrate twice
          block_data(2:end,channel_n) = cumsum(block_data(2:end,channel_n),1);
          block_data(:,channel_n) = cumsum(block_data(:,channel_n),1);
        case CONST_ZLIB_DD
          % Yes zlib. No pre-compression. Yes double difference
          % First two elements are int16. Rest are int16
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = typecast(buffer_data,'int16');
        case CONST_ZLIB_FIRSTSCHEME
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, first scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_firstscheme(fid,buffer_data(5:end), n_samples, typecast(buffer_data(1:4),'int16')));
        case CONST_ZLIB_SECONDSCHEME
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, second scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_secondscheme(fid,buffer_data(5:end), n_samples, typecast(buffer_data(1:4),'int16')));
        case CONST_ZLIB_THIRDSCHEME
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, third scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_thirdscheme(fid,buffer_data(5:end), n_samples, typecast(buffer_data(1:4),'int16')));
        case CONST_ZLIB_FIRSTSCHEME_FIRST2INT
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int16. Rest are int8 (pre-compressed, first scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_firstscheme(fid,buffer_data(9:end), n_samples, typecast(buffer_data(1:8),'int32')));
        case CONST_ZLIB_SECONDSCHEME_FIRST2INT
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int32. Rest are int8 (pre-compressed, second scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_secondscheme(fid,buffer_data(9:end), n_samples, typecast(buffer_data(1:8),'int32')));
        case CONST_ZLIB_THIRDSCHEME_FIRST2INT
          % Yes zlib. Yes pre-compression. Yes double difference
          % First two elements are int32. Rest are int8 (pre-compressed, third scheme)
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*uint8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = double(decode_thirdscheme(fid,buffer_data(9:end), n_samples, typecast(buffer_data(1:8),'int32')));
        case CONST_ZLIB_DD_ALLINT
          % Yes zlib. No pre-compression. Yes double difference
          % First two elements are int32. Rest are int32
          buffer_len = fread(fid,1,'*uint32');
          buffer_data = fread(fid,buffer_len,'*int8');
          buffer_data = typecast(dunzip(buffer_data),'uint8')';
          block_data(:,channel_n) = typecast(buffer_data,'int32'); 
        otherwise
          current_loc = ftell(fid);
          fclose(fid);
          ft_error('ReadBesaMatlab:ErrorBDATReadPrefixValueUnknownScheme','Unknown scheme  CH:%d  prefix_val:%d  File offset:%d',channel_n,prefix_val,current_loc);
      end
    end
    
    if(strcmp(num2str([data_type data_comp]),num2str([CONST_INT16 CONST_COMPRESSED])))
      % Multiply int16 data by lsbs
      block_data = bsxfun(@times,lsbs',block_data);
    end
end

% Check that expected amout of data was read
if((data_block_offset+double(data_block_length)) ~= ftell(fid))
  ft_warning('ReadBesaMatlab:WarningDidNotReadExactBlockLength','%d bytes off. Read %d bytes from data block. Should have read %d bytes', ...
    (ftell(fid)-data_block_offset)-double(data_block_length),ftell(fid)-data_block_offset,double(data_block_length));
end

function outbuffer = decode_firstscheme(fid, inbuffer, n_samples, first2vals)
% Read data in first scheme

CONST_MESHGRID_VALS_1 = -7:7;
CONST_AB_INT32_RANGE = 241:-1:236; % Reverse order. This is needed to determine n_vals
CONST_AB_INT16_RANGE = 247:-1:242;
CONST_AB_INT8_RANGE  = 254:-1:248;

max_lut_val = numel(CONST_MESHGRID_VALS_1)^2-1; % Any buffer value greater than this is an announcing byte

% Use persistent variable so lookup table does not need to be recomputed each time
persistent firstscheme_lookuptable;
if isempty(firstscheme_lookuptable)
  % Create the lookup grid from -7 to 7 in x and y
  [firstscheme_lookuptable(:,:,1),firstscheme_lookuptable(:,:,2)] = meshgrid(CONST_MESHGRID_VALS_1,CONST_MESHGRID_VALS_1);
  % Reshape the lookup grid to be [1:225 x 1:2]
  firstscheme_lookuptable = reshape(firstscheme_lookuptable,[numel(CONST_MESHGRID_VALS_1)^2 2]);
end

% Initialize outbuffer
outbuffer = zeros(n_samples,1,'int32');

% Fill in the first two values
outbuffer(1:2) = first2vals;

% Find first announcing byte (AB) (value outside of LUT)
ab_idx = find(inbuffer>max_lut_val,1,'first');

last_outbuffer_idx = 2; % first2vals
if isempty(ab_idx)
  % No ABs, just use lookup table for whole inbuffer
  % Get the output from the lookup table
  %   Transpose and then use linear indexing in the output to put all
  %   elements into a 1-d array
  try
    outbuffer((last_outbuffer_idx+1):end) = firstscheme_lookuptable(inbuffer+1); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(firstscheme_lookuptable(inbuffer+1));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [first scheme, no ABs]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

% Loop until out of announcing bytes
possible_abs = inbuffer > max_lut_val;
last_ab_idx = 0;
while ~isempty(ab_idx)
  
  % Fill outbuffer using LUT with all values between the last set of non-encodable values 
  %   and the current set of non-encodable values,
  %   starting at the last filled outbuffer index.
  try
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+2*(ab_idx-last_ab_idx-1))) = ...
      firstscheme_lookuptable(inbuffer((last_ab_idx+1):(ab_idx-1))+1,:); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+2*(ab_idx-last_ab_idx-1))));
      received_samples = numel(firstscheme_lookuptable(inbuffer((last_ab_idx+1):(ab_idx-1))+1,:));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [first scheme, middle of buffer]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
  last_outbuffer_idx = (last_outbuffer_idx+2*(ab_idx-last_ab_idx-1));
  
  if(any(CONST_AB_INT32_RANGE == inbuffer(ab_idx)))
    % AB indicates int32
    n_vals = find(CONST_AB_INT32_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals*4; % x4 for int32
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int32');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  elseif(any(CONST_AB_INT16_RANGE == inbuffer(ab_idx)))
    % AB indicates int16
    n_vals = find(CONST_AB_INT16_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals*2; % x2 for int16
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int16');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  elseif(any(CONST_AB_INT8_RANGE == inbuffer(ab_idx)))
    % AB indicates int8
    n_vals = find(CONST_AB_INT8_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals; % x1 for int8
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int8');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  else
    % not an alowed announcing byte value
    fclose(fid);
    ft_error('ReadBesaMatlab:ErrorABOutOfRange','Announcing byte out of range: %d',inbuffer(ab_idx));
  end
  
  % Go to next AB
  ab_idx = last_ab_idx + find(possible_abs((last_ab_idx+1):end),1,'first'); % Note: X+[]=[]
  
end

if(last_ab_idx<numel(inbuffer))
  % Fill outbuffer using LUT with all values after the last set of non-encodable values
  %   starting at the last filled outbuffer index.
  try
    outbuffer((last_outbuffer_idx+1):end) = ...
      firstscheme_lookuptable(inbuffer((last_ab_idx+1):end)+1,:); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(firstscheme_lookuptable(inbuffer((last_ab_idx+1):end)+1,:));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [first scheme, end of buffer]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

% Integrate twice
outbuffer(2:end) = cumsum(outbuffer(2:end));
outbuffer = cumsum(outbuffer);

function outbuffer = decode_secondscheme(fid, inbuffer, n_samples, first2vals)
% Decode second scheme

CONST_MESHGRID_VALS_2A = -2:2;
CONST_MESHGRID_VALS_2B = -5:5;
CONST_AB_INT16_RANGE = 249:-1:246; % Reverse order. This is needed to determine n_vals
CONST_AB_INT8_RANGE  = 254:-1:250;
meshgrid_vals.A = CONST_MESHGRID_VALS_2A;
meshgrid_vals.B = CONST_MESHGRID_VALS_2B;

max_lut_val = numel(CONST_MESHGRID_VALS_2A)^3 + numel(CONST_MESHGRID_VALS_2B)^2 - 1; % Any buffer value greater than this is an announcing byte

% Initialize outbuffer
outbuffer = zeros(n_samples,1,'int32');

% Fill in the first two values
outbuffer(1:2) = first2vals;

% Find first announcing byte (AB) (value outside of LUT)
ab_idx = find(inbuffer>max_lut_val,1,'first');

last_outbuffer_idx = 2; % first2vals
if isempty(ab_idx)
  % No ABs, just use lookup table for whole inbuffer
  % Get the output from the lookup table
  try
    outbuffer((last_outbuffer_idx+1):end) = secondscheme_lookup(inbuffer+1,meshgrid_vals); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(secondscheme_lookup(inbuffer+1,meshgrid_vals));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [second scheme, no ABs]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

% Loop until out of announcing bytes
possible_abs = inbuffer > max_lut_val;
last_ab_idx = 0;
while ~isempty(ab_idx)
  
  % Fill outbuffer using LUT with all values between the last set of non-encodable values 
  %   and the current set of non-encodable values,
  %   starting at the last filled outbuffer index.
  % No error checking, because we don't know how long it should be
  decoded_buffer = secondscheme_lookup(inbuffer((last_ab_idx+1):(ab_idx-1))+1,meshgrid_vals); % Plus 1 because indices start at 0
  outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+numel(decoded_buffer))) = ...
    decoded_buffer;
  last_outbuffer_idx = (last_outbuffer_idx+numel(decoded_buffer));
  clear decoded_buffer;
  
  if(any(CONST_AB_INT16_RANGE == inbuffer(ab_idx)))
    % AB indicates int16
    n_vals = find(CONST_AB_INT16_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals*2; % x2 for int16
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int16');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  elseif(any(CONST_AB_INT8_RANGE == inbuffer(ab_idx)))
    % AB indicates int8
    n_vals = find(CONST_AB_INT8_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals; % x1 for int8
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int8');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  else
    % not an allowed announcing byte value
    fclose(fid);
    ft_error('ReadBesaMatlab:ErrorABOutOfRange','Announcing byte out of range [second scheme]: %d',inbuffer(ab_idx));
  end
  
  % Go to next AB
  ab_idx = last_ab_idx + find(possible_abs((last_ab_idx+1):end),1,'first'); % Note: X+[]=[]
  
end

if(last_ab_idx<numel(inbuffer))
  % Fill outbuffer using LUT with all values after the last set of non-encodable values
  %   starting at the last filled outbuffer index.
  try
    outbuffer((last_outbuffer_idx+1):end) = ...
      secondscheme_lookup(inbuffer((last_ab_idx+1):end)+1,meshgrid_vals); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(secondscheme_lookup(inbuffer((last_ab_idx+1):end)+1,meshgrid_vals));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [second scheme, end of buffer]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

function output = secondscheme_lookup(input, meshgrid_vals)
% Lookup table for second scheme

% Use persistent variable so lookup table does not need to be recomputed each time
persistent secondscheme_lookuptable;
if isempty(secondscheme_lookuptable)
  
  % Create the lookup grid from -2 to 2 in x, y, z
  [secondscheme_lookuptable_a(:,:,:,1),secondscheme_lookuptable_a(:,:,:,2),secondscheme_lookuptable_a(:,:,:,3)] = ...
    meshgrid(meshgrid_vals.A,meshgrid_vals.A,meshgrid_vals.A);
  % Reshape the lookup grid to be [1:125 x 1:3]
  secondscheme_lookuptable_a = reshape(secondscheme_lookuptable_a,[numel(meshgrid_vals.A)^3 3]);
  % Correct order of x,y,z
  secondscheme_lookuptable_a(:,[1 2 3]) = secondscheme_lookuptable_a(:,[3 1 2]);
  
  % Create the lookup grid from -5 to 5 in x and y
  [secondscheme_lookuptable_b(:,:,1),secondscheme_lookuptable_b(:,:,2)] = meshgrid(meshgrid_vals.B,meshgrid_vals.B);
  % Reshape the lookup grid to be [1:121 x 1:2]
  secondscheme_lookuptable_b = reshape(secondscheme_lookuptable_b,[numel(meshgrid_vals.B)^2 2]);
  
  % Put the lookup tables together in a cell-array (because of different sized cells)
  secondscheme_lookuptable = num2cell(secondscheme_lookuptable_a,2);
  secondscheme_lookuptable = [secondscheme_lookuptable; num2cell(secondscheme_lookuptable_b,2)];
  
  clear secondscheme_lookuptable_a;
  clear secondscheme_lookuptable_b;
end

output_cell = secondscheme_lookuptable(input);
output = [output_cell{:}];

function outbuffer = decode_thirdscheme(fid, inbuffer, n_samples, first2vals)
% Decode third scheme

CONST_MESHGRID_VALS_3A = -1:1;
CONST_MESHGRID_VALS_3B = -6:6;
CONST_AB_INT16_RANGE = 251:-1:250; % Reverse order. This is needed to determine n_vals
CONST_AB_INT8_RANGE  = 254:-1:252;
meshgrid_vals.A = CONST_MESHGRID_VALS_3A;
meshgrid_vals.B = CONST_MESHGRID_VALS_3B;

max_lut_val = numel(CONST_MESHGRID_VALS_3A)^4 + numel(CONST_MESHGRID_VALS_3B)^2 - 1; % Any buffer value greater than this is an announcing byte

% Initialize outbuffer
outbuffer = zeros(n_samples,1,'int32');

% Fill in the first two values
outbuffer(1:2) = first2vals;

% Find first announcing byte (AB) (value outside of LUT)
ab_idx = find(inbuffer>max_lut_val,1,'first');

last_outbuffer_idx = 2; % first2vals
if isempty(ab_idx)
  % No ABs, just use lookup table for whole inbuffer
  % Get the output from the lookup table
  try
    outbuffer((last_outbuffer_idx+1):end) = thirdscheme_lookup(inbuffer+1,meshgrid_vals); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(thirdscheme_lookup(inbuffer+1,meshgrid_vals));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [third scheme, no ABs]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

% Loop until out of announcing bytes
possible_abs = inbuffer > max_lut_val;
last_ab_idx = 0;
while ~isempty(ab_idx)
  
  % Fill outbuffer using LUT with all values between the last set of non-encodable values 
  %   and the current set of non-encodable values,
  %   starting at the last filled outbuffer index.
  % No error checking, because we don't know how long it should be
  decoded_buffer = thirdscheme_lookup(inbuffer((last_ab_idx+1):(ab_idx-1))+1,meshgrid_vals); % Plus 1 because indices start at 0
  outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+numel(decoded_buffer))) = ...
    decoded_buffer;
  last_outbuffer_idx = (last_outbuffer_idx+numel(decoded_buffer));
  clear decoded_buffer;
  
  if(any(CONST_AB_INT16_RANGE == inbuffer(ab_idx)))
    % AB indicates int16
    n_vals = find(CONST_AB_INT16_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals*2; % x2 for int16
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int16');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  elseif(any(CONST_AB_INT8_RANGE == inbuffer(ab_idx)))
    % AB indicates int8
    n_vals = find(CONST_AB_INT8_RANGE==inbuffer(ab_idx),1);
    n_skip = n_vals; % x1 for int8
    % Fill outbuffer with n_vals
    outbuffer((last_outbuffer_idx+1):(last_outbuffer_idx+n_vals)) = typecast(inbuffer((ab_idx+1):(ab_idx+n_skip)),'int8');
    last_outbuffer_idx = last_outbuffer_idx+n_vals;
    last_ab_idx = ab_idx+n_skip;
  else
    % not an allowed announcing byte value
    fclose(fid);
    ft_error('ReadBesaMatlab:ErrorABOutOfRange','Announcing byte out of range [third scheme]: %d',inbuffer(ab_idx));
  end
  
  % Go to next AB
  ab_idx = last_ab_idx + find(possible_abs((last_ab_idx+1):end),1,'first'); % Note: X+[]=[]
  
end

if(last_ab_idx<numel(inbuffer))
  % Fill outbuffer using LUT with all values after the last set of non-encodable values
  %   starting at the last filled outbuffer index.
  try
    outbuffer((last_outbuffer_idx+1):end) = ...
      thirdscheme_lookup(inbuffer((last_ab_idx+1):end)+1,meshgrid_vals); % Plus 1 because indices start at 0
  catch ME
    if(strcmp(ME.identifier,'MATLAB:subsassignnumelmismatch'))
      expected_samples = numel(outbuffer((last_outbuffer_idx+1):end));
      received_samples = numel(thirdscheme_lookup(inbuffer((last_ab_idx+1):end)+1,meshgrid_vals));
      fclose(fid);
      ft_error('ReadBesaMatlab:ErrorUnexpectedNSamplesFromPreCompression','Expected %d samples, but got %d samples. [third scheme, end of buffer]', ...
        expected_samples,received_samples);
    else
      rethrow(ME);
    end
  end
end

function output = thirdscheme_lookup(input, meshgrid_vals)
% Lookup table for third scheme

% Use persistent variable so lookup table does not need to be recomputed each time
persistent thirdscheme_lookuptable;
if isempty(thirdscheme_lookuptable)
  
  % Create the lookup grid from -1 to 1 in x, y, z, c
  [thirdscheme_lookuptable_a(:,:,:,:,1),thirdscheme_lookuptable_a(:,:,:,:,2),thirdscheme_lookuptable_a(:,:,:,:,3),thirdscheme_lookuptable_a(:,:,:,:,4)] = ...
    ndgrid(meshgrid_vals.A);
  % Reshape the lookup grid to be [1:81 x 1:4]
  thirdscheme_lookuptable_a = reshape(thirdscheme_lookuptable_a,[numel(meshgrid_vals.A)^4 4]);
  % Correct order of x,y,z,c
  thirdscheme_lookuptable_a(:,[1 2 3 4]) = thirdscheme_lookuptable_a(:,[4 3 2 1]);
  
  % Create the lookup grid from -6 to 6 in x and y
  [thirdscheme_lookuptable_b(:,:,1),thirdscheme_lookuptable_b(:,:,2)] = meshgrid(meshgrid_vals.B,meshgrid_vals.B);
  % Reshape the lookup grid to be [1:169 x 1:2]
  thirdscheme_lookuptable_b = reshape(thirdscheme_lookuptable_b,[numel(meshgrid_vals.B)^2 2]);
  
  % Put the lookup tables together in a cell-array (because of different sized cells)
  thirdscheme_lookuptable = num2cell(thirdscheme_lookuptable_a,2);
  thirdscheme_lookuptable = [thirdscheme_lookuptable; num2cell(thirdscheme_lookuptable_b,2)];
  
  clear thirdscheme_lookuptable_a;
  clear thirdscheme_lookuptable_b;
end

output_cell = thirdscheme_lookuptable(input);
output = [output_cell{:}];


%% HELPER FUNCTIONS

function M = dunzip(Z)
% DUNZIP - decompress gzipped stream of bytes
% FORMAT M = dzip(Z)
% Z  -  compressed variable to decompress (uint8 vector)
% M  -  decompressed output
% 
% See also DZIP

% Carefully tested, but no warranty; use at your own risk.
% Michael Kleder, Nov 2005
% Modified by Guillaume Flandin, May 2008

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier
a   = java.io.ByteArrayInputStream(Z);
b   = java.util.zip.InflaterInputStream(a);
isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
c   = java.io.ByteArrayOutputStream;
isc.copyStream(b,c);
M   = c.toByteArray;

function [out_tag, out_offset] = read_tag_offset_pair(fid,expected_tag)
% Read 4 bytes and check if they match expected value
out_tag = fread(fid,4,'*char')';
if(nargin>1)
  % Compare tag with expected tag
  if ~strcmp(expected_tag,out_tag)
    curr_offset = ftell(fid);
    fclose(fid);
    ft_error('ReadBesaMatlab:ErrorTagMismatch','Expecting [%s] but read [%s] at offset %d',expected_tag,out_tag,curr_offset);
  end
end
% Read offset value following tag
out_offset = fread(fid,1,'*uint32');


function [header] = read_besa_besa_header(fname)
% READ_BESA_BESA_HEADER reads header information from a BESA fileheader and skips data

%% Open file
fid = fopen_or_error(fname,'r');

% Get length of file
fseek(fid,0,'eof');
file_length = ftell(fid);
fseek(fid,0,'bof');

%% Header Block
[dum,ofst_BCF1] = read_tag_offset_pair(fid,'BCF1');

% Read data in header block
while ~feof(fid) && ftell(fid) < (8+ofst_BCF1) % 8 for header tag ('BCF1') and header offset (uint32)
  [current_tag,current_length] = read_tag_offset_pair(fid);
  switch current_tag
    case 'VERS'
      % File version
      header.orig.file_info.besa_file_version = read_chars(fid,current_length);
    case 'OFFM'
      % Index of first 'file main info' block (BFMI)
      BFMI_offset = fread(fid,1,'*int64');
    case 'OFTL'
      % Index of first 'tag list' block (BTAG)
      BTAG_offset = fread(fid,1,'*int64');
    case 'OFBI'
      % Index of first 'channel and location' block (BCAL)
      BCAL_offset = fread(fid,1,'*int64');
    otherwise
      % Unrecognzed tag. Try to skip forward by offset
      ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
      if((ftell(fid)+current_length) <= file_length)
        if(fseek(fid,current_length,'cof') == -1)
          fclose(fid);
          ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in header block [BCF1]))',current_length);
        end
      else
        fclose(fid);
        ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
      end
  end
  
end

% Check for necessary header data
if ~exist('BFMI_offset','var')
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorNoHeaderBFMI','No BFMI block found in header');
end
if ~exist('BTAG_offset','var')
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorNoHeaderBTAG','No BTAG block found in header');
end
if ~exist('BCAL_offset','var')
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorNoHeaderBCAL','No BCAL block found in header');
end

%% 'tag list' blocks
header.orig.tags.next_BTAG_ofst = BTAG_offset;
header.orig.tags.offsets = [];
header.orig.tags.n_tags = 0;
% Keep reading until no more BTAG blocks
while header.orig.tags.next_BTAG_ofst > 0
  header.orig.tags = read_BTAG(fid, file_length, header.orig.tags);
end
header.orig.tags = rmfield(header.orig.tags,'next_BTAG_ofst');

% Check that file is not much shorter than expected
%  This does not take into account length of final block but might still be useful
if(file_length <= header.orig.tags.tags.position(end))
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorFileTooShort','Expected file at least %d bytes long but file is %d bytes long',header.orig.tags.tags(end).position,file_length);
end

%% 'file main info' blocks
header.orig.file_info.next_BFMI_ofst = BFMI_offset;
header.orig.file_info.offsets = [];
% Keep reading until no more BFMI blocks
while header.orig.file_info.next_BFMI_ofst > 0
  header.orig.file_info = read_BFMI(fid, file_length, header.orig.file_info);
end
header.orig.file_info = rmfield(header.orig.file_info,'next_BFMI_ofst');
% NEED TO IMPLEMENT OVERWRITES %%%%%%%%%%%%%%%%%%%%%%%%%%% TODO

%% 'channel and location' blocks
header.orig.channel_info.next_BCAL_ofst = BCAL_offset;
header.orig.channel_info.offsets = [];
% Keep reading until no more BCAL blocks
while header.orig.channel_info.next_BCAL_ofst > 0
  header.orig.channel_info = read_BCAL(fid, file_length, header.orig.channel_info);
end
header.orig.channel_info = rmfield(header.orig.channel_info,'next_BCAL_ofst');
% NEED TO IMPLEMENT OVERWRITES %%%%%%%%%%%%%%%%%%%%%%%%%%% TODO

if ~isfield(header.orig.channel_info,'n_channels')
  ft_error('ReadBesaMatlab:ErrorNoHeaderNChannels','Missing number of channels in header [BCAL:CHNR]');
end

% Combine info from channel_info.coord_data and channel_info.channel_states to get actual coordinate data
if(isfield(header.orig.channel_info,'channel_states') && isfield(header.orig.channel_info,'coord_data'))
  for channel_n = 1:header.orig.channel_info.n_channels
    %header.orig.channel_info.channel_locations(channel_n) = [];
    header.orig.channel_info.channel_locations(channel_n).x = NaN;
    header.orig.channel_info.channel_locations(channel_n).y = NaN;
    header.orig.channel_info.channel_locations(channel_n).z = NaN;
    header.orig.channel_info.channel_locations(channel_n).xori = NaN; % Orientation
    header.orig.channel_info.channel_locations(channel_n).yori = NaN;
    header.orig.channel_info.channel_locations(channel_n).zori = NaN;
    header.orig.channel_info.channel_locations(channel_n).x2 = NaN; % Second coil
    header.orig.channel_info.channel_locations(channel_n).y2 = NaN;
    header.orig.channel_info.channel_locations(channel_n).z2 = NaN;
    if( header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_SCALPELECTRODE || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MAGNETOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_AXIAL_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_PLANAR_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MEGREFERENCE )
      header.orig.channel_info.channel_locations(channel_n).x = double(header.orig.channel_info.coord_data(channel_n,1));
      header.orig.channel_info.channel_locations(channel_n).y = double(header.orig.channel_info.coord_data(channel_n,2));
      header.orig.channel_info.channel_locations(channel_n).z = double(header.orig.channel_info.coord_data(channel_n,3));
    end
    if( header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MAGNETOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_AXIAL_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_PLANAR_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MEGREFERENCE )
      header.orig.channel_info.channel_locations(channel_n).xori = double(header.orig.channel_info.coord_data(channel_n,7));
      header.orig.channel_info.channel_locations(channel_n).yori = double(header.orig.channel_info.coord_data(channel_n,8));
      header.orig.channel_info.channel_locations(channel_n).zori = double(header.orig.channel_info.coord_data(channel_n,9));
    end
    if( header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_AXIAL_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_PLANAR_GRADIOMETER || ...
        header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MEGREFERENCE )
      header.orig.channel_info.channel_locations(channel_n).x2 = double(header.orig.channel_info.coord_data(channel_n,4));
      header.orig.channel_info.channel_locations(channel_n).y2 = double(header.orig.channel_info.coord_data(channel_n,5));
      header.orig.channel_info.channel_locations(channel_n).z2 = double(header.orig.channel_info.coord_data(channel_n,6));
    end
    if( header.orig.channel_info.channel_states(channel_n).BSA_CHANTYPE_MEGREFERENCE )
      if( header.orig.channel_info.channel_locations(channel_n).x2==0 && ...
          header.orig.channel_info.channel_locations(channel_n).y2==0 && ...
          header.orig.channel_info.channel_locations(channel_n).z2==0 )
        header.orig.channel_info.channel_locations(channel_n).x2 = NaN;
        header.orig.channel_info.channel_locations(channel_n).y2 = NaN;
        header.orig.channel_info.channel_locations(channel_n).z2 = NaN;
      end
    end
  end
end

%% Events
% Collect event block info
header.orig.events.offsets = header.orig.tags.tags.position(strcmp(header.orig.tags.tags.type,'BEVT'));
header.orig.events.offsets = sort(header.orig.events.offsets, 'ascend'); % Later blocks overwrite matching events
for block_n = 1:numel(header.orig.events.offsets)
  header.orig.events = read_BEVT(fid, file_length, header.orig.events, header.orig.events.offsets(block_n));
end
% NEED TO IMPLEMENT OVERWRITES %%%%%%%%%%%%%%%%%%%%%%%%%%% TODO

%% Reorganize header structure
header.nChans = header.orig.channel_info.n_channels;
if isfield(header.orig.file_info,'s_rate')
  header.Fs = header.orig.file_info.s_rate;
else
  ft_warning('ReadBesaMatlab:WarningMissingHeaderInfo','Missing sample rate in header');
  header.Fs = [];
end
if isfield(header.orig.file_info,'n_samples')
  header.nSamples = header.orig.file_info.n_samples;
else
  ft_warning('ReadBesaMatlab:WarningMissingHeaderInfo','Missing number of samples in header');
  header.nSamples = [];
end

header.nSamplesPre = 0; % Continuous data
header.nTrials     = 1;  % Continuous data

%  Channel labels
if isfield(header.orig.channel_info,'channel_labels')
  header.label = header.orig.channel_info.channel_labels;
else
  ft_warning('ReadBesaMatlab:WarningMissingHeaderInfo','Missing channel labels in header.orig. Creating default channel names');
  for channel_n = 1:header.nChans
    header.label{channel_n} = sprintf('chan%03d', channel_n);
  end
end

%  Channel coordinates
if isfield(header.orig.channel_info,'channel_locations')
  for channel_n = 1:header.nChans
    header.elec.label{channel_n} = header.label{channel_n};
    header.elec.pnt(channel_n,1) = header.orig.channel_info.channel_locations(channel_n).x;
    header.elec.pnt(channel_n,2) = header.orig.channel_info.channel_locations(channel_n).y;
    header.elec.pnt(channel_n,3) = header.orig.channel_info.channel_locations(channel_n).z;
  end
end

function tags = read_BTAG(fid, file_length, tags)
%% Read tag block
% tags [structure] - Existing or blank BTAG structure
%                            Blank needs fields:
%                               next_BTAG_ofst - file offset for BTAG to be read
%                               offsets = []
%                               n_tags = 0
% file_length [scalar] - Length of file in bytes
% fid [scalar] - File identifier

% Skip to start of BTAG section
if(fseek(fid,tags.next_BTAG_ofst,'bof') == -1)
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed [BTAG]',tags.next_BTAG_ofst);
end
tags.offsets(end+1) = tags.next_BTAG_ofst;

% Read BTAG tag and offset
[dum,tag_block_length] = read_tag_offset_pair(fid,'BTAG');

% Untagged offset to next BTAG section
tags.next_BTAG_ofst = fread(fid,1,'*int64');

% Loop through all tags in data section
while ftell(fid) < (uint64(tags.offsets(end))+uint64(tag_block_length))
  [current_tag,current_length] = read_tag_offset_pair(fid);
  switch current_tag
    case 'TAGE'
      % Tag list entry
      tags.n_tags = tags.n_tags+1;
      tags.tags.type{tags.n_tags} = fread(fid,4,'*char')';
      tags.tags.position(tags.n_tags) = fread(fid,1,'*uint64');
      tags.tags.n_samples(tags.n_tags) = double(fread(fid,1,'*uint32'));
    otherwise
      % Unrecognzed tag. Try to skip forward by offset
      ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
      if((ftell(fid)+current_length) <= file_length)
        if(fseek(fid,current_length,'cof') == -1)
          fclose(fid);
          ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in [BTAG]))',current_length);
        end
      else
        fclose(fid);
        ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
      end
  end
end

% Check that expected amout of file was read
expected_length = double(tag_block_length) + 8; % 8 for tag and offset
if((tags.offsets(end)+expected_length) ~= ftell(fid))
  ft_warning('ReadBesaMatlab:WarningDidNotReadExactBlockLength','%d bytes off. Read %d bytes from tag block. Should have read %d bytes', ...
    (ftell(fid)-tags.offsets(end))-expected_length,ftell(fid)-tags.offsets(end),expected_length);
end

function file_info = read_BFMI(fid, file_length, file_info)
%% Read file main info block
% file_info [structure] - Existing or blank BFMI structure
%                            Blank needs fields:
%                               next_BFMI_ofst - file offset for BFMI to be read
%                               offsets = []
% file_length [scalar] - Length of file in bytes
% fid [scalar] - File identifier

% Skip to start of BFMI section
if(fseek(fid,file_info.next_BFMI_ofst,'bof') == -1)
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed [BFMI]',file_info.next_BFMI_ofst);
end
file_info.offsets(end+1) = file_info.next_BFMI_ofst;

% Read BFMI tag and offset
[dum,fileinfo_block_length] = read_tag_offset_pair(fid,'BFMI');

% Untagged offset to next BFMI section
file_info.next_BFMI_ofst = fread(fid,1,'*int64');

% Create staff field if it doesn't exist already. This is necessary because
%   there is no indication of how many staff to expect, so to increment an
%   array, you need an existing array
if(~isfield(file_info,'staff'))
  file_info.staff = [];
end

% Loop through all tags in data section
while ftell(fid) < (uint64(file_info.offsets(end))+uint64(fileinfo_block_length))
  [current_tag,current_length] = read_tag_offset_pair(fid);
  switch current_tag
    case 'SAMT'
      % Total number of samples
      file_info.n_samples = double(fread(fid,1,'*int64'));
    case 'SAMP'
      % Number of samples per second
      file_info.s_rate = fread(fid,1,'*double');
    case 'FINN'
      % Name of the institution
      file_info.institution.name = read_chars(fid,current_length);
    case 'FINA'
      % Address of the institution
      fina_end = ftell(fid)+current_length;
      while ~feof(fid) && ftell(fid) < fina_end
        [current_tag,current_length] = read_tag_offset_pair(fid);
        switch current_tag
          case 'ASTR'
            % Street name
            file_info.institution.street_name = read_chars(fid,current_length);
          case 'ASTA'
            % State
            file_info.institution.state = read_chars(fid,current_length);
          case 'ACIT'
            % City
            file_info.institution.city = read_chars(fid,current_length);
          case 'APOS'
            % Post code
            file_info.institution.post_code = read_chars(fid,current_length);
          case 'ACOU'
            % Country
            file_info.institution.country = read_chars(fid,current_length);
          case 'APHO'
            % Phone number
            file_info.institution.phone_number = read_chars(fid,current_length);
          otherwise
            % Unrecognzed tag. Try to skip forward by offset
            ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
            if((ftell(fid)+current_length) <= file_length)
              if(fseek(fid,current_length,'cof') == -1)
                fclose(fid);
                ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in [BFMI:FINA]))',current_length);
              end
            else
              fclose(fid);
              ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
            end
        end
      end
      clear fina_end;
    case 'FENA'
      % Encryption algorithm
      file_info.encryption = read_chars(fid,current_length);
    case 'FCOA'
      % Compression algorithm
      file_info.compression = read_chars(fid,current_length);
    case 'RECD'
      % Recording start date and time
      file_info.recording_date.start = read_chars(fid,current_length);
    case 'RECE'
      % Recording end date and time
      file_info.recording_date.end = read_chars(fid,current_length);
    case 'RECO'
      % Recording offset to GMT
      file_info.recording_date.gmt_offset = fread(fid,1,'*single');
    case 'RECS'
      % Recording system
      file_info.recording_system.name = read_chars(fid,current_length);
    case 'RIBN'
      % Name of the input box
      file_info.recording_system.info = read_chars(fid,current_length);
    case 'RESW'
      % Name of recording software
      file_info.recording_system.software = read_chars(fid,current_length);
    case 'RATC'
      % Amplifier time constant
      file_info.recording_system.time_constant = fread(fid,1,'*single');
    case 'RSEQ'
      % Sequence number
      file_info.sequence_n = double(fread(fid,1,'*uint32'));
    case 'RSID'
      % Session unique identifier
      file_info.session_id = read_chars(fid,current_length);
    case 'RSNR'
      % Session number
      file_info.sequence_n = double(fread(fid,1,'*int32'));
    case 'RSTC'
      % Study comment
      file_info.comment = read_chars(fid,current_length);
    case 'RSTA'
      % Responsible staff
      % This assumes that, for each staff member, all fields are contiguous
      %   Otherwise, the indices may not line up
      file_info.staff(end+1).name = '';
      file_info.staff(end+1).initials = '';
      file_info.staff(end+1).function = '';
      rsta_end = ftell(fid)+current_length;
      while ~feof(fid) && ftell(fid) < rsta_end
        [current_tag,current_length] = read_tag_offset_pair(fid);
        switch current_tag
          case 'SNAM'
            % Name
            file_info.staff(end).name = read_chars(fid,current_length);
          case 'ASTA'
            % Initials
            file_info.staff(end).initials = read_chars(fid,current_length);
          case 'ACIT'
            % Function
            file_info.staff(end).function = read_chars(fid,current_length);
          otherwise
            % Unrecognzed tag. Try to skip forward by offset
            ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
            if((ftell(fid)+current_length) <= file_length)
              if(fseek(fid,current_length,'cof') == -1)
                fclose(fid);
                ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in [BFMI:RSTA]))',current_length);
              end
            else
              fclose(fid);
              ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
            end
        end
      end
      clear rsta_end;
    case 'PNAF'
      % Subject first name
      file_info.subject.name.first = read_chars(fid,current_length);
    case 'PNAM'
      % Subject middle name
      file_info.subject.name.middle = read_chars(fid,current_length);
    case 'PATN'
      % Subject last name
      file_info.subject.name.last = read_chars(fid,current_length);
    case 'PNAA'
      % Anonymized subject name
      file_info.subject.anon_name = read_chars(fid,current_length);
    case 'PNAT'
      % Subject title
      file_info.subject.title = read_chars(fid,current_length);
    case 'PATD'
      % Subject date of birth
      file_info.subject.birthdate = read_chars(fid,current_length);
    case 'PDOD'
      % Subject date of death
      file_info.subject.deathdate = read_chars(fid,current_length);
    case 'PAGE'
      % Subject gender
      file_info.subject.gender = read_chars(fid,current_length);
    case 'PAWE'
      % Subject weight
      file_info.subject.weight = fread(fid,1,'*single');
    case 'PAHE'
      % Subject height
      file_info.subject.height = fread(fid,1,'*single');
    case 'PAMS'
      % Subject marital status
      file_info.subject.marital_status = read_chars(fid,current_length);
    case 'PAAD'
      % Subject address
      paad_end = ftell(fid)+current_length;
      while ~feof(fid) && ftell(fid) < paad_end
        [current_tag,current_length] = read_tag_offset_pair(fid);
        switch current_tag
          case 'ASTR'
            % Street name
            file_info.subject.address.street_name = read_chars(fid,current_length);
          case 'ASTA'
            % State
            file_info.subject.address.state = read_chars(fid,current_length);
          case 'ACIT'
            % City
            file_info.subject.address.city = read_chars(fid,current_length);
          case 'APOS'
            % Post code
            file_info.subject.address.post_code = read_chars(fid,current_length);
          case 'ACOU'
            % Country
            file_info.subject.address.country = read_chars(fid,current_length);
          case 'APHO'
            % Phone number
            file_info.subject.address.phone_number = read_chars(fid,current_length);
          otherwise
            % Unrecognzed tag. Try to skip forward by offset
            ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
            if((ftell(fid)+current_length) <= file_length)
              if(fseek(fid,current_length,'cof') == -1)
                fclose(fid);
                ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in [BFMI:PAAD]))',current_length);
              end
            else
              fclose(fid);
              ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
            end
        end
      end
      clear paad_end;
    case 'PALA'
      % Subject language
      file_info.subject.language = read_chars(fid,current_length);
    case 'PAMH'
      % Subject medical history
      file_info.subject.medical_history = read_chars(fid,current_length);
    case 'PATC'
      % Subject comment
      file_info.subject.comment = read_chars(fid,current_length);
    case 'PATI'
      % Subject ID
      file_info.subject.id = read_chars(fid,current_length);
    case 'INF1'
      % Additional information 1
      file_info.additional_info.inf1 = read_chars(fid,current_length);
    case 'INF2'
      % Additional information 2
      file_info.additional_info.inf2 = read_chars(fid,current_length);
    otherwise
      % Unrecognzed tag. Try to skip forward by offset
      ft_warning('ReadBesaMatlab:WarningUnexpectedTag','Read unexpected tag [%s] at offset %d',current_tag,ftell(fid));
      if((ftell(fid)+current_length) <= file_length)
        if(fseek(fid,current_length,'cof') == -1)
          fclose(fid);
          ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed (after unexpected tag in [BFMI]))',current_length);
        end
      else
        fclose(fid);
        ft_error('ReadBesaMatlab:ErrorSkippingForwardAfterUnexpectedTag','Offset after unexpected [%d] tag points to beyond eof [%d]',current_length,file_length);
      end
  end
end

% Check that expected amout of file was read
expected_length = double(fileinfo_block_length) + 8; % 8 for tag and offset
if((file_info.offsets(end)+expected_length) ~= ftell(fid))
  ft_warning('ReadBesaMatlab:WarningDidNotReadExactBlockLength','%d bytes off. Read %d bytes from file info block. Should have read %d bytes', ...
    (ftell(fid)-file_info.offsets(end))-expected_length,ftell(fid)-file_info.offsets(end),expected_length);
end

function channel_info = read_BCAL(fid, file_length, channel_info)
%% Read channel info block
% channel_info [structure] - Existing or blank BCAL structure
%                            Blank needs fields:
%                               next_BFMI_ofst - file offset for BCAL to be read
%                               offsets = []
% file_length [scalar] - Length of file in bytes
% fid [scalar] - File identifier

% Skip to start of BCAL section
if(fseek(fid,channel_info.next_BCAL_ofst,'bof') == -1)
  fclose(fid);
  ft_error('ReadBesaMatlab:ErrorFseek','fseek to %d failed [BCAL]',channel_info.next_BCAL_ofst);
end
channel_info.offsets(end+1) = channel_info.next_BCAL_ofst;

% Read BCAL tag and offset
[dum,channel_block_length] = read_tag_offset_pair(fid,'BCAL');

% Untagged offset to next BCAL section
channel_info.next_BCAL_ofst = fread(fid,1,'*int64');

% Loop through all tags in data section
while ftell(fid) < (uint64(channel_info.offsets(end))+uint64(channel_block_length))
  [current_tag,current_length] = read_tag_offset_pair(fid);
  switch current_tag
    case 'CHFL'
      % Channel flag
      channel_info.channel_flags.flag = fread(fid,1,'*uint32');
      channel_info.channel_flags.BSA_ELECTRODE_COORDINATES_FROM_LABELS = logical(bitand(channel_info.channel_flags.flag,uint32(hex2dec('0001')),'uint32'));
      channel_info.channel_flags.BSA_SUPPRESS_SPHERE_TO_ELLIPSOID_TRANSFORMATION = logical(bitand(channel_info.channel_flags.flag,uint32(hex2dec('0002')),'uint32'));
      channel_info.channel_flags.BSA_ELECTRODE_COORDINATES_ON_SPHERE = logical(bitand(channel_info.channel_flags.flag,uint32(hex2dec('0004')),'uint32'));
      channel_info.channel_flags.BSA_ADAPT_SPHERICAL_EEG_TO_MEG_COORDS = logical(bitand(channel_info.channel_flags.flag,uint32(hex2dec('0008')),'uint32'));
      channel_info.channel_flags.BSA_SOURCE_CHANNELS_DERIVED_FROM_MEG = logical(bitand(channel_info.channel_flags.flag,uint32(hex2dec('0010')),'uint32'));
    case 'CHTS'
      % Channel type and states of a channel with the specified index
      channel_n = double(fread(fid,1,'*uint16'))+1; % Plus 1 because index starts at 0
      channel_info.channel_states(channel_n).flag = fread(fid,1,'*uint32');
      channel_info.channel_states(channel_n).BSA_CHANTYPE_UNDEFINED = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00000000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_POLYGRAPHIC = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00010000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_TRIGGER = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00020000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_CORTICALGRID = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00040000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_INTRACRANIAL = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00080000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_SCALPELECTRODE = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00100000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_MAGNETOMETER = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00200000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_AXIAL_GRADIOMETER = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00400000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_PLANAR_GRADIOMETER = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('01000000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_MEGREFERENCE = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00800000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_NKC_REFERENCE = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('02000000')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANTYPE_CHANSTATE_BAD = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00000001')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANSTATE_REFERENCE = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00000002')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANSTATE_INTERPOLRECORDED = logical(bitand(channel_info.channel_states(channel_n).flag,uint32(hex2dec('00000004')),'uint32'));
      channel_info.channel_states(channel_n).BSA_CHANSTATE_INVISIBLE = logical(bitand(c