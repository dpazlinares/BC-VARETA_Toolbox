function [dim] = pos2dim3d(pos,dimold)

% POS2DIM3D reconstructs the volumetric dimensions from an ordered list of 
% positions. optionally, the original dim can be provided, and the (2:end)
% elements are appended to the output.
%
% Use as
%   [dim] = pos2dim3d(pos, dimold)
% where pos is an ordered list of positions and where the (optional)
% dimold is a vector with the original dimensionality of the anatomical
% or functional data.
%
% The output dim is a 1x3 or 1xN vector of which the first three elements
% correspond to the 3D volumetric dimensions.
%
% See also POS2DIM, POS2TRANSFORM

% Copyright (C) 2009, Jan-Mathijs Schoffelen

if nargin==1 && ~isstruct(pos),
  dimold = zeros(0,2);
elseif isstruct(pos),
  % the input is a FieldTrip data structure
  dimord = pos.dimord;
  dimtok = tokenize(dimord, '_');
  for i = 1:length(dimtok)
    if strcmp(dimtok{i},'pos'),
      dimold(i,1) = size(pos.pos,1);
    else
      dimold(i,1) = numel(getfield(pos, dimtok{i}));
    end
  end
  pos = pos.pos;
else
  if size(pos,1)~=dimold(1),
    ft_error('the first element in the second input should be equal to the number of positions');
  end
end

% extract the dim now that the bookkeeping is done
dim = pos2dim(pos);

                                                                                                                                                                                                                                                                                                                      �D	�fn��Y���ɍA��Y��Y�����Y��\�fn�B�D	�����^�fn��A�����Y��Y��\�fn��Ffn����B�D	��^�fn���ۍF����Y��Y�fn�B�	�Y�����\��Y�fn�����^�fn��A����Y��Y��\�fn��Ffn������^�fn���ҍA����Y��Y��Y��\�fn��Ffn����B�D	�^�fn���ۍA����Y��Y��Y��\�fn�����^؍F
fn�B�D	fn����A�Y��Y�����Y��\�fn��F��fn����B��^�fn���ҍA��I������Y��Y��Y��\�fn�����^�f(��?���L�|$0L�t$8L�l$@L�d$pH�t$hH�l$`D;�TA��C�T �+�A+�D�Cfn�B�D	�fnɃ���I���������Y�fn��Y�����Y�f(��\��^�f(�u�f(�(t$ H��H_[���������H�\$H�l$H�t$WH��0)t$ I��H��A��tH�  �   H��s   H�K�,��f   H�K�,��Y   �   ��E3�f(��@   H��H�E �.   �׋�f(�H���.���H�l$HH�t$P(t$ �H�\$@H��0_��%  �%�  �%�  �%�  �%�  ��@SH�� �   ��  H��H���  H�,  H�  H��u�C�#H�# ��  H��  �  H��  �  3�H�� [���H��H�XH�hH�xL�` AUAVAWH�� 3�M��L����8  ��  ���#  ��D��z  eH�%0   H�X�H;�t��  �c
  3��H�p  u��A�   �X  ��t�   �_  �  H�U  �/
  L��H����   H�4  �
  M��L��H��H��I;�rZH9} t�� 
  H9E t�H�M ��	  H���
  H�E ��H��  ��	  H��  H����	  L;�uL;�t�L��L���I����	  ��	  H��  H��  �=�  E����   H�=�  ��   3���   ����   eH�%0   ��H�X�H;�t��  �9	  3��H�F  u���   �/  ��t�   �7  �>H��	  H��	  �     �  ��u�H��	  H��	  ��  ��     ��u
