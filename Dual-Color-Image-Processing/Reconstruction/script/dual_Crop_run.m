clear
clc

path_g = '/home/d2/220608/g/new/recon_mat/nii2';
path_r = '/home/d2/220608/r/new/recon_mat/nii2';

g_nii_files = dir(fullfile(path_g,'*.nii'));
r_nii_files = dir(fullfile(path_r,'*.nii'));

crop_size = [410,328,230];
atlas = imread('/home/d2/220608/MIP_Red_1004.tif');
atlas = atlas(1:400,1:308);

for i = 44000:47000
    % nii_name = g_nii_files(i).name;
    % num = str2num(nii_name(isstrprop(nii_name,"digit")));
    green_ObjRecon = niftiread(fullfile(path_g,['green_recon_G2R',num2str(i),'.nii']));
    red_ObjRecon = niftiread(fullfile(path_r,['red_recon',num2str(i),'.nii']));

    dualCrop(red_ObjRecon,green_ObjRecon,path_r,path_g,i,atlas,crop_size);
    disp(['green_recon_G2R',num2str(i),'.nii done.']);
end
