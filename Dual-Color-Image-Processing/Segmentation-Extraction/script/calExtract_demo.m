%% Note: You must run the adpath.m script firstly, then run this code under Segmentation-Extraction path.

%% Segment brain regions using Correlation Map method and extract the calcium trace.

% set path.
file_dir = '/home/d1/kexin_raphe/norm/230619-01/back_up';

start_frame = 305;
% end_frame = 2299;

CalTrace_path = fullfile(file_dir,'CalTrace');
if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end

% path_files_g = getsubfolders(path_g);
% path_files_r = getsubfolders(path_r);

for j = 1:1

    file_path_red = fullfile(file_dir,'Red_Demons/');

    file_path_green = fullfile(file_dir,'Green_Demons/');

    % set the prefix name and value name of images.
    pre_name_green = 'Green_Demons_';
    value_name_green = 'ObjRecon';
    pre_name_red = 'Red_Demons_';
    value_name_red = 'ObjRecon';

    % set start frame, end frame and frame index.
    files = dir(fullfile(file_path_green,[pre_name_green,'*.mat']));
    [~,name_num] = sortName(files);

    if ~exist('start_frame',"var")
        start_frame = 1;
    end
    
    if ~exist('end_frame',"var")
        end_frame = length(name_num);
    end

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
    [G_trace,Coherence_G,seg_regions,water_corMap_filter,info_data] = corMap(file_path_green,pre_name_green,value_name_green,start_frame,end_frame,name_num,ad_dist,thresh,min_size);
    save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace');
    save(fullfile(CalTrace_path,'G_Coherence.mat'),'Coherence_G');
    save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
    save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap_filter');
    disp('Green trace done.');

    % extract the red trace.
    batch_size = 1;
    write_flag = 1;
    R_trace = traceExtract(file_path_red,pre_name_red,value_name_red,seg_regions,water_corMap_filter,info_data,start_frame,end_frame,name_num);
    save(fullfile(CalTrace_path,'R_trace.mat'),'R_trace');
    disp('Red trace done.');
    
    Cal_index = name_num(start_frame:end_frame);
    save(fullfile(CalTrace_path,'Cal_index.mat'),'Cal_index');
    toc;
end