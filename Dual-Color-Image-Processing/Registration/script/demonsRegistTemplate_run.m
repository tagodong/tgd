%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run demons registration.

% Set environment.
cd ../;
adpath;

% Set parameters.
% template_path=""
template_crop_path = fullfile(template_path,'template_eyes_crop');
file_path_template = fullfile(template_path,'eyes_crop_affine_mean_template.nii');
refer_image = uint16(niftiread(file_path_template));

if ~exist('start_num','var')
    start_num = 1;
end
if ~exist('end_num','var')
    end_num = length(dir(fullfile(template_crop_path,'template_eyes_crop*.mat')));
end
if ~exist('step_size','var')
    step_size = 1;
end

% Set gpu index for demonRegist(if have multi-gpus, use a vector.).
gpu_index = [1,2,3,4];

% extract the name number of affine registed images.
tif_struct = dir(fullfile(template_crop_path,'template_eyes_crop*.mat'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    file_name = all_tifs{i};
    num_index(i) = str2double(file_name(isstrprop(file_name,"digit")));
end

% demons registration for mean template.
demonsRegistTemplate(template_path,start_num,step_size,end_num,num_index,refer_image,gpu_index);

disp('Demons registration work has done!');