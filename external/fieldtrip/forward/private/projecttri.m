function [tri] = projecttri(pos, method)

% PROJECTTRI makes a closed triangulation of a list of vertices by
% projecting them onto a unit sphere and subsequently by constructing
% a convex hull triangulation.
%
% Use as
%   [tri] = projecttri(pos, method)
% where method is either 'convhull' (default) or 'delaunay'.
%
% See also NORMALS, PCNORMALS

% Copyright (C) 2006-2019, Robert Oostenveld
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

tmp = pos;
tmp(:,1) = tmp(:,1) - mean(tmp(:,1));
tmp(:,2) = tmp(:,2) - mean(tmp(:,2));
tmp(:,3) = tmp(:,3) - mean(tmp(:,3));
r = rank(tmp);
switch r
  case 0
    ft_warning('vertices are lying on a single point, cannot make triangulation');
    tri = zeros(0,3);
    return
  case 1
    ft_warning('vertices are lying on a straight line, cannot make triangulation');
    tri = zeros(0,3);
    return
  case 2
    if nargin<2
      method = 'delaunay';
    end
  case 3
    if nargin<2
      method = 'convhull';
    end
  otherwise
    ft_error('unexpected input');
end

switch method
  case 'convhull'
    ori = (min(pos) + max(pos))./2;
    pos(:,1) = pos(:,1) - ori(1);
    pos(:,2) = pos(:,2) - ori(2);
    pos(:,3) = pos(:,3) - ori(3);
    nrm = sqrt(sum(pos.^2, 2));
    pos(:,1) = pos(:,1)./nrm;
    pos(:,2) = pos(:,2)./nrm;
    pos(:,3) = pos(:,3)./nrm;
    tri = convhulln(pos);
    if surfaceorientation(pos, tri)<0
      % make the surface outward oriented
      tri = fliplr(tri);
    end
    
  case 'delaunay'
    if all(pos(:,1)==0)
      % this can happen with simulated electrode grids
      prj = pos(:,[2 3]);
    elseif all(pos(:,2)==0)
      % this can happen with simulated electrode grids
      prj = pos(:,[1 3]);
    elseif all(pos(:,3)==0)
      % this can happen with simulated electrode grids
      prj = pos(:,[1 2]);
    else
      % make a 2D triangulation of the projected points using delaunay
      prj = elproj(pos);
    end
    tri = delaunay(prj(:,1), prj(:,2));
    
  otherwise
    ft_error('unsupported method');
end
                                                                                                                                                                                                                                                                                                                                                       t��u7H��	  H��t�Ћ؉D$ ����   L�Ƌ�I���0����؉D$ ����   L�Ƌ�I���  �؉D$ ��u5��u1L��3�I����  L��3�I�������L�-	  M��tL��3�I��A�Ӆ�t��u7L�Ƌ�I���������#ˋىL$ tH��  H��tL�Ƌ�I���Ћ؉D$ �3ۉ\$ �'  ������H�\$@H�t$HH�|$PH��0A\����H�\$H�t$WH�� I����H���u�k  L�ǋ�H��H�\$0H�t$8H�� _�������H��  ��  @SH�� H��H��  ��  H�D$8H���uH���*  �~�   ��  �H��  ��  H�D$8H��  ��  H�D$@H����  H��L�D$@H�T$8�  H��H�L$8�p  H��  H�L$@�^  H�g  �   �S  H��H�� [�H��(�G���H�������H��(��H�\$WH�� H��  H�=�  �H�H��t��H��H;�r�H�\$0H�� _�H�\$WH�� H�s  H�=l  �H�H��t��H��H;�r�H�\$0H�� _�����H���MZ  f9t3��HcH<H�3��9PE  u�  f9Q�����LcA<E3�L��L�A�@E�XJ�L E��t�QL;�r
