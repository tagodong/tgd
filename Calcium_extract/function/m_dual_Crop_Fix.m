function m_dual_Crop_Fix(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame)
    %% function summary: muti thread crop the backgroup and rotate the fish to standard.
    %  input:
    %   file_Path_Red --- the directory path of red fish.
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   MIPs --- the MIP directory of croped red/green fish.
    %   red/green.nii --- the nii file of croped red/green fish.
    
    %   2022.12.06 by tgd.

    % parallel.gpu.enableCUDAForwardCompatibility(true);
    % gpuDevice(gpu_index);
    %% read the reference image

    thread_num = 32;
    parpool('local',thread_num);

    red_Mip_Path = fullfile(file_Path_Red,'MIPs');
    green_Mip_Path = fullfile(file_Path_Green,'MIPs');
    if ~exist(red_Mip_Path)
        mkdir(fullfile(file_Path_Red,'MIPs'));
        mkdir(fullfile(file_Path_Green,'MIPs'));
    end

    
    spmd_num = ceil((endFrame-startFrame)/stepSize/thread_num);

    %% regist run.
    tic;
    spmd

        if startFrame+(spmd_num*labindex-1)*stepSize <= endFrame
            dual_Crop_Fix(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,startFrame+(spmd_num*labindex-1)*stepSize);
        else
            dual_Crop_Fix(file_Path_Red,file_Path_Green,startFrame+spmd_num*(labindex-1)*stepSize,stepSize,endFrame);
        end

    end
    toc;
    delete(gcp('nocreate'));