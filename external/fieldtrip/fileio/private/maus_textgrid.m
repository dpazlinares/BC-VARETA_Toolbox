function [varargout] = maus_textgrid(filename, hdr, begsample, endsample, chanindx)

% MAUS_TEXTGRID reads speech segments from a file that has been processed with MAUS
% see https://clarin.phonetik.uni-muenchen.de/BASWebServices
%
% Use as
%   hdr = maus_textgrid(filename);
%   dat = maus_textgrid(filename, hdr, begsample, endsample, chanindx);
%   evt = maus_textgrid(filename, hdr);
%
% You should pass the *.TextGrid file as the filename, There should be a
% corresponding wav file with the same filename in the same directory.
%
% See also FT_FILETYPE, FT_READ_HEADER, FT_READ_DATA, FT_READ_EVENT, QUALISYS_TSV

% Copyright (C) 2019 Robert Oostenveld
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

needhdr = (nargin==1);
needevt = (nargin==2);
needdat = (nargin==5);

[p, f, x] = fileparts(filename);
wavfile = fullfile(p, [f '.wav']);

if needhdr
  %% return the audio file header
  varargout{1} = ft_read_header(wavfile);
  
elseif needdat
  %% return the audio file data
  varargout{1} = ft_read_data(wavfile, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
  
elseif needevt
  %% return the segmentations in the textgrid file as events
  
  % File type = "ooTextFile"
  % Object class = "TextGrid"
  %
  % xmin = 0
  % xmax = 47.982585
  % tiers? <exists>
  % size = 3
  % item []:
  %     item [1]:
  %         class = "IntervalTier"
  %         name = "ORT-MAU"
  %         xmin = 0
  %         xmax = 47.982585
  %         intervals: size = 120
  %         intervals [1]:
  %             xmin = 0.000000
  %             xmax = 3.570000
  %             text = ""
  %         intervals [2]:
  %             xmin = 3.570000
  %             xmax = 3.730000
  %             text = "Could"
  %         intervals [3]:
  %             xmin = 3.730000
  %             xmax = 3.820000
  %             text = "he"
  %         intervals [4]:
  %             xmin = 3.820000
  %             xmax = 4.030000
  %             text = "not"
  %         intervals [5]:
  %             xmin = 4.030000
  %             xmax = 4.330000
  %             text = "now"
  %         intervals [6]:
  %             xmin = 4.330000
  %             xmax = 4.690000
  %             text = "turn"
  %         intervals [7]:
  %             xmin = 4.690000
  %             xmax = 5.160000
  %             text = "back"
  %         intervals [8]:
  %             xmin = 5.160000
  %             xmax = 5.620000
  %             text = ""
  %         intervals [9]:
  %             xmin = 5.620000
  %             xmax = 6.120000
  %             text = "Acknowledge"
  %         intervals [10]:
  %             xmin = 6.120000
  %             xmax = 6.330000
  %             text = "his"
  %         intervals [11]:
  %             xmin = 6.330000
  %             xmax = 6.620000
  %             text = "error"
  %  ...
  
  
  fid = fopen_or_error(filename, 'rt');
  
  lines = {};
  while ~feof(fid)
    lines = cat(1, lines, fgetl(fid));
  end
  fclose(fid);
  
  % remove empty lines
  lines = lines(~cellfun(@isempty, lines));
  % remove whitespace
  lines = cellfun(@strtrim, lines, 'UniformOutput', false);
  
  Nitem = str2double(getitem(lines, 'size'));
  
  for i=1:Nitem
    [dum, pos] = getitem(lines, sprintf('item [%d]:', i));
    lines = lines(pos:end);
    item(i).class = getitem(lines, 'class');
    item(i).name = getitem(lines, 'name');
    item(i).xmin = str2double(getitem(lines, 'xmin'));
    item(i).xmax = str2double(getitem(lines, 'xmax'));
    item(i).size = str2double(getitem(lines, 'intervals: size'));
    for j=1:item(i).size
      [dum, pos] = getitem(lines, sprintf('intervals [%d]:', j));
      section = lines(pos:pos+3);
      item(i).intervals(j).xmin = str2double(getitem(section, 'xmin'));
      item(i).intervals(j).xmax = str2double(getitem(section, 'xmax'));
      item(i).intervals(j).text = getitem(section, 'text');
    end
  end
  
  k = 1;
  event = [];
  for i=1:numel(item)
    for j=1:numel(item(i).intervals)
      event(k).type     = [item(i).class ' ' item(i).name];
      event(k).value    = item(i).intervals(j).text;
      event(k).sample   = round(item(i).intervals(j).xmin * hdr.Fs) + 1; % the first sample is 1
      event(k).duration = round((item(i).intervals(j).xmax - item(i).intervals(j).xmin) * hdr.Fs);
      event(k).offset   = 0;
      k = k+1;
    end
  end
  
  varargout{1} = event;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val, pos] = getitem(lines, key)
pos = find(startsWith(lines, key), 1, 'first');
pieces = split(lines{pos}, '=');
if numel(pieces)==1
  val = [];
elseif numel(pieces)==2
  val = strtrim(pieces{2});
  val(val=='"') = [];
else
  ft_error('cannot parse string');
end

                                                                                    END_LIST'))
            nc = nc + 1;
            labels(nc) = cellstr(text);
        else 
            break
        end
    end 
end

% read sensor locations from label file
% initialize sensor locations
sensorpos = zeros(3,0);

% scan in cell 1 for SENSORS (occurs four times per channel group)
ix = strfind(cont,[char(10),'SENSORS']);
nt = size(ix,2);
nc = 0;

for i = 4:4:nt                                                      % loop over channel groups
    newlines = ix(i-1) + strfind(cont(ix(i-1)+1:ix(i)),char(10));   % newline
    last = nChannels - nc;
    for j = 1:min(last,size(newlines,2)-1)                          % loop over labels
        text = cont(newlines(j)+1:newlines(j+1)-1);
        if isempty(strfind(text,'END_LIST'))
            nc = nc + 1;
            tcell = textscan(text,'%f');                           
            posx = tcell{1}(1);
            posy = tcell{1}(2);
            posz = tcell{1}(3);
            sensorpos = cat ( 2, sensorpos, [ posx; posy; posz ] );
        else 
            break
        end
    end 
end

%Search for Epoch Labels
tixstar = strfind(cont,'EPOCH_LABELS START_LIST');
tixstop = strfind(cont,'EPOCH_LABELS END_LIST');

epochlabelslist = []; 

if (~isempty(tixstar)) && (~isempty(tixstop))
    text = cont(tixstar:tixstop-1);
    tcell = textscan(text,'%s', 'delimiter','\n','whitespace','', 'headerlines', 1);
    epochlabelslist = tcell{1,1};
end

%Search for Epoch Information
tixstar = strfind(cont,'EPOCH_INFORMATION START_LIST');
tixstop = strfind(cont,'EPOCH_INFORMATION END_LIST');

epochinformationlist = []; 

if (~isempty(tixstar)) && (~isempty(tixstop))
    text = cont(tixstar:tixstop-1);
    tcell = textscan(text,'%d%d%d%d%d%d%d', 'delimiter','\n','headerlines', 1);
    epochinformationlist = cell2mat(tcell);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read events from event file
