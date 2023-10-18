%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run demons registration.

% Set environment.
cd ../;
adpath;

% Set path parameters.
affine_template_path = fullfile(template_path,'affine_template');
Mask_path = fullfile(template_path,'zbb_SyN.nii.gz');
mean_template_path = fullfile(template_path,'affine_mean_template.nii');
eyes_crop_mean_template_path = fullfile(template_path,'eyes_crop_affine_mean_template.nii');

% Extract the name number of affine registed images.
tif_struct = dir(fullfile(affine_template_path,'Can_template_affine*.nii'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    file_name = all_tifs{i};
    num_index(i) = str2double(file_name(isstrprop(file_name,"digit")));
end

% For Mask method, it could only run on cpus and the thread_num could be setted as the number of cpu thread.
% Here, we have 28 threads.
start_num = 1;
end_num = length(dir(fullfile(affine_template_path,'Can_template_affine*.nii')));
thread_num = 28;

Mask = niftiread(Mask_path);
Mask = uint16(Mask>0);
step_size = 1; 

% crop the eyes.
mean_template = niftiread(mean_template_path);
eyes_crop_mean_template = uint16(mean_template).*Mask;
niftiwrite(eyes_crop_mean_template,eyes_crop_mean_template_path);

eyesCropTemplate(template_path,start_num,step_size,end_num,num_index,Mask,thread_num);

disp('Eyes crop work has done!!!')