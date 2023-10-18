%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run affine registration.

% Set environment.
cd ../;
adpath;

% set the directory path of template images.
% file_path_template = "/home/d1/HC_atlas_test/template";
file_path_template = "/home/d1/20230808_1534_g8s-lssm-none_7dpf-fix/fix/g/template";

% extract the name number of template images.
tif_struct = dir(fullfile(file_path_template,'template*.nii'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    file_name = all_tifs{i};
    name_num = isstrprop(file_name,'digit');
    num_index(i) = str2double(file_name(name_num));
end

% Check the number of bad templates in person and write the name number here.
% false_num = [3255,3355:50:4055];
% false_num = [20101,20301,20401,20601,21301,21501,23001,23301,23501,23701];
false_num=[];

mode = 1;
% Run the templateMean.
templateMean(file_path_template,num_index,false_num,mode);
% atlas = uint16(niftiread("/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii"));
% templateGe(file_path_template,atlas,num_index,mode);