H��H��  H9=�  t!H��  �  ��tM�ĺ   I����  ��  �   H�\$@H�l$HH�|$PL�d$XH�� A_A^A]����H��H�XH�pH�xATH��0I����L��   �X�  ��u9/  u
3ۉX���   ��t��u7H��	  H��t�Ћ؉D$ ����   L�Ƌ�I���0����؉D$ ����   L�Ƌ�I���  �؉D$ ��u5��u1L��3�I����  L��3�I�������L�-	  M��tL��3�I��A�Ӆ�t��u7L�Ƌ�I���������#ˋىL$ tH��  H��tL�Ƌ�I���Ћ؉D$ �3ۉ\$ �'  ������H�\$@H�t$HH�|$PH��0A\����H�\$H�t$WH�� I����H���u�k  L�ǋ�H��H�\$0H�t$8H�� _�������H��  ��  @SH�� H��H��  ��  H�D$8H���uH���*  �~�   ��  �H��  ��  H�D$8H��  ��  H�D$@H����  H��L�D$@H�T$8�  H��H�L$8�p  H��  H�L$@�^  H�g  �   �S  H��H�� [�H��(�G���H�������H��(��H�\$WH�� H��  H�=�  �H�H��t��H��H;�r�H�\$0H�� _�H�\$WH�� H�s  H�=l  �H�H��t��H��H;�r�H�\$0H�� _�����H���MZ  f9t3��HcH<H�3��9PE  u�  f9Q�����LcA<E3�L��L�A�@E�XJ�L E��t�QL;�r
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
</assembly>PAPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPAD       �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ub_binding_helper __dyld_func_lookup _legendre_Pmm _plgndr  stub helpers dyld__mach_header _mexFunction _mexErrMsgTxt _mxCreateDoubleMatrix_700 _mxGetData _mxGetScalar dyld_stub_binder                                                                                                                                                                                                                                                                                                                                        );
%uicontrol(opt.handles.colorbar);
if strcmp(cfg.zlim, 'maxmin') 
  set(opt.handles.checkbox.automatic, 'Value', 1) 
  set(opt.handles.checkbox.symmetric, 'Value', 0)
  cb_colorbar(opt.handles.figure);
elseif strcmp(cfg.zlim, 'maxabs')
  set(opt.handles.checkbox.automatic, 'Value', 1)
  set(opt.handles.checkbox.symmetric, 'Value', 1)
  cb_colorbar(opt.handles.figure);
else
  set(opt.handles.checkbox.automatic, 'Value', 0)
  set(opt.handles.checkbox.symmetric, 'Value', 0)
  cb_colorbar(opt.handles.figure, cfg.zlim);
end

if opt.record
  opt.record = false;
  opt.quit = true;
  guidata(opt.handles.figure, opt);
  cb_recordbutton(opt.handles.button.record);
else 
  opt.quit = false;
  guidata(opt.handles.figure, opt);
end

end

%%
%  **************************************************************
%  ********************* CREATE GUI *****************************
%  **************************************************************
function opt = createGUI(opt)

%% main figure
opt.handles.figure = figure(    ...
  'Units',       'normalized',  ...
  'Name',        'ft_movieplot',...
  'Menu',        'none',        ...
  'Toolbar',     'figure',      ...
  'NumberTitle', 'off',         ...
  'UserData',    [],            ...
  'Tag',         'mainFigure',  ...
  'Visible',     'on',          ...
  'windowbuttondownfcn', @cb_getposition);
  %'WindowButtonUpFcn', @cb_stopDrag, ...

%%  panels 
clf

% visualization panel for the geometrical information
opt.handles.panel.visualization_geometry = uipanel(...
  'tag',      'mainPanels1',      ... % tag according to position
  'parent',   opt.handles.figure, ...
  'units',    'normalized',       ...
  'title',    'Visualization_geometry', ...
  'clipping', 'on',               ...
  'visible',  'on');

% rearrange 
ft_uilayout(opt.handles.figure,     ...
  'tag',             'mainPanels1', ...
  'backgroundcolor', [.8 .8 .8],    ...
  'hpos',            'auto',        ...
  'vpos',            .15,           ...
  'halign',          'left',        ...
  'width',           1,             ...
  'height',          0.1);

% visualization panel for the non-geometrical information
opt.handles.panel.visualization = uipanel(...
  'tag',      'mainPanels2',      ... % tag according to position
  'parent',   opt.handles.figure, ...
  'units',    'normalized',       ...
  'title',    'Visualization',    ...
  'clipping', 'on',               ...
  'visible',  'on');

