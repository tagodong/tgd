function demonRegist(file_path_red,file_path_green,red_flag,start_frame,step_size,end_frame,num_index,refer_image,gpu_index)
%% function summary: muti thread regist the fish image using demons method.

%  input:
%   file_path_red/green --- the nii format image directory path of affine registed red/green images.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   num_index --- the transform between template name number and index.
%   template_path --- the path of template.
%   gpu_index --- the gpu id. For multi-GPUs, use a vector.  

%  write: this function will generate 2 directories under both file_path_red and file_path_green.
%   red/green_demons --- contain demon registed red/green images in mat format.
%   red/green_demons_MIPs --- contain the maximum intensity projections in three directions of the demon registed images.

%   Update on 2022.12.03.

%% Run.
    % Initialize the parameters.
    if nargin == 8
        gpu_index = [1 2 3 4];
    end
    thread_num = length(gpu_index);
    delete(gcp('nocreate'));
    parpool('local',thread_num);
    spmd_num = ceil((end_frame-start_frame+1)/step_size/thread_num);

    % create non-rigid nii directory.
    red_demons_path = fullfile(file_path_red,'..','..','back_up','Red_Demons');
    red_demons_MIPs_path = fullfile(file_path_red,'..','..','back_up','Red_Demons_MIP');
    green_demons_path = fullfile(file_path_green,'..','..','back_up','Green_Demons');
    green_demons_MIPs_path = fullfile(file_path_green,'..','..','back_up','Green_Demons_MIP');
    if ~exist(green_demons_path,"dir")
        mkdir(red_demons_path);
        mkdir(red_demons_MIPs_path);
        mkdir(green_demons_path);
        mkdir(green_demons_MIPs_path);
    end

    % run non-regid registration.
    tic;
    spmd
        gpuDevice(gpu_index(spmdIndex));
        if start_frame+(spmd_num*spmdIndex-1)*step_size <= end_frame
            registDemons(file_path_red,file_path_green,red_flag,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,start_frame+(spmd_num*spmdIndex-1)*step_size,num_index,refer_image);
        else
            registDemons(file_path_red,file_path_green,red_flag,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,end_frame,num_index,refer_image);
        end
    end
    toc;

end
