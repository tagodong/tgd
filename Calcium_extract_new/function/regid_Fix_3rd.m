function regid_Fix_3rd(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame,mod)
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

    if mod ==1
        refer_image = niftiread('/home/d2/Ref-zbb4.nii');
    else
        refer_image = niftiread(fullfile(file_Path_Red,'regist_red_mat_3','mean_template_2.nii'));
    end
    

    %% regist run.
    for i = startFrame:stepSize:endFrame

        if ~exist(fullfile(file_Path_Red,['regist_red_1_',num2str(i),'.nii']))
            continue;
        end

        disp([num2str(i),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        crop_2_red_path = fullfile(file_Path_Red,'crop_red_mat_2');
        crop_2_red_name = ['crop_red_2_',num2str(i),'.mat'];
        load(fullfile(crop_2_red_path,crop_2_red_name));
        crop_2_red_image = red_image_crop_2nd;

        crop_2_green_path = fullfile(file_Path_Green,'crop_green_mat_2');
        crop_2_green_name = ['crop_green_2_',num2str(i),'.mat'];
        load(fullfile(crop_2_green_path,crop_2_green_name));
        crop_2_green_image = green_image_crop_2nd;

        regist_3_red_name_out = ['red_regist_3_',num2str(i),'.mat'];
        regist_3_green_name_out = ['green_regist_3_',num2str(i),'.mat'];

        %% apply affine transformation.
        crop_2_red_image = gpuArray(crop_2_red_image);
        refer_image = gpuArray(refer_image);
        crop_2_green_image = gpuArray(crop_2_green_image);

        [Affine_T,regist_3_red_image] = imregdemons(crop_2_red_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        regist_3_green_image = imwarp(crop_2_green_image,Affine_T,'linear');
        
        %% write the registed image.
        regist_3_red_image = gather(regist_3_red_image);
        regist_3_green_image = gather(regist_3_green_image);

        regist_red_mat_path_3 = fullfile(file_Path_Red,'regist_red_mat_3');
        regit_green_mat_path_3 = fullfile(file_Path_Green,'regist_green_mat_3');
        save(fullfile(regist_red_mat_path_3,regist_3_red_name_out),'regist_3_red_image');
        save(fullfile(regit_green_mat_path_3,regist_3_green_name_out),'regist_3_green_image');
        
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