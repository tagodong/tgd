%% Note: You must run the adpath.m script firstly, then run this code under Segmentation-Extraction path.

%% Segment brain regions using Correlation Map method and extract the calcium trace.

% set path.
path_g = '/home/d1/fix/20230928_1512_g8s-lssm-tph2-chri_9dpf/g';
path_r = '/home/d1/fix/20230928_1512_g8s-lssm-tph2-chri_9dpf/r';
CalTrace_path = fullfile(path_g,'..','CalTrace');
if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end

path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

start_frame = 324;
end_frame = 1199;

for j = 1:1

    file_path_red = fullfile(path_r,'regist_red/red_demons/');

    file_path_green = fullfile(path_g,'regist_green/green_demons/');

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
    min_size = 2; %% 14

    % set the start and end.
    % start_frame = start_num(j);
    % end_frame = end_num(j);
    % boat_interval_final = start_frame:end_frame;

    % extract the green trace.
    tic;
    [G_trace,Coherence_G,seg_regions,water_corMap_filter,info_data] = corMap(file_path_green,pre_name_green,value_name_green,start_frame,end_frame,ad_dist,thresh,min_size);
    save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace');
    save(fullfile(CalTrace_path,'G_Coherence.mat'),'Coherence_G');
    save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
    save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap_filter');
    disp('Green trace done.');

    % extract the red trace.
    batch_size = 1;
    write_flag = 1;
    [R_trace,Coherence_R] = traceExtract(file_path_red,pre_name_red,value_name_red,seg_regions,water_corMap_filter,info_data,start_frame,batch_size,end_frame,write_flag);
    save(fullfile(CalTrace_path,'R_trace.mat'),'R_trace');
    save(fullfile(CalTrace_path,'R_Coherence.mat'),'Coherence_R');
    disp('Red trace done.');
    toc;
end