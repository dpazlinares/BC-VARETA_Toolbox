function [ avw, machine ] = avw_img_read(fileprefix,IMGorient,machine,verbose)

% avw_img_read - read Analyze format data image (*.img)
%
% [ avw, machine ] = avw_img_read(fileprefix,[orient],[machine],[verbose])
%
% fileprefix - a string, the filename without the .img extension
%
% orient - read a specified orientation, integer values:
%
%          '', use header history orient field
%          0,  transverse unflipped (LAS*)
%          1,  coronal unflipped (LA*S)
%          2,  sagittal unflipped (L*AS)
%          3,  transverse flipped (LPS*)
%          4,  coronal flipped (LA*I)
%          5,  sagittal flipped (L*AI)
%
% where * follows the slice dimension and letters indicate +XYZ
% orientations (L left, R right, A anterior, P posterior,
% I inferior, & S superior).
%
% Some files may contain data in the 3-5 orientations, but this
% is unlikely. For more information about orientation, see the
% documentation at the end of this .m file.  See also the
% AVW_FLIP function for orthogonal reorientation.
%
% machine - a string, see machineformat in fread for details.
%           The default here is 'ieee-le' but the routine
%           will automatically switch between little and big
%           endian to read any such Analyze header.  It
%           reports the appropriate machine format and can
%           return the machine value.
%
% verbose - the default is to output processing information to the command
%           window.  If verbose = 0, this will not happen.
%
% Returned values:
%
% avw.hdr - a struct with image data parameters.
% avw.img - a 3D matrix of image data (double precision).
%
% A returned 3D matrix will correspond with the
% default ANALYZE coordinate system, which
% is Left-handed:
%
% X-Y plane is Transverse
% X-Z plane is Coronal
% Y-Z plane is Sagittal
%
% X axis runs from patient right (low X) to patient Left (high X)
% Y axis runs from posterior (low Y) to Anterior (high Y)
% Z axis runs from inferior (low Z) to Superior (high Z)
%
% The function can read a 4D Analyze volume, but only if it is in the
% axial unflipped orientation.
%
% See also: avw_hdr_read (called by this function),
%           avw_view, avw_write, avw_img_write, avw_flip
%


% $Revision$ $Date: 2009/01/14 09:24:45 $

% Licence:  GNU GPL, no express or implied warranties
% History:  05/2002, Darren.Weber@flinders.edu.au
%                    The Analyze format is copyright
%                    (c) Copyright, 1986-1995
%                    Biomedical Imaging Resource, Mayo Foundation
%           01/2003, Darren.Weber@flinders.edu.au
%                    - adapted for matlab v5
%                    - revised all orientation information and handling
%                      after seeking further advice from AnalyzeDirect.com
%           03/2003, Darren.Weber@flinders.edu.au
%                    - adapted for -ve pixdim values (non standard Analyze)
%           07/2004, chodkowski@kennedykrieger.org, added ability to
%                    read volumes with dimensionality greather than 3.
%  a >3D volume cannot be flipped.  and error is thrown if a volume of
%  greater than 3D (ie, avw.hdr.dime.dim(1) > 3) requests a data flip
%  (ie, avw.hdr.hist.orient ~= 0 ).  i pulled the transfer of read-in
%  data (tmp) to avw.img out of any looping mechanism.  looping is not
%  necessary as the data is already in its correct orientation.  using
%  'reshape' rather than looping should be faster but, more importantly,
%  it allows the reading in of N-D volumes. See lines 270-280.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist('IMGorient','var'), IMGorient = ''; end
if ~exist('machine','var'), machine = 'ieee-le'; end
if ~exist('verbose','var'), verbose = 1; end

if isempty(IMGorient), IMGorient = ''; end
if isempty(machine), machine = 'ieee-le'; end
if isempty(verbose), verbose = 1; end

if ~exist('fileprefix','var'),
  msg = sprintf('...no input fileprefix - see help avw_img_read\n\n');
  ft_error(msg);
