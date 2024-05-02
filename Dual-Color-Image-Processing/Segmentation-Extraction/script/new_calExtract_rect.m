%% Note: You must run the adpath.m script firstly, then run this code under Segmentation-Extraction path.

%% Segment brain regions using Correlation Map method and extract the calcium trace.

clear
% set path.
file_dir = '/home/d2/daguang/2023-12-03_17-14-10_g8s_lssm_5dpf/back_up';
% load(fullfile(file_dir,'CalTrace','bad_index.mat'));

start_frame = 1; % note it is the sort index.
% end_frame = 2299;

CalTrace_path = fullfile(file_dir,'CalTrace_Rect');
if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end

% path_files_g = getsubfolders(path_g);
% path_files_r = getsubfolders(path_r);

path_r = fullfile(file_dir,'Red_Demons/');

path_g = fullfile(file_dir,'Green_Demons/');

% set the prefix name and value name of images.
pre_name_green = 'Green_Demons_';
value_name_green = 'ObjRecon';
pre_name_red = 'Red_Demons_';
value_name_red = 'ObjRecon';

% set start frame, end frame and frame index.
files = dir(fullfile(path_g,[pre_name_green,'*.mat']));
[~,name_num] = sortName(files);

if ~exist('start_frame',"var")
    start_frame = 1;
end

if ~exist('end_frame',"var")
    end_frame = length(name_num);
end

rect_size = [8,8,6];

% Generate the rect segmentation mask.
[seg_regions, water_corMap, info_data] = rectSegGenerate2(path_g,pre_name_green,start_frame,end_frame,rect_size,name_num);
save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap');
% extract the green trace.
tic;
[G_trace,G_Coherence]=traceExtract(path_g,pre_name_green,value_name_green,seg_regions,water_corMap,info_data,start_frame,end_frame,name_num);
G_trace_base = prctile(G_trace,30,2);
region_id = find(G_trace_base>0);
G_trace_filter = G_trace(region_id,:);

save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace','-v7.3');
save(fullfile(CalTrace_path,'G_trace_filter.mat'),'G_trace_filter','-v7.3');
save(fullfile(CalTrace_path,'region_id.mat'),'region_id','-v7.3');
save(fullfile(CalTrace_path,'G_Coherence.mat'),'G_Coherence','-v7.3');
disp('Green trace done.');

% extract the red trace.
R_trace = traceExtract2(path_r,pre_name_red,value_name_red,seg_regions,start_frame,end_frame,name_num);
R_trace_filter = R_trace(region_id,:);
save(fullfile(CalTrace_path,'R_trace.mat'),'R_trace','-v7.3');
save(fullfile(CalTrace_path,'R_trace_filter.mat'),'R_trace_filter','-v7.3');
disp('Red trace done.');

Cal_index = name_num(start_frame:end_frame);
save(fullfile(CalTrace_path,'Cal_index.mat'),'Cal_index');
toc;

