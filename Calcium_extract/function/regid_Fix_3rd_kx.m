function regid_Fix_3rd_kx(file_Path)
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
    gpuDevice(0);
    %% read the reference image
    refer_image = niftiread('/home/d2/Ref-zbb2.nii');
    refer_image = refer_image(1:380,:,:);

    crop_2_obj_path = fullfile(file_Path,'crop_obj_nii_2');
    obj_crop_2_nii = dir(fullfile(crop_2_obj_path,'*.nii'));
    
    regist_obj_nii_path_3 = fullfile(file_Path,'regist_obj_nii_3');
    regist_3_obj_Mip_Path = fullfile(file_Path,'regist_obj_MIPs_3');

    if ~exist(regist_obj_nii_path_3)
        mkdir(regist_obj_nii_path_3);
        mkdir(regist_3_obj_Mip_Path);
    end

    %% regist run.
    for i = 1:length(obj_crop_2_nii)

        filename_in = obj_crop_2_nii(i).name;
        name_char = split(filename_in,'.');
        name_char = name_char{1};
        name_char = split(name_char,'_');
        name_char = name_char{4};
        frame_num = str2num(name_char);

        disp([num2str(frame_num),' is doing...']);

        tic;
        %% nifread the nii image stacks.

        crop_2_red_name = ['crop_obj_2_',num2str(frame_num),'.nii'];
        crop_2_red_image = niftiread(fullfile(crop_2_obj_path,crop_2_obj_name));

        regist_3_obj_name_out = ['obj_regist_3',num2str(frame_num),'.nii'];

        %% apply affine transformation.
        crop_2_obj_image = gpuArray(crop_2_obj_image);
        refer_image = gpuArray(refer_image);
        [Affine_T,regist_3_obj_image] = imregdemons(crop_2_obj_image,refer_image,[500 400 200],'PyramidLevels',3,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
        
        %% write the registed image.
        regist_3_obj_image = gather(regist_3_obj_image);
        niftiwrite(regist_3_obj_image,fullfile(regist_obj_nii_path_3,regist_3_obj_name_out));
        
        % write the MIP of second non-regid registed fish image for check them convenient.
        regist_3_obj_Mip = [max(regist_3_obj_image,[],3) squeeze(max(regist_3_obj_image,[],2));squeeze(max(regist_3_obj_image,[],1))' zeros(size(regist_3_obj_image,3),size(regist_3_obj_image,3))];
        regist_3_obj_Mip = uint16(regist_3_obj_Mip);
        imwrite(regist_3_obj_Mip,fullfile(regist_3_obj_Mip_Path,['regist_obj_MIP_3','_',num2str(frame_num),'.tif']));
        

        disp(['reg_obj_MIP','_',num2str(frame_num),'.tif done!']);
        toc

    end
    
end