%% Note: You must run the adpath.m script firstly, then run this code under Reconstruction path.

%% A demo to run image reconstruction and crop the black background.

% Directory path of the tif multi-view light field images.
% Note: in the demo, the name of the images is like '00000001.tif'.
path_g = '/home/d2/motor/g20001_24000/';
path_r = '/home/d2/motor/r20001_24000/';
path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

% Point spread function.
PSF_path_red = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_R.mat';
PSF_path_green = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_G.mat';
red_PSF = load(PSF_path_red).PSF_1;
green_PSF = load(PSF_path_green).PSF_1;

% Atlas.
atlas_path = '/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii';
atlas = niftiread(atlas_path);

% Affine transform between the green and the red.
load('/home/user/tgd/Dual-Color-Image-Processing/data/Transform/Affine_G2R.mat','tform');

% set the output size which was cropped.
crop_size = [400,308,210];

% Initialize the parameters.
start_num = 1;
step_size = 1;

% Set gpu index (if have multi-gpus, use a vector.).
gpu_index = [1,2,3,4];

% for i = 1:size(path_files_g,1)
for i = 1:1

    % file_Path_Red = fullfile(path_r,path_files_r{i});
    file_Path_Red = path_r;

    % file_Path_Green = fullfile(path_g,path_files_g{i});
    file_Path_Green = path_g;

    end_num = length(dir(fullfile(file_Path_Red,'*.tif')));

    % end_num = 40;
    % Run reconstruction and crop the black background.
    tic;
    reConstruction(file_Path_Red,file_Path_Green,red_PSF,green_PSF,atlas,crop_size,start_num,step_size,end_num,tform,gpu_index);
    toc;
    
end


% cd /home/user/tgd/Dual-Color-Image-Processing/Registration/
% adpath;
% demonsRegist_run;
