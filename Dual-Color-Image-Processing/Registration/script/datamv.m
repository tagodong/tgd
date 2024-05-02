clear
clc

data_path = '/home/d1/daguang/2023-11-28_16-56-41_g8f_lssm_6dpf/back_up/bad_index.mat';
path_g = '/home/d1/daguang/2023-11-28_16-56-41_g8f_lssm_6dpf/g';
path_r = '/home/d1/daguang/2023-11-28_16-56-41_g8f_lssm_6dpf/r';

mkdir(fullfile(path_g,'badg'));
mkdir(fullfile(path_r,'badr'))

load(data_path);

for i = 1:length(bad_index_final)
    green_Obj = niftiread(fullfile(path_g,'Green_Crop',['Green_Crop_',num2str(bad_index_final(i)),'.nii']));
    red_Obj = niftiread(fullfile(path_r,'Red_Crop',['Red_Crop_',num2str(bad_index_final(i)),'.nii']));

    niftiwrite(green_Obj,fullfile(path_g,'badg',['Green_Crop_',num2str(bad_index_final(i)),'.nii']));
    niftiwrite(red_Obj,fullfile(path_r,'badr',['Red_Crop_',num2str(bad_index_final(i)),'.nii']));

end