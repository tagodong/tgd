%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run demons registration.

% Set environment.
cd ../;
adpath;

% Set parameters.
% path_g="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/g";
% path_r="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/r";
% Red_flag = 0;
file_path_red = fullfile(path_r,'regist_red');
file_path_green = fullfile(path_g,'regist_green');

if ~exist('start_num','var')
    start_num = 1;
end
if ~exist('end_num','var')
    end_num = length(dir(fullfile(file_path_red,'regist_red_1_*.nii')));
end
if ~exist('step_size','var')
    step_size = 1;
end

if red_flag
    file_path_template = fullfile(path_r,'template','mean_template.nii');
else
    file_path_template = fullfile(path_g,'template','mean_template.nii');
end

refer_image = uint16(niftiread(file_path_template));
refer_image = refer_image(1:160,:,:);

% Set gpu index for demonRegist(if have multi-gpus, use a vector.).
gpu_index = [1,2,3,4];

% extract the name number of affine registed images.
tif_struct = dir(fullfile(file_path_red,'regist_red_1_*.nii'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    name_num = split(all_tifs{i},'.');
    name_num = split(name_num{1},'_');
    name_num = name_num{4};
    num_index(i) = str2double(name_num);
end
num_index = sort(num_index);

% demons registration for mean template.
demonRegist(file_path_red,file_path_green,red_flag,start_num,step_size,end_num,num_index,refer_image,gpu_index);

disp('Demons registration work has done!');