end
if contains(fileprefix, '.hdr')
  fileprefix = strrep(fileprefix,'.hdr','');
end
if contains(fileprefix, '.img')
  fileprefix = strrep(fileprefix,'.img','');
end

% MAIN

% Read the file header
[ avw, machine ] = avw_hdr_read(fileprefix,machine,verbose);

avw = read_image(avw,IMGorient,machine,verbose);

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ avw ] = read_image(avw,IMGorient,machine,verbose)

fid = fopen_or_error(sprintf('%s.img',avw.fileprefix),'r',machine);

if verbose,
    ver = '[$Revision$]';
    fprintf('\nAVW_IMG_READ [v%s]\n',ver(12:16));  tic;
end

% short int bitpix;    /* Number of bits per pixel; 1, 8, 16, 32, or 64. */
% short int datatype      /* Datatype for this image set */
% /*Acceptable values for datatype are*/
% #define DT_NONE             0
% #define DT_UNKNOWN          0    /*Unknown data type*/
% #define DT_BINARY           1    /*Binary             ( 1 bit per voxel)*/
% #define DT_UNSIGNED_CHAR    2    /*Unsigned character ( 8 bits per voxel)*/
% #define DT_SIGNED_SHORT     4    /*Signed short       (16 bits per voxel)*/
% #define DT_SIGNED_INT       8    /*Signed integer     (32 bits per voxel)*/
% #define DT_FLOAT           16    /*Floating point     (32 bits per voxel)*/
% #define DT_COMPLEX         32    /*Complex (64 bits per voxel; 2 floating point numbers)/*
% #define DT_DOUBLE          64    /*Double precision   (64 bits per voxel)*/
% #define DT_RGB            128    /*A Red-Green-Blue datatype*/
% #define DT_ALL            255    /*Undocumented*/

switch double(avw.hdr.dime.bitpix),
  case  1,   precision = 'bit1';
  case  8,   precision = 'uchar';
  case 16,   precision = 'int16';
  case 32,
    if     isequal(avw.hdr.dime.datatype, 8), precision = 'int32';
    else                                      precision = 'single';
    end
  case 64,   precision = 'double';
  otherwise,
    precision = 'uchar';
    if verbose, fprintf('...precision undefined in header, using ''uchar''\n'); end
end

% read the whole .img file into matlab (faster)
if verbose,
    fprintf('...reading %s Analyze %s image format.\n',machine,precision);
end
fseek(fid,0,'bof');
% adjust for matlab version
ver = version;
ver = str2num(ver(1));
if ver < 6,
  tmp = fread(fid,inf,sprintf('%s',precision));
else,
  tmp = fread(fid,inf,sprintf('%s=>double',precision));
end
fclose(fid);

% Update the global min and max values
avw.hdr.dime.glmax = max(double(tmp));
avw.hdr.dime.glmin = min(double(tmp));


%---------------------------------------------------------------
% Now partition the img data into xyz

% --- first figure out the size of the image

% short int dim[ ];      /* Array of the image dimensions */
%
% dim[0]      Number of dimensions in database; usually 4.
% dim[1]      Image X dimension;  number of pixels in an image row.
% dim[2]      Image Y dimension;  number of pixel rows in slice.
% dim[3]      Volume Z dimension; number of slices in a volume.
% dim[4]      Time points; number of volumes in database.

PixelDim = double(avw.hdr.dime.dim(2));
RowDim   = double(avw.hdr.dime.dim(3));
SliceDim = double(avw.hdr.dime.dim(4));
TimeDim  = double(avw.hdr.dime.dim(5));

PixelSz  = double(avw.hdr.dime.pixdim(2));
RowSz    = double(avw.hdr.dime.pixdim(3));
SliceSz  = double(avw.hdr.dime.pixdim(4));
TimeSz   = double(avw.hdr.dime.pixdim(5));




% ---- NON STANDARD ANALYZE...