% rearrange 
ft_uilayout(opt.handles.figure,     ...
  'tag',             'mainPanels2', ...
  'backgroundcolor', [.8 .8 .8],    ...
  'hpos',            'auto',        ...
  'vpos',            .55,           ...
  'halign',          'left',        ...
  'width',           0.5,           ...
  'height',          0.1);

% settings panel (between different views can be switched)
% opt.handles.panel.view = uipanel(...
%   'tag',    'sidePanels', ... % tag according to position
%   'parent', opt.handles.figure,...
%   'units',  'normalized', ...
%   'title',  'View',...
%   'clipping','on',...
%   'visible', 'on');

% settings panel ()
opt.handles.panel.settings = uipanel(...
  'tag',      'sidePanels',       ... % tag according to position
  'parent',   opt.handles.figure, ...
  'units',    'normalized',       ...
  'title',    'Settings',         ...
  'clipping', 'on',               ...
  'visible',  'on');

% rearrange panel
ft_uilayout(opt.handles.figure,    ...
  'tag',             'sidePanels', ...
  'backgroundcolor', [.8 .8 .8],   ...
  'hpos',            'auto',       ...
  'vpos',            0.15,         ...
  'halign',          'right',      ...
  'width',           0.15,         ...
  'height',          0.55);

% control panel
opt.handles.panel.controls = uipanel(...
  'tag',    'lowerPanels', ... % tag according to position
  'parent', opt.handles.figure,...
  'units',  'normalized', ...
  'title',  'Controls',...
  'clipping','on',...
  'visible', 'on');

% rearrange 
ft_uilayout(opt.handles.figure,     ...
  'tag',             'lowerPanels', ...
  'backgroundcolor', [0.8 0.8 0.8], ...
  'hpos',            'auto',        ...
  'vpos',            0,             ...
  'halign',          'right',       ...
  'width',           1,             ...
  'height',          0.15);

ft_uilayout(opt.handles.figure, ...
  'tag',   'mainPanels1',       ...
  'retag', 'sidePanels');

ft_uilayout(opt.handles.figure, ...
  'tag',   'mainPanels2',       ...
  'retag', 'sidePanels');

ft_uilayout(opt.handles.figure,    ...
  'tag',             'sidePanels', ...
  'backgroundcolor', [.8 .8 .8],   ...
  'hpos',            'auto',       ...
  'vpos',            'align',      ...
  'halign',          'left',       ...
  'valign',          'top',        ...
  'height',          .85);


% add axes
% 3 axes for switching to topo viewmode
% opt.handles.axes.A = axes(...
%   'Parent',opt.handles.panel.view,...
%   'Position',[0 0 1 .33], ...
%   'Tag','topoAxes',...
%   'HandleVisibility', 'on', ...
%   'UserData',[]);
% 
% opt.handles.axes.B = axes(...
%   'Parent',opt.handles.panel.view,...
%   'Position',[0 0.33 1 .33], ...
%   'Tag','topoAxes',...
%   'HandleVisibility', 'on', ...
%   'UserData',[]);
% 
% opt.handles.axes.C = axes(...
%   'Parent',opt.handles.panel.view,...
%   'Position',[0 0.66 1 .33], ...
%   'Tag','topoAxes',...
%   'HandleVisibility', 'on', ...
%   'UserData',[]);

% control panel uicontrols

opt.handles.button.play = uicontrol(...
  'parent',opt.handles.panel.controls,...
  'tag', 'controlInput', ...
  'string','Play',... 
  'units', 'normalized', ...
  'style', 'pushbutton', ...
  'callback',@cb_playbutton,...
  'userdata', 'space');
  
opt.handles.button.record = uicontrol(...
  'parent',opt.handles.panel.controls,...
  'tag', 'controlInput', ...
  'string','Record?',... 
  'units', 'normalized', ...
  'style', 'checkbox', ...
  'Callback',@cb_recordbutton,...
  'userdata', 'enter');

