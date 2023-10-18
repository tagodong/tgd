%% Note: You must run the adpath.m script firstly, then run this code under Segmentation-Extraction path.

%% Segment brain regions using Correlation Map method and extract the calcium trace.

% set path.
path_g = '/home/d2/g8s_lssm_huc-chri_7dpf_2023-04-18_16-21-34/new_g11/';
path_r = '/home/d2/g8s_lssm_huc-chri_7dpf_2023-04-18_16-21-34/new_r11/';

path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

start_num = [12774];
end_num = [12873];

for j = 1:size(path_files_r,1)

    file_path_red = fullfile(path_r,path_files_r{j},'regist_red/crop_red_demons/');

    file_path_green = fullfile(path_g,path_files_g{j},'regist_green/crop_green_demons/');
 
    % set the prefix name and value name of images.
    pre_name_green = 'demons_green_3_';
    value_name_green = 'green_demons';
    pre_name_red = 'demons_red_3_';
    value_name_red = 'red_demons';

    % set the distance between two adjacent brain voxels for calculating correlation.
    ad_dist = 3;

    % set the max and min intensity threshold of dataset.
    thresh.max = 9;
    thresh.min = 2;

    % set the minimum size of segmented regions. 
    min_size = 14;

    % set the start and end.
    start_frame = start_num(j);
    end_frame = end_num(j);

    % extract the green trace.
    tic;
    [Cal_G,Coherence_G,seg_regions,water_corMap_filter,info_data] = corMap(file_path_green,pre_name_green,value_name_green,start_frame,end_frame,ad_dist,thresh,min_size);
    save(fullfile(file_path_green,'seg_regions.mat'),'seg_regions');
    save(fullfile(file_path_green,'Cal_G.mat'),'Cal_G');
    save(fullfile(file_path_green,'water_corMap.mat'),'water_corMap_filter');
    disp('Green trace done.');

    % extract the red trace.
    batch_size = 1;
    write_flag = 1;
    [Cal_R,Coherence_R] = traceExtract(file_path_red,pre_name_red,value_name_red,seg_regions,water_corMap_filter,info_data,start_frame,batch_size,end_frame,write_flag);
    save(fullfile(file_path_red,'Cal_R.mat'),'Cal_R');
    disp('Red trace done.');
toc;
end