function old_Regid_Fix_3rd_kx(file_Path_Green,startFrame,stepSize,endFrame,mod,num_flag)
    %% function summary: regist the fish using affine motion according to refer fish.
    %  input:
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    %   mod --- mod: 1. the refer image is zbb4 2. the refer image is mean_template.

    %   output: in the file_Path_Red and file_Path_Green directory.
    %   reg_MIPs --- the MIP directory of registed red/green fish.
    %   reg_green_mat --- the mat directory of registed green fish.

    %   2022.12.02 by tgd.

    if mod == 1
        refer_image = niftiread('/home/d2/Ref-zbb4.nii');
    else
        refer_image = niftiread(fullfile(file_Path_Green,'regist_green_mat_3','mean_template_2.nii'));
    end

    %% regist run.
    for ii = startFrame:stepSize:endFrame

        i = num_flag(ii);

        disp([num2str(i),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        crop_2_green_path = fullfile(file_Path_Green,'crop_green_mat_2');
        crop_2_green_name = ['crop_green_2_',num2str(i),'.mat'];
        load(fullfile(crop_2_green_path,crop_2_green_name),'ObjRecon');
        crop_2_green_image = ObjRecon;

        regist_3_green_name_out = ['green_regist_3_',num2str(i),'.mat'];

        %% apply affine transformation.
        refer_image = gpuArray(refer_image);
        crop_2_green_image = gpuArray(crop_2_green_image);

        [Affine_T,regist_3_green_image] = imregdemons(crop_2_green_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        
        %% write the registed image.
        ObjRecon = gather(regist_3_green_image);

        regist_green_mat_path_3 = fullfile(file_Path_Green,'regist_green_mat_3');
        save(fullfile(regist_green_mat_path_3,regist_3_green_name_out),'ObjRecon');
        
        % write the MIP of second non-regid registed fish image for check them convenient.
        regist_3_green_Mip = [max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
        regist_3_green_Mip = uint16(regist_3_green_Mip);
        reg_3_green_Mip_Path = fullfile(file_Path_Green,'regist_green_MIPs_3');
        imwrite(regist_3_green_Mip,fullfile(reg_3_green_Mip_Path,['regist_green_MIP_3','_',num2str(i),'.tif']));

        disp(['reg_green_MIP','_',num2str(i),'.tif done!']);
        toc

    end
    
end