ft_uilayout(opt.handles.panel.controls, ...
  'tag', 'controlInput', ...
  'width', 0.15, ...
  'height', 0.25, ...
  'hpos', 'auto', ...
  'vpos', .75, ...
  'halign', 'right', ...
  'valign', 'top');


opt.handles.text.speed = uicontrol(...
  'parent',opt.handles.panel.controls,...
  'tag', 'speedInput', ...
  'string','Speed',... 
  'units', 'normalized', ...
  'style', 'text');

opt.handles.edit.speed = uicontrol(...
  'parent',opt.handles.panel.controls,...
  'tag', 'speedInput', ...
  'string','1.0',... 
  'units', 'normalized', ...
  'Callback',@cb_speed, ...
  'style', 'edit');


ft_uilayout(opt.handles.panel.controls, ...
  'tag', 'speedInput', ...
  'width', 0.15, ...
  'height', 0.25, ...
  'hpos', 'auto', ...
  'vpos', .25, ...
  'halign', 'right', ...
  'valign', 'top');


% opt.handles.button.faster = uicontrol(...
%   'parent',opt.handles.panel.controls,...
%   'tag', 'controlInput', ...
%   'string','+',... 
%   'units', 'normalized', ...
%   'style', 'pushbutton', ...
%   'userdata', '+', ...
%   'Callback',@cb_slider);
% 
% 
% opt.handles.button.slower = uicontrol(...
%   'parent',opt.handles.panel.controls,...
%   'tag', 'controlInput', ...
%   'string','-',... 
%   'units', 'normalized', ...
%   'style', 'pushbutton', ...
%   'userdata', '-', ...
%   'Callback',@cb_slider);

% ft_uilayout(opt.handles.panel.controls, ...
%   'tag', 'controlInput', ...
%   'width', 0.15, ...
%   'height', 0.25, ...
%   'hpos', 'auto', ...
%   'vpos', .75, ...
%   'valign', 'top');
% 
% set(opt.handles.button.slower, 'tag', 'speedButtons');
% set(opt.handles.button.faster, 'tag', 'speedButtons');
% 
% 
% ft_uilayout(opt.handles.panel.controls, ...
%   'tag', 'speedButtons', ...
%   'width', 0.05, ...
%   'height', 0.125, ...
%   'vpos', 'auto');
% 
% ft_uilayout(opt.handles.panel.controls, ...
%   'tag', 'speedButtons', ...
%   'hpos', 'align');
% 
% 
% ft_uilayout(opt.handles.panel.controls, ...
%   'tag', 'speedButtons', ...
%   'retag', 'controlInput');

% speed control

opt.handles.slider.xparam = uicontrol(...
  'Parent',opt.handles.panel.controls,...
  'Units','normalized',...
  'BackgroundColor',[0.9 0.9 0.9],...
  'Callback',@cb_slider,...
  'Position',[0.0 0.75 0.625 0.25],...
  'SliderStep', [1/numel(opt.xvalues) 1/numel(opt.xvalues)],...  
  'String',{  'Slider' },...
  'Style','slider',...
  'Tag','xparamslider');

opt.handles.label.xparam = uicontrol(...
  'Parent',opt.handles.panel.controls,...
  'Units','normalized',...
  'Position',[0.0 0.5 0.625 0.25],...
  'String','xparamLabel',...
  'Style','text',...
  'Tag','xparamLabel');

if ~isempty(opt.ydim)
  opt.handles.slider.yparam = uicontrol(...
    'Parent',opt.handles.panel.controls,...
    'Units','normalized',...
    'BackgroundColor',[0.9 0.9 0.9],...
    'Callback',@cb_slider,...
    'Position',[0.0 0.25 0.625 0.25],...
    'SliderStep', [1/numel(opt.yvalues) 1/numel(opt.yvalues)],...  
    'String',{  'Slider' },...
    'Style','slider',...
    'Tag','yparamSlider');

  opt.handles.label.yparam = uicontrol(...
    'Parent',opt.handles.panel.controls,...
    'Units','normalized',...
    'Position',[0.0 0.0 0.625 0.25],...
    'String','yparamLabel',...
    'Style','text',...
    'Tag','text3');