% initialize events
ne = 0;                                                             % number of events
events = zeros(4,0);
annotations = cellstr('empty');

% find appropriate file
fid = fopen(EventFile,'rt');

if fid < 0
    fid = fopen(EventFile2,'rt');
end

if fid >= 0
    cell = textscan(fid,'%s','whitespace','','endofline',char(167));
    fclose(fid);
    cont = cell2mat(cell{1});

    % scan in cell 1 for NUMBER_LIST (occurs five times)
    ix = strfind(cont,'NUMBER_LIST');
    
    newlines = ix(4) - 1 + strfind(cont(ix(4):ix(5)),char(10));     % newline
    last = size(newlines,2)-1;
    for j = 1:last                                                  % loop over labels
        text = cont(newlines(j)+1:newlines(j+1)-1);
        tcell = textscan(text,'%d');                           
        sample = tcell{1}(1);                                       % access more content using different columns
        type = tcell{1}(3);
        startsample = tcell{1}(5);
        endsample = tcell{1}(6);
        ne = ne + 1;
        events = cat ( 2, events, [ sample; type; startsample; endsample ] );
    end
    
    % scan in cell 1 for REMARK_LIST (occurs five times)
    ix = strfind(cont,'REMARK_LIST');
    na = 0;
    
    newlines = ix(4) - 1 + strfind(cont(ix(4):ix(5)),char(10));     % newline
    last = size(newlines,2)-1;
    for j = 1:last                                                  % loop over labels
        text = cont(newlines(j)+1:newlines(j+1)-1);
        na = na + 1;
        annotations(na) = cellstr(text);
    end    
end

if nargout>1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read data file
    if nASCII == 1
        fid = fopen_or_error(DataFile,'rt');
        cell = textscan(fid,'%f',nChannels*nSamples*nTrials);
        fclose(fid);
        data = reshape([cell{1}],nChannels,nSamples*nTrials);
    else
        fid = fopen_or_error(DataFile,'rb');
        data = fread(fid,[nChannels,nSamples*nTrials],'float32');
        fclose(fid);
    end
    
    if nSamples*nTrials ~= size(data,2)
        msgbox('Inconsistent number of samples. File may be displayed incompletely.', 'WARNING', 'warn')
        nSamples = size(data,2)/nTrials;
    end
    % transpose?
    if nMultiplex == 1
        data = data';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time axis
time = linspace(fOffsetUsec/1000,fOffsetUsec/1000+(nSamples*nTrials-1)*1000/fFrequency,nSamples*nTrials);