% Some Analyze files have been found to set -ve pixdim values, eg
% the MNI template avg152T1_brain in the FSL etc/standard folder,
% perhaps to indicate flipped orientation?  If so, this code below
% will NOT handle the flip correctly!
if PixelSz < 0,
  ft_warning('X pixdim < 0 !!! resetting to abs(avw.hdr.dime.pixdim(2))');
  PixelSz = abs(PixelSz);
  avw.hdr.dime.pixdim(2) = single(PixelSz);
end
if RowSz < 0,
  ft_warning('Y pixdim < 0 !!! resetting to abs(avw.hdr.dime.pixdim(3))');
  RowSz = abs(RowSz);
  avw.hdr.dime.pixdim(3) = single(RowSz);
end
if SliceSz < 0,
  ft_warning('Z pixdim < 0 !!! resetting to abs(avw.hdr.dime.pixdim(4))');
  SliceSz = abs(SliceSz);
  avw.hdr.dime.pixdim(4) = single(SliceSz);
end

% ---- END OF NON STANDARD ANALYZE





% --- check the orientation specification and arrange img accordingly
if ~isempty(IMGorient),
  if ischar(IMGorient),
    avw.hdr.hist.orient = uint8(str2num(IMGorient));
  else
    avw.hdr.hist.orient = uint8(IMGorient);
  end
end,

if isempty(avw.hdr.hist.orient),
  msg = [ '...unspecified avw.hdr.hist.orient, using default 0\n',...
      '   (check image and try explicit IMGorient option).\n'];
  fprintf(msg);
  avw.hdr.hist.orient = uint8(0);
end

% --- check if the orientation is to be flipped for a volume with more
% --- than 3 dimensions.  this logic is currently unsupported so throw
% --- an error.  volumes of any dimensionality may be read in *only* as
% --- unflipped, ie, avw.hdr.hist.orient == 0
if ( TimeDim > 1 ) && (avw.hdr.hist.orient ~= 0 ),
   msg = [ 'ERROR: This volume has more than 3 dimensions *and* ', ...
           'requires flipping the data.  Flipping is not supported ', ...
           'for volumes with dimensionality greater than 3.  Set ', ...
           'avw.hdr.hist.orient = 0 and flip your volume after ', ...
           'calling this function' ];
   msg = ft_error( '%s (%s).', msg, mfilename );
   ft_error( msg );
end

switch double(avw.hdr.hist.orient),

  case 0, % transverse unflipped

    % orient = 0:  The primary orientation of the data on disk is in the
    % transverse plane relative to the object scanned.  Most commonly, the fastest
    % moving index through the voxels that are part of this transverse image would
    % span the right-left extent of the structure imaged, with the next fastest
    % moving index spanning the posterior-anterior extent of the structure.  This
    % 'orient' flag would indicate to Analyze that this data should be placed in
    % the X-Y plane of the 3D Analyze Coordinate System, with the Z dimension
    % being the slice direction.

    % For the 'transverse unflipped' type, the voxels are stored with
    % Pixels in 'x' axis (varies fastest) - from patient right to left
    % Rows in   'y' axis                  - from patient posterior to anterior
    % Slices in 'z' axis                  - from patient inferior to superior

    if verbose, fprintf('...reading axial unflipped orientation\n'); end

    % -- This code will handle nD files
    dims = double( avw.hdr.dime.dim(2:end) );
    % replace dimensions of 0 with 1 to be used in reshape
    idx = find( dims == 0 );
    dims( idx ) = 1;
    avw.img = reshape( tmp, dims );

    % -- The code above replaces this
    %         avw.img = zeros(PixelDim,RowDim,SliceDim);
    %
    %         n = 1;
    %         x = 1:PixelDim;
    %         for z = 1:SliceDim,
    %             for y = 1:RowDim,
    %                 % load Y row of X values into Z slice avw.img
    %                 avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
    %                 n = n + PixelDim;
    %             end
    %         end


    % no need to rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim


