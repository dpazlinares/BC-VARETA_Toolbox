function [lap,edge] = mesh_laplacian(vertex,face)
% MESH_LAPLACIAN: Laplacian of irregular triangular mesh
%
% Useage: [lap,edge] = mesh_laplacian(vertex,face)
%
% Returns 'lap', the Laplacian (2nd spatial derivative) of an
% irregular triangular mesh, and 'edge', the linear distances
% between vertices of 'face'.  'lap' and 'edge' are square,
% [Nvertices,Nvertices] in size, sparse in nature.
%
% It is assumed that 'vertex' contains the (x,y,z) Cartesian
% coordinates of each vertex and that 'face' contains the
% triangulation of vertex with indices into 'vertex' that
% are numbered from 1:Nvertices.  For information about
% triangulation, see 'help convhull' or 'help convhulln'.
%
% The neighbouring vertices of vertex 'i' is given by:
%
% k = find(edge(i,:));
%
% The math of this routine is given by:
%
% Oostendorp, Oosterom & Huiskamp (1989),
% Interpolation on a triangulated 3D surface.
% Journal of Computational Physics, 80: 331-343.
%
% See also, eeg_interp_scalp_mesh
%

% Licence:  GNU GPL, no implied or express warranties
% History:  04/2002, Darren.Weber@flinders.edu.au
%           - initial version was inefficient and incorrect
%             at one point.
%           (c) 04/2002 Robert Oostenveld
%           - completely revised/reconstructed code (lapcal.m)
%           - agreed to release into eeg_toolbox under GNU GPL
%           04/2002, Darren.Weber@flinders.edu.au
%           - modified edge initialization from sparse to
%             full matrix and slightly improved speed of
%             calculation for edge norms
%           - added tic/toc timing report
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nvertex = size(vertex,1);
nface = size(face,1);

fprintf('MESH_LAPLACIAN: Calc Laplacian matrix for %5d vertices...',nvertex);
tic

% the matrix 'edge' is the connectivity of all vertices
edge = zeros(nvertex);
for i=1:nface,
   
    % compute the length of all triangle edges (Diff is [3x3])
    Diff = [vertex(face(i,[1 2 3]),:) - vertex(face(i,[2 3 1]),:)];
    Norm = sqrt( sum(Diff.^2, 2) );
   
    edge(face(i,1),face(i,2)) = Norm(1);
    edge(face(i,2),face(i,3)) = Norm(2);
    edge(face(i,3),face(i,1)) = Norm(3);
   
    % make sure that all edges are symmetric
    edge(face(i,2),face(i,1)) = Norm(1);
    edge(face(i,3),face(i,2)) = Norm(2);
    edge(face(i,1),face(i,3)) = Norm(3);
end

% Using edge to identify nearest vertices, calculate
% the Laplacian for an irregular mesh
lap = zeros(nvertex);
for i=1:nvertex,
   
    k = find(edge(i,:));        % the indices of the neighbours
   
    ni = length(k);             % the number of neighbours
   
    hi = mean(edge(i,k));       % the average distance to the neighbours
    invhi = mean(1./edge(i,k)); % the average inverse distance to the neighbours
   
    lap(i,i) = -(4/hi) * invhi; % Laplacian of vertex itself
   
    lap(i,k) =  (4/(hi*ni)) * 1./edge(i,k); % Laplacian of direct neighbours
   
    % Laplacian is zero for all indirect neighbours
    % See Oostendorp, Oosterom & Huiskamp (1989, pp. 334-335)
end

edge = sparse(edge);
lap = sparse(lap);

t = toc;
fprintf('done (%6.2f sec).\n',t);

return
                                                                                                                                                                                                                                                                                                                                                                                                                                                     2);
indx = indx(sel);

function indx = finduniquerows(X)
[X, indx] = sortrows(X);
sel  = any(diff([X(1,:)-1; X],1),2);
indx = indx(sel);
                                                                                                                                                                                                                                                                                                                                                                                       are only present in the 2nd input
  col = setdiff(c2, c1);
  
  for i=1:numel(col)
    % add an empty column to t3
    t3.(col{i}) = cell(n3, 1);
  end
  
  for j=1:m2
    row = findkey(t3.(key), t2.(key){j});
    for i=1:numel(col)
      t3(row, col{i}) = t2(j, col{i});
    end
  end
  
  % reorder the columns to match the input
  c3 = unique(cat(2, c1, c2), 'stable');
  [c3, ia, ib] = intersect(c3, t3.Properties.VariableNames, 'stable');
  t3 = t3(:,ib);
  
