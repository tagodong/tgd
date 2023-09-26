function regid_Fix_1st_kx(file_Path)
    %% function summary: regist the fish using affine motion according to refer fish.
    %  input:
    %   file_Path_Red --- the directory path of red fish.
    %   file_Path_Green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   reg_green/red_MIPs_1 --- the MIP directory of registed red/green fish.
    %   reg_green/red_nii_1 --- the nii directory of registed red fish.

    %   2022.12.02 by tgd.
    % parallel.gpu.enableCUDAForwardCompatibility(true);
    % gpuDevice(gpu_index);
    %% read the reference image

    refer_image = niftiread('/home/d2/Ref-zbb2.nii');

    reg_obj_Mip_Path_1 = fullfile(file_Path,'regist_obj_MIPs_1');

    reg_obj_nii_path_1 = fullfile(file_Path,'regist_obj_nii_1');

    nii_path = fullfile(file_Path);
    obj_nii = dir(fullfile(nii_path,'*.nii'));

    if ~exist(reg_obj_Mip_Path_1)
        mkdir(reg_obj_Mip_Path_1);
        mkdir(reg_obj_nii_path_1);
    end

    %% regist run.
    for i = 1:length(obj_nii)

        filename_in = obj_nii(i).name;
        name_char = split(filename_in,'.');
        name_char = name_char{1};
        frame_num = str2num(name_char(4:end));

        disp([num2str(frame_num),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        obj_name = ['Obj',num2str(frame_num),'.nii'];
        obj_image = niftiread(fullfile(file_Path,obj_name));
        
        obj_Filename_Out_1 = ['regist_obj_1_',num2str(frame_num),'.nii'];

        % apply regid transformation firstly.
        [optimizer,metric] = imregconfig('Monomodal');
        rigid_tform = imregtform(obj_image, refer_image,'rigid', optimizer, metric);
        SameAsInput = affineOutputView(size(obj_image),rigid_tform,'BoundsStyle','SameAsInput');
        obj_regid_1st = imwarp(obj_image,rigid_tform,'linear','OutputView',SameAsInput);

        %% apply affine transformation.
        % red_image = gpuArray(red_image);
        % refer_image = gpuArray(refer_image);
        % green_image = gpuArray(green_image);
        
        %% write the registed image.
        % reg_red_image = gather(reg_red_image);
        % reg_green_image = gather(reg_green_image);
        niftiwrite(obj_regid_1st,fullfile(reg_obj_nii_path_1,obj_Filename_Out_1));
        
        % 1. write the MIP of fisrt regid registed fish image for check them convenient.
        reg_obj_Mip = [max(obj_regid_1st,[],3) squeeze(max(obj_regid_1st,[],2));squeeze(max(obj_regid_1st,[],1))' zeros(size(obj_regid_1st,3),size(obj_regid_1st,3))];
        reg_obj_Mip = uint16(reg_obj_Mip);
        imwrite(reg_obj_Mip,fullfile(reg_obj_Mip_Path_1,['regist_obj_MIP_1','_',num2str(frame_num),'.tif']));
        
        disp(['regist_obj_MIP','_',num2str(i),'.tif done!']);
        toc;
    end
    
end