case 1, % coronal unflipped

    % orient = 1:  The primary orientation of the data on disk is in the coronal
    % plane relative to the object scanned.  Most commonly, the fastest moving
    % index through the voxels that are part of this coronal image would span the
    % right-left extent of the structure imaged, with the next fastest moving
    % index spanning the inferior-superior extent of the structure.  This 'orient'
    % flag would indicate to Analyze that this data should be placed in the X-Z
    % plane of the 3D Analyze Coordinate System, with the Y dimension being the
    % slice direction.

    % For the 'coronal unflipped' type, the voxels are stored with
    % Pixels in 'x' axis (varies fastest) - from patient right to left
    % Rows in   'z' axis                  - from patient inferior to superior
    % Slices in 'y' axis                  - from patient posterior to anterior

    if verbose, fprintf('...reading coronal unflipped orientation\n'); end

    avw.img = zeros(PixelDim,SliceDim,RowDim);

    n = 1;
    x = 1:PixelDim;
    for y = 1:SliceDim,
      for z = 1:RowDim,
        % load Z row of X values into Y slice avw.img
        avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
        n = n + PixelDim;
      end
    end

    % rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim
    avw.hdr.dime.dim(2:4) = int16([PixelDim,SliceDim,RowDim]);
    avw.hdr.dime.pixdim(2:4) = single([PixelSz,SliceSz,RowSz]);


  case 2, % sagittal unflipped

    % orient = 2:  The primary orientation of the data on disk is in the sagittal
    % plane relative to the object scanned.  Most commonly, the fastest moving
    % index through the voxels that are part of this sagittal image would span the
    % posterior-anterior extent of the structure imaged, with the next fastest
    % moving index spanning the inferior-superior extent of the structure.  This
    % 'orient' flag would indicate to Analyze that this data should be placed in
    % the Y-Z plane of the 3D Analyze Coordinate System, with the X dimension
    % being the slice direction.

    % For the 'sagittal unflipped' type, the voxels are stored with
    % Pixels in 'y' axis (varies fastest) - from patient posterior to anterior
    % Rows in   'z' axis                  - from patient inferior to superior
    % Slices in 'x' axis                  - from patient right to left

    if verbose, fprintf('...reading sagittal unflipped orientation\n'); end

    avw.img = zeros(SliceDim,PixelDim,RowDim);

    n = 1;
    y = 1:PixelDim;         % posterior to anterior (fastest)

    for x = 1:SliceDim,     % right to left (slowest)
      for z = 1:RowDim,   % inferior to superior

        % load Z row of Y values into X slice avw.img
        avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
        n = n + PixelDim;
      end
    end

    % rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim
    avw.hdr.dime.dim(2:4) = int16([SliceDim,PixelDim,RowDim]);
    avw.hdr.dime.pixdim(2:4) = single([SliceSz,PixelSz,RowSz]);


    %--------------------------------------------------------------------------------
    % Orient values 3-5 have the second index reversed in order, essentially
    % 'flipping' the images relative to what would most likely become the vertical
    % axis of the displayed image.
    %--------------------------------------------------------------------------------

  case 3, % transverse/axial flipped

    % orient = 3:  The primary orientation of the data on disk is in the
    % transverse plane relative to the object scanned.  Most commonly, the fastest
    % moving index through the voxels that are part of this transverse image would
    % span the right-left extent of the structure imaged, with the next fastest
    % moving index spanning the *anterior-posterior* extent of the structure.  This
    % 'orient' flag would indicate to Analyze that this data should be placed in
    % the X-Y plane of the 3D Analyze Coordinate System, with the Z dimension
    % being the slice direction.

    % For the 'transverse flipped' type, the voxels are stored with
    % Pixels in 'x' axis (varies fastest) - from patient right to Left
    % Rows in   'y' axis                  - from patient anterior to Posterior *
    % Slices in 'z' axis                  - from patient inferior to Superior

    if verbose, fprintf('...reading axial flipped (+Y from Anterior to Posterior)\n'); end

    avw.img = zeros(PixelDim,RowDim,SliceDim);

    n = 1;
    x = 1:PixelDim;
    for z = 1:SliceDim,
      for y = RowDim:-1:1, % flip in Y, read A2P file into P2A 3D matrix

        % load a flipped Y row of X values into Z slice avw.img
        avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
        n = n + PixelDim;
      end
    end

    % no need to rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim


  case 4, % coronal flipped

    % orient = 4:  The primary orientation of the data on disk is in the coronal
    % plane relative to the object scanned.  Most commonly, the fastest moving
    % index through the voxels that are part of this coronal image would span the
    % right-left extent of the structure imaged, with the next fastest moving
    % index spanning the *superior-inferior* extent of the structure.  This 'orient'
    % flag would indicate to Analyze that this data should be placed in the X-Z
    % plane of the 3D Analyze Coordinate System, with the Y dimension being the
    % slice direction.

    % For the 'coronal flipped' type, the voxels are stored with
    % Pixels in 'x' axis (varies fastest) - from patient right to Left
    % Rows in   'z' axis                  - from patient superior to Inferior*
    % Slices in 'y' axis                  - from patient posterior to Anterior

    if verbose, fprintf('...reading coronal flipped (+Z from Superior to Inferior)\n'); end

    avw.img = zeros(PixelDim,SliceDim,RowDim);

    n = 1;
    x = 1:PixelDim;
    for y = 1:SliceDim,
      for z = RowDim:-1:1, % flip in Z, read S2I file into I2S 3D matrix

        % load a flipped Z row of X values into Y slice avw.img
        avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
        n = n + PixelDim;
      end
    end

    % rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim
    avw.hdr.dime.dim(2:4) = int16([PixelDim,SliceDim,RowDim]);
    avw.hdr.dime.pixdim(2:4) = single([PixelSz,SliceSz,RowSz]);


  case 5, % sagittal flipped

    % orient = 5:  The primary orientation of the data on disk is in the sagittal
    % plane relative to the object scanned.  Most commonly, the fastest moving
    % index through the voxels that are part of this sagittal image would span the
    % posterior-anterior extent of the structure imaged, with the next fastest
    % moving index spanning the *superior-inferior* extent of the structure.  This
    % 'orient' flag would indicate to Analyze that this data should be placed in
    % the Y-Z plane of the 3D Analyze Coordinate System, with the X dimension
    % being the slice direction.

    % For the 'sagittal flipped' type, the voxels are stored with
    % Pixels in 'y' axis (varies fastest) - from patient posterior to Anterior
    % Rows in   'z' axis                  - from patient superior to Inferior*
    % Slices in 'x' axis                  - from patient right to Left

    if verbose, fprintf('...reading sagittal flipped (+Z from Superior to Inferior)\n'); end

    avw.img = zeros(SliceDim,PixelDim,RowDim);

    n = 1;
    y = 1:PixelDim;

    for x = 1:SliceDim,
      for z = RowDim:-1:1, % flip in Z, read S2I file into I2S 3D matrix

        % load a flipped Z row of Y values into X slice avw.img
        avw.img(x,y,z) = tmp(n:n+(PixelDim-1));
        n = n + PixelDim;
      end
    end

    % rearrange avw.hdr.dime.dim or avw.hdr.dime.pixdim
    avw.hdr.dime.dim(2:4) = int16([SliceDim,PixelDim,RowDim]);
    avw.hdr.dime.pixdim(2:4) = single([SliceSz,PixelSz,RowSz]);

  otherwise

    ft_error('unknown value in avw.hdr.hist.orient, try explicit IMGorient option.');