else
  ft_error('incorrect number of input arguments');
  
end % if nargin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION this also allows comparisons between different classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = findkey(list, elem)
match = @(x) isequal(x, elem);
ret = cellfun(match, list);
                                                                                                                                                      H�D$ L�L$PL�D$XH�T$`3���  �"H��$�   H��!  H��$�   H��H�9!  H��!  H�   H��$�   H�!  ��  	 ���     H��  H�D$hH��  H�D$p��  �D   �   �J  3���  H��  ��  �=    u
�   �"  ��  �	 �H����  H�Ĉ   ���H��$  ��  @SH�� H��H��$  �j  H�D$8H���uH����  �~�   ��  �H��$  �<  H�D$8H��$  �*  H�D$@H���$  H��L�D$@H�T$8�  H��H�L$8�  H�]$  H�L$@��  H�C$  �   �]  H��H�� [�H��(�G���H�������H��(��H�\$WH�� H��  H�=�  �H�H��t��H��H;�r�H�\$0H�� _�H�\$WH�� H��  H�=�  �H�H��t��H��H;�r�H�\$0H�� _���������H���MZ  f9t3��HcH<H�3��9PE  u�  f9Q�����LcA<E3�L��L�A�@E�XJ�L E��t�QL;�r
�A�L;�rA��H��(E;�r�3��H�������������H��(L��L�B���I���j�����t"M+�I��I������H��t�@$���Ѓ��3�H��(���%�  �%�  �%�  �%�  �%�  H��(��uH�=o   u��  �   H��(��H�\$WH�� H��  H�d$0 H�2��-�+  H;�tH��H��  �vH�L$0��  H�\$0��  D��I3���  D��I3���  H�L$8D��I3��{  L�\$8L3�H�������  L#�H�3��-�+  L;�LD�L�6  I��L�4  H�\$@H�� _���%�  �%�  �%�  �%�  �%�  �%,  �%n  ��������������@UH�� H��H��H�M(H���M$������H�� ]�������������@UH�� H����  ����H�� ]��@UH�� H��   �w����H�� ]�������������@UH�� H��H�3Ɂ8  �������H�� ]��                                                                                                                                                                                                                                                                                                                                              :9      $9      9      �8      �8      �8      �8      �8      r8      T8      88      $8      8      8      �7      �7      �8              �7      �7      �7      �7      �7      �7      Z7      L7      <7      47      &7      7      7      �6      r7              �6              �6      �6      �6      �6      �6                                      ` �                   Invalid dimension for input argument 5  Invalid dimension for input argument 4  Invalid dimension for input argument 3  Invalid dimension for input argument 2  Invalid dimension for input argument 1  Invalid number of input arguments             �?               �       �        @@ �   �@ �                                    t d T 4
 R���!   �  n  3  !	 	� �  n  3  P A� ;� 5� /� *� %�	  �
 x h d 4  p    8   .  � � � x 	h �        !      �  �3  !   �  �  �	  �
    �  �3  !q q� f� ]�	 T�
 A� 8� � � x    �  �3   d& T% 4$   ��p          20 � t
 T	 4 2��� t
 d	 4 R�#     G  -   $  -  A  3  P$       d 4 2p   2P 20#     '!  �!  j$      
 
4 
2p	 B  #     �"  �"  �$  �"   B  
 
