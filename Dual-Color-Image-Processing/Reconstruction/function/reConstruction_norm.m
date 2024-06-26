function reConstruction_norm(file_path_red,file_path_green,red_flag,heart_flag,red_have,red_PSF,green_PSF,atlas,crop_size,start_frame,step_size,end_frame,tform,x_shift,gpu_index)
%% function summary: reconstruct frames.

%  input:
%   file_path_red/green --- the .tif format image directory path of red/green fish.
%   red_flag --- If use the red channel image.
%   heart_flag --- Whether your data has heart fluorescence.
%   red_have --- Whether process your red channel data
%   red/green_PSF --- the PSF of red/green .tif format image.
%   atlas --- the registered template.
%   crop_size --- the image size of cropped.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   tform --- the transform matrix from green image to red image.
%   x_shift --- the x direction shift.
%   gpu_index --- the gpu id. For multi-GPUs, use a vector.  

%  update on 2024.04.13.

%% Initialize the parameters.
    if nargin == 13
        x_shift = 60;
        gpu_index = [1 2 3 4];
    else 
        if nargin == 14
            gpu_index = [1 2 3 4];
        end
    end

%% Read the image and run reConstruct function to construct image.
    gpu_num = length(gpu_index);
    if red_have
        r_files = dir(fullfile(file_path_red,'*.tif'));  %%% 3
        all_tifs = sortName(r_files);
    end

    g_files = dir(fullfile(file_path_green,'*.tif'));  %%%
    all_tifs_g = sortName(g_files);
    disp(all_tifs_g);
    spmd_num = ceil((end_frame-start_frame+1)/step_size/gpu_num);

    delete(gcp('nocreate'));
    parpool(gpu_num);
    spmd
        gpuDevice(spmdIndex);
        for i = start_frame+spmd_num*(spmdIndex-1)*step_size:step_size:start_frame+(spmd_num*spmdIndex-1)*step_size
            
            if i <= end_frame
                tif_name = all_tifs_g{i};

                % Extract the name num of the frame.
                num_index=isstrprop(tif_name,'digit');
                num = str2double(tif_name(num_index));

                % cur_path = fullfile(file_path_green,'Green_Crop');
                % green_recon_name = ['Green_Crop_',num2str(num),'.nii'];
                % if exist(fullfile(cur_path,green_recon_name),"file")
                %     continue;
                % end

                tic;
                disp(['frame ',all_tifs_g{i},' start.']);

                %% Reconstruct the red.
                if red_have
                    red_file_Name = fullfile(file_path_red,all_tifs{i});
                    imstack = tif2mat(red_file_Name);
                    % imstack = flip(imstack,1); %% for daguang and yu bin.
                    red_ObjRecon = reConstruct(imstack,red_PSF);
                    
                    % Save the reconstructed result.
                    red_recon_path = fullfile(file_path_red,'..','back_up','Red_Recon');
                    red_recon_name = ['Red_Recon_',num2str(num),'.mat'];
                    red_recon_MIP_path = fullfile(file_path_red,'..','back_up','Red_Recon_MIP');
                    red_recon_MIP_name = ['Red_Recon_MIP_',num2str(num),'.tif'];
                    imageWrite(red_recon_path,red_recon_MIP_path,red_recon_name,red_recon_MIP_name,red_ObjRecon,1);

                    % red_ObjRecon = gpuArray(load(fullfile(red_recon_path,red_recon_name)).ObjRecon);
                else
                    red_ObjRecon = [];
                end

                %% Reconstruct the green.
                green_file_Name = fullfile(file_path_green,all_tifs_g{i});
                imstack = tif2mat(green_file_Name);
                green_ObjRecon = reConstruct(imstack,green_PSF);

                % Save the reconstructed result.
                green_recon_path = fullfile(file_path_green,'..','back_up','Green_Recon');
                green_recon_name = ['Green_Recon_',num2str(num),'.mat'];
                green_recon_MIP_path = fullfile(file_path_green,'..','back_up','Green_Recon_MIP');
                green_recon_MIP_name = ['Green_Recon_MIP_',num2str(num),'.tif'];
                imageWrite(green_recon_path,green_recon_MIP_path,green_recon_name,green_recon_MIP_name,green_ObjRecon,1);
                
                % green_ObjRecon = gpuArray(load(fullfile(green_recon_path,green_recon_name)).ObjRecon);
                toc;

                %% Synchronize the red and green.
                [red_ObjRecon,green_ObjRecon] = rgSyn(red_ObjRecon,green_ObjRecon,red_have);  %%%

                %% Important: Transform the green to register the red because of dissynchrony of dichroic mirrors.
                green_ObjRecon = imwarp(green_ObjRecon,tform,'linear','OutputView',imref3d(size(green_ObjRecon)));

                % Crop the black background and rotate the two ObjRecons.
                disp('dual crop start.');
                tic;
                if red_flag
                    dual_Crop_norm(red_ObjRecon,green_ObjRecon,heart_flag,file_path_red,file_path_green,num,atlas,crop_size,x_shift);
                else
                    dualCrop_G(red_ObjRecon,green_ObjRecon,heart_flag,red_have,file_path_red,file_path_green,num,atlas,crop_size,x_shift);
                end
                toc;
                disp(['frame ',num2str(num),' end.']);
            end
        end
    end

    delete(gcp('nocreate'));
    disp('All done!');
end