end

opt.handles.axes.colorbar = axes(...
  'Parent',opt.handles.panel.settings,...
  'Units','normalized',...
  'Position',[0 0 1.0 1],...
  'ButtonDownFcn',@cb_color,...
  'HandleVisibility', 'on', ...
  'Tag','colorbarAxes', ...
  'YLim', [0 1], ...
  'YLimMode', 'manual', ...
  'XLim', [0 1], ...
  'XLimMode', 'manual');

opt.handles.colorbar = colorbar('ButtonDownFcn', []);
set(opt.handles.colorbar, 'Parent', opt.handles.panel.settings);
set(opt.handles.colorbar, 'Position', [0.4 0.2 0.2 0.65]);
nColors = size(colormap, 1);
set(opt.handles.colorbar, 'YTick', [1 nColors/4 nColors/2 3*nColors/4 nColors]);
if (gcf~=opt.handles.figure)
  close gcf; % sometimes there is a new window that opens up
end
%
% set lines
%YLim = get(opt.handles.colorbar, 'YLim');
opt.handles.lines.upperColor = line([-1 0], [32 32], ...
  'Color', 'black', ...
  'LineWidth', 4, ...
  'ButtonDownFcn', @cb_startDrag, ...
  'Parent', opt.handles.colorbar, ...
  'Visible', 'off', ...
  'Tag', 'upperColor');

opt.handles.lines.lowerColor = line([1 2], [32 32], ...
  'Color', 'black', ...
  'LineWidth', 4, ...
  'ButtonDownFcn', @cb_startDrag, ...
  'Parent', opt.handles.colorbar, ...
  'Visible', 'off', ...
  'Tag', 'lowerColor');

opt.handles.menu.colormap = uicontrol(...
  'Parent',opt.handles.panel.settings,...
  'Units','normalized',...
  'BackgroundColor',[1 1 1],...
  'Callback',@cb_colormap,...
  'Position',[0.25 0.95 0.5 0.05],...
  'String',{  'jet'; 'hot'; 'cool'; 'ikelvin'; 'ikelvinr' },...
  'Style','popupmenu',...
  'Value',1, ...
  'Tag','colormapMenu');

opt.handles.checkbox.automatic = uicontrol(...
  'Parent',opt.handles.panel.settings,...
  'Units','normalized',...
  'Callback',@cb_colorbar,...
  'Position',[0.10 0.05 0.75 0.05],...
  'String','automatic',...
  'Style','checkbox',...
  'Value', 1, ... % TODO make this dependet on cfg.zlim
  'Tag','autoCheck');

opt.handles.checkbox.symmetric = uicontrol(...
  'Parent',opt.handles.panel.settings,...
  'Units','normalized',...
  'Callback',@cb_colorbar,...
  'Position',[0.10 0.0 0.75 0.05],...
  'String','symmetric',...
  'Style','checkbox',...
  'Value', 0, ... % TODO make this dependet on cfg.zlim
  'Tag','symCheck');

% buttons

opt.handles.button.decrLowerColor = uicontrol(...
  'Parent', opt.handles.panel.settings,...
  'Units','normalized',...
  'Enable', 'off', ...
  'Callback',@cb_colorbar,...
  'Position',[0.35 0.125 0.15 0.05],...
  'String','-',...
  'Tag','decrLowerColor');

opt.handles.button.incrLowerColor = uicontrol(...
  'Parent', opt.handles.panel.settings,...
  'Units','normalized',...
  'Enable', 'off', ...
  'Callback',@cb_colorbar,...
  'Position',[0.5 0.125 0.15 0.05],...
  'String','+',...
  'Tag','incrLowerColor');


opt.handles.button.decrUpperColor = uicontrol(...
  'Parent', opt.handles.panel.settings,...
  'Units','normalized',...
  'Enable', 'off', ...
  'Callback',@cb_colorbar,...
  'Position',[0.35 0.875 0.15 0.05],...
  'String','-',...
  'Tag','decrUpperColor');

