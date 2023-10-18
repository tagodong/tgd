%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run demons registration.

% Set environment.
cd ../;
adpath;

% set the red and green directory path of affine registed images.
% path_g="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/g";
% path_r="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/r";
% red_flag = 0;

file_path_red = fullfile(path_r,'Red_Registration');
file_path_green = fullfile(path_g,'Green_Registration');


template_path = fullfile(path_g,'..','template');

if ~exist('Mask_path','var')
    Mask_path = fullfile(template_path,'zbb_SyN.nii.gz');
end

% extract the name number of affine registed images.
tif_struct = dir(fullfile(file_path_green,'Green_Affine_*.nii'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    name = all_tifs{i};
    name_num = name(isstrprop(name,"digit"));
    num_index(i) = str2double(name_num);
end

% for Mask method, it could only run on cpus and the thread_num could be setted as the number of cpu thread.
% Here, we have 28 threads.
start_num = 1;
end_num = length(dir(fullfile(file_path_green,'Green_Affine_*.nii')));
thread_num = 28;

Mask = niftiread(Mask_path);
Mask = uint16(Mask>0);
step_size = 1; 

% crop the eyes.
eyesCrop_Mask(file_path_red,file_path_green,start_num,step_size,end_num,num_index,Mask,thread_num);

disp('Eyes crop work has done!!!');
