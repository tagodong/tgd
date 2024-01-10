clear
clc

file_path = '/home/d1/daguang/2023-12-06_16-47-30_g8s_lssm_8dpf/back_up/Red_Recon';

files = dir(fullfile(file_path,'*.mat'));
files = sortName(files);
heart_flag = 0;
file_path_red = fullfile(file_path,'..','Red_test');
red_crop_path = fullfile(file_path_red,'Red_Crop');
red_crop_MIP_path = fullfile(file_path_red,'Red_Crop_MIP');
mkdir(file_path_red);
mkdir(red_crop_path);
mkdir(red_crop_MIP_path);
atlas_path = '/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii';
atlas = niftiread(atlas_path);
crop_size = [400,308,210];
x_shift = 80;


for i = 1:length(files)
    load(fullfile(file_path,files{i}));
    red_ObjRecon = gpuArray(ObjRecon);
    [red_ObjRecon,green_ObjRecon] = rgSyn(red_ObjRecon,red_ObjRecon);
    newDualCrop(red_ObjRecon,green_ObjRecon,heart_flag,file_path_red,file_path_red,14999+i,atlas,crop_size,x_shift);
    disp(i);
end