opt.handles.button.incrUpperColor = uicontrol(...
  'Parent', opt.handles.panel.settings,...
  'Units','normalized',...
  'Enable', 'off', ...
  'Callback',@cb_colorbar,...
  'Position',[0.5 0.875 0.15 0.05],...
  'String','+',...
  'Tag','incrUpperColor');

% Handle to the axes that will contain the geometry
opt.handles.axes.movie = axes(...
  'Parent',             opt.handles.panel.visualization_geometry,...
  'Position',           [0 0 1 1],                     ...
  'CameraPosition',     [0.5 0.5 9.16025403784439],    ...
  'CameraPositionMode', get(0,'defaultaxesCameraPositionMode'),...
  'CLim',               get(0,'defaultaxesCLim'),      ...
  'CLimMode',           'manual',                      ...
  'Color',              [0.9 0.9 0.94],                ...
  'ColorOrder',         get(0,'defaultaxesColorOrder'),...
  'XColor',             get(0,'defaultaxesXColor'),    ...
  'YColor',             get(0,'defaultaxesYColor'),    ...
  'ZColor',             get(0,'defaultaxesZColor'),    ...
  'HandleVisibility',   'on',                          ...
  'ButtonDownFcn',      @cb_view,                      ...
  'Tag',                'geometry');

% Handle to the axes that will contain the non-geometry
opt.handles.axes.other = axes(...
  'Parent',             opt.handles.panel.visualization,...
  'Position',           [0 0 1 1],                     ...
  'CameraPosition',     [0.5 0.5 9.16025403784439],    ...
  'CameraPositionMode', get(0,'defaultaxesCameraPositionMode'),...
  'CLim',               get(0,'defaultaxesCLim'),      ...
  'CLimMode',           'manual',                      ...
  'Color',              [0.9 0.9 0.94],                ...
  'ColorOrder',         get(0,'defaultaxesColorOrder'),...
  'XColor',             get(0,'defaultaxesXColor'),    ...
  'YColor',             get(0,'defaultaxesYColor'),    ...
  'ZColor',             get(0,'defaultaxesZColor'),    ...
  'HandleVisibility',   'on',                          ...
  'ButtonDownFcn',      @cb_view,                      ...
  'Tag',                'other');


% Disable axis labels
axis(opt.handles.axes.movie,    'equal');
axis(opt.handles.axes.colorbar, 'equal');
% axis(opt.handles.axes.A, 'equal');
% axis(opt.handles.axes.B, 'equal');
% axis(opt.handles.axes.C, 'equal');
%
axis(opt.handles.axes.movie,    'off');
axis(opt.handles.axes.colorbar, 'off');
% axis(opt.handles.axes.A, 'off');
% axis(opt.handles.axes.B, 'off');
% axis(opt.handles.axes.C, 'off');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_panels(opt)
  for i=1:numel(opt.dat)
    if ~any(opt.issource)
      set(opt.handles.grid{i}, 'cdata', griddata(opt.chanx{i}, opt.chany{i}, opt.mask{i}(:,opt.valx,opt.valy).*opt.dat{i}(:,opt.valx,opt.valy), opt.xdata{i}, opt.nanmask{i}.*opt.ydata{i}, 'v4'));
    else
      set(opt.handles.mesh{i}, 'FaceVertexCData',     squeeze(opt.dat{i}(:,opt.valx,opt.valy)));
      set(opt.handles.mesh{i}, 'FaceVertexAlphaData', squeeze(opt.mask{i}(:,opt.valx,opt.valy)));
    end
  end

  if opt.doplot
    opt.valz
    set(get(opt.handles.axes.other,'children'), 'ydata', opt.dat{1}(opt.valz,:));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_speed(h, eventdata)
if ~ishandle(h)
  return
end
opt = guidata(h);

