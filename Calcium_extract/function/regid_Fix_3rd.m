function regid_Fix_3rd(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame)
    %% function summary: regist the fish using affine motion according to refer fish.
    %  input:
    %   file_Path_Red --- the directory path of red fish.
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   reg_MIPs --- the MIP directory of registed red/green fish.
    %   reg_green/red_nii --- the nii directory of registed red fish.

    %   2022.12.02 by tgd.
    % parallel.gpu.enableCUDAForwardCompatibility(true);
    % gpuDevice(gpu_index);
    %% read the reference image
    refer_image = niftiread('/home/d2/Ref-zbb2.nii');
    refer_image = refer_image(1:380,:,:);

    %% regist run.
    for i = startFrame:stepSize:endFrame

        disp([num2str(i),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        crop_2_red_path = fullfile(file_Path_Red,'crop_red_nii_2');
        crop_2_red_name = ['crop_red_2_',num2str(i),'.nii'];
        crop_2_red_image = niftiread(fullfile(crop_2_red_path,crop_2_red_name));

        crop_2_green_path = fullfile(file_Path_Green,'crop_green_nii_2');
        crop_2_green_name = ['crop_green_2_',num2str(i),'.nii'];
        crop_2_green_image = niftiread(fullfile(crop_2_green_path,crop_2_green_name));

        regist_3_red_name_out = ['red_regist_3_',num2str(i),'.nii'];
        regist_3_green_name_out = ['green_regist_3_',num2str(i),'.nii'];

        %% apply affine transformation.
        % red_image = gpuArray(red_image);
        % refer_image = gpuArray(refer_image);
        % green_image = gpuArray(green_image);
        [Affine_T,regist_3_red_image] = imregdemons(crop_2_red_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        regist_3_green_image = imwarp(crop_2_green_image,Affine_T,'linear');
        
        %% write the registed image.
        % reg_red_image = gather(reg_red_image);
        % reg_green_image = gather(reg_green_image);
        regist_red_nii_path_3 = fullfile(file_Path_Red,'regist_red_nii_3');
        reg_green_nii_path_3 = fullfile(file_Path_Green,'regist_green_nii_3');
        niftiwrite(regist_3_red_image,fullfile(regist_red_nii_path_3,regist_3_red_name_out));
        niftiwrite(regist_3_green_image,fullfile(reg_green_nii_path_3,regist_3_green_name_out));
        
        % write the MIP of second non-regid registed fish image for check them convenient.
        regist_3_Red_Mip = [max(regist_3_red_image,[],3) squeeze(max(regist_3_red_image,[],2));squeeze(max(regist_3_red_image,[],1))' zeros(size(regist_3_red_image,3),size(regist_3_red_image,3))];
        regist_3_Red_Mip = uint16(regist_3_Red_Mip);
        regist_3_red_Mip_Path = fullfile(file_Path_Red,'regist_red_MIPs_3');
        imwrite(regist_3_Red_Mip,fullfile(regist_3_red_Mip_Path,['regist_red_MIP_3','_',num2str(i),'.tif']));
        
        regist_3_green_Mip = [max(regist_3_green_image,[],3) squeeze(max(regist_3_green_image,[],2));squeeze(max(regist_3_green_image,[],1))' zeros(size(regist_3_green_image,3),size(regist_3_green_image,3))];
        regist_3_green_Mip = uint16(regist_3_green_Mip);
        reg_3_green_Mip_Path = fullfile(file_Path_Green,'regist_green_MIPs_3');
        imwrite(regist_3_green_Mip,fullfile(reg_3_green_Mip_Path,['regist_green_MIP_3','_',num2str(i),'.tif']));

        disp(['reg_green_MIP','_',num2str(i),'.tif done!']);
        toc

    end
    
end