end

if verbose, t=toc; fprintf('...done (%5.2f sec).\n\n',t); end

return




% This function attempts to read the orientation of the
% Analyze file according to the hdr.hist.orient field of the
% header.  Unfortunately, this field is optional and not
% all programs will set it correctly, so there is no guarantee,
% that the data loaded will be correctly oriented.  If necessary,
% experiment with the 'orient' option to read the .img
% data into the 3D matrix of avw.img as preferred.
%

% (Conventions gathered from e-mail with support@AnalyzeDirect.com)
%
% 0  transverse unflipped
%       X direction first,  progressing from patient right to left,
%       Y direction second, progressing from patient posterior to anterior,
%       Z direction third,  progressing from patient inferior to superior.
% 1  coronal unflipped
%       X direction first,  progressing from patient right to left,
%       Z direction second, progressing from patient inferior to superior,
%       Y direction third,  progressing from patient posterior to anterior.
% 2  sagittal unflipped
%       Y direction first,  progressing from patient posterior to anterior,
%       Z direction second, progressing from patient inferior to superior,
%       X direction third,  progressing from patient right to left.
% 3  transverse flipped
%       X direction first,  progressing from patient right to left,
%       Y direction second, progressing from patient anterior to posterior,
%       Z direction third,  progressing from patient inferior to superior.
% 4  coronal flipped
%       X direction first,  progressing from patient right to left,
%       Z direction second, progressing from patient superior to inferior,
%       Y direction third,  progressing from patient posterior to anterior.
% 5  sagittal flipped
%       Y direction first,  progressing from patient posterior to anterior,
%       Z direction second, progressing from patient superior to inferior,
%       X direction third,  progressing from patient right to left.


