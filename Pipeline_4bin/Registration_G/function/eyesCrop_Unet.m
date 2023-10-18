function eyesCrop_Unet(file_path_red,file_path_green,start_frame,step_size,end_frame,num_index,unet_path,thread_num)
    %% function summary: Crop the eyes according to the reference mask.
    
    %  input:
    %   file_path_red/green --- the nii format image directory path of affine registed red/green images.
    %   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
    %   num_index --- the transform between template name number and index.
    %   unet_path --- the path of unet.
    %   thread_num --- the number of thread.  
    
    %  write: this function will generate 2 directories under both file_path_red and file_path_green.
    %   red/green_crop --- contain eyes cropped red/green image in mat format.
    %   red/green_crop_MIPs --- contain the maximum intensity projections in three directions of the eyes cropped images.
    
    %   Update on 2022.12.03.
        
    %% Run crop eyes.
        % Initialize the parameters.
        if nargin == 6
            thread_num = 4;
        end
        delete(gcp('nocreate'));
        parpool('local',thread_num);
        spmd_num = ceil((end_frame-start_frame+1)/step_size/thread_num);
        
        %% use Unet to crop fish eyes.
        load(unet_path,'net');
    
        % create output directory.
        red_crop_path = fullfile(file_path_red,'red_crop');
        green_crop_path = fullfile(file_path_green,'green_crop');
        red_crop_MIPs_path = fullfile(file_path_red,'red_crop_MIPs');
        green_crop_MIPs_path = fullfile(file_path_green,'green_crop_MIPs');
        if ~exist(red_crop_path,"dir")
            mkdir(red_crop_path);
            mkdir(green_crop_path);
            mkdir(red_crop_MIPs_path);
            mkdir(green_crop_MIPs_path);
        end
    
        % run eyes crop using mask.
        tic;
        spmd
            gpuDevice(spmdIndex);
            if start_frame+(spmd_num*spmdIndex-1)*step_size <= end_frame
                cropEye_Unet(file_path_red,file_path_green,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,start_frame+(spmd_num*spmdIndex-1)*step_size,num_index,net);
            else
                cropEye_Unet(file_path_red,file_path_green,start_frame+spmd_num*(spmdIndex-1)*step_size,step_size,end_frame,num_index,net);
            end
        end
        toc;
        
    end