val = get(h, 'String');
% val = get(opt.handles.slider.speed, 'value');
% val = exp(log(opt.MAX_SPEED) * (val-.5)./0.5);
% 
% % make sure we can easily get back to normal speed
% if abs(val-opt.AVG_SPEED) < 0.08
%   val = opt.AVG_SPEED;
%   set(opt.handles.slider.speed, 'value', 0.5);
% end

speed = str2num(val);
if isempty(speed)
  speed = opt.speed;
end
opt.speed = speed;

set(h, 'String', opt.speed)

% if val >=100
%   set(opt.handles.label.speed, 'String', ['Speed ' num2str(opt.speed, '%.1f'), 'x'])
% elseif val >= 10
%   set(opt.handles.label.speed, 'String', ['Speed ' num2str(opt.speed, '%.2f'), 'x'])
% else
%   set(opt.handles.label.speed, 'String', ['Speed ' num2str(opt.speed, '%.3f'), 'x'])
% end

guidata(h, opt);
uiresume;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_timer(obj, info, h)
if ~ishandle(h)
  return
end
opt = guidata(h);
delta = opt.speed/numel(opt.xvalues);
val = get(opt.handles.slider.xparam, 'value');
val = val + delta;

if opt.record
  if val>1
    % stop recording
    stop(opt.timer);
    % reset again
    val = 0;    
    set(opt.handles.slider.xparam, 'value', val);
    cb_slider(h);
    cb_recordbutton(opt.handles.button.record);
    % TODO FIXME add some message here
    guidata(h, opt);
    return;
  end
end

while val>1
    val = val-1;  
end
set(opt.handles.slider.xparam, 'value', val);
cb_slider(h);

if opt.record
  pause(.1);
  drawnow;
  vs = version('-release');
  vs = vs(1:4);
  % get starting position via parameter panel    
  currFrame = getframe(opt.handles.figure);
  for i=1:opt.samperframe
    if vs<2010
      opt.vidObj = addframe(opt.vidObj, currFrame);
    else
      writeVideo(opt.vidObj, currFrame);
    end
    
  end
  guidata(h, opt);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_slider(h, eventdata)
opt = guidata(h);
valx = get(opt.handles.slider.xparam, 'value');
valx = round(valx*(numel(opt.xvalues)-1))+1;
valx = min(valx, numel(opt.xvalues));
valx = max(valx, 1);
set(opt.handles.label.xparam, 'String', [opt.xparam ' ' num2str(opt.xvalues(valx), '%.2f') 's']);


if ~isempty(opt.yvalues)
  valy = get(opt.handles.slider.yparam, 'value');
  valy = round(valy*(numel(opt.yvalues)-1))+1;
  valy = min(valy, numel(opt.yvalues));
  valy = max(valy, 1);
  
  if valy ~= opt.valy
    cb_colorbar(h);
  end
  
  set(opt.handles.label.yparam, 'String', [opt.yparam ' ' num2str(opt.yvalues(valy), '%.2f') 'Hz']);
else
  valy = 1;
end

opt.valx = valx;
opt.valy = valy;

guidata(h, opt);

