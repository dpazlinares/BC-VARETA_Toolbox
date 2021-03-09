function varargout = cstructdecode(buf, varargin)

% CSTRUCTDECODE decodes a structure from a uint8 buffer
%
% See READ_NEURALYNX_NEV for an example

% Copyright (C) 2007, Robert Oostenveld
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

if ~isa(buf, 'uint8')
  ft_error('incorrect type of input data, should be uint8');
end

nbytes = numel(buf);
nfield = length(varargin);

wordsize = zeros(1,nfield);
for i=1:nfield
  switch varargin{i}
  case 'uint8'
    wordsize(i) = 1;
  case 'int8'
    wordsize(i) = 1;
  case 'uint16'
    wordsize(i) = 2;
  case 'int16'
    wordsize(i) = 2;
  case 'uint32'
    wordsize(i) = 4;
  case 'int32'
    wordsize(i) = 4;
  case 'uint64'
    wordsize(i) = 8;
  case 'int64'
    wordsize(i) = 8;
  case {'float32' 'single'}
    varargin{i} = 'single';
    wordsize(i) = 4;
  case {'float64' 'double'}
    varargin{i} = 'double';
    wordsize(i) = 8;
  otherwise
    if strncmp(varargin{i}, 'char', 4)
      if length(varargin{i})>4
        % assume a string like 'char128' which means 128 characters
        wordsize(i) = str2num(varargin{i}(5:end));
        varargin{i} = 'char';
      else
        wordsize(i) = 1;
      end
    else
      ft_error('incorrect type specification');
    end
  end
end

pklen = sum(wordsize);
pknum = nbytes/sum(wordsize);

buf = reshape(buf, pklen, pknum);

for i=1:nfield
  rowbeg = sum(wordsize(1:(i-1)))+1;
  rowend = sum(wordsize(1:(i-0)))+0;
  sel = buf(rowbeg:rowend,:);
  if strcmp(varargin{i}, 'char')
    varargout{i} = char(sel)';
  else
    varargout{i} = typecast(sel(:), varargin{i});
  end
