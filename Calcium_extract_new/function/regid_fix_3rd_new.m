function regid_fix_3rd_new(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame,mod,num_flag)
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
        false_num = [8210];
        refer_image = niftiread('/home/d2/Ref-zbb4.nii');
        % false_num = [28414,28463,28513,28563,28631,28704,28771,28857,28937,29024];
        % refer_image = niftiread("/home/d1/atlas-zebrafish/big_atlas_1.nii");
    else
        % refer_image_green = load("/media/user/Fish-free2/221207_23dpf/G/regist_green/crop_green_mat_2/crop_green_2_17438.mat").green_image_crop_2nd;
        % refer_image = load("/media/user/Fish-free2/221207_23dpf/R/regist_red/crop_red_mat_2/crop_red_2_17438.mat").red_image_crop_2nd;
        refer_image = load("/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/red_regist_3_8210.mat").regist_3_red_image;
    end
    

    %% regist run.
    for ii = startFrame:stepSize:endFrame
        i = num_flag(ii);

        if mod==1
            if ~sum(i==false_num)
                continue;
            end
        end
        disp([num2str(i),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        crop_2_red_path = fullfile(file_Path_Red,'crop_red_mat_2');
        crop_2_red_name = ['crop_red_2_',num2str(i),'.mat'];
        load(fullfile(crop_2_red_path,crop_2_red_name),'red_image_crop_2nd');
        crop_2_red_image = red_image_crop_2nd;

        crop_2_green_path = fullfile(file_Path_Green,'crop_green_mat_2');
        crop_2_green_name = ['crop_green_2_',num2str(i),'.mat'];
        load(fullfile(crop_2_green_path,crop_2_green_name),'green_image_crop_2nd');
        crop_2_green_image = green_image_crop_2nd;

        regist_3_red_name_out = ['red_regist_3_',num2str(i),'.mat'];
        regist_3_green_name_out = ['green_regist_3_',num2str(i),'.mat'];

        %% apply affine transformation.
        crop_2_red_image = gpuArray(crop_2_red_image);
        refer_image = gpuArray(refer_image);
        crop_2_green_image = gpuArray(crop_2_green_image);
        % refer_image_green = gpuArray(refer_image_green);

        [Affine_T,regist_3_red_image] = imregdemons(crop_2_red_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        % [~,regist_3_green_image] = imregdemons(crop_2_green_image,refer_image_green,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        % regist_3_red_image = imwarp(crop_2_red_image,Affine_T,'linear');
        regist_3_green_image = imwarp(crop_2_green_image,Affine_T,'linear');
        % [Affine_T,regist_3_green_image] = imregdemons(crop_2_green_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        % regist_3_red_image = imwarp(crop_2_red_image,Affine_T,'linear');
        
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
        toc;

    end
    
end