%----------------------------------------------------------------------------
% From ANALYZE documentation...
%
% The ANALYZE coordinate system has an origin in the lower left
% corner. That is, with the subject lying supine, the coordinate
% origin is on the right side of the body (x), at the back (y),
% and at the feet (z). This means that:
%
% +X increases from right (R) to left (L)
% +Y increases from the back (posterior,P) to the front (anterior, A)
% +Z increases from the feet (inferior,I) to the head (superior, S)
%
% The LAS orientation is the radiological convention, where patient
% left is on the image right.  The alternative neurological
% convention is RAS (also Talairach convention).
%
% A major advantage of the Analzye origin convention is that the
% coordinate origin of each orthogonal orientation (transverse,
% coronal, and sagittal) lies in the lower left corner of the
% slice as it is displayed.
%
% Orthogonal slices are numbered from one to the number of slices
% in that orientation. For example, a volume (x, y, z) dimensioned
% 128, 256, 48 has:
%
%   128 sagittal   slices numbered 1 through 128 (X)
%   256 coronal    slices numbered 1 through 256 (Y)
%    48 transverse slices numbered 1 through  48 (Z)
%
% Pixel coordinates are made with reference to the slice numbers from
% which the pixels come. Thus, the first pixel in the volume is
% referenced p(1,1,1) and not at p(0,0,0).
%
% Transverse slices are in the XY plane (also known as axial slices).
% Sagittal slices are in the ZY plane.
% Coronal slices are in the ZX plane.
%
%----------------------------------------------------------------------------


