function regid_Fix_1st(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame)
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

    reg_red_Mip_Path_1 = fullfile(file_Path_Red,'regist_red_MIPs_1');
    reg_green_Mip_Path_1 = fullfile(file_Path_Green,'regist_green_MIPs_1');
 
    reg_green_nii_path_1 = fullfile(file_Path_Green,'regist_green_nii_1');
    reg_red_nii_path_1 = fullfile(file_Path_Red,'regist_red_nii_1');

    %% regist run.
    for i = startFrame:stepSize:endFrame

        disp([num2str(i),' is doing...']);

        tic;
        %% nifread the nii image stacks.
        red_name = ['Red',num2str(i),'.nii'];
        red_image = niftiread(fullfile(file_Path_Red,red_name));
        green_name = ['Green',num2str(i),'.nii'];
        green_image = niftiread(fullfile(file_Path_Green,green_name));
        
        red_Filename_Out_1 = ['regist_red_nii_1_',num2str(i),'.nii'];
        green_Filename_Out_1 = ['regist_green_nii_1_',num2str(i),'.nii'];

        % apply regid transformation firstly.
        [optimizer,metric] = imregconfig('Monomodal');
        rigid_tform = imregtform(red_image, refer_image,'rigid', optimizer, metric);
        SameAsInput = affineOutputView(size(red_image),rigid_tform,'BoundsStyle','SameAsInput');
        Red_regid_1st = imwarp(red_image,rigid_tform,'linear','OutputView',SameAsInput);
        Green_regid_1st = imwarp(green_image,rigid_tform,'linear','OutputView',SameAsInput);

        %% apply affine transformation.
        % red_image = gpuArray(red_image);
        % refer_image = gpuArray(refer_image);
        % green_image = gpuArray(green_image);
        
        %% write the registed image.
        % reg_red_image = gather(reg_red_image);
        % reg_green_image = gather(reg_green_image);
        niftiwrite(Red_regid_1st,fullfile(reg_red_nii_path_1,red_Filename_Out_1));
        niftiwrite(Green_regid_1st,fullfile(reg_green_nii_path_1,green_Filename_Out_1));
        
        % 1. write the MIP of fisrt regid registed fish image for check them convenient.
        reg_Red_Mip = [max(Red_regid_1st,[],3) squeeze(max(Red_regid_1st,[],2));squeeze(max(Red_regid_1st,[],1))' zeros(size(Red_regid_1st,3),size(Red_regid_1st,3))];
        reg_Red_Mip = uint16(reg_Red_Mip);
        imwrite(reg_Red_Mip,fullfile(reg_red_Mip_Path_1,['regist_red_MIPs_1','_',num2str(i),'.tif']));
        
        reg_Green_Mip = [max(Green_regid_1st,[],3) squeeze(max(Green_regid_1st,[],2));squeeze(max(Green_regid_1st,[],1))' zeros(size(Green_regid_1st,3),size(Green_regid_1st,3))];
        reg_Green_Mip = uint16(reg_Green_Mip);
        imwrite(reg_Green_Mip,fullfile(reg_green_Mip_Path_1,['regist_green_MIPs_1','_',num2str(i),'.tif']));
        
        disp(['regist_green_MIP','_',num2str(i),'.tif done!']);
        toc;
    end
    
end