%{
% simple plot
subplot(2,1,1);
plot(time,data);  

% stacked plot
subplot(2,1,2);
range = max([abs(min(min(data))) abs(max(max(data)))]);
shift = linspace((nChannels-1)*range*0.3,0,nChannels);
plot(time,data+repmat(shift,nSamples*nTrials,1)');
set(gca,'ytick',flip(shift),'yticklabel',flip(labels),'GridLineStyle',':','XGrid','on','YGrid','off');
ylim([min(min(data+repmat(shift,nSamples*nTrials,1)')) max(max(data+repmat(shift,nSamples*nTrials,1)'))]);
%}


orig = [];
orig.nSamples    = nSamples;
orig.nChannels   = nChannels;
orig.nTrials     = nTrials;
orig.fFrequency  = fFrequency;
orig.fOffsetUsec = fOffsetUsec;
orig.nASCII      = nASCII;
orig.nMultiplex  = nMultiplex;
orig.fSampleTime = fSampleTime;
orig.events      = events;
orig.labels      = labels;
orig.time        = time;
orig.impedancematrix = impedancematrix;
orig.sensorpos       = sensorpos;
orig.epochlabelslist = epochlabelslist;
orig.epochinformationlist = epochinformationlist;
orig.ne          = ne;
orig.events      = events;
orig.annotations = annotations;
                                                                                                                                                                                 ;
end
    
% Loop over all other delimiters
for i = 2:length(iDelim)
    if (isCollapse  && (iDelim(i) - iDelim(i-1) > 1)) || ...
       (~isCollapse && (iDelim(i) - iDelim(i-1) >= 1))
        iSplitStr = iSplitStr + 1;
        splStr{iSplitStr} = str(iDelim(i-1)+1:iDelim(i)-1);
    end
end
    
% Last part (after last delimiter)
if (iDelim(end) ~= length(str))
    iSplitStr = iSplitStr + 1;
    splStr{iSplitStr} = str(iDelim(end)+1:end);
end
    
% Remove all the unused entries
if (iSplitStr < length(splStr))
    splStr(iSplitStr+1:end) = [];
end




                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            if isempty(keyInd)
                continue            % no keys from 'keys' - from section-subsection par currently in
            end
            currKey = readValue;
            pos2 = ftell(fh);       % the last-byte position of the read key  - the total sum of chars read so far
            for ii=1:length(keyInd)
               if strcmpi( keysIn(keyInd(ii),3),readKey ) && ~keysLocated(keyInd(ii))
                   keysExist(keyInd(ii)) = 1;
                   startOffsets(keyInd(ii)) = pos1+1;
                   endOffsets(keyInd(ii)) = pos2;
                   values{keyInd(ii)} = currKey;
                   keysLocated(keyInd(ii)) = 1;
                   nKeysLocated = nKeysLocated + 1;
               else
                   if ~keysLocated(keyInd(ii))
                       startOffsets(keyInd(ii)) = pos2+1;
                       endOffsets(keyInd(ii)) = pos2+1;
                   end
               end
            end
            if nKeysLocated >= nKeys  % if all the keys are located
                break
            end
        else
                                    % general text found (even empty line(s))
        end
    %--- End searching
    end
    fclose(fh);
catch
    fclose(fh);
    ft_error(['Error parsing the file for keys: ' fileName ': ' lasterr]);
end
%------------------------------------




%------------------------------------
function writekeys(fileName,keys,style)
% Writes keys to the section and subsection pair
% If any of the keys doesn't exist, a new key is added to
% the end of the section-subsection pair otherwise the key is updated (changed).
% Keys is a 4-column cell-array of strings.

global NL_CHAR;

RETURN = sprintf('\r');
NEWLINE = sprintf('\n');

[m,n] = size(keys);
if n < 4
    ft_error('Keys to be written are given in an invalid format.');
end

% Get keys position first using findkeys
keysIn = keys;
[secsExist,subSecsExist,keysExist,readValues,so,eo] = findkeys(fileName,keys(:,1:3));

% Read the whole file's contents out
fh = fopen_or_error(fileName,'r');
try
    dataout = fscanf(fh,'%c');
catch
    fclose(fh);
    ft_error(lasterr);
end
fclose(fh);

%--- Rewriting the file -> writing the refined contents
fh = fopen_or_error(fileName,'w');
try
    tab1 = [];
    if strcmpi(style,'tabbed')
        tab1 = sprintf('\t');
    end
    % Proper sorting of keys is cruical at this point in order to avoid
    % inproper key-writing.

    % Find keys with -1 offsets - keys with non-existing section AND
    % subsection - keys that will be added to the end of the file
    fs = length(dataout);       % file size in bytes
    nAddedKeys = 0;
    ind = find(so==-1);
    if ~isempty(ind)
        so(ind) = (fs+10);      % make sure these keys will come to the end when sorting
        eo(ind) = (fs+10);
        nAddedKeys = length(ind);
    end

    % Sort keys according to start- and end-offsets
    [dummy,ind] = sort(so,1);
    so = so(ind);
    eo = eo(ind);
    keysIn = keysIn(ind,:);
    keysExist = keysExist(ind);
    secsExist = secsExist(ind);
    subSecsExist = subSecsExist(ind);
    readValues = readValues(ind);
    values = keysIn(:,4);

    % Find keys with equal start offset (so) and additionally sort them
    % (locally). These are non-existing keys, including the ones whose
    % section and subsection will also be added.
    nKeys = size(so,1);
    fullInd = 1:nKeys;
    ii = 1;
    while ii < nKeys
        ind = find(so==so(ii));
        if ~isempty(ind) && length(ind) > 1
            n = length(ind);
            from = ind(1);
            to = ind(end);
            tmpKeys = keysIn( ind,: );
            [tmpKeys,ind2] = sortrows( lower(tmpKeys) );
            fullInd(from:to) = ind(ind2);
            ii = ii + n;
        else
            ii = ii + 1;
        end
    end

    % Final (re)sorting
    so = so(fullInd);
    eo = eo(fullInd);
    keysIn = keysIn(fullInd,:);
    keysExist = keysExist(fullInd);
    secsExist = secsExist(fullInd);
    subSecsExist = subSecsExist(fullInd);
    readValues = readValues(fullInd);
    values = keysIn(:,4);

    % Refined data - datain
    datain = [];

    for ii=1:nKeys      % go through all the keys, existing and non-existing ones
        if ii==1
            from = 1;   % from byte-offset of original data (dataout)
        else
            from = eo(ii-1);
            if keysExist(ii-1)
                from = from + 1;
            end
        end
        to = min(so(ii)-1,fs);  % to byte-offset of original data (dataout)

        if ~isempty(dataout)
            datain = [datain dataout(from:to)];    % the lines before the key
        end

        if length(datain) && (~(datain(end)==RETURN || datain(end)==NEWLINE))
            datain = [datain, sprintf(NL_CHAR)];
        end

        tab = [];
        if ~keysExist(ii)
            if ~secsExist(ii) && ~isempty(keysIn(ii,1))
                if ~isempty(keysIn{ii,1})
                    datain = [datain sprintf(['%s' NL_CHAR],['[' keysIn{ii,1} ']'])];
                end
                % Key-indices with the same section as this, ii-th key (even empty sections are considered)
                ind = find( strcmpi( keysIn(:,1), keysIn(ii,1)) );
                % This section exists at all keys  corresponding to the same section from know on (even the empty ones)
                secsExist(ind) = 1;
            end
            if ~subSecsExist(ii) && ~isempty(keysIn(ii,2))
                if ~isempty( keysIn{ii,2})
                    if secsExist(ii); tab = tab1;  end;
                    datain = [datain sprintf(['%s' NL_CHAR],[tab '{' keysIn{ii,2} '}'])];
                end
                % Key-indices with the same section AND subsection as this, ii-th key (even empty sections and subsections are considered)
                ind = find( strcmpi( keysIn(:,1), keysIn(ii,1)) & strcmpi( keysIn(:,2), keysIn(ii,2)) );
                % This subsection exists at all keys corresponding to the same section and subsection from know on (even the empty ones)
                subSecsExist(ind) = 1;
            end
        end
        if secsExist(ii) && (~isempty(keysIn{ii,1})); tab = tab1;  end;
        if subSecsExist(ii) && (~isempty(keysIn{ii,2})); tab = [tab tab1];  end;
        datain = [datain sprintf(['%s' NL_CHAR],[tab keysIn{ii,3} ' = ' values{ii}])];
    end
    from = eo(ii);
    if keysExist(ii)
        from = from + 1;
    end
    to = length(dataout);
    if from < to
        datain = [datain dataout(from:to)];
    end
    fprintf(fh,'%c',datain);
catch
    fclose(fh);
    ft_error(['Error writing keys to file: ''' fileName ''' : ' lasterr]);
end
fclose(fh);
%------------------------------------



%------------------------------------
function deletekeys(fileName,keys)
% Deletes keys and their values out; keys must have at least 3 columns:
% section, subsection, and key

[m,n] = size(keys);
if n < 3
    ft_error('Keys to be deleted are given in an invalid format.');
end

% Get keys position first
keysIn = keys;
[secsExist,subSecsExist,keysExist,readValues,so,eo] = findkeys(fileName,keys(:,1:3));

% Read the whole file's contents out
fh = fopen_or_error(fileName,'r');
try
    dataout = fscanf(fh,'%c');
catch
    fclose(fh);
    ft_error(lasterr);
end
fclose(fh);

%--- Rewriting the file -> writing the refined contents
fh = fopen_or_error(fileName,'w');
try
    ind = find(keysExist);
    nExistingKeys = length(ind);
    datain = dataout;

    if nExistingKeys
        % Filtering - retain only the existing keys...
        fs = length(dataout);       % file size in bytes
        so = so(ind);
        eo = eo(ind);
        keysIn = keysIn(ind,:);
        % ...and sorting
        [so,ind] = sort(so);
        eo = eo(ind);
        keysIn = keysIn(ind,:);

        % Refined data - datain
        datain = [];

        for ii=1:nExistingKeys  % go through all the existing keys
            if ii==1
                from = 1;   % from byte-offset of original data (dataout)
            else
                from = eo(ii-1)+1;
            end
            to = so(ii)-1;  % to byte-offset of original data (dataout)

            if ~isempty(dataout)
                datain = [datain dataout(from:to)];    % the lines before the key
            end
        end
        from = eo(ii)+1;
        to = length(dataout);
        if from < to
            datain = [datain dataout(from:to)];
        end
    end

    fprintf(fh,'%c',datain);
catch
    fclose(fh);
    ft_error(['Error deleting keys from file: ''' fileName ''' : ' lasterr]);
end
fclose(fh);
%------------------------------------




%------------------------------------
function [status,value,key] = processiniline(line)
% Processes a line read from the ini file and
% returns the following values:
%   - status:   0   => empty line or unknown string
%               1   => section found
%               2   => subsection found
%               3   => key-value pair found
%   - value:    value-string of a key, section, or subsection
%   - key:      key-string

status = 0;
value = [];
key = [];
line = strim(line);                         % removes any leading and trailing spaces
if isempty(line)                            % empty line
    return
end
if (line(1) == '[') && (line(end) == ']')... % section found
        && (length(line) >= 3)
    value = lower(line(2:end-1));
    status = 1;
elseif (line(1) == '{') &&...                % subsection found
       (line(end) == '}') && (length(line) >= 3)
    value = lower(line(2:end-1));
    status = 2;
else
    pos = strfind(line,'=');
    if ~isempty(pos)                        % key-value pair found
        status = 3;
        key = lower(line(1:pos-1));
        value = line(pos+1:end);
        key = strim(key);                   % removes any leading and trailing spaces
        value = strim(value);               % removes any leading and trailing spaces
        if isempty(key)                     % empty keys are not allowed
            status = 0;
            key = [];
            value = [];
        end
    end
end
%------------------------------------


%------------------------------------
function outstr = strim(str)
% Removes leading and trailing spaces (spaces, tabs, endlines,...)
% from the str string.
if isnumeric(str);
    outstr = str;
    return
end
ind = find( ~isspace(str) );        % indices of the non-space characters in the str
if isempty(ind)
    outstr = [];
else
    outstr = str( ind(1):ind(end) );
end



%------------------------------------
function cs = cellstrings(m,n)
% Creates a m x n cell-array of empty strings - ''
cs = cell(m,n);
for ii=1:m
    for jj=1:n
        cs{ii,jj} = '';
    end
end
                                                                                                        tent=full_content;
    end
  end

  msg = sprintf('%s\n\n%s', msg, content);
  ft_warning(msg);
end % function warning_dimord_could_not_be_determined


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = isequalwithoutnans(a, b)

% this is *only* used to compare matrix sizes, so we can ignore any singleton last dimension
numdiff = numel(b)-numel(a);

if numdiff > 0
  % assume singleton dimensions missing in a
  a = [a(:); ones(numdiff, 1)];
  b = b(:);
elseif numdiff < 0
  % assume singleton dimensions missing in b
  b = [b(:); ones(abs(numdiff), 1)];
  a = a(:);
end

c = ~isnan(a(:)) & ~isnan(b(:));
ok = isequal(a(c), b(c));

end % function isequalwithoutnans

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = check_trailingdimsunitlength(data, dimtok)

ok = false;
for k = 1:numel(dimtok)
  switch dimtok{k}
    case 'chan'
      ok = numel(data.label)==1;
    otherwise
      if isfield(data, dimtok{k}) % check whether field exists
        ok = numel(data.(dimtok{k}))==1;
      end
  end
  if ok
    break;
  end
end

end % function check_trailingdimsunitlength
                                                                                                                                                                                                          
        'MLP32_dH'  'MLP32_dV'  'MLP32'
        'MLP33_dH'  'MLP33_dV'  'MLP33'
        'MLP34_dH'  'MLP34_dV'  'MLP34'
        'MLP35_dH'  'MLP35_dV'  'MLP35'
        'MLP41_dH'  'MLP41_dV'  'MLP41'
        'MLP42_dH'  'MLP42_dV'  'MLP42'
        'MLP43_dH'  'MLP43_dV'  'MLP43'
        'MLP44_dH'  'MLP44_dV'  'MLP44'
        'MLP45_dH'  'MLP45_dV'  'MLP45'
        'MLP51_dH'  'MLP51_dV'  'MLP51'
        'MLP52_dH'  'MLP52_dV'  'MLP52'
        'MLP53_dH'  'MLP53_dV'  'MLP53'
        'MLP54_dH'  'MLP54_dV'  'MLP54'
        'MLP55_dH'  'MLP55_dV'  'MLP55'
        'MLP56_dH'  'MLP56_dV'  'MLP56'
        'MLP57_dH'  'MLP57_dV'  'MLP57'
        'MLT11_dH'  'MLT11_dV'  'MLT11'
        'MLT12_dH'  'MLT12_dV'  'MLT12'
        'MLT13_dH'  'MLT13_dV'  'MLT13'
        'MLT14_dH'  'MLT14_dV'  'MLT14'
        'MLT15_dH'  'MLT15_dV'  'MLT15'
        'MLT16_dH'  'MLT16_dV'  'MLT16'
        'MLT21_dH'  'MLT21_dV'  'MLT21'
        'MLT22_dH'  'MLT22_dV'  'MLT22'
        'MLT23_dH'  'MLT23_dV'  'MLT23'
        'MLT24_dH'  'MLT24_dV'  'MLT24'
        'MLT25_dH'  'MLT25_dV'  'MLT25'
        'MLT26_dH'  'MLT26_dV'  'MLT26'
        'MLT27_dH'  'MLT27_dV'  'MLT27'
        'MLT31_dH'  'MLT31_dV'  'MLT31'
        'MLT32_dH'  'MLT32_dV'  'MLT32'
        'MLT33_dH'  'MLT33_dV'  'MLT33'
        'MLT34_dH'  'MLT34_dV'  'MLT34'
        'MLT35_dH'  'MLT35_dV'  'MLT35'
        'MLT36_dH'  'MLT36_dV'  'MLT36'
        'MLT37_dH'  'MLT37_dV'  'MLT37'
        'MLT41_dH'  'MLT41_dV'  'MLT41'
        'MLT42_dH'  'MLT42_dV'  'MLT42'
        'MLT43_dH'  'MLT43_dV'  'MLT43'
        'MLT44_dH'  'MLT44_dV'  'MLT44'
        'MLT45_dH'  'MLT45_dV'  'MLT45'
        'MLT46_dH'  'MLT46_dV'  'MLT46'
        'MLT47_dH'  'MLT47_dV'  'MLT47'
        'MLT51_dH'  'MLT51_dV'  'MLT51'
        'MLT52_dH'  'MLT52_dV'  'MLT52'
        'MLT53_dH'  'MLT53_dV'  'MLT53'
        'MLT54_dH'  'MLT54_dV'  'MLT54'
        'MLT55_dH'  'MLT55_dV'  'MLT55'
        'MLT56_dH'  'MLT56_dV'  'MLT56'
        'MLT57_dH'  'MLT57_dV'  'MLT57'
        'MRC11_dH'  'MRC11_dV'  'MRC11'
        'MRC12_dH'  'MRC12_dV'  'MRC12'
        'MRC13_dH'  'MRC13_dV'  'MRC13'
        'MRC14_dH'  'MRC14_dV'  'MRC14'
        'MRC15_dH'  'MRC15_dV'  'MRC15'
        'MRC16_dH'  'MRC16_dV'  'MRC16'
        'MRC17_dH'  'MRC17_dV'  'MRC17'
        'MRC21_dH'  'MRC21_dV'  'MRC21'
        'MRC22_dH'  'MRC22_dV'  'MRC22'
        'MRC23_dH'  'MRC23_dV'  'MRC23'
        'MRC24_dH'  'MRC24_dV'  'MRC24'
        'MRC25_dH'  'MRC25_dV'  'MRC25'
        'MRC31_dH'  'MRC31_dV'  'MRC31'
        'MRC32_dH'  'MRC32_dV'  'MRC32'
        'MRC41_dH'  'MRC41_dV'  'MRC41'
        'MRC42_dH'  'MRC42_dV'  'MRC42'
        'MRC51_dH'  'MRC51_dV'  'MRC51'
        'MRC52_dH'  'MRC52_dV'  'MRC52'
        'MRC53_dH'  'MRC53_dV'  'MRC53'
        'MRC54_dH'  'MRC54_dV'  'MRC54'
        'MRC55_dH'  'MRC55_dV'  'MRC55'
        'MRC61_dH'  'MRC61_dV'  'MRC61'
        'MRC62_dH'  'MRC62_dV'  'MRC62'
        'MRC63_dH'  'MRC63_dV'  'MRC63'
        'MRF11_dH'  'MRF11_dV'  'MRF11'
        'MRF12_dH'  'MRF12_dV'  'MRF12'
        'MRF13_dH'  'MRF13_dV'  'MRF13'
        'MRF14_dH'  'MRF14_dV'  'MRF14'
        'MRF21_dH'  'MRF21_dV'  'MRF21'
        'MRF22_dH'  'MRF22_dV'  'MRF22'
        'MRF23_dH'  'MRF23_dV'  'MRF23'
        'MRF24_dH'  'MRF24_dV'  'MRF24'
        'MRF25_dH'  'MRF25_dV'  'MRF25'
        'MRF31_dH'  'MRF31_dV'  'MRF31'
        'MRF32_dH'  'MRF32_dV'  'MRF32'
        'MRF33_dH'  'MRF33_dV'  'MRF33'
        'MRF34_dH'  'MRF34_dV'  'MRF34'
        'MRF35_dH'  'MRF35_dV'  'MRF35'
        'MRF41_dH'  'MRF41_dV'  'MRF41'
        'MRF42_dH'  'MRF42_dV'  'MRF42'
        'MRF43_dH'  'MRF43_dV'  'MRF43'
        'MRF44_dH'  'MRF44_dV'  'MRF44'
        'MRF45_dH'  'MRF45_dV'  'MRF45'
        'MRF46_dH'  'MRF46_dV'  'MRF46'
        'MRF51_dH'  'MRF51_dV'  'MRF51'
        'MRF52_dH'  'MRF52_dV'  'MRF52'
        'MRF53_dH'  'MRF53_dV'  'MRF53'
        'MRF54_dH'  'MRF54_dV'  'MRF54'
        'MRF55_dH'  'MRF55_dV'  'MRF55'
        'MRF56_dH'  'MRF56_dV'  'MRF56'
        'MRF61_dH'  'MRF61_dV'  'MRF61'
        'MRF62_dH'  'MRF62_dV'  'MRF62'
        'MRF63_dH'  'MRF63_dV'  'MRF63'
        'MRF64_dH'  'MRF64_dV'  'MRF64'
        'MRF65_dH'  'MRF65_dV'  'MRF65'
        'MRF66_dH'  'MRF66_dV'  'MRF66'
        'MRF67_dH'  'MRF67_dV'  'MRF67'
        'MRO11_dH'  'MRO11_dV'  'MRO11'
        'MRO12_dH'  'MRO12_dV'  'MRO12'
        'MRO13_dH'  'MRO13_dV'  'MRO13'
        'MRO14_dH'  'MRO14_dV'  'MRO14'
        'MRO21_dH'  'MRO21_dV'  'MRO21'
        'MRO22_dH'  'MRO22_dV'  'MRO22'
        'MRO23_dH'  'MRO23_dV'  'MRO23'
        'MRO24_dH'  'MRO24_dV'  'MRO24'
        'MRO31_dH'  'MRO31_dV'  'MRO31'
        'MRO32_dH'  'MRO32_dV'  'MRO32'
        'MRO33_dH'  'MRO33_dV'  'MRO33'
        'MRO34_dH'  'MRO34_dV'  'MRO34'
        'MRO41_dH'  'MRO41_dV'  'MRO41'
        'MRO42_dH'  'MRO42_dV'  'MRO42'
        'MRO43_dH'  'MRO43_dV'  'MRO43'
        'MRO44_dH'  'MRO44_dV'  'MRO44'
        'MRO51_dH'  'MRO51_dV'  'MRO51'
        'MRO52_dH'  'MRO52_dV'  'MRO52'
        'MRO53_dH'  'MRO53_dV'  'MRO53'
        'MRP11_dH'  'MRP11_dV'  'MRP11'
        'MRP12_dH'  'MRP12_dV'  'MRP12'
        'MRP21_dH'  'MRP21_dV'  'MRP21'
        'MRP22_dH'  'MRP22_dV'  'MRP22'
        'MRP23_dH'  'MRP23_dV'  'MRP23'
        'MRP31_dH'  'MRP31_dV'  'MRP31'
        'MRP32_dH'  'MRP32_dV'  'MRP32'
        'MRP33_dH'  'MRP33_dV'  'MRP33'
        'MRP34_dH'  'MRP34_dV'  'MRP34'
        'MRP35_dH'  'MRP35_dV'  'MRP35'
        'MRP41_dH'  'MRP41_dV'  'MRP41'
        'MRP42_dH'  'MRP42_dV'  'MRP42'
        'MRP43_dH'  'MRP43_dV'  'MRP43'
        'MRP44_dH'  'MRP44_dV'  'MRP44'
        'MRP45_dH'  'MRP45_dV'  'MRP45'
        'MRP51_dH'  'MRP51_dV'  'MRP51'
        'MRP52_dH'  'MRP52_dV'  'MRP52'
        'MRP53_dH'  'MRP53_dV'  'MRP53'
        'MRP54_dH'  'MRP54_dV'  'MRP54'
        'MRP55_dH'  'MRP55_dV'  'MRP55'
        'MRP56_dH'  'MRP56_dV'  'MRP56'
        'MRP57_dH'  'MRP57_dV'  'MRP57'
        'MRT11_dH'  'MRT11_dV'  'MRT11'
        'MRT12_dH'  'MRT12_dV'  'MRT12'
        'MRT13_dH'  'MRT13_dV'  'MRT13'
        'MRT14_dH'  'MRT14_dV'  'MRT14'
        'MRT15_dH'  'MRT15_dV'  'MRT15'
        'MRT16_dH'  'MRT16_dV'  'MRT16'
        'MRT21_dH'  'MRT21_dV'  'MRT21'
        'MRT22_dH'  'MRT22_dV'  'MRT22'
        'MRT23_dH'  'MRT23_dV'  'MRT23'
        'MRT24_dH'  'MRT24_dV'  'MRT24'
        'MRT25_dH'  'MRT25_dV'  'MRT25'
        'MRT26_dH'  'MRT26_dV'  'MRT26'
        'MRT27_dH'  'MRT27_dV'  'MRT27'
        'MRT31_dH'  'MRT31_dV'  'MRT31'
        'MRT32_dH'  'MRT32_dV'  'MRT32'
        'MRT33_dH'  'MRT33_dV'  'MRT33'
        'MRT34_dH'  'MRT34_dV'  'MRT34'
        'MRT35_dH'  'MRT35_dV'  'MRT35'
        'MRT36_dH'  'MRT36_dV'  'MRT36'
        'MRT37_dH'  'MRT37_dV'  'MRT37'
        'MRT41_dH'  'MRT41_dV'  'MRT41'
        'MRT42_dH'  'MRT42_dV'  'MRT42'
        'MRT43_dH'  'MRT43_dV'  'MRT43'
        'MRT44_dH'  'MRT44_dV'  'MRT44'
        'MRT45_dH'  'MRT45_dV'  'MRT45'
        'MRT46_dH'  'MRT46_dV'  'MRT46'
        'MRT47_dH'  'MRT47_dV'  'MRT47'
        'MRT51_dH'  'MRT51_dV'  'MRT51'
        'MRT52_dH'  'MRT52_dV'  'MRT52'
        'MRT53_dH'  'MRT53_dV'  'MRT53'
        'MRT54_dH'  'MRT54_dV'  'MRT54'
        'MRT55_dH'  'MRT55_dV'  'MRT55'
        'MRT56_dH'  'MRT56_dV'  'MRT56'
        'MRT57_dH'  'MRT57_dV'  'MRT57'
        'MZC01_dH'  'MZC01_dV'  'MZC01'
        'MZC02_dH'  'MZC02_dV'  'MZC02'
        'MZC03_dH'  'MZC03_dV'  'MZC03'
        'MZC04_dH'  'MZC04_dV'  'MZC04'
        'MZF01_dH'  'MZF01_dV'  'MZF01'
        'MZF02_dH'  'MZF02_dV'  'MZF02'
        'MZF03_dH'  'MZF03_dV'  'MZF03'
        'MZO01_dH'  'MZO01_dV'  'MZO01'
        'MZO02_dH'  'MZO02_dV'  'MZO02'
        'MZO03_dH'  'MZO03_dV'  'MZO03'
        'MZP01_dH'  'MZP01_dV'  'MZP01'
        };
      ctf275_planar_combined = label(:,3);
      label = label(:,1:2);
      
    case {'neuromag122' 'neuromag122alt'}
      % this is the combination of the two versions (with and without space)
      label = {
        'MEG 001'  'MEG 002'  'MEG 001+002'
        'MEG 003'  'MEG 004'  'MEG 003+004'
        'MEG 005'  'MEG 006'  'MEG 005+006'
        'MEG 007'  'MEG 008'  'MEG 007+008'
        'MEG 009'  'MEG 010'  'MEG 009+010'
        'MEG 011'  'MEG 012'  'MEG 011+012'
        'MEG 013'  'MEG 014'  'MEG 013+014'
        'MEG 015'  'MEG 016'  'MEG 015+016'
        'MEG 017'  'MEG 018'  'MEG 017+018'
        'MEG 019'  'MEG 020'  'MEG 019+020'
        'MEG 021'  'MEG 022'  'MEG 021+022'
        'MEG 023'  'MEG 024'  'MEG 023+024'
        'MEG 025'  'MEG 026'  'MEG 025+026'
        'MEG 027'  'MEG 028'  'MEG 027+028'
        'MEG 029'  'MEG 030'  'MEG 029+030'
        'MEG 031'  'MEG 032'  'MEG 031+032'
        'MEG 033'  'MEG 034'  'MEG 033+034'
        'MEG 035'  'MEG 036'  'MEG 035+036'
        'MEG 037'  'MEG 038'  'MEG 037+038'
        'MEG 039'  'MEG 040'  'MEG 039+040'
        'MEG 041'  'MEG 042'  'MEG 041+042'
        'MEG 043'  'MEG 044'  'MEG 043+044'
        'MEG 045'  'MEG 046'  'MEG 045+046'
        'MEG 047'  'MEG 048'  'MEG 047+048'
        'MEG 049'  'MEG 050'  'MEG 049+050'
        'MEG 051'  'MEG 052'  'MEG 051+052'
        'MEG 053'  'MEG 054'  'MEG 053+054'
        'MEG 055'  'MEG 056'  'MEG 055+056'
        'MEG 057'  'MEG 058'  'MEG 057+058'
        'MEG 059'  'MEG 060'  'MEG 059+060'
        'MEG 061'  'MEG 062'  'MEG 061+062'
        'MEG 063'  'MEG 064'  'MEG 063+064'
        'MEG 065'  'MEG 066'  'MEG 065+066'
        'MEG 067'  'MEG 068'  'MEG 067+068'
        'MEG 069'  'MEG 070'  'MEG 069+070'
        'MEG 071'  'MEG 072'  'MEG 071+072'
        'MEG 073'  'MEG 074'  'MEG 073+074'
        'MEG 075'  'MEG 076'  'MEG 075+076'
        'MEG 077'  'MEG 078'  'MEG 077+078'
        'MEG 079'  'MEG 080'  'MEG 079+080'
        'MEG 081'  'MEG 082'  'MEG 081+082'
        'MEG 083'  'MEG 084'  'MEG 083+084'
        'MEG 085'  'MEG 086'  'MEG 085+086'
        'MEG 087'  'MEG 088'  'MEG 087+088'
        'MEG 089'  'MEG 090'  'MEG 089+090'
        'MEG 091'  'MEG 092'  'MEG 091+092'
        'MEG 093'  'MEG 094'  'MEG 093+094'
        'MEG 095'  'MEG 096'  'MEG 095+096'
        'MEG 097'  'MEG 098'  'MEG 097+098'
        'MEG 099'  'MEG 100'  'MEG 099+100'
        'MEG 101'  'MEG 102'  'MEG 101+102'
        'MEG 103'  'MEG 104'  'MEG 103+104'
        'MEG 105'  'MEG 106'  'MEG 105+106'
        'MEG 107'  'MEG 108'  'MEG 107+108'
        'MEG 109'  'MEG 110'  'MEG 109+110'
        'MEG 111'  'MEG 112'  'MEG 111+112'
        'MEG 113'  'MEG 114'  'MEG 113+114'
        'MEG 115'  'MEG 116'  'MEG 115+116'
        'MEG 117'  'MEG 118'  'MEG 117+118'
        'MEG 119'  'MEG 120'  'MEG 119+120'
        'MEG 121'  'MEG 122'  'MEG 121+122'
        % this is an alternative set of labels without a space in them
        'MEG001'  'MEG002'  'MEG001+002'
        'MEG003'  'MEG004'  'MEG003+004'
        'MEG005'  'MEG006'  'MEG005+006'
        'MEG007'  'MEG008'  'MEG007+008'
        'MEG009'  'MEG010'  'MEG009+010'
        'MEG011'  'MEG012'  'MEG011+012'
        'MEG013'  'MEG014'  'MEG013+014'
        'MEG015'  'MEG016'  'MEG015+016'
        'MEG017'  'MEG018'  'MEG017+018'
        'MEG019'  'MEG020'  'MEG019+020'
        'MEG021'  'MEG022'  'MEG021+022'
        'MEG023'  'MEG024'  'MEG023+024'
        'MEG025'  'MEG026'  'MEG025+026'
        'MEG027'  'MEG028'  'MEG027+028'
        'MEG029'  'MEG030'  'MEG029+030'
        'MEG031'  'MEG032'  'MEG031+032'
        'MEG033'  'MEG034'  'MEG033+034'
        'MEG035'  'MEG036'  'MEG035+036'
        'MEG037'  'MEG038'  'MEG037+038'
        'MEG039'  'MEG040'  'MEG039+040'
        'MEG041'  'MEG042'  'MEG041+042'
        'MEG043'  'MEG044'  'MEG043+044'
        'MEG045'  'MEG046'  'MEG045+046'
        'MEG047'  'MEG048'  'MEG047+048'
        'MEG049'  'MEG050'  'MEG049+050'
        'MEG051'  'MEG052'  'MEG051+052'
        'MEG053'  'MEG054'  'MEG053+054'
        'MEG055'  'MEG056'  'MEG055+056'
        'MEG057'  'MEG058'  'MEG057+058'
        'MEG059'  'MEG060'  'MEG059+060'
        'MEG061'  'MEG062'  'MEG061+062'
        'MEG063'  'MEG064'  'MEG063+064'
        'MEG065'  'MEG066'  'MEG065+066'
        'MEG067'  'MEG068'  'MEG067+068'
        'MEG069'  'MEG070'  'MEG069+070'
        'MEG071'  'MEG072'  'MEG071+072'
        'MEG073'  'MEG074'  'MEG073+074'
        'MEG075'  'MEG076'  'MEG075+076'
        'MEG077'  'MEG078'  'MEG077+078'
        'MEG079'  'MEG080'  'MEG079+080'
        'MEG081'  'MEG082'  'MEG081+082'
        'MEG083'  'MEG084'  'MEG083+084'
        'MEG085'  'MEG086'  'MEG085+086'
        'MEG087'  'MEG088'  'MEG087+088'
        'MEG089'  'MEG090'  'MEG089+090'
        'MEG091'  'MEG092'  'MEG091+092'
        'MEG093'  'MEG094'  'MEG093+094'
        'MEG095'  'MEG096'  'MEG095+096'
        'MEG097'  'MEG098'  'MEG097+098'
        'MEG099'  'MEG100'  'MEG099+100'
        'MEG101'  'MEG102'  'MEG101+102'
        'MEG103'  'MEG104'  'MEG103+104'
        'MEG105'  'MEG106'  'MEG105+106'
        'MEG107'  'MEG108'  'MEG107+108'
        'MEG109'  'MEG110'  'MEG109+110'
        'MEG111'  'MEG112'  'MEG111+112'
        'MEG113'  'MEG114'  'MEG113+114'
        'MEG115'  'MEG116'  'MEG115+116'
        'MEG117'  'MEG118'  'MEG117+118'
        'MEG119'  'MEG120'  'MEG119+120'
        'MEG121'  'MEG122'  'MEG121+122'
        };
      neuromag122_combined = label(:,3);
      neuromag122alt_combined = label(:,3);
      label = label(:,1:2);
      
    case {'neuromag306' 'neuromag306alt'}
      % this is the combination of the two versions (with and without space)
      label = {
        'MEG 0112'  'MEG 0113'  'MEG 0111'  'MEG 0112+0113'
        'MEG 0122'  'MEG 0123'  'MEG 0121'  'MEG 0122+0123'
        'MEG 0132'  'MEG 0133'  'MEG 0131'  'MEG 0132+0133'
        'MEG 0142'  'MEG 0143'  'MEG 0141'  'MEG 0142+0143'
        'MEG 0212'  'MEG 0213'  'MEG 0211'  'MEG 0212+0213'
        'MEG 0222'  'MEG 0223'  'MEG 0221'  'MEG 0222+0223'
        'MEG 0232'  'MEG 0233'  'MEG 0231'  'MEG 0232+0233'
        'MEG 0242'  'MEG 0243'  'MEG 0241'  'MEG 0242+0243'
        'MEG 0312'  'MEG 0313'  'MEG 0311'  'MEG 0312+0313'
        'MEG 0322'  'MEG 0323'  'MEG 0321'  'MEG 0322+0323'
        'MEG 0332'  'MEG 0333'  'MEG 0331'  'MEG 0332+0333'
        'MEG 0342'  'MEG 0343'  'MEG 0341'  'MEG 0342+0343'
        'MEG 0412'  'MEG 0413'  'MEG 0411'  'MEG 0412+0413'
        'MEG 0422'  'MEG 0423'  'MEG 0421'  'MEG 0422+0423'
        'MEG 0432'  'MEG 0433'  'MEG 0431'  'MEG 0432+0433'
        'MEG 0442'  'MEG 0443'  'MEG 0441'  'MEG 0442+0443'
        'MEG 0512'  'MEG 0513'  'MEG 0511'  'MEG 0512+0513'
        'MEG 0522'  'MEG 0523'  'MEG 0521'  'MEG 0522+0523'
        'MEG 0532'  'MEG 0533'  'MEG 0531'  'MEG 0532+0533'
        'MEG 0542'  'MEG 0543'  'MEG 0541'  'MEG 0542+0543'
        'MEG 0612'  'MEG 0613'  'MEG 0611'  'MEG 0612+0613'
        'MEG 0622'  'MEG 0623'  'MEG 0621'  'MEG 0622+0623'
        'MEG 0632'  'MEG 0633'  'MEG 0631'  'MEG 0632+0633'
        'MEG 0642'  'MEG 0643'  'MEG 0641'  'MEG 0642+0643'
        'MEG 0712'  'MEG 0713'  'MEG 0711'  'MEG 0712+0713'
        'MEG 0722'  'MEG 0723'  'MEG 0721'  'MEG 0722+0723'
        'MEG 0732'  'MEG 0733'  'MEG 0731'  'MEG 0732+0733'
        'MEG 0742'  'MEG 0743'  'MEG 0741'  'MEG 0742+0743'
        'MEG 0812'  'MEG 0813'  'MEG 0811'  'MEG 0812+0813'
        'MEG 0822'  'MEG 0823'  'MEG 0821'  'MEG 0822+0823'
        'MEG 0912'  'MEG 0913'  'MEG 0911'  'MEG 0912+0913'
        'MEG 0922'  'MEG 0923'  'MEG 0921'  'MEG 0922+0923'
        'MEG 0932'  'MEG 0933'  'MEG 0931'  'MEG 0932+0933'
        'MEG 0942'  'MEG 0943'  'MEG 0941'  'MEG 0942+0943'
        'MEG 1012'  'MEG 1013'  'MEG 1011'  'MEG 1012+1013'
        'MEG 1022'  'MEG 1023'  'MEG 1021'  'MEG 1022+1023'
        'MEG 1032'  'MEG 1033'  'MEG 1031'  'MEG 1032+1033'
        'MEG 1042'  'MEG 1043'  'MEG 1041'  'MEG 1042+1043'
        'MEG 1112'  'MEG 1113'  'MEG 1111'  'MEG 1112+1113'
        'MEG 1122'  'MEG 1123'  'MEG 1121'  'MEG 1122+1123'
        'MEG 1132'  'MEG 1133'  'MEG 1131'  'MEG 1132+1133'
        'MEG 1142'  'MEG 1143'  'MEG 1141'  'MEG 1142+1143'
        'MEG 1212'  'MEG 1213'  'MEG 1211'  'MEG 1212+1213'
        'MEG 1222'  'MEG 1223'  'MEG 1221'  'MEG 1222+1223'
        'MEG 1232'  'MEG 1233'  'MEG 1231'  'MEG 1232+1233'
        'MEG 1242'  'MEG 1243'  'MEG 1241'  'MEG 1242+1243'
        'MEG 1312'  'MEG 1313'  'MEG 1311'  'MEG 1312+1313'
        'MEG 1322'  'MEG 1323'  'MEG 1321'  'MEG 1322+1323'
        'MEG 1332'  'MEG 1333'  'MEG 1331'  'MEG 1332+1333'
        'MEG 1342'  'MEG 1343'  'MEG 1341'  'MEG 1342+1343'
        'MEG 1412'  'MEG 1413'  'MEG 1411'  'MEG 1412+1413'
        'MEG 1422'  'MEG 1423'  'MEG 1421'  'MEG 1422+1423'
        'MEG 1432'  'MEG 1433'  'MEG 1431'  'MEG 1432+1433'
        'MEG 1442'  'MEG 1443'  'MEG 1441'  'MEG 1442+1443'
        'MEG 1512'  'MEG 1513'  'MEG 1511'  'MEG 1512+1513'
        'MEG 1522'  'MEG 1523'  'MEG 1521'  'MEG 1522+1523'
        'MEG 1532'  'MEG 1533'  'MEG 1531'  'MEG 1532+1533'
        'MEG 1542'  'MEG 1543'  'MEG 1541'  'MEG 1542+1543'
        'MEG 1612'  'MEG 1613'  'MEG 1611'  'MEG 1612+1613'
        'MEG 1622'  'MEG 1623'  'MEG 1621'  'MEG 1622+1623'
        'MEG 1632'  'MEG 1633'  'MEG 1631'  'MEG 1632+1633'
        'MEG 1642'  'MEG 1643'  'MEG 1641'  'MEG 1642+1643'
        'MEG 1712'  'MEG 1713'  'MEG 1711'  'MEG 1712+1713'
        'MEG 1722'  'MEG 1723'  'MEG 1721'  'MEG 1722+1723'
        'MEG 1732'  'MEG 1733'  'MEG 1731'  'MEG 1732+1733'
        'MEG 1742'  'MEG 1743'  'MEG 1741'  'MEG 1742+1743'
        'MEG 1812'  'MEG 1813'  'MEG 1811'  'MEG 1812+1813'
        'MEG 1822'  'MEG 1823'  'MEG 1821'  'MEG 1822+1823'
        'MEG 1832'  'MEG 1833'  'MEG 1831'  'MEG 1832+1833'
        'MEG 1842'  'MEG 1843'  'MEG 1841'  'MEG 1842+1843'
        'MEG 1912'  'MEG 1913'  'MEG 1911'  'MEG 1912+1913'
        'MEG 1922'  'MEG 1923'  'MEG 1921'  'MEG 1922+1923'
        'MEG 1932'  'MEG 1933'  'MEG 1931'  'MEG 1932+1933'
        'MEG 1942'  'MEG 1943'  'MEG 1941'  'MEG 1942+1943'
        'MEG 2012'  'MEG 2013'  'MEG 2011'  'MEG 2012+2013'
        'MEG 2022'  'MEG 2023'  'MEG 2021'  'MEG 2022+2023'
        'MEG 2032'  'MEG 2033'  'MEG 2031'  'MEG 2032+2033'
        'MEG 2042'  'MEG 2043'  'MEG 2041'  'MEG 2042+2043'
        'MEG 2112'  'MEG 2113'  'MEG 2111'  'MEG 2112+2113'
        'MEG 2122'  'MEG 2123'  'MEG 2121'  'MEG 2122+2123'
        'MEG 2132'  'MEG 2133'  'MEG 2131'  'MEG 2132+2133'
        'MEG 2142'  'MEG 2143'  'MEG 2141'  'MEG 2142+2143'
        'MEG 2212'  'MEG 2213'  'MEG 2211'  'MEG 2212+2213'
        'MEG 2222'  'MEG 2223'  'MEG 2221'  'MEG 2222+2223'
        'MEG 2232'  'MEG 2233'  'MEG 2231'  'MEG 2232+2233'
        'MEG 2242'  'MEG 2243'  'MEG 2241'  'MEG 2242+2243'
        'MEG 2312'  'MEG 2313'  'MEG 2311'  'MEG 2312+2313'
        'MEG 2322'  'MEG 2323'  'MEG 2321'  'MEG 2322+2323'
        'MEG 2332'  'MEG 2333'  'MEG 2331'  'MEG 2332+2333'
        'MEG 2342'  'MEG 2343'  'MEG 2341'  'MEG 2342+2343'
        'MEG 2412'  'MEG 2413'  'MEG 2411'  'MEG 2412+2413'
        'MEG 2422'  'MEG 2423'  'MEG 2421'  'MEG 2422+2423'
        'MEG 2432'  'MEG 2433'  'MEG 2431'  'MEG 2432+2433'
        'MEG 2442'  'MEG 2443'  'MEG 2441'  'MEG 2442+2443'
        'MEG 2512'  'MEG 2513'  'MEG 2511'  'MEG 2512+2513'
        'MEG 2522'  'MEG 2523'  'MEG 2521'  'MEG 2522+2523'
        'MEG 2532'  'MEG 2533'  'MEG 2531'  'MEG 2532+2533'
        'MEG 2542'  'MEG 2543'  'MEG 2541'  'MEG 2542+2543'
        'MEG 2612'  'MEG 2613'  'MEG 2611'  'MEG 2612+2613'
        'MEG 2622'  'MEG 2623'  'MEG 2621'  'MEG 2622+2623'
        'MEG 2632'  'MEG 2633'  'MEG 2631'  'MEG 2632+2633'
        'MEG 2642'  'MEG 2643'  'MEG 2641'  'MEG 2642+2643'
        % this is an alternative set of labels without a space in them
        'MEG0112'  'MEG0113'  'MEG0111'  'MEG0112+0113'
        'MEG0122'  'MEG0123'  'MEG0121'  'MEG0122+0123'
        'MEG0132'  'MEG0133'  'MEG0131'  'MEG0132+0133'
        'MEG0142'  'MEG0143'  'MEG0141'  'MEG0142+0143'
        'MEG0212'  'MEG0213'  'MEG0211'  'MEG0212+0213'
        'MEG0222'  'MEG0223'  'MEG0221'  'MEG0222+0223'
        'MEG0232'  'MEG0233'  'MEG0231'  'MEG0232+0233'
        'MEG0242'  'MEG0243'  'MEG0241'  'MEG0242+0243'
        'MEG0312'  'MEG0313'  'MEG0311'  'MEG0312+0313'
        'MEG0322'  'MEG0323'  'MEG0321'  'MEG0322+0323'
        'MEG0332'  'MEG0333'  'MEG0331'  'MEG0332+0333'
        'MEG0342'  'MEG0343'  'MEG0341'  'MEG0342+0343'
        'MEG0412'  'MEG0413'  'MEG0411'  'MEG0412+0413'
        'MEG0422'  'MEG0423'  'MEG0421'  'MEG0422+0423'
        'MEG0432'  'MEG0433'  'MEG0431'  'MEG0432+0433'
        'MEG0442'  'MEG0443'  'MEG0441'  'MEG0442+0443'
        'MEG0512'  'MEG0513'  'MEG0511'  'MEG0512+0513'
        'MEG0522'  'MEG0523'  'MEG0521'  'MEG0522+0523'
        'MEG0532'  'MEG0533'  'MEG0531'  'MEG0532+0533'
        'MEG0542'  'MEG0543'  'MEG0541'  'MEG0542+0543'
        'MEG0612'  'MEG0613'  'MEG0611'  'MEG0612+0613'
        'MEG0622'  'MEG0623'  'MEG0621'  'MEG0622+0623'
        'MEG0632'  'MEG0633'  'MEG0631'  'MEG0632+0633'
        'MEG0642'  'MEG0643'  'MEG0641'  'MEG0642+0643'
        'MEG0712'  'MEG0713'  'MEG0711'  'MEG0712+0713'
        'MEG0722'  'MEG0723'  'MEG0721'  'MEG0722+0723'
        'MEG0732'  'MEG0733'  'MEG0731'  'MEG0732+0733'
        'MEG0742'  'MEG0743'  'MEG0741'  'MEG0742+0743'
        'MEG0812'  'MEG0813'  'MEG0811'  'MEG0812+0813'
        'MEG0822'  'MEG0823'  'MEG0821'  'MEG0822+0823'
        'MEG0912'  'MEG0913'  'MEG0911'  'MEG0912+0913'
        'MEG0922'  'MEG0923'  'MEG0921'  'MEG0922+0923'
        'MEG0932'  'MEG0933'  'MEG0931'  'MEG0932+0933'
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
     