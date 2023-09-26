function crop_Fix_2nd_kx(file_path)

    load('~/EyE_Crop3/Mask0824.mat');

    file_path_regist_1_obj = fullfile(file_path,'regist_obj_nii_1');
    obj_regid_1_nii = dir(fullfile(file_path_regist_1_obj,'*.nii'));

    file_path_crop_2_obj = fullfile(file_path,'crop_obj_nii_2');
    

    if ~exist(file_path_crop_2_obj)
        mkdir(file_path_crop_2_obj);
    end
    
    for ii = 1:length(obj_regid_1_nii)

        filename_in = obj_regid_1_nii(ii).name;
        name_char = split(filename_in,'.');
        name_char = name_char{1};
        name_char = split(name_char,'_');
        name_char = name_char{4};
        frame_num = str2num(name_char);

        disp([num2str(frame_num),' is doing...']);

        obj_image_regist_1st = niftiread(fullfile(file_path_regist_1_obj,['regist_obj_1_',num2str(frame_num),'.nii']));
        
        % run crop.
        obj_image_crop_2nd = obj_image_regist_1st(1:380,:,:);
        
        obj_image_crop_2nd=uint16(double(obj_image_crop_2nd).*Mask);
        
        %% writ nii file.
        crop_2_obj_name_out = ['crop_obj_2_',num2str(frame_num),'.nii'];

        niftiwrite(obj_image_crop_2nd,fullfile(file_path_crop_2_obj,crop_2_obj_name_out));
    
    end
    
end
    