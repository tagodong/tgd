%% Extract calcium trace using rect mask.

% file_dir = '';
% start_frame = 324;
% end_frame = 1199;

path_g = fullfile(file_dir,'regist2atlas','g');
path_r = fullfile(file_dir,'regist2atlas','r');
CalTrace_path = fullfile(file_dir,'back_up','CalTrace_Rect');

if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end

% file_path_red = fullfile(path_r,'regist_red/red_demons/');
% file_path_green = fullfile(path_g,'regist_green/green_demons/');

% set the prefix name and value name of images.
pre_name_green = 'ants_g_';
pre_name_red = 'ants_r_';

rect_size = [8,8,6];

files = dir(fullfile(path_g,[pre_name_green,'*.nii']));
[~,name_num] = sortName(files);

if ~exist('start_frame',"var")
    start_frame = 1;
end

if ~exist('end_frame',"var")
    end_frame = length(name_num);
end

% Generate the rect segmentation mask.
[seg_regions, water_corMap, info_data] = rectSegGenerate(path_g,pre_name_green,start_frame,end_frame,rect_size,name_num);
save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap');
% extract the green trace.
tic;
[G_trace] = traceExtract_rect(path_g,pre_name_green,seg_regions,start_frame,end_frame,name_num);
save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace','-v7.3');
disp('Green trace done.');

% extract the red trace.
R_trace = traceExtract_rect(path_r,pre_name_red,seg_regions,start_frame,end_frame,name_num);
save(fullfile(CalTrace_path,'R_trace.mat'),'R_trace','-v7.3');
disp('Red trace done.');

Cal_index = name_num(start_frame:end_frame);
save(fullfile(CalTrace_path,'Cal_index.mat'),'Cal_index');
toc;