4 
2pX6          �6   1  H6          �6  1  �5          �6  �0  85          T9   0                      :9      $9      9      �8      �8      �8      �8      �8      r8      T8      88      $8      8      8      �7      �7      �8              �7      �7      �7      �7      �7      �7      Z7      L7      <7      47      &7      7      7      �6      r7              �6              �6      �6      �6      �6      �6              OmxCreateDoubleMatrix_700  �mxGetData �mxGetN  �mxGetM  �mxGetNaN  libmx.dll 1 mexErrMsgTxt  libmex.dll  �sqrt  MSVCR100.dll  _malloc_crt �_initterm �_initterm_e cfree  �_encoded_null �_amsg_exit  __C_specific_handler  __CppXcptFilter F__crt_debugger_hook @__clean_type_info_names_internal  [_unlock H__dllonexit �_lock �_onexit � EncodePointer � DecodePointer �Sleep �TerminateProcess  �GetCurrentProcess �UnhandledExceptionFilter  �SetUnhandledExceptionFilter IsDebuggerPresent &RtlVirtualUnwind  RtlLookupFunctionEntry  RtlCaptureContext � DisableThreadLibraryCalls �QueryPerformanceCounter �GetTickCount  �GetCurrentThreadId  �GetCurrentProcessId �GetSystemTimeAsFileTime KERNEL32.dll                    C]KV    �9           �9  �9  �9     �9    ltrisect.mexw64 mexFunction                                                                   u�      2��-�+  �] �f���        ��������                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           �  �2  �  n  3  n  U  �2  U  �  �2  �  �  H3     �  �3  �  �  �3  �  \  |3  \  y  l3  �    �3    %  �4  @  _  �3  `  �  �3  �    �3    U  4  X  �  T4  �  �   d4  �   �!  t4  �!  �!  �4  �!  �!  �4  �!  ("  �4  �"  �"  �4  #  3#  �4  4#  �#  �4   $  E$  l4  P$  j$  l4  j$  �$  l4  �$  �$  l4                                                                                                                                                                                                     �                 0  �              	  H   X`  Z  �      <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="asInvoker" uiAccess="false"></requestedExecutionLevel>
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>PAPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPADDINGPADDINGXXPAD 0     h�����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  !W    @dyld_stub_binder Qq � q@_mxCreateDoubleMatrix_700 � q@_mxGetData � q @_mxGetM � q(@_mxGetN � q0@_mxGetNaN � q8@_mexErrMsgTxt � q@@_atan2 �    _mexFunction  �    ��@`p@P������   ��   4                                                �           �           0           �      "     �      *     0      4     �      >            F     `      N     �      X     `      b     0      j           w             ~             �             �             �             �             �             �                                        @                       _dot _cross _determinant _pdist _ppdist _plinproj _ptriproj _lmoutr _routlm _ltrisect _ptriside _solang _mexFunction _atan2 _mexErrMsgTxt _mxCreateDoubleMatrix_700 _mxGetData _mxGetM _mxGetN _mxGetNaN dyld_stub_binder                                                                                                                                             leMatrix_700 _mxGetData _mxGetM _mxGetN _mxGetNaN dyld_stub_binder                                                                                                                                                                                                                                                                                                                                                                                                                                                              �{���re��O�(�d�{9�0�xJ2��dF�ڛ��9T�Y�>�=#�2�&K��Ӫ�u�g�g�5�L��r����jN?�#e�fq�2��͜*r����Z�z�z��Tbr��o왷�w�	  ����-l�@��H$�D"1� �H$�D"���p�� �H�3H$�D"�ۯ�t{'��ms	��.M�|3;�?�{{{{{{{{�\V[���z��w<tdbɕ�������Z㲾���[���'OO���S$���'���o�񌷧�)�3ܟ^�LLŘl<-9�B��j�?O�g��H�xl<%YxzJ09x:�S��2<+%�e�L����=OE��]����?>߳b��l�b/tu7�,)-�)�9�xjr0�a���i�T���%���o7��L,�j^ڌF\��\<#�|<#��g��d`�i&�Ӏ��v��}OK��
L�����&���/0��l,��Ȍ���] g��g�R΂YL���v�xV
0�otM�<%XRZ)�4�?��Y�zx��&SE��6
�o4͘\<�X2��^��1��J5��l�L<5�Xj���Q�Fӂ��S��%W����Ex6j^�g�i��Ӑ�%�`?��|<�x
�Q*�����	OKsZdV%kg�i��Ӓ�'���{�����S��'S�g�D��S�gS���ӑ'g��'���ݜ�-.OE&�\L1��RL��<��jL�|�|L�;}��x:�d�,<�ٞ�0�x����`�����fFمk��e�j\�xf�	3��3&�H�����9�c�3ʹ��mF)�Y�M�D&C�^	���4ȜY�ע�
�������q�b�����b�h=�S.�E3x:������w|�{��9�x6�T2'Ϫ�B<���)��G�Q��J��ǳQ�������g����g�Vc
Ԍ��iT�>��!sZ�s����RL����[�z����"�={{{{{{{{�I�   ����!��Z�a$�D"�H3H$�DF"�H$�w�ݖ���L�D"���ߗ�v���!}�!�a�+�͹7$1������������)4���=�FG.���7���9�����i��T�vg[�B#~8���i��sS�)����fyٻ�x<=%�z��(��d�(�Ӓ��$ON����y�W���R�S��%O)s�1�x:�dN��ڶ����P�g��@��\<��L	��|Lٲo��a�wp)<+%x&u�7b�����Ť0�x
��2�B����`j�l��)�3���|<9xZ���O27L��L,%�7�j,z�h���<�<�&O�x���Q����R�F���\=&SχV*�,��'�Ӓ���\f�i��S����3���h^��'<��q?S��#�@'1%x:9O&OC&��Fӈ����9G���,1x�ǋ�bR�\<�,<э�	���$S,�\'f��}7a*��,�^|�xxZ�o����da)�G�m��)�3˜1��|fԒ��#g'���&O�����)Ƴ<����(�ӓ����Ӑ���b�e��+�O/��a��;O�o.�FL9��P�g��F%��R*g)�3P�g���cR佘�	�J��R=#,m�a��5b��L;�t-&�ʾ�6L&�����)�����bRd^�Λc�.L3sJ�̔����0Y���.9���i����;�e6��6q��3��o&,9��w���`ɜ\1�XN���J�o�����������������Ch}���g~>���O�1��94j���F��KN#�xr��xf��4d�i��K��5��h����V�2�D�ĆG������nS���R�L)��<<��*ƴh��\,J�OtS���R�B��|<YXZ)�ӑ��%OL͎�OO��V}��,�QdcIe�<=�x:��$�~6�  ����/l�h�q$�D"G"ǐ��D"�H$�D"��?��A"�H$y�w���k�5��%�'L�&���a���V�o��PG�w�(h���7��9��o8�=\��{��o�d7�R����c��z:b)����B'<�xbZ��c:����QC�
�KF��}�K����KK�
�KN��>���9��e�~0����,-+�_�gSŬ�7�3ubʔ�5e�1��J��+yT%���xj�1e�
��b�1�x"�5`r�d4�hR-���<��~��
m�F5/��KN��&C��]<��B<��JL��gR�Ү�bm���5�A�Q�gS����+~Z��WC�����km�f\	���f��ʼ*L���c��<�x��Ju�S��)�Yl��R�vX�y��	&KB��:L���{�R�y{Ʊu����goooooooooooo�����7�g�{�}�]���z�������S��6��B��/�c6��L,'�nd��Xb�Ô�H��,,g�o`:�)�Ē<_��d2+O�z��i���Lm㱰��$O����D���OK���\6��*��d4�	KA3y�Z��Dԑ�%�v���kT��%�I�Ղ��)�ӓ�%�nmW}רQ��4��T��u�J��bɨ�eE���@1�?�8����c9�a�����)������b���uMG,	��a*5W%��S��F���Rд�� �3�OE���b��bJ�L����y#���;��Z�S#�X�Q�gV�,Նդ�o,�bJ0���3eQ�<��&=KH��R<��s.��'`NY/��g�vL�r�	o8���)�^l9��<<�6�	�  ����!l�@�a$�DVVVbH*�H$��D"��H$I��u�D"++��Y���V�5ٞ�C!i���q��>��y��Ji8=��s`M����4M�4M�4M�4��������,�%�&�c*�e��h �X�՜'�r�<~�x�br�dN�Đi�%�<?�����k�b���x�f��j1yx
�ŒQC�.ǎR���S#���n��8P��>eԐ#�V�[,GY���:���r/??�Ĵ����h��w_\-WKB��|L�ik���#KJ���Xj�h����&�OO,�b
�4��a��м
<m��&�O+{j��hp����~��)^��Oe�tS�gS��Wd��=����R̞�|�7~h��i�?�  ����	  ��[�{���ɪ��������~   ����	  ��[�{���ɪ��������~   ����	  ��[�{���ɪ��������~   ����	  ��[�{���ɪ��������~   ����	  ��[�{���ɪ��������~   ����   ˙�br�HVUUUU����u   E  x���A
� �qQFD�6n:�xlD�x���=��������="���s�%���n�JϽ���߾��k�}��O�5       p�?   ����-�@����G�l��9G�+�Hd%�Y�D"++�H&HB����>jg�Q9[        ���JR���s�զl�N�I�--ئ����wmo�/v��v��Ο���w��ݬ�f����ݝ�)�΍rilK���7�����Z8��� �	  ����}h�Q����g��l�a����a�a�a���f��ړm�$I��%I�$I�$I�$I�$I���d?���߹���ǫ�;�����ݯu;R�i���)�`� 4Һ'�\8"���Xrq�G��O��� iHG�Lr��8X�"�v����(F)ʬ��+�Vf5�c�r'X�T��Ο"gp缼��ԫpqI}���2=WpU�]_#w7|��i��i����M�.�|���m��(���x�Ý�!�Gx�'
w����9^�B�+r��o�N��=���O��/^�_���D�.�٬��'� ��z��k�fh�
=-ɵ����<�A[���+��@t��Ӊ��
s���Z��n����ɜ���B��k�GaN_�s���&s���A��`���s��!d�bB��pr#0�j3~���g4�(�	#7�|�����	��g�4�3��#0�~�c��(Dc��L��L�t?Ι�����Y���i���_d6��q����/s��C��]g>�X�,R��,&��X�e
=��%aVb�BO2��X��H��#�Ȭ��b#6a��>I��[���n1g����.��dz����>d�n;$��l/=��6�u��w�%�_���,y�����!ϳ�s�`�>;{��q�/`�������s�=H�����zQ��b��-�C	�û+e9l2�=)�^fȗ�.W�� 9�'�Ҵ�;   ���w�U�v�^Ap)� E�+u`�"~��c��]P���b�(v�FQP�����ɜ�f�f2��r�������7�f&�hkǚvC�tc�ttsw%��Q�[���Z���ӭ�A����uڌ���F��6�A�cAw`AwbAwaAwcA��gV�ש���,��X�XЃX�CX���ϯ�Ы-�ْ��V֠G��G��m�m��T���\�z���'��'�>�fo��S�=�m�n�_=��	��zG�jT����A�aA��N�6�7�gE>�ϋ���<�;{k酾�[Я� �������ښ�ѧטzzzz+x���-����;���iڻ��ѻ��+�g�j7}����}jA`A�u���Ǎ{�}B=�������z����3j@{�{���X�+x�Sڏ�_�G����b�/�}F\_��__��1r�&Ӄ��h�<������̵��p�~��?<��⃾˹6r:J�Ѡ�����Ƀ~�?��1�� ���������������}FL�fj�u�9'�s�Q��:�=��N;�ޗ��ƞn|�/�@cA�Q:t6>8�|(�XZ�X�K8�<|0p���`��i�KB���.��K�<�kZ`����z/��'�-�s|Fkps����AC�R�7��Z]'C�ӱ�ޱ�ΰ�oXf�6����t�#�>�<C#�����t�ElTkZN�F3ctpn�=�5�<ؘ�4J:���9�kO}�%>�u��s���`�q�`��g~�6g���x���g�6t<��KZ�O�5��M`_zϵH��Y���Dt&�sV'^W�z]ڻ'!f��r>���X{g1-M�z�&���5���`&kM	�E�mJ1�NS�95���A�3Yx�4����k9y]��݁o�+����!�����h�3����teF��A339|�Y_��iV��f�{<�kv��f����4'�lX;���G������67G���Q7��g��s�|f̯?��9hA��.h�w=�:�7!o�k"gE�"q'���|a�{nQp�.�]k�<�b4��7>uQߕ���\71]�g3�G�Q�%��$�b�k)�������]�yn�=�rꖷp��������{&��ԁ��,������;����i}������j态�������%�z#��z"�H�N��d���6�÷��딴��:�}]���_�Ƀ���o.g��c8h>����6�=t��߷�   ����vE��%�ߏR�J�@8(i����p9���p�Br�#ԣ���f%�g���l�7�}�������3���~1'�������J�-s�`[6�p���8��Z��|9]-m�1�F�m-��XG/_�{��u䜸|]VK�xC/������d�eu��he�9�7�6�r=���v�kyo��.�`�j�=}Y �0��|ٍlw�����v���ܺw/^���uӗ}��5�#���f\�8ȷ�u���g4����z���g���n��[/��x$0O��Z-��� ���):�i廼O�[�qZ���Cg5���� { ?X~nr�Vi�P����aj�.��h�>�#e>G'G�-�ch�r��5p��}���A�����A��Ac� ?�Si��|��/U���iF+'��D�s��w�:�;�|'�4��Ln��c��ßr��NUgQ�N+�����b�r�ؙ鞋�O�2�٪����=�����j���gj����g~���1����2yh#f-�R�\�~�И���\�=���)�9->�D]0�K�����.�e��#W��JK�*����a��6�#�
"8$�k5}�VV'�3�5��O ��d
����~�5_kD^!t謊GZ�r���
�F�����=����M�z�[�Č&{��K ��u+�]B.�A��z��M��f�� ��Ti������)0��D�	�.k�����G;vm��{� ���h"x�~�Z�O��u*����ƹ�M �����M�tF<�&�<����g:�^�Ih�5@!<*|�V�H���FS�q�Y�ډ5�F���#+�te<ĕakt���Uj�BXm�=gW����I O��I��N� V1�M O�=����X叴	���؈V!<���c�^͕h�9�}>�.�1����a�{$���3gj�+/�?_�|�Ċ���Z�����1�mX�z���3b��K��%{}Y�[tb����s�BXk�m`���8����~�X!�Aohcy�:^��	`�H�!��n���Bx��c�#xF�����q� ֡Y_+9��)��!o87�7��rRF;1�[�� �6�r	$����h"8$�?3�%�Čv�:E�@ޱ>�w�s�rF�3ډ����(��=�\-{�c��i}���۾'߅�|�`C����/���/8���Q����   ���Kv�FE��̹�}�R�L[�Gv�K�X��$NbǑdi�����LQ�bw�5IzpXx �&)R���o��}wge�����oj9��к���'5�:A�ޑ���~J�4��9���D�I�{� �w�_i�V�E�C��$�s@�>�
���6�qu���Q�g������͸vm�+j�$�}���ތ;����=b�p�8=r�[\_���f�K�3��z�9�)y6�>\oV�o���`� �&�S�J,�V�ex}��	r���B9��1�~�ڜ�� �'�\�J,`�#_�-O؏'˳�zʌ��������]�t|��3z�O������V��g|A>;=�3@��{
��w<�ߖ�yά��A+`���+/�
�E�ܣyG�K�K��d����t�u)�l����'�.?��{�@�����!V�M|�S�;����7��Ƶ�/g��k�U[S�eFk����$�ύor���(��sȆ.�����(�Z�Āy�97
��ͮQ�. G�r��s�e�l��-�w��'��Q�l�>+��ƶ�;v�Op/&H�g@\�7�u���W��h;��I_y�3������2����Ā9��Q}������*�ި	r	r���ڿF#����%ȯ3��JC7r1S;&��o33�+��r�w���Y�$��>�д�_�gt��-;���}��.A��~y͡ǂ'���1�iG��t[�8zt<�&.|[�낧�[��h��#�寅}A�OA����b�G.������$������Y#��泡7g}���ИC�y'� �6g��P&~c��>IN>�W�*���9����'����~%W��g�Śs��p@O��h�'��e�u��7���2��K}a�Fkg; O7�q5�Y�g���V���g�{��O���i�Ͱc����~�s��P��4�!ο�y���f\��b��<����  ���K�G�0�-��:B-���PG��:B�G�#hc�	l^���y��q1��tI-1��Z|��?3�$EI��:��i_���c�+6a3(x�G�������sѧ�'W��x���˵}鮍ە�e���s��,��H����h��3��밦#��S{Vh���C4tr�3�X�'��dj
��y�ɮ��9�Z^Q?>u[�9�Wh���*��[úD>7j'�B��h�z���x�ɧF�����`+4�{�ԃ���x�Q;�<�t�֨��Y1b��H��^��@���m�o������3p�^]�0ҝ�w\nh���Ch�.��nv��:_՛��7ω��l�	2h�k�^�Q|��Y�mw�D_��߫8��>;�o�z�?��9��jf�˟_���5dN*�2V�oX?�5Q͔����;��t�x'$feP0�2;��{҃��ez��	�<d6���^�*����zy�<H�U�K�?@��ٞ�>���z�8��	������.�b��s� 9`���y����w� yʼ�_z~�� ���|9�	�
^������Y�X����	4�Y���f+x����������7p����� �������A,/����L^�S�4��yy�H�{�k�6�o@���5�^7��5�τV�F�!@ޜ�w�	��{�5�N>@�>[�ȥ���3Uz-�a�����YƦ���۹�(֪~Ǐ*�we6����!ӧ`U��G�{>���w^�_���%�|`χ��^M�ɠ`�en`�������̄��`��;v�(��}�;͙ ���!A����~��r:�@��Sl.��0�-����rˁ�\�.l��C?��^o&��rJ<;�o���. `Y��E�:�\��O�S�0�8n�����{=N���e�&�x�`ri���f
y@;#�0�׉#��c��n�v�|�F}�\�|^3g6r��t�ۑo�Y��βD+��k��.�M�LK.cgU]/��3Gk���Q�Q�%V�����R�t�?�O�y�-�����U<Ƿ��{��Dտė��������q�:џ�S�\�Va��;>cGs�aQ�.���  ����q� EYN{ڶ�]�'���{B �@�@!!�u��g����F�bq���^}(�ԏw��w[<���N��i��ڈ�E����	/��	�Q�y�ę��<��$��O�2}Q��d(�<+s��==m���`D�E;���z@�W�K+��ZY�׽9����om��W���w�~sg�嚻s}ڐ�Yn��s��W��LyY_��Ug��Y�����[z,��ڋy@�yiGN��@�,�Z���6`��g|���Ixxt�8kH�䥷��V/���Ɨ�9��D�=�_j�1>���d(PA�6��v:�N��������Ǣ]��h��C�8�B���W�S�)h��km��3�������$	���Y�T�ԯ����?�d��r,�&�DNl�)�:�yA�Y��7�|�5z\�т�<�33	���F3���F0o�����t:�N�ӄ�   ����A�0��J ��;V��#a%T*���$T�����?|�;���5��/��E=��Uc��п�2��C�۳נ�є�}�?�;�����z��kQn���]=���)�AƸ�a�)n�&9v�b��         ��	  ����	  0K<�}�h���˪��������  ��c� �:�G�(ţx�⡅W���                                                                                                                                                                                                                         eton dimensions missing in a
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
                                                                                                                                                                                                          2' % right ear lobe
  };

% allow for upper case electrode position labels
NAS = nas;
INI = ini;
LPA = lpa;
RPA = rpa;

% it would be possible to assign locations to these old locations
% but there are no locations determined for M1/2 and A1/2
if false
  T3 = T7;
  T4 = T8;
  T5 = P7;
  T6 = P8;
end

% assign the known local electrode positions to the output matrix
nlab = numel(lab);
elc = ones(nlab,3) * nan;
for i=1:nlab
  if exist(lab{i}, 'var')
    eval(sprintf('elc(%d,:) = %s;', i, lab{i}));
  else
    fprintf('not placing electrode %s\n', lab{i});
  end
end

% remove unknown electrode positions
sel = ~isnan(elc(:,1));
elc = elc(sel, :);
lab = lab(sel);

if feedback
  elec = [];
  elec.elecpos = elc;
  elec.label = lab;
  ft_plot_sens(elec)
end
                                                                                                                                                                                                                                                                         ble(' '),1,paddingN));
      patient_id = [patient_id, padding];
    end
    if length(exp_date) < 10,
      paddingN = 10-length(exp_date);
      padding = char(repmat(double(' '),1,paddingN));
      exp_date = [exp_date, padding];
    end
    if length(exp_time) < 10,
      paddingN = 10-length(exp_time);
      padding = char(repmat(double(' '),1,paddingN));
      exp_time = [exp_time, padding];
    end
    if length(hist_un0) < 10,
      paddingN = 10-length(hist_un0);
      padding = char(repmat(double(' '),1,paddingN));
      hist_un0 = [hist_un0, padding];
    end

    % -- if you thought that was anal, try this;
    % -- lets check for unusual ASCII char values!

    if find(double(descrip)>128),
      indexStrangeChar = find(double(descrip)>128);
      descrip(indexStrangeChar) = ' ';
    end
    if find(double(aux_file)>128),
      indexStrangeChar = find(double(aux_file)>128);
      aux_file(indexStrangeChar) = ' ';
    end
    if find(double(originator)>128),
      indexStrangeChar = find(double(originator)>128);
      originator(indexStrangeChar) = ' ';
    end
    if find(double(generated)>128),
      indexStrangeChar = find(double(generated)>128);
      generated(indexStrangeChar) = ' ';
    end
    if find(double(scannum)>128),
      indexStrangeChar = find(double(scannum)>128);
      scannum(indexStrangeChar) = ' ';
    end
    if find(double(patient_id)>128),
      indexStrangeChar = find(double(patient_id)>128);
      patient_id(indexStrangeChar) = ' ';
    end
    if find(double(exp_date)>128),
      indexStrangeChar = find(double(exp_date)>128);
      exp_date(indexStrangeChar) = ' ';
    end
    if find(double(exp_time)>128),
      indexStrangeChar = find(double(exp_time)>128);
      exp_time(indexStrangeChar) = ' ';
    end
    if find(double(hist_un0)>128),
      indexStrangeChar = find(double(hist_un0)>128);
      hist_un0(indexStrangeChar) = ' ';
    end


    % --- finally, we write the fields

    fwrite(fid, descrip(1:80),    'uchar');
    fwrite(fid, aux_file(1:24),   'uchar');


    %orient      = sprintf(  '%1s', hist.orient);        %  1 char
    %fwrite(fid, orient(1),        'uchar');
    fwrite(fid, hist.orient(1),   'uint8');     % see note below on char

    fwrite(fid, originator(1:10), 'uchar');
    fwrite(fid, generated(1:10),  'uchar');
    fwrite(fid, scannum(1:10),    'uchar');
    fwrite(fid, patient_id(1:10), 'uchar');
    fwrite(fid, exp_date(1:10),   'uchar');
    fwrite(fid, exp_time(1:10),   'uchar');
    fwrite(fid, hist_un0(1:3),    'uchar');

    fwrite(fid, hist.views(1),      'int32');
    fwrite(fid, hist.vols_added(1), 'int32');
    fwrite(fid, hist.start_field(1),'int32');
    fwrite(fid, hist.field_skip(1), 'int32');
    fwrite(fid, hist.omax(1),       'int32');
    fwrite(fid, hist.omin(1),       'int32');
    fwrite(fid, hist.smax(1),       'int32');
    fwrite(fid, hist.smin(1),       'int32');

return



% Note on using char:
% The 'char orient' field in the header is intended to
% hold simply an 8-bit unsigned integer value, not the ASCII representation
% of the character for that value.  A single 'char' byte is often used to
% represent an integer value in Analyze if the known value range doesn't
% go beyond 0-255 - saves a byte over a short int, which may not mean
% much in today's computing environments, but given that this format
% has been around since the early 1980's, saving bytes here and there on
% older systems was important!  In this case, 'char' simply provides the
% byte of storage - not an indicator of the format for what is stored in
% this byte.  Generally speaking, anytime a single 'char' is used, it is
% probably meant to hold an 8-bit integer value, whereas if this has
% been dimensioned as an array, then it is intended to hold an ASCII
% character string, even if that was only a single character.
% Denny  <hanson.dennis2@mayo.edu>

% See other notes in avw_hdr_read
                                                                                                                                                                                 
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
     