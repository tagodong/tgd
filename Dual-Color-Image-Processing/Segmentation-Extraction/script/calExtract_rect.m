%% Extract calcium trace using rect mask.

file_dir = '/home/d1/blueLaser';
path_files = getsubfolders(file_dir);

for i = 2:length(path_files)

    path_g = fullfile(file_dir,path_files{i},'g');
    path_r = fullfile(file_dir,path_files{i},'r');
    CalTrace_path = fullfile(file_dir,path_files{i},'CalTrace_Rect');
    if ~exist(CalTrace_path,'dir')
        mkdir(CalTrace_path);
    end
    
    file_path_red = fullfile(path_r,'regist_red/red_demons/');
    file_path_green = fullfile(path_g,'regist_green/green_demons/');
    
    % set the prefix name and value name of images.
    pre_name_green = 'demons_green_3_';
    value_name_green = 'green_demons';
    pre_name_red = 'demons_red_3_';
    value_name_red = 'red_demons';
    batch_size = 1;
    write_flag = 0;
    rect_size = [8,8,6];
    start_frame = 324;
    end_frame = 1199;
    
    % Generate the rect segmentation mask.
    [seg_regions, water_corMap, info_data] = rectSegGenerate(file_path_green, pre_name_green, value_name_green, start_frame, end_frame, rect_size);
    save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
    save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap');
    % extract the green trace.
    tic;
    [G_trace,Coherence_G] = traceExtract(file_path_green,pre_name_green,value_name_green,seg_regions,water_corMap,info_data,start_frame,batch_size,end_frame,write_flag);
    save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace');
    save(fullfile(CalTrace_path,'G_Coherence.mat'),'Coherence_G');
    disp('Green trace done.');
    
    % extract the red trace.
    R_trace = traceExtract(file_path_red,pre_name_red,value_name_red,seg_regions,water_corMap,info_data,start_frame,batch_size,end_frame,write_flag);
    save(fullfile(CalTrace_path,'R_trace.mat'),'R_trace');
    disp('Red trace done.');
    toc;

end
