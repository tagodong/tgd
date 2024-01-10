%% Note: You must run the adpath.m script firstly, then run this code under Reconstruction path.

%% A demo to run image reconstruction and crop the black background.

% Directory path of the tif multi-view light field images.
% Note: in the demo, the name of the images is like '00000001.tif'.
% cd ../;
% adpath;

%% Initialize the parameters.
path_g="/home/d2/tgd/test/g";
path_r="/home/d2/tgd/test/r";
% path_g="/home/d2/new_beads/g";
% path_r="/home/d2/new_beads/r";
% red_flag = 1;
% start_num = 3371;
% end_num = 9370;
% step_size = 1;
% heart_flag = 0; % Note your data.

file_Path_Red = path_r;
file_Path_Green = path_g;
% load(fullfile(file_Path_Red,'..','idx_frame_left_final.mat'),'idx_frame_left_final');
% idx_frame_left_final = start_num:end_num;

% mkdir directories.
if ~exist(fullfile(file_Path_Green,'..','back_up'),"dir")

    % For back up.
    mkdir(fullfile(file_Path_Green,'..','back_up'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Parameters'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Red_Recon'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Red_Recon_MIP'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Green_Recon'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Green_Recon_MIP'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Green_Crop_MIP'));
    mkdir(fullfile(file_Path_Green,'..','back_up','Red_Crop_MIP'));
    
    % For Computation.
    mkdir(fullfile(file_Path_Green,'Green_Crop'));
    mkdir(fullfile(file_Path_Red,'Red_Crop'));

end

% Point spread function.
% PSF_path_red = '/home/user/RG-corr/PSFr210825.mat';
PSF_path_red = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_R.mat';
% PSF_path_green = '/home/user/RG-corr/PSFg210825.mat';
PSF_path_green = '/home/user/tgd/Dual-Color-Image-Processing/data/PSF/PSF_G.mat';
red_PSF = load(PSF_path_red).PSF_1;
green_PSF = load(PSF_path_green).PSF_1;

% Atlas.
atlas_path = '/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii';
atlas = niftiread(atlas_path);

% Affine transform between the green and the red.
load('/home/user/tgd/Dual-Color-Image-Processing/data/Transform/tform_231017.mat','tform');

% set the output size which was cropped.
crop_size = [400,308,210];

% Set gpu index (if have multi-gpus, use a vector.).
gpu_index = [1,2,3,4];

if ~exist('red_flag','var')
    red_flag = 1;
end

if ~exist('heart_flag','var')
    heart_flag = 0;
end

if ~exist('start_num','var')
    start_num = 1;
end

if ~exist('end_num','var')
    end_num = min(length(dir(fullfile(file_Path_Red,'*.tif'))),length(dir(fullfile(file_Path_Green,'*.tif'))));
end

if ~exist('step_size','var')
    step_size = 1;
end

if ~exist('x_shift','var')
    x_shift = 80;
end

% Run reconstruction and crop the black background.
tic;
    reConstruction_norm(file_Path_Red,file_Path_Green,red_flag,heart_flag,red_PSF,green_PSF,atlas,crop_size,start_num,step_size,end_num,tform,x_shift,gpu_index);
toc;

save(fullfile(file_Path_Green,'..','back_up','Parameters','base.mat'),'heart_flag','tform');

disp('Reconstruction has done.');