%----------------------------------------------------------------------------
% E-mail from support@AnalyzeDirect.com
%
% The 'orient' field in the data_history structure specifies the primary
% orientation of the data as it is stored in the file on disk.  This usually
% corresponds to the orientation in the plane of acquisition, given that this
% would correspond to the order in which the data is written to disk by the
% scanner or other software application.  As you know, this field will contain
% the values:
%
% orient = 0 transverse unflipped
% 1 coronal unflipped
% 2 sagittal unflipped
% 3 transverse flipped
% 4 coronal flipped
% 5 sagittal flipped
%
% It would be vary rare that you would ever encounter any old Analyze 7.5
% files that contain values of 'orient' which indicate that the data has been
% 'flipped'.  The 'flipped flag' values were really only used internal to
% Analyze to precondition data for fast display in the Movie module, where the
% images were actually flipped vertically in order to accommodate the raster
% paint order on older graphics devices.  The only cases you will encounter
% will have values of 0, 1, or 2.
%
% As mentioned, the 'orient' flag only specifies the primary orientation of
% data as stored in the disk file itself.  It has nothing to do with the
% representation of the data in the 3D Analyze coordinate system, which always
% has a fixed representation to the data.  The meaning of the 'orient' values
% should be interpreted as follows:
%
% orient = 0:  The primary orientation of the data on disk is in the
% transverse plane relative to the object scanned.  Most commonly, the fastest
% moving index through the voxels that are part of this transverse image would
% span the right-left extent of the structure imaged, with the next fastest
% moving index spanning the posterior-anterior extent of the structure.  This
% 'orient' flag would indicate to Analyze that this data should be placed in
% the X-Y plane of the 3D Analyze Coordinate System, with the Z dimension
% being the slice direction.
%
% orient = 1:  The primary orientation of the data on disk is in the coronal
% plane relative to the object scanned.  Most commonly, the fastest moving
% index through the voxels that are part of this coronal image would span the
% right-left extent of the structure imaged, with the next fastest moving
% index spanning the inferior-superior extent of the structure.  This 'orient'
% flag would indicate to Analyze that this data should be placed in the X-Z
% plane of the 3D Analyze Coordinate System, with the Y dimension being the
% slice direction.
%
% orient = 2:  The primary orientation of the data on disk is in the sagittal
% plane relative to the object scanned.  Most commonly, the fastest moving
% index through the voxels that are part of this sagittal image would span the
% posterior-anterior extent of the structure imaged, with the next fastest
% moving index spanning the inferior-superior extent of the structure.  This
% 'orient' flag would indicate to Analyze that this data should be placed in
% the Y-Z plane of the 3D Analyze Coordinate System, with the X dimension
% being the slice direction.
%
% Orient values 3-5 have the second index reversed in order, essentially
% 'flipping' the images relative to what would most likely become the vertical
% axis of the displayed image.
%
% Hopefully you understand the difference between the indication this 'orient'
% flag has relative to data stored on disk and the full 3D Analyze Coordinate
% System for data that is managed as a volume image.  As mentioned previously,
% the orientation of patient anatomy in the 3D Analyze Coordinate System has a
% fixed orientation relative to each of the orthogonal axes.  This orientation
% is completely described in the information that is attached, but the basics
% are:
%
% Left-handed coordinate system
%
% X-Y plane is Transverse
% X-Z plane is Coronal
% Y-Z plane is Sagittal
%
% X axis runs from patient right (low X) to patient left (high X)
% Y axis runs from posterior (low Y) to anterior (high Y)
% Z axis runs from inferior (low Z) to superior (high Z)
%
%----------------------------------------------------------------------------



%----------------------------------------------------------------------------
% SPM2 NOTES from spm2 webpage: One thing to watch out for is the image
% orientation. The proper Analyze format uses a left-handed co-ordinate
% system, whereas Talairach uses a right-handed one. In SPM99, images were
% flipped at the spatial normalisation stage (from one co-ordinate system
% to the other). In SPM2b, a different approach is used, so that either a
% left- or right-handed co-ordinate system is used throughout. The SPM2b
% program is told about the handedness that the images are stored with by
% the spm_flip_analyze_images.m function and the defaults.analyze.flip
% parameter that is specified in the spm_defaults.m file. These files are
% intended to be customised for each site. If you previously used SPM99
% and your images were flipped during spatial normalisation, then set
% defaults.analyze.flip=1. If no flipping took place, then set
% defaults.analyze.flip=0. Check that when using the Display facility
% (possibly after specifying some rigid-body rotations) that:
%
% The top-left image is coronal with the top (superior) of the head displayed
% at the top and the left shown on the left. This is as if the subject is viewed
% from behind.
%
% The bottom-left image is axial with the front (anterior) of the head at the
% top and the left shown on the left. This is as if the subject is viewed from above.
%
% The top-right image is sagittal with the front (anterior) of the head at the
% left and the top of the head shown at the top. This is as if the subject is
% viewed from the left.
%----------------------------------------------------------------------------
                                                                                                                                                                                                                                                                                                                                                                                                                                                              \n', BrainStructurelabel{i}, surffile);
      
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