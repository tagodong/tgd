function old_m_regid_Fix(file_Path_Green,startFrame,stepSize,endFrame,regid_num,mod)
    %% function summary: muti thread regist the old fish image using different regid_num method.
    %  input:
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    %   regid_num --- the mode of function. 2: eyes crop; 3: non-rigid registration;
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   regist_green_MIPs_3 --- the MIP directory of thirdly non-regid green fish.
    %   crop_green_mat_2 --- the mat directory of secondly eyes croped green fish.
    %   regist_green_mat_3 --- the mat directory of thirdly non-rigid registed green fish.
    
    %   2022.12.03 by tgd.
    if nargin == 5
        mod = 1;
    end

    if regid_num == 2
        thread_num = 28;
        parpool('local',thread_num);
        spmd_num = ceil((endFrame-startFrame+1)/stepSize/thread_num);
        % create crop directory.
        file_path_crop_2_green = fullfile(file_Path_Green,'crop_green_mat_2');
        if ~exist(file_path_crop_2_green)
            mkdir(file_path_crop_2_green);
        end
        
        % run eyes crop.
        tic;
        spmd
            if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
                old_Crop_Fix_2nd(file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize);
            else
                old_Crop_Fix_2nd(file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame);
            end
        end
        toc;
        
        %% non-rigid registration thirdly.
    else
        thread_num = 4;
        parpool('local',thread_num);
        spmd_num = ceil((endFrame-startFrame+1)/stepSize/thread_num);
        % create non-rigid mip directory.
        reg_green_Mip_Path_3 = fullfile(file_Path_Green,'regist_green_MIPs_3');
        if ~exist(reg_green_Mip_Path_3)
            mkdir(reg_green_Mip_Path_3);
        end
        % create non-rigid nii directory.
        reg_green_mat_path_3 = fullfile(file_Path_Green,'regist_green_mat_3');
        if ~exist(reg_green_mat_path_3)
            mkdir(reg_green_mat_path_3);
        end
        % run non-regid registration.
        tic;
        spmd
            gpuDevice(labindex);
            if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
                old_Regid_Fix_3rd(file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize,mod);
            else
                old_Regid_Fix_3rd(file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame,mod);
            end
        end
        toc;
        
    end
        
    delete(gcp('nocreate'));
    
end