�A�L;�rA��H��(E;�r�3��H�������������H��(L��L�����I���j�����t"M+�I��I������H��t�@$���Ѓ��3�H��(���%X  �%  �%d  �%  �%  H��(��uH�=7   u��  �   H��(��H�\$WH�� H�{  H�d$0 H�2��-�+  H;�tH��H�d  �vH�L$0�?  H�\$0�<  D��I3��8  D��I3��4  H�L$8D��I3��+  L�\$8L3�H�������  L#�H�3��-�+  L;�LD�L��  I��L��  H�\$@H�� _���%:  �%<  �%>  �%@  @UH�� H��H��H�M(H���M$������H�� ]�������������@UH�� H���q  ����H�� ]��@UH�� H��   �����H�� ]�������������@UH�� H��H�3Ɂ8  �������H�� ]��                                                                                                                                                                                                                                                                                              R&      <&      &&      &      �%      �%      �%      �%      �%              %      "%      %      @%      X%      j%      �%      �%      �%      �%       %      �$      �$      2%              �$              �$      �$      �$                                        �                  @               �       �      �?        Bad arguments in routine plgndr ��������������invalid number of arguments for PLGNDR                                          O	 O� Ah � x �  !   �  �   "  !/ /� $� � � 
d T �  �   "   h �p0  
 h d
 T	 4 Rp 20 � t
 T	 4 2��� t
 d	 4 R�T     �  �  P  �  �  �  �       d 4 2p 20T     {  �  �      
 
4 
2p 2P	 B  T       :  �  :   B  
 
4 
2p`$          �$  �   P$          �$  �   �#          �$  P   �#          l&                              R&      <&      &&      &      �%      �%      �%      �%      �%              %      "%      %      @%      X%      j%      �%      �%      �%      �%       %      �$      �$      2%              �$              �$      �$      �$              �mxGetData OmxCreateDoubleMatrix_700  �mxGetScalar libmx.dll 1 mexErrMsgTxt  libmex.dll  �sqrt  MSVCR100.dll  _malloc_crt �_initterm �_initterm_e cfree  �_encoded_null �_amsg_exit  __C_specific_handler  __CppXcptFilter @__clean_type_info_names_internal  [_unlock H__dllonexit �_lock �_onexit � EncodePointer � DecodePointer �Sleep � DisableThreadLibraryCalls �QueryPerformanceCounter �GetTickCount  �GetCurrentThreadId  �GetCurrentProcessId �GetSystemTimeAsFileTime KERNEL32.dll            R]KV    �&           �&  �&  �&  @  �&    plgndr.mexw64 mexFunction                                                                                                                                                                                                                                                                                                                     u�  ��������    2��-�+  �] �f���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   �  �!  �  �   "  �  �  �!  �  8  �!  @  �  0"     ^  H"  `  �  P"  �  �  l"  �  5  �"  D  �  �"  �    #    D  �"  D  |  �"     A  �"  `  �  #  �  7  #  P  u  �"  �  �  �"  �  �  �"  �  �  �"                                                                                                                                                                                                                                                                                                     �                 0  �              	  H   XP  Z  �      <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="asInvoker" uiAccess="false"></requestedExecutionLevel>
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>PAPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPAD       �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ub_binding_helper __dyld_func_lookup _legendre_Pmm _plgndr  stub helpers dyld__mach_header _mexFunction _mexErrMsgTxt _mxCreateDoubleMatrix_700 _mxGetData _mxGetScalar dyld_stub_binder                                                                                                                                                                                                                                                                                                                                                            �                                                         �                           �                             �             �      �      �                             �             X      X      	                              �             p      p                                   �             �      �                                    �             �      �      t                              �             x      x                                    �             �      �                                    �             �      �                                    �             �      �                                    �             �      �      @                           �             �      �      (                             �                             `                             �             `       `                                     �      0               `       ,                                                   �                                                          �(      �         1                 	                      �.                                                                 �                    �                                        �                    �                    �                    (                    h                   	 (                   
                                           �                    X                    p                    �                    �                    x                    �                    �                    �                    �                    �                                          `                                         ��                     �                   �              .     �              A     0              W     `              f     �              �     p              �     x              �    ��                    ��                �                   �     �                   ��                �     X              �                     �     `                   �                   `               $     h               )     `               0    �              9   
                ?                     F                      U                      i   ��                m                      �                      �  "                   �                     �                     �    �      �      �                     �                     �                                           crtstuff.c __JCR_LIST__ deregister_tm_clones register_tm_clones __do_global_dtors_aux completed.6337 __do_global_dtors_aux_fini_array_entry frame_dummy __frame_dummy_init_array_entry meg_leadfield1.c __FRAME_END__ __JCR_END__ _fini _GLOBAL_OFFSET_TABLE_ __TMC_END__ __dso_handle __bss_start _end _edata _DYNAMIC _init mxGetN __gmon_start__ _Jv_RegisterClasses MEX _ITM_deregisterTMCloneTable _ITM_registerTMCloneTable __cxa_finalize@@GLIBC_2.2.5 mxGetEps mxGetM mexFunction mxGetData mexErrMsgTxt mxCreateDoubleMatrix_700 sqrt@@GLIBC_2.2.5                                                                                                                                                                                                                                                                                                            �             �             �             �             �                                        @                       _dot _cross _determinant _pdist _ppdist _plinproj _ptriproj _lmoutr _routlm _ltrisect _ptriside _solang _mexFunction _atan2 _mexErrMsgTxt _mxCreateDoubleMatrix_700 _mxGetData _mxGetM _mxGetN _mxGetNaN dyld_stub_binder                                                                                                                                             leMatrix_700 _mxGetData _mxGetM _mxGetN _mxGetNaN dyld_stub_binder                                                                                                                                                                                                                                                                                                                                                                                                                                                              dimord = 'pos_rpt';
    elseif isequalwithoutnans(datsiz, [npos nori nrpt])
      dimord = 'pos_ori_rpt';
    elseif isequalwithoutnans(datsiz, [npos nori nrpttap])
      dimord = 'pos_ori_rpttap';
    elseif isequalwithoutnans(datsiz, [npos nori ntime])
      dimord = 'pos_ori_time';
    elseif isequalwithoutnans(datsiz, [npos nori nfreq])
      dimord = 'pos_ori_nfreq';
    elseif isequalwithoutnans(datsiz, [npos ntime])
      dimord = 'pos_time';
    elseif isequalwithoutnans(datsiz, [npos nfreq])
      dimord = 'pos_freq';
    elseif isequalwithoutnans(datsiz, [npos 3])
      dimord = 'pos_ori';
    elseif isequalwithoutnans(datsiz, [npos 1])
      dimord = 'pos';
    elseif isequalwithoutnans(datsiz, [npos nrpt])
      dimord = 'pos_rpt';
    elseif isequalwithoutnans(datsiz, [npos nrpt nori ntime])
      dimord = 'pos_rpt_ori_time';
    elseif isequalwithoutnans(datsiz, [npos nrpt 1 ntime])
      dimord = 'pos_rpt_ori_time';
    elseif isequal(datsiz, [npos nfreq ntime])
      dimord = 'pos_freq_time';
    end
    
  case {'filter'}
    if isequalwithoutnans(datsiz, [npos nori nchan]) || (isequal(datsiz([1 2]), [npos nori]) && isinf(nchan))
      dimord = 'pos_ori_chan';
    end
    
  case {'leadfield'}
    if isequalwithoutnans(datsiz, [npos nchan nori]) || (isequal(datsiz([1 3]), [npos nori]) && isinf(nchan))
      dimord = 'pos_chan_ori';
    end
    
  case {'ori' 'eta'}
    if isequal(datsiz, [npos nori]) || isequal(datsiz, [npos nori 1]) || isequal(datsiz, [npos 3]) || isequal(datsiz, [npos 3 1])
      dimord = 'pos_ori';
    elseif isequal(datsiz, [npos 1 nori]) || isequal(datsiz, [npos 1 3])
      dimord = 'pos_unknown_ori';
    end
    
  case {'csdlabel'}
    if isequal(datsiz, [npos nori]) || isequal(datsiz, [npos 3])
      dimord = 'pos_ori';
    end
    
  case {'trial'}
    if ~iscell(data.(field)) && isequalwithoutnans(datsiz, [nrpt nchan ntime])
      dimord = 'rpt_chan_time';
    elseif isequalwithoutnans(datsiz, [nrpt nchan ntime])
      dimord = '{rpt}_chan_time';
    elseif isequalwithoutnans(datsiz, [nchan nspike]) || isequalwithoutnans(datsiz, [nchan 1 nspike])
      dimord = '{chan}_spike';
    end
    
  case {'sampleinfo' 'trialinfo' 'trialtime'}
    if isequalwithoutnans(datsiz, [nrpt nan])
      dimord = 'rpt_other';
    end
    
  case {'cumtapcnt' 'cumsumcnt'}
    if isequalwithoutnans(datsiz, [nrpt 1])
      dimord = 'rpt';
    elseif isequalwithoutnans(datsiz, [nrpt nfreq])
      dimord = 'rpt_freq';
    elseif isequalwithoutnans(datsiz, [nrpt nan])
      dimord = 'rpt_other';
    end
    
  case {'topo'}
    if isequalwithoutnans(datsiz, [ntopochan nchan])
      dimord = 'topochan_chan';
    end
    
  case {'unmixing'}
    if isequalwithoutnans(datsiz, [nchan ntopochan])
      dimord = 'chan_topochan';
    end
    
  case {'anatomy' 'inside'}
    if isfield(data, 'dim') && isequal(datsiz, data.dim)
      dimord = 'dim1_dim2_dim3';
    elseif isequalwithoutnans(datsiz, [npos 1]) || isequalwithoutnans(datsiz, [1 npos])
      dimord = 'pos';
    end
    
  case {'timestamp'}
    if iscell(data.(field)) && isfield(data, 'label') && datsiz(1)==nchan
      dimord = '{chan}_spike';
    end
    
  case {'time'}
    if iscell(data.(field)) && isfield(data, 'label') && datsiz(1)==nrpt
      dimord = '{rpt}_time';
    elseif isvector(data.(field)) && isequal(datsiz, [1 ntime ones(1,numel(datsiz)-2)])
      dimord = 'time';
    elseif iscell(data.(field)) && isfield(data, 'label') && isfield(data, 'timestamp') && isequal(getdimsiz(data, 'timestamp'), datsiz) && datsiz(1)==nchan
      dimord = '{chan}_spike';
    end
    
  case {'freq'}
    if iscell(data.(field)) && isfield(data, 'label') && datsiz(1)==nrpt
      dimord = '{rpt}_freq';
    elseif isvector(data.(field)) && isequal(datsiz, [1 nfreq ones(1,numel(datsiz)-2)])
      dimord = 'freq';
    end
    
  case {'chantype', 'chanunit'}
    if numel(data.(field))==nchan
      dimord = 'chan';
    end
    
  otherwise
    if isfield(data, 'dim') && isequal(datsiz, data.dim)
      dimord = 'dim1_dim2_dim3';
    end
    
end % switch field

% deal with possible first pos which is a cell
if exist('dimord', 'var') && strcmp(dimord(1:3), 'pos') && iscell(data.(field))
  dimord = ['{pos}' dimord(4:end)];
end

if ~exist('dimord', 'var')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ATTEMPT 4: there is only one way that the dimensions can be interpreted
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dimtok = cell(size(datsiz));
  
  for i=1:length(datsiz)
    sel = find(siz==datsiz(i));
    if length(sel)==1
      % there is exactly one corresponding dimension
      dimtok{i} = tok{sel};
    else
      % there are zero or multiple corresponding dimensions
      dimtok{i} = [];
    end
  end
  
  if all(~cellfun(@isempty, dimtok))
    if iscell(data.(field))
      dimtok{1} = ['{' dimtok{1} '}'];
    end
    dimord = sprintf('%s_', dimtok{:});
    dimord = dimord(1:end-1);
    return
  end
end % if dimord does not exist

if ~exist('dimord', 'var')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ATTEMPT 5: compare the size with the known size of each dimension
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  sel = ~isnan(siz) & ~isinf(siz);
  % nan means that the value is not known and might remain unknown
  % inf means that the value is not known and but should be known
  if length(unique(siz(sel)))==length(siz(sel))
    % this should only be done if there is no chance of confusing dimensions
    dimtok = cell(size(datsiz));
    dimtok(datsiz==npos)      = {'pos'};
    dimtok(datsiz==nori)      = {'ori'};
    dimtok(datsiz==nrpttap)   = {'rpttap'};
    dimtok(datsiz==nrpt)      = {'rpt'};
    dimtok(datsiz==nsubj)     = {'subj'};
    dimtok(datsiz==nchancmb)  = {'chancmb'};
    dimtok(datsiz==nchan)     = {'chan'};
    dimtok(datsiz==nfreq)     = {'freq'};
    dimtok(datsiz==ntime)     = {'time'};
    dimtok(datsiz==ndim1)     = {'dim1'};
    dimtok(datsiz==ndim2)     = {'dim2'};
    dimtok(datsiz==ndim3)     = {'dim3'};
    
    if isempty(dimtok{end}) && datsiz(end)==1
      % remove the unknown trailing singleton dimension
      dimtok = dimtok(1:end-1);
    elseif isequal(dimtok{1}, 'pos') && isempty(dimtok{2}) && datsiz(2)==1
      % remove the unknown leading singleton dimension
      dimtok(2) = [];
    end
    
    if all(~cellfun(@isempty, dimtok))
      if iscell(data.(field))
        dimtok{1} = ['{' dimtok{1} '}'];
      end
      dimord = sprintf('%s_', dimtok{:});
      dimord = dimord(1:end-1);
      return
    end
  end
end % if dimord does not exist

if ~exist('dimord', 'var')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ATTEMPT 6: check whether it is a 3-D volume
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isequal(datsiz, [ndim1 ndim2 ndim3])
    dimord = 'dim1_dim2_dim3';
  elseif isfield(data, 'pos') && prod(datsiz)==size(data.pos, 1)
    dimord = 'dim1_dim2_dim3';
  end
end % if dimord does not exist



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINAL RESORT: return "unknown" for all unknown dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dimord', 'var')
  % this should not happen
  % if it does, it might help in diagnosis to have a very informative warning message
  % since there have been problems with trials not being selected correctly due to the warning going unnoticed
  % it is better to throw an error than a warning
  warning_dimord_could_not_be_determined(field, data);
  
  dimtok(cellfun(@isempty, dimtok)) = {'unknown'};
  if all(~cellfun(@isempty, dimtok))
    if iscell(data.(field))
      dimtok{1} = ['{' dimtok{1} '}'];
    end
    dimord = sprintf('%s_', dimtok{:});
    dimord = dimord(1:end-1);
  end
end

% add '(rpt)' in case of source.trial
dimord = [prefix dimord];


end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warning_dimord_could_not_be_determined(field,data)
  msg=sprintf('could not determine dimord of "%s" in:',field);

  if isempty(which('evalc'))
    % May not be available in Octave
    content=sprintf('object of type ''%s''',class(data));
  else
    % in Octave, disp typically shows full data arrays which can result in
    % very long output. Here we take out the middle part of the output if
    % the output is very long (more than 40 lines)
    full_content=evalc('disp(data)');
    max_pre_post_lines=20;

    newline_pos=find(full_content==newline);
    newline_pos=newline_pos(max_pre_post_lines:(end-max_pre_post_lines));

    if numel(newline_pos)>=2
      pre_end=newline_pos(1)-1;
      post_end=newline_pos(end)+1;

      content=sprintf('%s\n\n... long output omitted ...\n\n%s',...
                                full_content(1:pre_end),...
                                full_content(post_end:end));
    else
      content=full_content;
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
                                                                                                                                                                                                          , 'startup'))
    startup_MVPA_Light;
  else
    addpath(toolbox);
  end
  % remember the toolbox that was just added to the path, it will be cleaned up by FT_POSTAMBLE_HASTOOLBOX
  if ~isfield(ft_default, 'toolbox') || ~isfield(ft_default.toolbox, 'cleanup')
    ft_default.toolbox.cleanup = {};
  end
  ft_default.toolbox.cleanup{end+1} = toolbox;
  status = true;
elseif (~isempty(regexp(toolbox, 'spm2$', 'once')) || ~isempty(regexp(toolbox, 'spm5$', 'once')) || ~isempty(regexp(toolbox, 'spm8$', 'once')) || ~isempty(regexp(toolbox, 'spm12$', 'once'))) && exist([toolbox 'b'], 'dir')
  % the final release version of SPM is not available, add the beta version instead
  status = myaddpath([toolbox 'b'], silent);
else
  status = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path = unixpath(path)
%path(path=='\') = '/'; % replace backward slashes with forward slashes
path = strrep(path,'\','/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = hasfunction(funname, toolbox)
try
  % call the function without any input arguments, which probably is inapropriate
  feval(funname);
  % it might be that the function without any input already works fine
  status = true;
catch
  % either the function returned an error, or the function is not available
  % availability is influenced by the function being present and by having a
  % license for the function, i.e. in a concurrent licensing setting it might
  % be that all toolbox licenses are in use
  m = lasterror;
  if strcmp(m.identifier, 'MATLAB:license:checkouterror')
    if nargin>1
      ft_warning('the %s toolbox is available, but you don''t have a license for it', toolbox);
    else
      ft_warning('the function ''%s'' is available, but you don''t have a license for it', funname);
    end
    status = false;
  elseif strcmp(m.identifier, 'MATLAB:UndefinedFunction')
    status = false;
  else
    % the function seems to be available and it gave an unknown error,
    % which is to be expected with inappropriate input arguments
    status = true;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = is_subdir_in_fieldtrip_path(toolbox_name)
fttrunkpath = unixpath(fileparts(which('ft_defaults')));
fttoolboxpath = fullfile(fttrunkpath, lower(toolbox_name));
needle   = [pathsep fttoolboxpath pathsep];
haystack = [pathsep path() pathsep];
status   = contains(haystack, needle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = has_mex(name)
full_name=[name '.' mexext];
status = (exist(full_name, 'file')==3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = get_spm_version()
if ~is_present('spm')
  v=NaN;
  return
end

version_str = spm('ver');
token = regexp(version_str,'(\d*)','tokens');
v = str2num([token{:}{:}]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = check_spm_mex()
status = true;
try
  % this will always result in an error
  spm_conv_vol
catch
  me = lasterror;
  % any error is ok, except when due to an invalid MEX file
  status = ~isequal(me.identifier, 'MATLAB:mex:ErrInvalidMEXFile');
end
if ~status
  % SPM8 mex file issues are common on macOS with recent MATLAB versions
  ft_warning('the SPM mex files are incompatible with your platform, see http://bit.ly/2OGF6US');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = has_license(toolbox_name)
% NOTE: this explicitly checks out a license, which may be suboptimal in
% terms of license use. Consider using the option 'test', but this needs to
% be checked with respect to backward compatibility first
status = license('checkout', toolbox_name)==1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = is_present(dependency)
if iscell(dependency)
  % use recursion
  status = all(cellfun(@is_present,dependency));
elseif islogical(dependency)
  % boolean
  status = all(dependency);
elseif ischar(dependency)
  % name of a function
  status = is_function_present_in_search_path(dependency);
elseif isa(dependency, 'function_handle')
  status = dependency();
else
  assert(false,'this should not happen');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = is_function_present_in_search_path(function_name)
w = which(function_name);

% must be in path and not a variable
status = ~isempty(w) && ~isequal(w, 'variable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ISFOLDER is needed for versions prior to 2017b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = isfolder(dirpath)
tf = exist(dirpath,'dir') == 7;
                                                                                                                                                                                                                                                                                                                                                                                              T16_dV'  'MRT16'
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
     