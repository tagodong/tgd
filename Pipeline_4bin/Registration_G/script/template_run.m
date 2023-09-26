%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run affine registration.

% Set environment.
% cd ../;
% adpath;

% set the directory path of template images.
file_path_template = "/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving/04/g/template";

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
% false_num = [1556,1606,1656,1706,1756,1806,1856];
% false_num = [6161,6221,6301];
% false_num = [8880,8930,9530,9630,9980];
false_num = [12296,12396,12446];

mode = 1;
% Run the templateMean.
templateMean(file_path_template,num_index,false_num,mode);
% atlas = uint16(niftiread("/home/user/tgd/Pipeline_4bin/Registration/data/Atlas/atlas1_bin.nii"));
% templateGe(file_path_template,atlas,num_index,mode);