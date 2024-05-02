clear
clc
path = '/home/d1/Learn/2024-01-08-Gcamp8s_Lss_11dpf_learn/test/data';
seg_regions = load(fullfile(path,'Ratio_zoom_cnmf.mat')).A;

fov_size = [25,370;31,282;1,190];

path_Demons = '/home/d1/Learn/2024-01-08-Gcamp8s_Lss_11dpf_learn';
path_g = fullfile(path_Demons,'Green_Demons');
path_r = fullfile(path_Demons,'Red_Demons');
pre_name_green = 'Green_Demons_';
value_name_green = 'ObjRecon';
pre_name_red = 'Red_Demons_';
value_name_red = 'ObjRecon';

% set start frame, end frame and frame index.
files = dir(fullfile(path_g,[pre_name_green,'*.mat']));
[~,name_num] = sortName(files);

load(fullfile(path_Demons,'bad_index.mat'),'bad_index_final2');
name_num = setdiff(name_num,bad_index_final2);


if ~exist('start_frame',"var")
    start_frame = 1;
end

if ~exist('end_frame',"var")
    end_frame = length(name_num);
end

Cal_G = cnmfExtract(path_g,pre_name_green,value_name_green,seg_regions,fov_size,start_frame,end_frame,name_num);
disp('Cal_G done.');

Cal_R = cnmfExtract(path_r,pre_name_red,value_name_red,seg_regions,fov_size,start_frame,end_frame,name_num);
disp('Cal_R done.');

save(fullfile(path_Demons,'data','CalTrace.m'),"Cal_R","Cal_G",'-v7.3');