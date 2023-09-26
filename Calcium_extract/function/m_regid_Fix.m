function m_regid_Fix(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame,regid_num)
    %% function summary: muti thread regist the fish using affine motion according to refer fish.
    %  input:
    %   file_Path_Red --- the directory path of red fish.
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    %   regid_num --- the mode of function. 1: rigid registration; 2: eyes crop; 3: non-rigid registration;
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   regist_red/green_MIPs_1 --- the MIP directory of firstly regid red/green fish.
    %   regist_red/green_MIPs_3 --- the MIP directory of thirdly non-regid red/green fish.
    %   regist_green/red_nii_1 --- the nii directory of firstly rigid registed green/red fish.
    %   crop_red/green_nii_2 --- the nii directory of secondly eyes croped green/red fish.
    %   regist_green/red_nii_3 --- the nii directory of thirdly non-rigid registed green/red fish.
    
    %   2022.12.03 by tgd.
    
    % parallel.gpu.enableCUDAForwardCompatibility(true);
    % gpuDevice(gpu_index);
    %% read the reference image
    
    thread_num = 28;
    parpool('local',thread_num);
    spmd_num = ceil((endFrame-startFrame+1)/stepSize/thread_num);
    
    %% rigid registration firstly
    if regid_num == 1
        % create mip directory.
        reg_red_Mip_Path_1 = fullfile(file_Path_Red,'regist_red_MIPs_1');
        reg_green_Mip_Path_1 = fullfile(file_Path_Green,'regist_green_MIPs_1');
        if ~exist(reg_red_Mip_Path_1)
            mkdir(reg_red_Mip_Path_1);
            mkdir(reg_green_Mip_Path_1);
        end
        
        % create nii directory.
        reg_green_nii_path_1 = fullfile(file_Path_Green,'regist_green_nii_1');
        reg_red_nii_path_1 = fullfile(file_Path_Red,'regist_red_nii_1');
        if ~exist(reg_green_nii_path_1)
            mkdir(reg_green_nii_path_1);
            mkdir(reg_red_nii_path_1);
        end
        
        % run rigid registration.
        tic;
        spmd
            if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
                regid_Fix_1st(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize);
            else
                regid_Fix_1st(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame);
            end
        end
        toc;
        
        %% crop eyes secondly.
    else if regid_num == 2
            % create crop directory.
            file_path_crop_2_red = fullfile(file_Path_Red,'crop_red_nii_2');
            file_path_crop_2_green = fullfile(file_Path_Green,'crop_green_nii_2');
            if ~exist(file_path_crop_2_red)
                mkdir(file_path_crop_2_red);
                mkdir(file_path_crop_2_green);
            end
            
            % run eyes crop.
            tic;
            spmd
                if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
                    crop_Fix_2nd(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize);
                else
                    crop_Fix_2nd(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame);
                end
            end
            toc;
            
            %% non-rigid registration thirdly.
        else
            % create non-rigid mip directory.
            reg_red_Mip_Path_3 = fullfile(file_Path_Red,'regist_red_MIPs_3');
            reg_green_Mip_Path_3 = fullfile(file_Path_Green,'regist_green_MIPs_3');
            if ~exist(reg_red_Mip_Path_3)
                mkdir(reg_red_Mip_Path_3);
                mkdir(reg_green_Mip_Path_3);
            end
            % create non-rigid nii directory.
            reg_green_nii_path_3 = fullfile(file_Path_Green,'regist_green_nii_3');
            reg_red_nii_path_3 = fullfile(file_Path_Red,'regist_red_nii_3');
            if ~exist(reg_green_nii_path_3)
                mkdir(reg_green_nii_path_3);
                mkdir(reg_red_nii_path_3);
            end
            
            % run non-regid registration.
            tic;
            spmd
                if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
                    regid_Fix_3rd(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize);
                else
                    regid_Fix_3rd(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame);
                end
            end
            toc;
            
        end
        
    end
    
    delete(gcp('nocreate'));
    
    end