end

                                                                                                                                                                                                                                                                 e the unused coils
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
                                                                                                                                                                                                                                                                                         �       ��$�   �D$H�|$H tU�|$@ ~%膄  H��`D��$�   D�D$HH�rp H��莂  H��$�    tH��$�   �fw  HǄ$�       ��   H��$�    tH��$�   �=w  HǄ$�       �   A�   H�D$8H��L$l�A����D$HHcD$HH��t,�|$@ ~#��  H��`A�   D�D$HH� p H����  �qD��$�   H�D$8H�P�L$l������D$H��$�   9D$Ht.�|$@ ~%苃  H��`D��$�   D�D$HH��o H��蓁  �H�L$8�.  H�D$8    ����H�� ��  H�|$8 t
H�L$8�g.  H�D$8    �   �v  H��o ��u  �� �ȉޛ H��o ��u  H��o ��u  ��� �ȉ�� H�uo �u  3���u  3�H�ĸ   ��������H��8�D$     �|$  ~褂  H��`H�uo H��蹀  H�=m�  txH�d� H�8 tH�W� H��u  H�H� H�     H�:� H�x tH�,� H�H�Wu  H�� H�@    H�=�  tH�� �2u  H��     H��8���������������H��8�D$     �|$  ~��  H��`H��n H����  H�=��  txH��� H�8 tH��� H���t  H��� H�     H��� H�x tH�t� H�H�t  H�d� H�@    H�=T�  tH�K� �rt  H�;�     �E�     H�=!�  tH�� H� �@    H��8����������H��8�D$     �|$  ~��  H��`H�n H���  H�=ݙ  ��   �D$$    �
�D$$���D$$�|$$d��   HcD$$Hk�H��� H�< t1HcD$$Hk�H��� H��s  HcD$$Hk�H�x� H�    HcD$$Hk�H�`� H�| t3HcD$$Hk�H�H� H�L�bs  HcD$$Hk�H�.� H�D    �S���H�=�  tH�� �.s  H���     ��     H�=ݘ  tH�Ԙ H� �@    H��8����������������������H��H�D$     �|$  ~�  H��`H��l H����}  H�=}�  ��  H�p� H� �H�����D$$�|$$ u5H�S� H� H�D$(�b  H��`H�L$(D�AH��l H���n}  �{  H�� H� �8   w�!� �'	 �*H� � H� �L$$����D$03Ҹ    �L$0���� �   �v  H�ԗ H�=̗  u(��~  H��`A�_   H�dl H����|  �   �V�  �   �dv  H��� H�H��� H�8 u(�~  H��`A�c   H�Kl H���|  �   ��  H�J� H� H�H� H�	� �H�:� H� �A� �HH�� H� H�� H�	�@�AH�� H� � �� �D$$�����u  H�� H�AH�� H�x u(��}  H��`A�j   H��k H����{  �   �f�  H��H����������������������H��8�D$     �|$  ~�}  H��`H��k H���{  H�=]�  ��   �@  �!u  H�V� H�=N�  u(�S}  H��`A�t   H��k H���b{  �   �Ѕ  �D$$    �
�D$$���D$$�|$$d}3HcD$$Hk�H��� H�    HcD$$Hk�H�� H�D    �H��8������������������H�T$H�L$H��8  H��y H3�H��$   �D$(    �   �Ot  H�D$ H�|$  uH��$H  H�     ������  �   �t  H�L$ H�H�D$ H�8 u#H��$H  H�     H�L$ �So  ������T  H�D$ H�@    H��$H  H�L$ H��|$(~H��$@  H��Q���H��$@  H� �@��$�   ��$�     k��$�     �B  ��$�     ��   ��$�     ��  ��$�     �  ��$�     ��	  ��$�     �  �K  ��$�     �@  ��$�     ��  ��$�     ��  ��$�     �<  �  �|$(~�{  H��`H��i H���/y  H��g ��m  H��g ��m  H��g ��m  H��$@  H�@H�D$H�|$(~
H�L$H�5���� ������������   �`r  H��� H�=}�  u(�z  H��`A��   H�i H���x  �   ��  �   �r  H�B� H�H�8� H�8 u(�Iz  H��`A��   H�i H���Xx  �   �Ƃ  H�D$H�@����q  H��� H�AH�� H�x u(��y  H��`A��   H��h H���x  �   �v�  A�   H��$@  H�PH��� H���m  H�D$H�@H��$@  H�IH��D��H��H�t� H�H�m  H�d� H� �@    H�S� H� �@    ��������H�D$ H� �   f�H�D$ H� �@    H�= �  t.H�� H�x t H�	� H�8 tH�D$ H� �  f�H�H�D$ H� �  f�HH��e ��k  H��e �k  H��e �k  �  �|$(~�x  H��`H��g H����v  H�Xe �k  H�Te �sk  H��$@  H�@H�D$p�|$(~
H�L$p�����|$(~H��$@  H� �PH��$@  H�H����H�D$ H� �   f�H�D$ H� �@    H��$@  H� �@H��sH�D$ H� �  f�H�c  H�=ސ  t
H�=ܐ  uH�D$ H� �  f�H�9  H��� H� H�L$p�	9tH�D$ H� �  f�H�  H��� H� H�L$p�I9HtH�D$ H� �  f�H��  H�D$p�q� 9HvH�D$ H� �  f�H�  H�7� H� �H�|�����$�   H�D$ H� �  f�H��$�    u7�!w  H��`H�L$pD�AH�Qf H���-u  H�D$ H� �  f�H�P  H�ԏ H� ��$�   �����$�   H��$@  H�@H��H��$�   H��� H�@H��$�   Ǆ$�       ���$�   ����$�   H�D$p�@9�$�   ��   ��$�   ��$�   ��$�   ��H��$�   H�H�ʋI� ��$�   ��L��$�   L�I��H��$�   D��H��H��$�   H���Gj  H��� H� �@��H�� H�	�A�� ���� fn� [��Ԏ f���H*��^��,���� ��� +ȋ���� ����H�pb �h  H�Tb �mh  H�@b �ah  �v  �|$(~�vu  H��`H��d H���s  H�b �7h  H�b �+h  H�='�  t-H�=-�  t#H��$@  H� H��$@  H�Q�H�l�����}5H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �9  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �D$P    H��$@  H� �@9D$P��  Hc�� Hk�H�q� H�< t5Hcs� Hk�H�X� H��sg  HcX� Hk�H�=� H�    Hc>� Hk�H�#� H�| t7Hc$� Hk�H�	� H�L�#g  Hc� Hk�H�� H�D    �D$PH��$@  HAH�D$h�|$(~
H�L$h�����    �xk  Hc�� Hk�H��� H�
Hc�� Hk�H��� H�< u(�s  H��`A�'  H��b H���q  �   �	|  �D$PH��$@  HAHcV� Hk�A�    H��H�2� H��ig  Hc2� Hk�H�� H��x�u&H��� H� Hc� Hk�H�� H�
�@�A�D$PH�� �D$PH�D$h�@���j  HcՋ Hk�H��� H�D
Hc�� Hk�H��� H�| u(�r  H��`A�3  H�Eb H���p  �   �{  H�D$h�@�L$PH��$@  HJHcd� Hk�H��$�   D��H��H�;� H��$�   H�L�if  H�D$h�@�L$Pȋ��D$P�|$(~Hc� Hk�H��� H��S������ ����� fn� [��^N� �,�k�d�Պ +ȋ��ˊ H��� H� �@��H��� H�	�A�����H�c^ �td  H�G^ �hd  �}  �|$(~�}q  H��`H�Va H���o  H�=F�  u5H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H��] ��c  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    H�D$ H� H�L$ H��A�   H��� L��P�:���H�L$ H�	�AH��� H� H�L$ H�	H�T$ H��H��$   D�HH�q� L�@�QH��$   H�������H�L$ H�	�AH�] �9c  �N  �|$(~�Np  H��`H�?` H���cn  H�=�  t
H�=�  u5H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    ��  H��\ ��b  H��\ �b  H��$@  H� �x t8A�   H��$@  H�PH�L$X��c  �|$\�uH��� H� �@�ȉD$\�^H�n� H� �}� 9Hv.H�Y� H� �h� �@+��D$XH�@� H� �@�ȉD$\��D$X    H�#� H� �@�ȉD$\�|$(~H�	� H������|$(~
H�L$X�����|$X r�|$\ sM��n  H��`H�_ H���m  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H��� H� �@9D$XsH�{� H� �@9D$\rM�n  H��`H��^ H���l  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H�� H� �L$X�@+�;!� vM�n  H��`H�W^ H���3l  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �2  H��� H� �H�������$�   ��$�    ukH��� H� H��$  �m  H��`H��$  D�AH��] H���k  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �D$X�L$\+ȋ�����$�   H�� H� ��$�   �����$�   ��H��H���d  H�L$ H�AH�D$ H�x u.�l  H��`H�6] H����j  H�D$ H� �  f�H��  H�y� H� � ��$�   ��$�   H�D$ H�@H��H��$�   �D$Xf���H*��M� f���H*��^��,��5� �L$X+ȋ���$�   H�D$ H�@H�D$pH�� H� H�L$p� �H�� H� H�L$p�@�AH�D$p��$�   �H��$�   ��$�   H�L$p�AH�D$p�@H��H�L$ H�	�A��$�   ��$�   ȋ�;�� wE��$�   ��$�   ����$�   ��$�   ��H�`� HJD��H��H��$�   �_  �   ��$�   �G� +ȋ���$�   ��$�   ��$�   +ȋ���$�   ��$�   ��$�   ����$�   ��$�   ��H�� HJD��H��H��$�   �_  ��$�   ��$�   ����$�   ��$�   ��H��$�   H�H��D��H��� H�P��^  H�YW �r]  H�EW �f]  �{  �|$(~�{j  H��`H�[ H���h  H�=D�  tH�=J�  tH�1� H� �x u5H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H��V ��\  H��V ��\  �   �a  H�D$`H�|$` u(��i  H��`A��  H��Z H����g  �   �Xr  H��$@  H� �x tA�   H��$@  H�PH�L$`�]  �bH�f� H� �xdv0H�V� H� �@��dH�L$`�H�?� H� �@��H�L$`�A�"H�D$`�     H�� H� �@��H�L$`�A�|$(~H��� H������|$(~
H�L$`�����H�|$` u5H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �m  H�D$`�8 rH�D$`�x sM�h  H��`H��Y H���f  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H�>� H� H�L$`�@9sH�(� H� H�L$`�@9ArM�/h  H��`H�(Y H���Df  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �  H�Ā H� H�L$`�	�@+���dvM��g  H��`H��X H����e  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �)  H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    H�D$`H�L$`�	�@+�����$�   Ǆ$�       ���$�   ����$�   ��$�   9�$�   ��  �|$(~NH�D$`� �$�   H�L$`�	�$�   ��f���H*��^>� �,�k�d+���Hk�H�� H�����H�D$`� �$�   H�L$`�	�$�   ��f���H*��^�� �,�k�d+���Hk�H�L$ H�	H�T$ H��H��$  A�    L�? M� �QH��$  H��訿��H�L$ H�	�AH�D$`� �$�   H�L$`�	�$�   ��f���H*��^j� �,�k�d+���Hk�H��~ H�H�L$`�	�$�   H�T$`��$�   ��f���H*��^!� �,�k�d+ʋ�Hk�H�T$ H�L�D$ I��L��$  D�HH�r~ L�D�RH��$  H���ھ��H�L$ H�	�A�.���H�|$` tH�L$`�\X  H�D$`    H��Q �	X  H��Q ��W  �  H��Q ��W  H��Q ��W  H��Q ��W  H�=�}  tA�/�������������H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �0H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    H�,Q �MW  H�(Q �AW  H�$Q �5W  �J  H�Q �*W  H��P �W  H�=}  tYH�=}  tO� }     H��| H� �} �HH�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �0H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    H�`P �yV  H�LP �mV  �  H�;P �bV  H�?P �VV  H�=R|  �,  H�=T|  �  �T|     H�-| H� �D| �HǄ$�       ���$�   ����$�   ��$�   d��   ��$�   Hk�H��{ H�< t5��$�   Hk�H��{ H���U  ��$�   Hk�H��{ H�    ��$�   Hk�H��{ H�| t7��$�   Hk�H��{ H�L�U  ��$�   Hk�H�p{ H�D    �>���H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    �0H�D$ H� �   f�H�D$ H� �  f�HH�D$ H� �@    H��N ��T  H��N ��T  ��  H�D$ H� �   f�H�=�z  tH��$@  H� �@H��t%H�D$ H� �  f�HH�D$ H� �@    �v  H��$@  H�@H��$�   �   �6Y  H��$�   H��$�    u%H�D$ H� �  f�HH�D$ H� �@    �:  H�D$ H� �  f�HH�D$ H� �@   H�D$ H��$�   H�HH��M ��S  H��y H� �@��$�   H��y H� �@��$�   H��M �S  H��$�   �x t'H��$�   � 9�$�   wH��$�   �@9�$�   v(H��$�   ��$�   �H��$�   ��$�   �H�l  3�H�L$x�����3�H��$�   �@��  ��L$xȋ���H�D$83�H��$�   �@��  ���i��  �L$|ȋ�i��  �D$@�|$@ ʚ;|H�D$8H��H�D$8�D$@- ʚ;�D$@��H��L ��R  L�D$8H��L H��L ��R  ��$�   H��L �R  H�kL �R  H��x H� �@��$�   H�{x H� �@��$�   H�7L �XR  H��$�   � 9�$�   w"H��$�   �@9�$�   w��$�    �T���H��$�   ��$�   �H��$�   ��$�   �H��_  H��`H�HP H���4]  �|$( ~&� _  H��`D��w D��w H�;P H���]  3�H��$   H3��X  H��8  ����������H�T$�L$H��(H�D$8H�D$�$    ��$���$�D$09$s9H�D$� �D$H�D$H�L$�I�H�D$�L$�HH�D$H��H�D$�H��(������������������H�T$�L$H��(H�D$8H�D$�$    ��$���$�D$09$sdH�D$� �D$H�D$�@�D$H�D$H�L$�I�H�D$H�L$�I�HH�D$�L$�HH�D$�L$�HH�D$H��H�D$�H��(�������H�T$�L$H��(H�D$8H�D$�$    ��$���$�D$09$��   H�D$� �D$H�D$�@�D$H�D$�@�D$H�D$�@�D$H�D$H�L$�I�H�D$H�L$�I�HH�D$H�L$�I�HH�D$H�L$�I�HH�D$�L$�HH�D$�L$�HH�D$�L$�HH�D$�L$�HH�D$H��H�D$�.���H��(����������L�D$�T$�L$H��8�D$H�D$ �|$ 
wG�D$ H�ŕ�����|j  H����.H�T$P�L$@�����H�T$P�L$@�	����H�T$P�L$@����H��8�Gj  Gj  Ij  Yj  ij  Gj  Ij  Yj  ij  Yj  ij  ��������L�D$�T$�L$H��H�D$     �D$ H���L$PH;���   �D$ H�L$`H�H��H�D$(H�T$(�   �o���H�D$(�@�L$ H�D�D$ �D$P9D$ v������ZH�D$(� �D$0�|$0t�*H�D$(�@�L$XH��H;�rH�D$(H��H�ЋL$X����H�D$(�@�L$ H�D�D$ �J���3�H��H�����������H�T$�L$H��H�D$     �D$ H�� �L$PH;��  �D$ H�L$XH�H��H�D$(H�T$(�   ����H�D$(�@�L$ H�D �D$ �D$P9D$ v
������   H�D$(��λ���D$0H�D$(�H轻���D$4H�D$(�L$0�H��H�L$(�T$4�Q���H�L$(;Av������h�D$ H�L$XH�H��L��H�D$(�H�D$(�H�����D$ H�L$XH�H��H�L$(�T$0�Q�ʋ�H�L��H�D$(�PH�D$(�H�W��������3�H��H������������L�D$�T$f�L$H��8�D$@�D$(�|$(  9�|$(  tR�|$(  ��   �|$(  ��   �|$(  ��   �  �|$(  t �|$(  t3�|$(  tF��   3���   �|$HuH�T$P�   ����3��   �|$HuH�T$P�   �����3��   H�T$P�   �����3��   H�D$PH�D$ H�T$ �   ����H�D$ H��H�L$ H�T$ �	�JL��H�D$ �P�&���3��FH�T$P�   �s���H�D$PH���L$HH��L��H�D$P������H�T$P�L$H�c���������H��8��������L�D$�T$�L$H��H�D$     �D$ H���L$PH;���   �D$ H�L$`H�H��H�D$(H�D$(�@�L$ H�D�D$ �D$P9D$ v������TH�D$(� �D$0�|$0t�*H�D$(�@�L$XH��H;�rH�D$(H��H�ЋL$X�*���H�T$(�   �{����_���3�H��H����������������H�T$�L$H��H�D$     �D$ H�� �L$PH;���   �D$ H�L$XH�H��H�D$(H�D$(�@�L$ H�D �D$ H�D$(��q����D$0�D$ H�L$XH�H��L��H�D$(�H�D$(�H�w����D$ H�L$XH�H��H�L$(�T$0�Q�ʋ�H�L��H�D$(�PH�D$(�H�<���H�T$(�   �����=���3�H��H������������������H�T$f�L$H��HH�D$XH� �@�D$(H�D$XH��   �����H�D$XH� H��H�й   ����H�D$XH� H��H�й   �����|$( u3���   �D$P�D$0�|$0  t+�|$0  tf�|$0  ��   �|$0  ��   �   H�D$XH�@� �D$,H�D$XH�P�   ����H�D$XH�@H���L$(H��L���T$,�P����zH�D$XH�@H�D$ H�D$ H��H�L$ H�T$ �	�JL��H�D$ �P�����H�T$ �   �8���3��0H�D$XH�P�L$(������H�D$XH�P�   ����3�������H��H����������������H�L$H��(�=$n  ~ �U  H��`H�L$0D�H��F H���"S  H�D$0�8 ~H�D$0������H�D$0�     H��(���������H�L$H��8H�D$@H� H�D$ �=�m  ~�T  H��`H�9F H���R  H�|$  tfH�D$ H�8 tH�D$ H��G  H�D$ H�     H�D$ H�x tH�D$ H�H�gG  H�D$ H�@    H�|$  tH�L$ �HG  H�D$     H��8�������H�L$H��8H�D$@H� H�D$ �=m  ~��S  H��`H��E H���R  H�|$  tfH�D$ H�8 tH�D$ H���F  H�D$ H�     H�D$ H�x tH�D$ H�H�F  H�D$ H�@    H�|$  tH�L$ �F  H�D$     H��8�������H�L$H��8H�D$@H� H�D$ �=Wl  ~�HS  H��`H�	E H���]Q  H�|$  tfH�D$ H�8 tH�D$ H��-F  H�D$ H�     H�D$ H�x tH�D$ H�H�F  H�D$ H�@    H�|$  tH�L$ ��E  H�D$     H��8�������H�L$H��8H�D$@H� H�D$ �=�k  ~�R  H��`H�iD H���P  H�|$  tfH�D$ H�8 tH�D$ H��}E  H�D$ H�     H�D$ H�x tH�D$ H�H�WE  H�D$ H�@    H�|$  tH�L$ �8E  H�D$     H��8�������H�L$H��(�=k  ~��Q  H��`H��C H���
P  H�D$0H�8 t$H�D$0H�8 tH�D$0H���D  H�D$0H�     H��(���H�T$H�L$H��8H�T$HH�L$@�CC  ��|H�T$HH��C ��C  ������/H�T$HH�L$@�C  �D$ �|$  }H�T$HH�yC �C  �D$ H��8��������������������D�D$�T$H�L$H��H�D$     �   �L$`��B  H�D$(�D$$    �
�D$$���D$$�D$`9D$$��   �D$ �D$0�
�D$0���D$0�D$X9D$0}HcD$0H�L$P���u��֋D$X9D$0|�D$$����H��B ��B  �?HcD$ H�L$PH�H��H���1B  H�D$8L�D$8�T$$H�L$(�B  �D$0���D$ �U���H�D$(H��H���������������������D�L$ D�D$H�T$H�L$H��  �D$     �D$$    HǄ$@      HcD$ H��Hc�$�  H;��N  HcD$ H��$�  H�H��H��$H  HcD$ H��$H  �IH�DHc�$�  H;�vH��$H  �PH�@B ��A  ��  H��$H  � ��$X  ��$X  t=��$X  �  ��$X  ��   ��$X  �Z  ��$X  �  �  H��A H��$�  �j�����$0  ��$0   }�U  H��$H  H��D��$�  H��$H  �QH������H��$8  L��$8  D��$0  3�H��$�  �@  �  H��$H  �x\  tH��A ��@  ��  H�0A H��$�  �������$0  ��$0   }�  E3�A�	   �\  �   �'@  H��$8  H��$H  H��H��$`  H��$8  ��?  A�\  H��$`  H��H���;B  L��$8  D��$0  3�H��$�  ��?  �8  H�A H��$�  �#�����$0  ��$0   }�  E3�A�	   H��$H  �P�   �y?  H��$8  H��$H  �@H��$h  H��$H  H��H��$p  H��$8  �7?  H��$h  L��H��$p  H��H���uA  L��$8  D��$0  3�H��$�  �?  �r  H�Z@ H��$�  �]�����$0  ��$0   }�H  E3�A�	   H��$H  �P�   �>  H��$8  H��$H  �@H��$x  H��$H  H��H��$�  H��$8  �q>  H��$x  L��H��$�  H��H���@  L��$8  D��$0  3�H��$�  �@>  �  H��? H��$�  ������$0  ��$0   ��   H��$H  �@3ҹ   H��$P  ��$�  9�$P  ~��$�  ��$P  E3��   ��$�  �=  H��$8  Hc�$P  H��H��$�  H��$H  H��H��$�  H��$8  �o=  H��$�  L��H��$�  H��H���?  ��   �|$$ ��   H��$H  �x vǄ$�     �Ǆ$�      E3�A�	   ��$�  H��$H  �H�=  H��$8  H��$H  �@H��$�  H��$H  H��H��$�  H��$8  ��<  H��$�  L��H��$�  H��H���	?  HcD$$H��$8  H�L�0�D$$���D$$�H�$> �=  H��$H  �@HcL$ H�D�D$ �����|$$ ��   H�7> H��$�  �������$0  ��$0   }�   �   �L$$�<  H��$8  Ǆ$T      ���$T  ����$T  �D$$9�$T  }#Hc�$T  L�D�0��$T  H��$8  �;  ��L��$8  D��$0  3�H��$�  �;  H�ĸ  �������������������L�D$H�T$�L$H��   �D$(    �D$h    H�D$`    H�D$     H��< H�D$0H�V= H�D$8H�b= H�D$@H�f= H�D$HH�r= H�D$PH�~= H�D$X�   ��@  H�D$`�   ��@  H�L$`H�H�D$`H�@    H�D$`H� �   f�H�D$`H� �  f�HH�D$`H� �@    �|$( tH�D$`H�����L�D$ H�T$`��$�   �ɲ���D$h�|$h ��  �|$( tH�D$ H��v���H�D$ H� �@=  ��  H�D$ H�@H�D$p�|$( t
H�L$p�Э��L�L$0A�   �   �   �,:  H��$�   H�H�D$p� f���H*��9  L��E3�3�H��$�   H���9  H�D$p�@f���H*��~9  L��A�   3�H��$�   H��9  H�D$p�@f���H*��M9  L��A�   3�H��$�   H��9  H�D$p�@�Z��9  L��A�   3�H��$�   H��\9  H�D$p�@f���H*���8  L��A�   3�H��$�   H��+9  H�D$p�@f���H*��8  L��A�   3�H��$�   H���8  H�D$ H�@H��H�L$pD�	H�L$pD�AH��H��$�   H������H�D$ H� �@�D$hH�|$  tfH�D$ H�8 tH�D$ H���9  H�D$ H�     H�D$ H�x tH�D$ H�H�9  H�D$ H�@    H�|$  tH�L$ �9  H�D$     H�|$` tfH�D$`H�8 tH�D$`H��]9  H�D$`H�     H�D$`H�x tH�D$`H�H�79  H�D$`H�@    H�|$` tH�L$`�9  H�D$`    �D$hH�Ĉ   ����������������L�D$H�T$�L$H���   �D$(    �D$p    H�D$h    H�D$     H��9 H�D$0H��9 H�D$8H�
: H�D$@H�: H�D$HH��9 H�D$P�   �=  H�D$h�   �=  H�L$hH�H�D$hH�@    H�D$hH� �   f�H�D$hH� �  f�HH�D$hH� �@    H��$  H�8 ��   H��$  H���6  H����   H��$  H���6  ������   H��$  H��6  ����urH��$  H��u6  H�D$XH�D$X�H, �D$`H�D$X�H,@�D$d�|$( t
H�L$`�����H�D$hH� H�L$hH��A�   L�D$`�P躝��H�L$hH�	�A�|$( tH�D$hH��{���L�D$ H�T$h��$   �%����D$p�|$( tH�D$ H��ݨ���|$p �`  H�D$ H� �@=  �9  H�D$x    H�D$ H�@H��$�   H�D$ H�@H��H��$�   �|$( tH��$�   �(���H��$�   �@��$�   ��$�   �ȉ�$�   ��$�   	��  ��$�   H��|������  H���E3�A�	   H��$�   �PH��$�   ��5  H�D$xH��$�   H��$�   � �A��H��$�   H�L$x��4  H��$�   L��H��$�   H���7  �*  E3�A�   H��$�   �PH��$�   ��4  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�O4  H��$�   L��H��$�   H���6  �  E3�A�   H��$�   �PH��$�   ��4  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x��3  H��$�   L��H��$�   H���&6  �?  E3�A�   H��$�   �PH��$�   ��3  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�c3  H��$�   L��H��$�   H���5  ��  E3�A�   H��$�   �PH��$�   ��23  H�D$xH��$�   H��$�   � �A��H��$�   H�L$x��2  H��$�   L��H��$�   H���>5  �W  E3�A�
   H��$�   �PH��$�   ���2  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�|2  H��$�   L��H��$�   H����4  ��  E3�A�   H��$�   �PH��$�   ��K2  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�2  H��$�   L��H��$�   H���S4  �l  E3�A�   H��$�   �PH��$�   ���1  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�1  H��$�   L��H��$�   H����3  ��   E3�A�   H��$�   �PH��$�   ��_1  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�1  H��$�   L��H��$�   H���g3  �   E3�A�   H��$�   �PH��$�   ���0  H�D$xH��$�   H��$�   � �A��H��H��$�   H�L$x�0  H��$�   L��H��$�   H����2  ��D$p�����   L�L$0A�   �   �   �~0  H��$  H�H��$�   � f���H*���/  L��E3�3�H��$  H��=0  H��$�   �@f���H*���/  L��A�   3�H��$  H��	0  H��$�   �@f���H*��/  L��A�   3�H��$  H���/  H��$�   �@f���H*��b/  L��A�   3�H��$  H��/  L�L$xA�   3�H��$  H��/  �H�D$ H� �@�D$pH�|$h tfH�D$hH�8 tH�D$hH��0  H�D$hH�     H�D$hH�x tH�D$hH�H�`0  H�D$hH�@    H�|$h tH�L$h�A0  H�D$h    H�|$  tfH�D$ H�8 tH�D$ H��0  H�D$ H�     H�D$ H�x tH�D$ H�H��/  H�D$ H�@    H�|$  tH�L$ ��/  H�D$     �D$pH���   �f�b�  ԃ  I�  ��  5�  ��  �  ��  �  ~�  L�D$H�T$�L$H��   �D$(    H�D$h    H�D$     H��0 H�D$0H��0 H�D$8H��0 H�D$@H��0 H�D$HH�
1 H�D$P�   �3  H�D$h�   �3  H�L$hH�H�D$hH�@    H�D$hH� �   f�H�D$hH� �  f�HH�D$hH� �@    H��$�   H�8 ��   H��$�   H��-  H����   H��$�   H��m-  ������   H��$�   H��L-  ����urH��$�   H��-  H�D$`H�D$`�H, �D$xH�D$`�H,@�D$|�|$( t
H�L$x����H�D$hH� H�L$hH��A�   L�D$x�P�b���H�L$hH�	�A�|$( tH�D$hH��#���L�D$ H�T$h��$�   �ͤ���D$t�|$( tH�D$ H�腟���|$t ��  H�D$ H� �@=  �o  �D$p    �D$X    H�D$ H� �@9D$XsOHcD$XH�L$ HAH��$�   �|$( tH��$�   舡��H��$�   �@HcL$XH�D �D$X�D$p���D$p�L�L$0A�   �T$p�   ��+  H��$�   H��D$X    �D$,    �
�D$,���D$,�D$p9D$,��  HcD$XH�L$ HAH��$�   HcD$XH�L$ H�IH�D H��$�   H��$�   �赚��H��$�   �I�ȋ���H��$�   H�H��H��$�   L��$�   H��$�   D�@�   H��$�   ��%  L��E3��T$,H��$�   H���*  L��$�   H��$�   D�@�   H��$�   �H�b%  L��A�   �T$,H��$�   H��*  H��$�   fn@����X,� �=*  L��A�   �T$,H��$�   H��z*  H��$�   fn@����
*  L��A�   �T$,H��$�   H��G*  H��$�   fn@�����)  L��A�   �T$,H��$�   H��*  H��$�   �@HcL$XH�D �D$X�9����H�D$ H� �@�D$tH�|$h tfH�D$hH�8 tH�D$hH���*  H�D$hH�     H�D$hH�x tH�D$hH�H��*  H�D$hH�@    H�|$h tH�L$h�*  H�D$h    H�|$  tfH�D$ H�8 tH�D$ H��*  H�D$ H�     H�D$ H�x tH�D$ H�H�d*  H�D$ H�@    H�|$  tH�L$ �E*  H�D$     �D$tH�Ĩ   ������������̉T$H�L$H��hH�D$0    �D$8    H�L$p��(  ����u3��  H�L$p��(  �D$ �D$x9D$ ~3��s  �D$$    �
�D$$���D$$�D$ 9D$$}[�D$H    �T$$H�L$p�(  H�D$@H�|$@ tH�L$@�t(  ����u3��  H�L$@�P(  �D$H�D$8�L$H�D�D$8둋D$ �L$x+ȋ��L$8ȋ��D$8HcD$8H��H���'  H�D$0H�D$0�L$8�HH�D$0�    H�D$0H��H�D$(�D$$    �
�D$$���D$$�D$ 9D$$}O�T$$H�L$p��'  H�D$PH�L$P�'  H���D$LD�D$LH�T$(H�L$P�'  HcD$LH�L$(H�H��H�D$(띋D$ �D$$�
�D$$���D$$�D$x9D$$}H�D$(�  H�D$(H��H�D$(��H�D$0H��h�������������������̉T$H�L$H��8H�D$     H�L$@�'  ����tH�L$@��&  ����t3��   H�L$@�'  HcL$HH;�uH�L$@��&  H��t(H�L$@��&  H��uH�L$@��&  HcL$HH;�u3��lHcD$HH��   H���.&  H�D$ HcD$HH��H�L$ �AH�D$ �    HcD$HH��H�D$(H�L$@�&  H�L$ H��H�T$(L��H���n(  H�D$ H��8���������������������L�D$H�T$�L$H��   H�$1 H3�H��$�   H�D$     H�D$8H�D$`H�D$h    �   f�D$8�  f�D$:�D$<    H��$�   H��%  H��tH��( ��%  H��( H��$�   H��8%  �D$(�|$( }H��( ��%  D�D$(3�H��$�   H��%  H�D$pH�L$p��$  ����tH�L$p��$  ����tH��( �%  H�L$p�$  �H,��D$HH��( H��$�   H��$  �D$(�|$( }H�{( �>%  D�D$(3�H��$�   H���$  H�D$pH�L$p�R$  ����tH�L$p�G$  ����tH�Q( ��$  H�L$p�$  �H,��D$LH�Z( H��$�   H��"$  �D$(�|$( }H�@( �$  D�D$(3�H��$�   H��l$  H�D$pH�L$p��#  ����tH�L$p�#  ����tH�( �i$  H�L$p�#  �H,��D$PH�( H��$�   H��#  �D$(�|$( }H��' �($  D�D$(3�H��$�   H���#  H�D$pH�L$p�<#  ����tH�L$p�1#  ����tH��' ��#  H�L$p�#  �Z��D$TH��' H��$�   H��#  �D$(�|$( }H��' �#  D�D$(3�H��$�   H��U#  H�D$pH�L$p�"  ����tH�L$p�"  ����tH��' �R#  H�L$p�|"  �H,��D$XA�   L�D$H�T$<H�L$h��  �D$<H��' H��$�   H��c"  �D$(�|$( ��   D�D$(3�H��$�   H��"  H�D$pH�L$p�"  ����tH�L$p�e"  H=\  tH�&' �"  �Q�D$4\  �D$0   A�   L�D$0�T$<H�L$h�.  �D$<H�L$p��!  D�L$4L���T$<H�L$h�
  �D$<H��& H��$�   H��!  �D$(�|$( ��   D�D$(3�H��$�   H���!  H�D$pH�L$p��!  ����uH��& �"  �WH�L$p�!  �D$4�D$0   A�   L�D$0�T$<H�L$h�v  �D$<H�L$p�<!  D�L$4L���T$<H�L$h�R  �D$<H��& H��$�   H���   �D$(�|$( ��   D�D$(3�H��$�   H��9!  H�D$pH�L$p�$!  ����uH�L& �M!  �WH�L$p��   �D$4�D$0   A�   L�D$0�T$<H�L$h�  �D$<H�L$p�   D�L$4L���T$<H�L$h�  �D$<H�& H��$�   H��/   �D$(�|$( ��   HǄ$�       D�D$(3�H��$�   H��u   H�D$p�T$HH�L$p�*���H��$�   H��$�    uH��% �y   �9H��$�   �@H��L��L��$�   �T$<H�L$h��  �D$<H��$�   �`  H��% H��$�   H��y  �D$(�|$( ��   HǄ$�       D�D$(3�H��$�   H��  H�D$p�T$HH�L$p�T���H��$�   H��$�    uH�Z% ��  �9H��$�   �@H��L��L��$�   �T$<H�L$h�;  �D$<H��$�   �  �D$<H��H�L$h�AL�D$ H�T$`��$�   �����D$xH�|$h t
H�L$h�n  �|$x ��   H�|$  uH��$ �'  H�D$ H�8 uNH�D$ H�x tH�D$ H�H�  H�D$ H�@    H�|$  tH�L$ �  H�D$     H��$ ��  H�D$ H� �@=  tH�D$ H� �@�D$xH�|$  tfH�D$ H�8 tH�D$ H��G  H�D$ H�     H�D$ H�x tH�D$ H�H�!  H�D$ H�@    H�|$  tH�L$ �  H�D$     �D$xH��$�   H3��%  H�Ĩ   ����������L�D$H�T$�L$H��   H��( H3�H��$�   H�D$     H�D$pH�D$HH�D$0H�D$8H�D$@    �   f�D$0�  f�D$2�D$4    H��# H��$�   H���  �D$(�|$( }H��# �  D�D$(3�H��$�   H��:  H�D$XH�L$X�  ����tH�L$X�  ����tH�t# �7  H�L$X�a  �H,��D$pH�u# H��$�   H��e  �D$(�|$( }H�c# ��  D�D$(3�H��$�   H��  H�D$XH�L$X�
  ����tH�L$X��  ����tH�9# �  H�L$X��  �H,��D$tH�B# H��$�   H���  �D$(�|$( }H�0# �k  D�D$(3�H��$�   H��$  H�D$XH�L$X�  ����tH�L$X�t  ����tH�# �!  H�L$X�K  �H,��D$xH�;" H��$�   H��O  �D$(�|$( }H��" ��  D�D$(3�H��$�   H��  H�D$XH�L$X��  ����tH�L$X��  ����tH��" �  �D$x��$�   ��$�   
��   ��$�   H�gb�����D�  H����D$p�D$t�D$|��   �D$p�D$t�D$|��   �D$p�D$t��H���D$|�   �D$p�D$t��H���D$|�   �D$p�D$t��H���D$|�   �D$p�D$t�D$|�t�D$p�D$t��H���D$|�`�D$p�D$t��H���D$|�K�D$p�D$t��H���D$|�6�D$p�D$t��H���D$|�!�D$p�D$t��H���D$|�H��! �u  H�L$X��  H�D$PA�   L�D$H�T$4H�L$@�e����D$4D�L$|L�D$P�T$4H�L$@�I����D$4L�D$ H�T$8��$�   �ϑ���D$`H�|$@ tH�|$@ tH�L$@�  H�D$@    �|$` ��   H�|$  uH�.! ��  �~H�D$ H�8 uPH�D$ H�x tH�D$ H�H�f  H�D$ H�@    H�|$  tH�L$ �G  H�D$     H��  �v  �#H�D$ H� �@=  tH�D$ H� �@�D$`H�|$  tfH�D$ H�8 tH�D$ H���  H�D$ H�     H�D$ H�x tH�D$ H�H��  H�D$ H�@    H�|$  tH�L$ �  H�D$     �D$`H��$�   H3��7   H�Ę   � ��  ��  ɝ  ��  ��  �  �  3�  H�  ]�  r�  D�L$ L�D$H�T$�L$H��   H�?# H3�H�D$xH�D$0    H�D$     D�? ��$�   H��$�   �  H�D$@H�L$@�	  ���t  �D$P�D$P�D$p�|$p t�|$p�t�IH�� �  �jH�L$@�D  H�D$0H�|$0 uH�� ��  H�L$0��  �D$T�D$T�D$8�/H�L$@�]  �D$T�L$P舆���D$T�D$8H�L$@�  H�D$0D�E> ��$�   H��$�   �M  H�D$@H�L$@�D  ���  �D$X�D$X�D$t�|$t t�|$t�t�IH�, �?  �jH�L$@�  H�D$ H�|$  uH�' �  H�L$ �8  �D$\�D$\�D$,�/H�L$@�  �D$\�L$X�Å���D$\�D$,H�L$@�T  H�D$ �D$,�L$8ȋ��D$l�=|=  }
�D$`�����mD�i= ��$�   H��$�   �e  H�D$@H�L$@��  ����t
�D$`�����2H�L$@�  ����uH�� �X  H�L$@�  �H,��ȉD$`D��< ��$�   H��$�   ��  H�D$@H�L$@�S  ����tH�L$@�H  ����tH�R ��  H�L$@�  �,��D$dD��< ��$�   H��$�   �  H�D$@H�L$@��  ����tH�L$@��  ����tH� �  H�L$@�  �H,��D$hA�    L�D$P��$�   H��$�   �  �D$(D�L$8L�D$0�T$(H��$�   ��  �D$(D�L$,L�D$ �T$(H��$�   ��  �D$(�|$P u
H�L$0�8  �|$X u
H�L$ �'  �D$(H�L$xH3��V  H�Ĉ   ���������������L�D$H�T$�L$H��   H�� H3�H��$�   H�D$     H�D$0H�D$pH�D$x    �D$L    H�D$h    H�D$XH�D$`�   f�D$X�  f�D$Z�D$\    H��$�   H���  ��$�   ��$�    u�  H��$�   H��  ����uH�� �  H�� H��$�   H��V  ��: �=�:  }H�� ��  H�� H��$�   H��$  �z: �=s:  }H�� �  H�� H��$�   H���  �T: H�� H��$�   H���  �/: �=(:  }H�� �b  H�� H��$�   H��  �: �=�9  }H�� �0  �D$P    �
�D$P���D$P��$�   9D$P}$D�L$PH��$�   L� H�T$h�L$\�Y����D$\��L�D$ H�T$`��$�   荊����$�   H�L$h��  ��$�    ��   H�|$  uH� �  H�D$ H�8 uNH�D$ H�x tH�D$ H�H�9  H�D$ H�@    H�|$  tH�L$ �  H�D$     H�� �I  H�D$ H� �@=  tH�D$ H� �@��$�   H�|$  tfH�D$ H�8 tH�D$ H��  H�D$ H�     H�D$ H�x tH�D$ H�H�  H�D$ H�@    H�|$  tH�L$ �z  H�D$     ��$�   H��$�   H3��  H�Ĩ   ���������������L�D$H�T$�L$H��H�D$(    H�D$0    H�D$     �   �  H�D$0�   �  H�L$0H�H�D$0H�@    H�D$0H� �   f�H�D$0H� �  f�HH�D$0H� �@    �|$( tH�D$0H�����L�D$ H�T$0�L$P菈���D$8�|$( tH�D$ H��G����|$8 u#H�D$ H� �@=  tH�D$ H� �@�D$8H�|$0 tfH�D$0H�8 tH�D$0H��1  H�D$0H�     H�D$0H�x tH�D$0H�H�  H�D$0H�@    H�|$0 tH�L$0��  H�D$0    H�|$  tfH�D$ H�8 tH�D$ H���  H�D$ H�     H�D$ H�x tH�D$ H�H�  H�D$ H�@    H�|$  tH�L$ �~  H�D$     �D$8H��H���������L�D$H�T$�L$H��H�D$(    �D$8    H�D$0    H�D$     �   ��  H�D$0�   �  H�L$0H�H�D$0H�@    H�D$0H� �   f�H�D$0H� �  f�HH�D$0H� �@    �|$( tH�D$0H������L�D$ H�T$0�L$P视���D$8�|$( tH�D$ H��_����|$8 u#H�D$ H� �@=  tH�D$ H� �@�D$8H�|$0 tfH�D$0H�8 tH�D$0H��I  H�D$0H�     H�D$0H�x tH�D$0H�H�#  H�D$0H�@    H�|$0 tH�L$0�  H�D$0    H�|$  tfH�D$ H�8 tH�D$ H���  H�D$ H�     H�D$ H�x tH�D$ H�H�  H�D$ H�@    H�|$  tH�L$ �  H�D$     �D$8H��H�L�D$H�T$�L$H��H�D$(    H�D$0    H�D$     �   ��  H�D$0�   ��  H�L$0H�H�D$0H�@    H�D$0H� �   f�H�D$0H� �  f�HH�D$0H� �@    �|$( tH�D$0H��"��L�D$ H�T$0�L$P�τ���D$8�|$( tH�D$ H�����|$8 u#H�D$ H� �@=  tH�D$ H� �@�D$8H�|$0 tfH�D$0H�8 tH�D$0H��q  H�D$0H�     H�D$0H�x tH�D$0H�H�K  H�D$0H�@    H�|$0 tH�L$0�,  H�D$0    H�|$  tfH�D$ H�8 tH�D$ H��  H�D$ H�     H�D$ H�x tH�D$ H�H��  H�D$ H�@    H�|$  tH�L$ �  H�D$     �D$8H��H���������L�D$H�T$�L$H��   H�� H3�H��$�   H�D$     H�D$8H�D$@H�D$`H�D$H�   f�D$8�  f�D$:�D$<   H��$�   H��  H��u.H��$�   H���
  ����tH��$�   H���
  ����tH�� �8  H��$�   H��
  H�D$(H�D$(fW�f/ vǄ$�   �����H�D$(�H, ��$�   ��$�   �D$`H�D$(fW�f/@vǄ$�   �����H�D$(�H,@��$�   ��$�   �D$dH�D$(fW�f/@vǄ$�       �H�D$(�H,@��$�   ��$�   �D$hL�D$ H�T$@��$�   �����D$p�|$p �m  H�|$  uH�K �>
  H�D$ H�8 uNH�D$ H�x tH�D$ H�H��
  H�D$ H�@    H�|$  tH�L$ �
  H�D$     H� ��	  H�D$ H� �@=  uH�D$ H�x tH�D$ H� �@H��tH�D$ H� �@�D$p�   H�� H��$�   H�� H��$�   H�D$ H�@H��$�   L��$�   A�   �   �   ��  H��$�   H�H��$�   � f���H*��_  L��E3�3�H��$�   H��  H��$�   �@f���H*��.  L��A�   3�H��$�   H��m  H�|$  tfH�D$ H�8 tH�D$ H��	  H�D$ H�     H�D$ H�x tH�D$ H�H�[	  H�D$ H�@    H�|$  tH�L$ �<	  H�D$     �D$pH��$�   H3���  H�ĸ   ����D�L$ L�D$�T$H�L$H��(H�D$0H�8 t�|$8 t!H�D$0H�8 u�|$8 uH�|$@ u�|$H tH� �  �|$H u�D$8�nH�D$0H�8 u�D$H���%  H�L$0H��%�D$H�L$8ȋ�����H�D$0H��  H�L$0H��D$H�L$8H�T$0H
D��H�T$@�k	  �D$H�L$8ȋ�H��(����������̉L$H���D$ �$�<$
wc�$H�QN������  H���	   �H�   �A�   �:�   �3�   �,�
   �%�   ��   ��   ��   �	�   �3�H��Ð�  ��  ±  ɱ  б  ױ  ޱ  �  �  �  ��  �������������������̉L$H���D$ �$�$���$�<$waHc$H��M�����ܲ  H���3��K�
   �D�	   �=�   �6�   �/�   �(�   �!�   ��   ��   ��   ������H��� ��  ϲ  ��  ��  ��  ��  ��  ��  ��  ��  ��  Ȳ  ��������������������L�L$ D�D$�T$�L$H��   ��$�   �D$H�|$H
��  �D$HH��L������  H���H��$�   H�D$@��$�   �D$8��$�   �D$<H�T$8�   �^  H�D$ H�L$ �I  H�D$0�D$(    �
�D$(���D$(��$�   ��$�   9D$(s.H�D$@f� H�L$0f�H�D$0H��H�D$0H�D$@H��H�D$@���  E3�A�	   ��$�   ��$�   �f  H�D$ ��$�   ��$�   ��H�D$PH�L$ �;  H�L$PL��H��$�   H���  �  E3�A�   ��$�   ��$�   �  H�D$ ��$�   ��$�   ��H��H�D$XH�L$ ��  H�L$XL��H��$�   H���  �.  E3�A�   ��$�   ��$�   �  H�D$ ��$�   ��$�   ��H��H�D$`H�L$ �x  H�L$`L��H��$�   H���  ��  E3�A�   ��$�   ��$�   �E  H�D$ ��$�   ��$�   ��H��H�D$hH�L$ �  H�L$hL��H��$�   H���Z  �j  E3�A�   ��$�   ��$�   ��  H�D$ ��$�   ��$�   ��H�D$pH�L$ �  H�L$pL��H��$�   H����  �  E3�A�
   ��$�   ��$�   �  H�D$ ��$�   ��$�   ��H��H�D$xH�L$ �W  H�L$xL��H��$�   H���  �  E3�A�   ��$�   ��$�   �$  H�D$ ��$�   ��$�   ��H��H��$�   H�L$ ��  H��$�   L��H��$�   H���3  �C  E3�A�   ��$�   ��$�   �  H�D$ ��$�   ��$�   ��H��H��$�   H�L$ �  H��$�   L��H��$�   H����  ��   E3�A�   ��$�   ��$�   �T  H�D$ ��$�   ��$�   ��H��H��$�   H�L$ �"  H��$�   L��H��$�   H���c  �vE3�A�   ��$�   ��$�   ��   H�D$ ��$�   ��$�   ��H��H��$�   H�L$ �   H��$�   L��H��$�   H����  �E3�3�3��   H�D$ H�D$ H�Ĩ   �f�f�  �  f�  Ǵ  )�  ��  �  J�  ��  �  �  �%B� �%4� �%&� �%� �%
� �%�� �%� �%�� �%Ҋ �%Ċ �%�� �%�� �%�� �%�� �%�� �%�� �%r� �%d� �%V� �%H� �%:� �%,� �%� �%� �%� �%� �%� �%؊ �%ʊ �%�� �%�� �%�� �%�� �%�� �%� �%�� �%� �%� �%&� �%(� �%r� �%t� �%v� �%x� �%z� �%|� �%~� �%�� �%�� �%� �%� �%� �%� �%� �%^� �%�� �%�� �%�� �%�� �%�� �%�� �%�� �%�� �%�� �% �%Ċ �%Ɗ ��H��t7SH�� L��H�@' 3�� � ��u�$  H���F� ���/$  �H�� [����������������������ff�     H+�L����t�B�	:�uVH����tWH��   u�I� �J�	f���f���w�H�J�	H;�u�I��������~L�H���H��I3�I��t��H�H����3��fff���t'��t#H����t��tH����t��t����t��u�3��H�H����������ff�     L��H+���  I��ra��t6��t�
I�ȈH����tf�
I��f�H����t�
I���H��M��I��uQM��I��tH�
H�H��I��u�I��M��uI���@ �
�H��I��u�I���fffffff�     fff�ff�I��    sBH�
L�T
H�� H�A�L�Q�H�D
�L�T
�I��H�A�L�Q�u�I���q���fff�     f�H��   r��    
D
@H���   ��u�H��   �@   L�
L�T
L�	L�QL�L
L�T
L�IL�QL�L
 L�T
(H��@L�I�L�Q�L�L
�L�T
���L�I�L�Q�u�I��   I��   �q�����$ ����ffff�     fff�fff�f�I�I��ra��t6��tH�Ɋ
I�Ȉ��tH��f�
I��f���tH���
I���M��I��uPM��I��tH��H�
I��H�u�I��M��uI��� H�Ɋ
I�Ȉu�I���fffffff�     fff�ff�I��    sBH�D
�L�T
�H�� H�AL�QH�D
L�
I��H�AL�u�I���s���ffff�     f�H�� ���w��    H��   
D
@��u�H��   �@   L�L
�L�T
�L�I�L�Q�L�L
�L�T
�L�I�L�Q�L�L
�L�T
�H��@L�IL�QL�L
L�
��L�IL�u�I��   I��   �q�����$ ����@SH�� H��H��" H��u �v'  �   �%  ��   �v  H��" H��A�   LE�3�H�� [H�%� H�\$H�t$WH�� H��H���w|�   H��HE�H��" H��u �'  �   �$  ��   �  H�d" L��3���� H��H��u,9�( tH���'  ��t��  �    �  �    H����['  �n  �    3�H�\$0H�t$8H�� _�������������ff�     H��H��H�   tf��H����t_�u�I��������~I� �H�M��H��L�H��I3�I#�t�H�P���tQ��tGH����t9��t/H����t!��t����t
��u�H�D��H�D��H�D��H�D��H�D��H�D��H�D��H�D��@SH�� E�H��L��A���A� L��tA�@McP��L�Hc�L#�Ic�J�H�C�HHK�At�A���H�L�L3�I��H�� [�5   �H��(M�A8H��I�������   H��(��������������ff�     H;Y uH��f����u��H����%  �H�T$L�D$L�L$ USWH��H��PH�e� H��3�H��H�M�D�B(��	  H��u�  �    �p7  ����KH��t�L�M0H�M�E3�H���E�����E�B   H�]�H�]��*  �M؋�x	H�M�� �H�U�3��&  ��H��P_[]�L�D$L�L$ H��(L�L$H�h7  H��(����L��M�CM�K H��8I�C E3�I�C��I:  H��8�L�L$ H��8H�D$`H�D$ �,:  H��8����L��M�K H��8I�C(I�C�I�c� �:  H��8���L��H��8I�C0I�C�I�C(I�C��l:  H��8����L��M�CM�K H��8I�C E3�I�C���;  H��8�L�L$ H��8H�D$`H�D$ ��;  H��8����H��H�HH�PL�@L�H H��(H�P��7  H��(����H��H�HH�PL�@L�H H��(H�P��7  H��(����H��H�PL�@L�H H��(L�@�7  H��(����H��H�PL�@L�H H��(L�@�7  H��(������������������ff�     L��M�t$H+���t(������   H��I��t��u��I���H�H��H�I��v&I��������~L�L��I���M3�I� �M��t�I����   �����   H��I��tx��$tuH��I��tiH�����tbH��I��tV��$tSH��I��tGH�����t@H��I��t4��$t1H��I��t%�����tH��I��t��$tH��I���<���I���H�H3�I��rE��t
H���I����I�� rH�H�QH�QH�QH�� I�� s�I�� I��r	H�H����I��I��r�H����I�����H��;  H�RG  H�� H�H;  H�� H�� H�o;  H�� H�� H��:  H�� H�tF  H�� H��:  H�� H��9  H�� H�j9  H� ��̋
 � �����c������H��H�PH�HL�@L�H SVWATH��(H��3�3�H������u�j  �    �73  �����   3�H������t�L�d$`�  ��G@��   H���M  ���t*���t%Hc�H��H��L��, ��Hk�XI�H�� �H�� H��L�~, �B8u%���t���tHc�H��H����Hk�XI��A8�t�  �    �2  �����u*H���$H  ��M��E3�H�T$XH���%  ��H�׋���H  �H���^  ��H��(A\_^[���L�D$L�L$ H��(L�L$H�M  H��(����L�D$L�L$ H��(L�L$H�M  H��(����H��H�PL�@L�H H��(L�HE3��qM  H��(�L�D$L�L$ H��(L�L$H�xM  H��(����H��H�PL�@L�H H��(L�HE3��QM  H��(�H�=� �@SH�� ��= �   ��u�   �;�L�HcȺ   �]= �XN  H�I- H��u$�PH�ˉ@= �;N  H�,- H��u�   �v3�H��� H�H��0H��H��t	H��, ��E3�H��� E�HI��L��* I��H����I��Hk�XL�I���tI���tM��u�����I��H��0I��u�3�H�� [�H��(��Q  �=|  t�)O  H��, H��(�	����@SH�� H��H�$� H;�r>H��� H;�w2H��H��������*H+�H��H��H��H��?�L�S  �kH�� [�H�K0H�� [H�%1z �@SH�� H�ڃ�}���zS  �kH�� [�H�J0H�� [H�%�y ���H��� H;�r5H�� H;�w)�qH+�H��������*H��H��H��H��?�L��Q  H��0H�%�y ��}�r����Q  H�J0H�%�y ���@SH�� �م�x	�#S  ;|�S  ��S  L��Hc�I��H�� [����H�\$WH�� H�ٿ   ����T  �H��t+�; t&H������L��H�Ӌ��{X  D��H��{ ���jX  �-  ���x	�R  ;|�R  ��R  Hc�H��H�������L��H�Ӌ��.X  A�   H��{ ���X  �����T  H�\$0H�� _����H�\$H�t$WH�� H��H��H��u
H�������jH��u������\H���wCH�7 �   H��HD�L��3�L���ex H��H��uo9G tPH���E  ��t+H���v�H���3  �F  �    3�H�\$0H�t$8H�� _��)  H����w ����  ����  H����w ���  �H������������������ff�     H��I��rS��I�I��I��@rH�ك�tL+�H�H�M��I��?I��u9M��I��I��tfff��H�H��I��u�M��t
�H��I��u��@ fff�ff�I��   s0H�H�QH�QH��@H�Q�H�Q�I��H�Q�H�Q�H�Q�u��fD  H�H�QH�QH��@H�Q�H�Q�I��H�Q�H�Q�H�Q�u���$ �T�����@SH�� ��H��y ��v H��tH��y H����v H��t����H�� [����@SH�� ���������Sv ��̹   ��O  �̹   �N  ��@SH�� �g  H��H����  H����)  H���jg  H���zd  H���V^  H��H�� [�)^  �H;�s-H�\$WH�� H��H��H�H��t��H��H;�r�H�\$0H�� _��H�\$WH�� 3�H��H��H;�s��uH�H��t��H��H;�r�H�\$0H�� _����H��(H��u��  �    �+  �   �H�U H��t�H�3�H��(���H��(H��u�  �    �[+  �   �H� H��t�H�3�H��(���H�\$WH�� H�=
x  ��tH��w �bm  ��t����w �y>  H��w H�[w ������uZH�ol  �l  H�/w H�=0w �H�H��t��H��H;�r�H�=�&  tH��& ��l  ��tE3�3�A�P��& 3�H�\$0H�� _��H�\$H�t$D�D$WATAUAVAWH��@E����D���   ��M  ��=6 �  �"    D�% ����   H�& ��s H��H�D$0H����   H��% ��s H��H�D$ L��H�t$(L��H�D$8H��H�|$ H;�rp�e  H9u��H;�r_H���s H����d  H���H��% ��s H��H�x% �rs L;�uL;�t�L��H�\$(H��H�\$0L��H�D$8H��H�D$ �H�v H��u �G���H�v H��u �4����E��t�   �K  E��u&�    �   �oK  A���S���A����r �H�\$pH�t$xH��@A_A^A]A\_��E3�3��f�����E3�A�P�X���3�3�D�B�K�����̺   3�D���9����@SH�� ���  ���  E3���   A�P�������H��(H��u�  �    �(  �   �
��� �3�H��(��H��(H��u�  �    �S(  �   �
��� �3�H��(��H��(H��u�V  �    �#(  �   �
�~� �3�H��(��H��H�XH�hH�pH�x ATH�� I��H��H��H��t?H��t?H��t� H��t2E��tA��u'Ic�L�%�� I������H��H�H��u3��5H��t���  �   ��'  ���H;�v�"   �M��H��H����i  H�\$0H�l$8H�t$@H�|$HH�� A\���H��� �H��� �H��� �H�-� �@SH�� ��������H�� [����@SH�� ��������H�� [����@SH�� �������H�� [���̅�t,SH��0H�D$hM��D�L$`M��H��M��I��H��H�D$ �&  �����H��SVWATAUAVAWH��PE3�E��A��D�pD�pD�pA�N��I  ��F���L��H��$�   �6������  H��$�   ���������  H��$�   ���������  �[s  ��D�5� A���D�=?� D�=(� H�qs �j  H��H�D$@H����   D80��   H�� H��t$H��H����������  H�l H��t�F���H������H�H�1B  H�J H����  H������L��H�PH�+ �h  ���h  L�t$ E3�E3�3�3��$  H� H��t�����L�5� H�; �o ����!  ��    � k�<��$�   �` fD95J t��k�<ȉ�$�   fD95� t#�� ��tǄ$�      +�k�<��$�   �D��$�   D��$�   H��$�   H�D$8L�t$0�?   �t$(I�$H�D$ E��L�� 3ҋ��_n ��tD9�$�   u
I�$D�p?�I�$D�0H��$�   H�D$8L�t$0�t$(I�D$H�D$ E��L�� 3ҋ��n ��tD9�$�   uI�D$D�p?�I�D$D�0�   ��$�   ��������$�   �������$�   ������   �2F  ����  D�~E��L�ǍV@I�$�g  ���(  I��?-uD�nH��H���f  D��Ei�  D��$�   �0@�9�<+��   :�|	@:���   �?:udH��H���_f  k�<D��$�   D�D��$�   �@:�	H�Ǌ:�}�?:u.H��H���)f  D��$�   D�D��$�   �@:�	H�Ǌ:�}�E��tA��D��$�   ���$�   ��t.M��L�Ǻ@   I�L$�'f  ��tL�t$ E3�E3�3�3��"  �I�D$D�0��$�   �r������$�   �T�����ZH������L�t$ E3�E3�3�3���!  �L�t$ E3�E3�3�3��!  L�t$ E3�E3�3�3��!  L�t$ E3�E3�3�3��!  �H��PA_A^A]A\_^[���H�\$H�l$VWATH��0�d$P A��D����k  D��A��  �}
A��A���A�þ��QE��u�����������k�d;�u3A��l  �����������iҐ  ;�tH�=o)��Ic�D���|� �H�=[)��Ic�D���D� A�ȍ�+  ��A����D��A��A����Dȋ�A���������A��D+ʙ�����A���A�i�m  D��%����L$p��$I�A��A�������Ћ�k�k�D+T$xA+��D;�E�T��DЃ���   E��u�����������k�d;�u'��l  �����������iҐ  ;�t	����� ����H� D;���   A���{��%  �}�ȃ�������Q��u�����������k�d;�u3A��l  �����������iҐ  ;�tH�=(��Ic�D���|� �H�=�'��Ic�D���D� D�$�   ��$�   k�<�$�   k�<�$�   i��  �$�   A��u&D�� �� ��� H�\$XH�l$`H��0A\_^�H�L$PD��� ��� �U�����uC��� �D$Pi��  ȸ \&��� y
���� �;�|+���� ��� ��� �H�d$  E3�E3�3�3��  �H��H�XH�hH�p WATAUH��`H��H�H3ۉX�������c  9�$�   u3�L�\$`I�[ I�k0I�s8I��A]A\_ËwA�   ;5� u;5� ��  9 �  f9^ �c �^ �S D�C �D$P�L$H�T$@A��u0D�0 D�$ D� D�T$8�\$0D�\$(D�D$ A���$D�  D�� 3�D�D$8D�T$0�\$(�\$ D�������� D�y �x �m D�] �D$P�L$H�T$@3�f9F D�D$8D�Gu#D�7 D�1 �\$0D�T$(D�\$ �   D� 3�D�T$0�\$(�\$ �~�   E��h	D�H��k}D�HA��A�iE�a�\$P�\$H�\$@�D$8   �\$0D��A��A�͉\$(�D$ �J���D�G�\$P�\$H�\$@�D$8   �\$0�\$(D�d$ D��3�A�������V� D�_� �OA;�}";��	���A;�� ���;�~#A;�}A�������A;�|�;��A;�~;�������Gk�<Gk�<i��  ;�u;�� �Ë�����;�� ����E3�E3�3�3�H�\$ �  ����H��(�=M  u)�   �	@  ��=9  u������, �   ��>  H��(��H��(�   ��?  �������   �>  H��(�@SH�� H�ٹ   �?  �H��������ع   �x>  ��H�� [�������ff�     H��L�$L�\$M3�L�T$L+�MB�eL�%   M;�sfA�� �M�� ���A� M;�u�L�$L�\$H�����H��H�HH�PL�@L�H SWH��(3�H������u��  �    �  ����jH�|$H�����H�P0�   �N���������H�H0�1  �������L��E3�H�T$@H�H0�  ������H�P0���1  �����H�P0�   �~�����H��(_[��H��H�PL�@L�H H��(L�@�pi  H��(����H��H�PL�@L�H H��(L�@�di  H��(����H��H�HH�PL�@L�H H��(L�@3��:i  H��(��H��H�PL�@L�H H��(L�@�0i  H��(����H��H�HH�PL�@L�H H��(L�@3��i  H��(��H��� 3�H��H9� ����H�H#�H�� ��H��� 3�H��H9� ���L�A� 3�I��D�@;
t+��IЃ�-r�A��w�   Á�D����   ��AF��H�A�D���H��(�V  H��u	H�S� �H��H��(�H��(��U  H��u	H�7� �H��H��(�@SH�� ����U  H��u	H�� �H����U  L��� H��tL�P���;���A�H�� [���@SH�� ���U  H��u�   ��rU  H��u	H��� �H���3�H�� [���@SH�� H��H��u
�  �C��7U  H��u	H�{� �H��� �3�H�� [��@SH�� ���U  H��u�   ���T  H��u	H�B� �H���3�H�� [���@SH�� H��H��u
�  �C��T  H��u	H�� �H��� �3�H�� [��L�D$SH�� I�؃�u}�  ��u3��*  �V  ��u��  ���uY  ��a H�� �k  H��  �.  ��y�bS  ���j  ��x��f  ��x3�������u��  �   �[1  �ʅ�uM�w  ���z����ȉg  9�� u�����H��u�(1  ��R  �>  �H��uw�=�� �tn��R  �g��uV��R  ��  �   �_4  H��H������H�ЋN� ��` H�˅�t3���R  ��` �H�K�������������u3��5U  �   H�� [���H�\$H�t$H�|$ATH��0I����L��   ��u9�� u3���   ��t��u3L�&d M��tA�щD$ ��tL�Ƌ�I���I����D$ ��u3��   L�Ƌ�I���l  ���D$ ��u5��u1L��3�I���yl  L��3�I������L��c M��tL��3�I��A�Ӆ�t��u7L�Ƌ�I����������#ϋ��L$ tH��c H��tL�Ƌ�I���Ћ��D$ ���3�H�\$@H�t$HH�|$PH��0A\��H�\$H�t$WH�� I����H���u��k  L�ǋ�H��H�\$0H�t$8H�� _�������H��(E3��   3��D$0   �$_ H�]� H��t)�_ <sH�G� L�D$0A�   3��_ �   H��(���H��(H�� ��^ H�%�  H��(���H�� �L�ak 3�I��;
t��H����r�3��H�H�I�D�����H�\$H�l$H�t$ WATAUH��P  H�j� H3�H��$@  ������3�H��H����  �N�fo  ���u  �N�Uo  ��u�=f� �\  ���   ��  H�-]� A�  L��l H��A���n  3Ʌ��  L�-f� A�  f�5a� I����] A�|$��u*L�.l ��I���ln  ��tE3�E3�3�3�H�t$ �\  �I���/n  H��H��<vGI���n  L��k A�   H�LE�H��I+�H��H+�H���(m  ��tE3�E3�3�3�H�t$ �  �L��k I��H���ul  ��uAL��I��H���cl  ��uH�$k A�  H���Bj  �   E3�E3�3�3�H�t$ �  �E3�E3�3�3�H�t$ �  �E3�E3�3�H�t$ �  ̹������\ H��H��tUH���tO��L�D$@�A�f93t��I��H�����  r�H�L$@@��$3  �����L�L$0H�T$@H��L��H�t$ �T\ H��$@  H3������L��$P  I�[(I�k0I�s8I��A]A\_����H��(�   �Bm  ��t�   �3m  ��u�=D� u��   �l�����   �b���H��(��H�Y �H�\$WH�� H���   �5  H�: �\ H��H����[ �   H� �_4  H��H�\$0H�� _��3������H��  H�%�[ ��@SH�� H��H��  ��[ H��tH���Ѕ�t�   �3�H�� [��H�L$H��   H�a ��Z H�L H�D$XE3�H�T$`H�L$X�%L H�D$PH�|$P tAH�D$8    H�D$HH�D$0H�D$@H�D$(H� H�D$ L�L$PL�D$XH�T$`3���K �"H��$�   H�� H��$�   H��H�e H�� H�/  H��$�   H�0 �  	 ��      H�e� H�D$hH�a� H�D$p�Z �p  �   �k  3���Y H�i ��Y �=J   u
�   �k  ��Y �	 �H����Y H�Ĉ   ���H��H�XH�hH�p �HWH�� H��H���J*  �KHc����u�f���� 	   �K ����4  ��@t�J���� "   ��3���t�{����   H�C���H��K�C�{�����C�  u/�C���H��0H;�t�5���H��`H;�u���l  ��uH���-l  �C  ��   �+H�S+kH�BH��C$�ȉC��~D�ŋ��B@  ���W�� �K�?������t#���tH��H��H�	 ��H��Hk�XH��H�<� �A t3ҋ�D�B��j  H��������H�K�D$0���   H�T$0��D����?  ��;�������D$0H�\$8H�l$@H�t$HH�� _����@SH�� H���A H��u�K  H�CH���   H�H���   H�KH;�� t���   �C� u�w  H�H�2� H9CtH�C���   �� u	�In  H�CH�C���   u���   �C��H��H�� [���̀y tH�A���   ����H���@SH�� �B@I��tH�z uA� �%�JxH��H�������������u	��H�� [��̅�~LH�\$H�l$H�t$WH�� I��I����@��L��H��@���������?�t���H�\$0H�l$8H�t$@H�� _����H��H�XH�hH�pH�x ATH�� I��I����H�������F@D� tH�~ u;�O�n����  �/�M L��H��������H�Ń;�u�L����8*uL��H�ֱ?���������1����8 u�'���D� H�\$0H�l$8H�t$@H�|$HH�� A\��H�H��@���H�H�H�@��H�H��@��H�\$UVWATAUAVAWH��$0���H���  H�� H3�H���  3�H��H�L$hH��H�M�I��M��D$`D��D$TD���D$H�D$\�D$P�v���E3�H��u,�q����    �>  E3�D8]�tH�E����   �����  ����C@L������   H���&  H��� ;�t(���t#Lc�L����I��A��H��Mk�XM�� � �
L��L����A�@8u(;�t���tHc�H��H��Hk�XI�� � �B8�t+�����    �  E3�D8]�tH�E����   �����  E3�H��t�D�'E��D�T$@D�T$DA��L�U�E����  H�]�A�   H��H�}�E����  A�D$�<XwI��B���P ���A��Hc�Hc�H��B��
�P ���T$X�ʅ��<  ���K  ����  ����  ����  ���j  ���c  ���  A�ă�d�k  �k  ��A�1  ��C��   ��E�  ��G�  ��Stl��X��  ��Zt��a�  ��c��   �%  I�I��H��t/H�XH��t&� A��s��D$P   +�����  D�T$P��  H��� ��  A��0  uA��I�D;�A�ǹ���D�I��A��  �  H���D$P   HDh� H����   A��0  uA��I��A��  t'E�N�H�U�H�L$DM���w  E3҅�t�D$\   �A�F��D$D   �E�H�]��9  �D$x   A�� A��@H�]�A��E���.  A�   �h  ��e�  ��g~Ӄ�i��   ��n��   ��o��   ��ptc��s������u��   ��x��  �'   �Q��fD9tH����u�H+�H��� H��HD`� H���
��D8tH����u�+ˉL$D�}  A�   A���   �D$`A�   E��y`Q�D$L0A�Q�D$M�SA�   E��yDE��?I�>I���&���E3҅���  �D$@A�� tf����D$\   �Y  A��@A�
   �T$H� �  D��t	M�I���:A��r�I��A�� tL�t$pA��@tM�F��E�F��A��@tMcF��E�F�L�t$pA��@tM��yI��A��D��u
A��rE��E��yA�   �A���E;�EO�D�t$`I��H���  H���#ʉL$HA��A�υ�M��t 3�I��Ic�H��L���B0��9~AƈH����L�t$pH���  +�H�ÉD$DE���  ��t	�;0��   H���D$D�0��   uA��gu=A�   �5E;�EO�A���   ~%A��]  Hc��a#  H�E�H��tH�؋��A��   I�H��� I��A��Hc�H�E���P H�M�D��H�L$0�L$xL�ƉL$(H�M�H��D�|$ ��A����   tE��uH�h� �BP H�U�H����A��gu��uH�@� �"P H�U�H���Ѐ;-uA��H��H������E3҉D$DD9T$\�F  A��@t1A��s�D$L-�A��t�D$L+�   �|$H�A��t�D$L ��|$HD�d$TH�t$hD+d$DD+�A��uL�L$@L��A�Ա �����L�L$@H�L$LL�Ƌ��!���A��tA��uL�L$@L��A�Ա0�����|$D3�9D$Pti��~eH��D�H���  H�M�A�   ��H����r  E3҅�u+�U���t$L�D$hL�L$@H���  ����E3҅�u�H�t$h�%H�t$hA���D�D$@�L�L$@L�Ƌ�H���|���E3�D�D$@E��x A��tL�L$@L��A�Ա ����E3�D�D$@H�E�H��tH���B���D�D$@E3�L�U�H�}�����T$XA�   L�Z��D�'E���Y���D8U�tH�M����   �A��H���  H3�����H��$   H���  A_A^A]A\_^]�A��It7A��ht(A��ltA��wu�A��뗀?lu
H��A���A���A�� �y����A��<6u�4uH��A���Z���<3u�2uH��A���B���<d�:���<i�2���<o�*���<u�"���<x����<X����D�T$XH�U�A��D�T$P�m  ��t!H�T$hL�D$@A���c���D�'H��E���  H�T$hL�D$@A���B���D�D$@E3�����A��*uE�>I��E�������D������C��A��D�|H�����E������A��*uA�I���D$T���f���A������D$T��A�čDHЉD$T�F���A�� tAA��#t1A��+t"A��-tA��0�$���A������A������A���	���A�������A�������D�T$xD�T$\D�T$TD�T$HE��D��D�T$P����������    �d  3�8E��������H��� �H�\$H�t$UWATH��$���H���  H��� H3�H���  A����ك��t�]  �d$p H�L$t3�A��   �B���L�\$pH�EH�ML�\$HH�D$P�K L��  H�T$@I��E3��f< H��t7H�d$8 H�T$@H�L$`H�L$0H�L$XL��H�L$(H�MM��H�L$ 3��&< �H��  H��  H��  H���   H��  �t$p�|$tH�E���J 3ɋ���J H�L$H��J ��u��u���t��� \  H���  H3��E���L��$�  I�[(I�s0I��A\_]��H�\$WH�� H��H�x� ��J H��H���FJ H�_� H��H�\$0H�� _��H�I� H�%�J ��H��(A�   � �A�H�P�����I � �H��H��(H�%�I ���H��8H�D$`H�D$ �����H�\$H�l$H�t$WH��0H��H��� A��I��H���J D��L��H��H��H��t!L�T$`L�T$ ��H�\$@H�l$HH�t$PH��0_�H�D$`H�D$ �J�����H��8H�d$  E3�E3�3�3��w���H��8���H��8H�d$  E3�E3�3�3��W���H�d$  E3�E3�3�3��������H��8H�D$`H�D$ �-���H��8�H��H�XH�hH�pWH��PH�`� H��3�I��H��D�B(H�H�I������H��u�����    �O�������RH��t�H�L$ L��L��H���D$(����D$8B   H�\$0H�\$ �\����L$(��x
H�L$ � �H�T$ 3�������H�\$`H�l$hH�t$pH��P_����M��E3��=����H��H�XH�hH�pWH��PH�`� H��3�I��H��D�B(H�H�I�������H��u�����    ��������,H�d$0 H�d$  H�L$ L��L��H���D$(����D$8B   ��H�\$`H�l$hH�t$pH��P_��L��H��H�{���E3��[������M��L��H��H�`����C������L��H��H�'o  E3��+������M��L��H��H�o  �������H�\$H�t$H�|$UATAUH��H��P3�M��L��H��H�M�D�C(3�I��H�]������H��u������    ��������vM��tH��t�L�MHL�E@����L;�A��H��G�H�M��E�B   H�u�H�uЉE�A�Ջ�H��t3��x!�M�xH�EЈ�H�U�3��������t���9]�B�\&��ÍC�L�\$PI�[ I�s(I�{0I��A]A\]���H��8L�L$(H�d$  M��L��H��H�!�������������H�H��8����H��8H�D$`H�D$(L�L$ M��L��H��H��������������H�H��8����@SH��0H��M��tGH��tBH��t=H�D$`H�D$(L�L$ M��L��H��H��  �p�����y� ���u �k���� "   ��^����    �+������H��0[���H��8L�L$ E3�����H��8���H��H�XH�hH�pH�x ATH��0I��I��H��H��M����   M��uH��uH����   3���   H����   H����   I;�vM�����L�FH�  �H�D$hL��H�D$(H�D$`H��H�D$ �������ul�����8"��   ������~����H��~  L��D� H�D$hL��H�D$(H�D$`H��H�D$ �G����D� ���uH���u�>����8"u3�4���D� �)��y(� ���u����� "   ������    ��������H�\$@H�l$HH�t$PH�|$XH��0A\�H��8H�D$`H�D$(H�d$  ����H��8���H��8L�L$(H�d$  M��L��H��H��k  ���������H�H��8����H��8H�D$`H�D$(L�L$ M��L��H��H�ik  �`��������H�H��8�����W�  ���@SH��@H��H�L$ �9�������  ��etH����i�  ��u����  ��xuH��H�D$ �H��(  H���H�Ê��ЊH�Ä�u�8D$8tH�D$0���   �H��@[��@SH��@H��H�L$ ����D�H�L$ E��tH��(  H��D:�tH��D�E��u��H�Ä�t?�<et<Et	H�Ê��u�H��H�ˀ;0t�H��(  H��8uH�ˊH��H���u�|$8 tH�D$0���   �H��@[�����f/�Q r�   �3���@SH��0I��H��M��H�Ѕ�tH�L$ ���  L�\$ L��H�L$@���  D�\$@D�H��0[���E3�������t/H�\$WH�� Hc�H���w���H�L�@H������H�\$0H�� _�3��A����3������H��H�XH�hH�pH�x ATAUAWH��PL��H��$�   H��H�H�E��Ic��J���H��uC�H����_������|$H tH�L$@���   ���L�\$PI�[ I�k(I�s0I�{8I��A_A]A\�M��u&� ���A�\$������D8d$Ht�H�D$@���   ��3���OÃ�	H�L;�w������"   �z�����$�    H��$�   t43�>-@��E3�H��A��E��tH���K���Ic�H��L�@H������>-H��u�-H�W��~�B�H�D$0H��H��(  H���
3�L�P 8�$�   ��H�H�H+�I���H��I�<ID��9  ����   H�KE��t�EH�F�80tVD�FA��yA���C-A��d|���QA��������� SkҜD�A��
|�gfffA��������� Sk��D�D C��� t�90uH�QA�   ������|$H tH�D$@���   �3��H���H�d$  E3�E3�3�3��|�������@SUVWH��   H��� H3�H�D$pH�	I��H��A��   L�D$XH�T$@D����  H��u�����(��������   H��t�H���H;�t3��|$@-H����H+�3�����H+�3��|$@-D�F��3Ʌ���H�L�L$@H���  ��t� �2H��$�   D��$�   D��H�D$0H�D$@H��H���D$( H�D$ �����H�L$pH3��m���H�Ĉ   _^][��H��8�D$`H�d$( �D$ �����H��8�H�\$H�|$UATAUAVAWH��H��PH��H�UXL��H�M�E��I��H�E0�  A�0   �����E3�E��EH�H��u'������_�����D8}�tH�M����   ����O  H��u$������   �����D8}�t�H�E����   ���A�D$D�?Hc�H;�w�����"   �I���  H��4H#�H;���   L�C�H���H�WE��I��LD�L�|$(D�|$ �������tD�?D8}���  H�M����   ��  �-u�-H�ǋ]P�0�e   ����ɀ����x�OH�O���  H��t��ɀ����p�D�xD8}��P  H�       �I�t�-H��D�MPA�0   H������� A��D���A��ɀ����x��H�      �҈O������I�uD�_I�H��H#�H��H�%�  H�E0��G1H��L��E3�H��E��uE��H�E�H��(  H��A�I���   I�       E��~/I�A��I#�H#�H��fA�f��9vfI��A��H��fA���y�fE��xGI�A��I#�H#�H��f��v2H�G��8ft�8FuD�H����I;�t���9u��:��	�����@�E��~E��A��H��A������D�MPH�E3�E�Z0E8ID�A���$�p�I�H��4���  H+M0x
�G+H����G-H��H��L��D�H���  |3H���S㥛� H��H��H��H��?H�A�Hi�����H��H�I;�uH��d|.H�ףp=
ףH��H�H��H��H��?H�A�HkҜ�H��H�I;�uH��
|+H�gfffffffH��H��H��H��?H�A�Hk���H��H�A�D8U��D�WtH�E����   �3�L�\$PI�[8I�{@I��A_A^A]A\]�H��8�D$`H�d$( �D$ �	���H��8�H��H�XH�hH�pH�x ATH��@A�YH��H�T$xH��H�H�M����A������H��u)�����_������@8|$8tH�L$0���   ����  H��u$������^�����@8t$8t�H�D$0���   ��Ѐ|$p t;�u3�A�<$-Hc���H�f�0 A�<$-u�-H��A�|$  H���:���H�OH��L�@�ڲ���0H���IcD$H���~wH��H�w�
���H��H��L�@諲��L�\$ I��(  H���A�\$��y@�ۀ|$p u	�Ë�;�M؅�tH�������Hc�H��L�@H��_���Lcú0   H��������|$8 tH�D$0���   �3�H�\$PH�l$XH�t$`H�|$hH��@A\����@SUVWH��xH��� H3�H�D$`H�	I��H��A��   L�D$HH�T$0D���A�  H��u�g����(�8������kH��t�H���H;�t3��|$0-H����H+�D�D$43�L�L$0Dƃ|$0-��H��[�  ��t� �%H��$�   L�L$0D��H�D$(H��H���D$  ����H�L$`H3�����H��x_^][����H��8H�d$  ����H��8�@SUVWATH��   H�� H3�H�D$pH�	I��H��A��   L�D$XH�T$@D���T�  H��u�z�����K�������   H��t�D�d$D3�A�̃|$@-��H���H�0H;�tH��H+�L�L$@D��H���n�  ��t� �~�D$D��D;������|;;�}7��t�H�Ä�u��C�H��$�   L�L$@D��H�D$(H��H���D$ �����2H��$�   D��$�   D��H�D$0H�D$@H��H���D$(H�D$ ����H�L$pH3�螵��H�Ā   A\_^][�H��8�D$`H�d$( �D$ ����H��8�H��8A��etjA��EtdA��fuH�D$pD�L$`H�D$ �����dA��at$A��AtH�D$pD�L$`H�D$(�D$h�D$ �\����:H�D$pD�L$`H�D$(�D$h�D$ �����H�D$pD�L$`H�D$(�D$h�D$ ����H��8����H��H�D$xH�d$0 �D$(�D$p�D$ �I���H��H�H�\$WH�� H�'� �
   H���5 H�H��H��u�H�\$0H�� _���L��I�[I�kI�s I