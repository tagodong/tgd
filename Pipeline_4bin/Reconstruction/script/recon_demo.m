%% Note: You must run the adpath.m script firstly, then run this code under Reconstruction path.

%% A demo to run image reconstruction and crop the black background.

% Directory path of the tif multi-view light field images.
% Note: in the demo, the name of the images is like '00000001.tif'.
cd ../;
adpath;

% Set parameters.
file_Path_Red = path_r;
file_Path_Green = path_g;
binsize = 2;

% Point spread function.
PSF_path_red = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_R.mat';
PSF_path_green = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_G.mat';
red_PSF = imageBin(load(PSF_path_red).PSF_1,binsize);
green_PSF = imageBin(load(PSF_path_green).PSF_1,binsize);

% Atlas.
atlas_path = '/home/d1/atlas-zebrafish/Ref-zbb4.nii';
atlas = imageBin(niftiread(atlas_path),binsize);

% Affine transform between the green and the red.
load('~/EyE_Crop3/0924Fit.mat','tform');
tform.T(4,1:3) = tform.T(4,1:3)/binsize;

% set the output size which was cropped.
crop_size = ceil([400,308,210]/binsize);

% Initialize the parameters.
if ~exist('start_num','var')
    start_num = 1;
end
if ~exist('end_num','var')
    end_num = length(dir(fullfile(file_Path_Red,'*.tif')));
end
if ~exist('step_size','var')
    step_size = 1;
end
if ~exist('x_shift','var')
    x_shift = 40;
end

% Set gpu index (if have multi-gpus, use a vector.).
gpu_index = [1,2,3,4];

% Run reconstruction and crop the black background.
reConstruction(file_Path_Red,file_Path_Green,red_PSF,green_PSF,atlas,crop_size,start_num,step_size,end_num,tform,binsize,x_shift,gpu_index);