update_panels(opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_playbutton(h, eventdata)
if ~ishandle(h)
  return
end
opt = guidata(h);
switch get(h, 'string')
  case 'Play'
    set(h, 'string', 'Stop');
    start(opt.timer);
  case 'Stop'
    set(h, 'string', 'Play');
    stop(opt.timer);
end
uiresume;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_recordbutton(h, eventdata)
if ~ishandle(h)
  return
end

opt = guidata(h);

 
opt.record = ~opt.record; % switch state
guidata(h, opt);

if opt.record
  
  if ~opt.fixedframesfile
    % open a save-file dialog
    [FileName,PathName,FilterIndex] = uiputfile('*.avi', 'Save AVI-file' , 'ft_movie');
    
    if (FileName == 0 && PathName == 0) % aborted
      cb_recordbutton(h);
      return;
    end
    
    opt.framesfile = fullfile(PathName, FileName);
    
    if (FilterIndex==1) % remove .avi again (4 chars)
      opt.framesfile = opt.framesfile(1:end-4);
    end
    
  end
  
  % FIXME open new window to play in there, so that frame getting works
  vs = version('-release');
  vs = vs(1:4);
  if vs<2010
    opt.vidObj = avifile(opt.framesfile, 'FPS', opt.framerate);
  else
    opt.vidObj = VideoWriter(opt.framesfile, 'Uncompressed AVI');
    opt.vidObj.FrameRate = opt.framerate;
    open(opt.vidObj);
  end
 
  %set(opt.handles.figure,'renderer','opengl')
  %opengl software;
  set(opt.handles.figure,'renderer','zbuffer');
  %opt.vidObj = avifile(opt.framesfile, 'fps', opt.framerate, 'quality', 75);
  
  set(h, 'string', 'Stop');  
  guidata(h, opt);
  start(opt.timer);
else
  % FIXME set handle back to old window
  stop(opt.timer);
  if ~isempty(opt.framesfile)
    vs = version('-release');
    vs = vs(1:4);
    if vs<2010
      opt.vidObj = close(opt.vidObj); 
    else    
      close(opt.vidObj);
    end
  end
  set(h, 'string', 'Record');  
  guidata(h, opt);
    
  if (opt.quit)
    close(opt.handles.figure);
  end
end


% 
% % This function should open a new window, plot in there, extract every
% % frame, store the movie in opt and return again
% 
% % this is not needed, no new window is needed
% %scrsz = get(0, 'ScreenSize');
% %f = figure('Position',[1 1 scrsz(3) scrsz(4)]);
% 
% % FIXME disable buttons (apart from RECORD) when recording
% % if record is pressed, stop recording and immediately return
% 
% % adapted from ft_movieplotTFR
% 
% % frequency/time selection
% if ~isempty(opt.yvalues) && any(~isnan(yvalues))
%   if ~isempty(cfg.movietime)
%     indx = cfg.movietime;
%     for iFrame = 1:floor(size(opt.dat, opt.xdim)/cfg.samperframe)
%       indy = ((iFrame-1)*cfg.samperframe+1):iFrame*cfg.samperframe;
%       updateMovie(opt, indx, indy);
%       F(iFrame) = getframe;
%     end
%   elseif ~isempty(cfg.moviefreq)
%     indy = cfg.moviefreq;
%     for iFrame = 1:floor(size(opt.dat, opt.ydim)/cfg.samperframe)
%       indx = ((iFrame-1)*cfg.samperframe+1):iFrame*cfg.samperframe;
%       updateMovie(opt, indx, indy);
%       F(iFrame) = getframe;
%     end
%   else
%     ft_error('Either moviefreq or movietime should contain a bin number')
%   end
% else
%   for iFrame = 1:floor(size(opt.dat, opt.xdim)/cfg.samperframe)
%     indx = ((iFrame-1)*cfg.samperframe+1):iFrame*cfg.samperframe;
%     updateMovie(opt, indx, 1);
%     F(iFrame) = getframe;
%   end
% end
% 
% % save movie
% if ~isempty(cfg.framesfile)
%   save(cfg.framesfile, 'F');
% end
% % play movie
% movie(F, cfg.movierpt, cfg.framespersec);

% uiresume;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_colormap(h, eventdata)
maps = get(h, 'String');
val = get(h, 'Value');

while ~strcmp(get(h, 'Tag'), 'mainFigure')
  h = get(h, 'Parent');
end

opt =  guidata(h);

cmap = feval(maps{val}, size(colormap, 1));
% if strcmp(maps{val}, 'ikelvin')
%   cmap = ikelvin(size(colormap, 1));
% elseif strcmp(maps{val}, 'kelvin')
%   cmap = kelvin(size(colormap, 1));
% else  
%   cmap = colormap(opt.handles.axes.movie, maps{val});
% end

if get(opt.handles.checkbox.automatic, 'Value')
  colormap(opt.handles.axes.movie_subplot{1}, cmap);
end

adjust_colorbar(opt);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb_colorbar(h, eventdata)
if strcmp(get(h, 'Tag'), 'mainFigure') % this is the init call
  incr = false;
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
     