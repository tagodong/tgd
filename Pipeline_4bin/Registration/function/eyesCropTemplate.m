function eyesCropTemplate(template_path,start_frame,step_size,end_frame,num_index,Mask,thread_num)
%% function summary: Crop the eyes according to the reference mask.

%  input:
%   file_path_red/green --- the nii format image directory path of affine registed red/green images.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   num_index --- the transform between template name number and index.
%   mask_path --- the path of atlas mask.
%   thread_num --- the number of thread.  

%  write: this function will generate 2 directories under both file_path_red and file_path_green.
%   red/green_crop --- contain eyes cropped red/green image in mat format.
%   red/green_crop_MIPs --- contain the maximum intensity projections in three directions of the eyes cropped images.

%   Update on 2022.12.03.
    
%% Run crop eyes.
% Initialize the parameters.
if nargin == 6
    thread_num = 28;
end
delete(gcp('nocreate'));
parpool('local',thread_num);
spmd_num = ceil((end_frame-start_frame+1)/step_size/thread_num);

% create output directory.
template_crop_path = fullfile(template_path,'template_eyes_crop');
template_crop_MIPs_path = fullfile(template_path,'template_eyes_crop_MIPs');
if ~exist(template_crop_path,"dir")
    mkdir(template_crop_path);
    mkdir(template_crop_MIPs_path);
end

% run eyes crop using mask.
tic;
spmd
    if start_frame+(spmd_num*spmdIndex-1)*step_size <= end_frame
        cropEyesTemplate(template_path,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,start_frame+(spmd_num*spmdIndex-1)*step_size,num_index,Mask);
    else
        cropEyesTemplate(template_path,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,end_frame,num_index,Mask);
    end
end
toc;
    
end