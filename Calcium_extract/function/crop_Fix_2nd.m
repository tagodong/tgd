function crop_Fix_2nd(file_path_red,file_path_green,startFrame,stepSize,endFrame)

    load('~/EyE_Crop3/Mask0824.mat');
    
    for ii = startFrame:stepSize:endFrame
    
        disp(ii);

        file_path_regist_1_green = fullfile(file_path_green,'regist_green_nii_1');
        file_path_regist_1_red = fullfile(file_path_red,'regist_red_nii_1');

        red_image_regist_1st = niftiread(fullfile(file_path_regist_1_red,['regist_red_1_',num2str(ii),'.nii']));
        green_image_regist_1st = niftiread(fullfile(file_path_regist_1_green,['regist_green_1_',num2str(ii),'.nii']));
        
        % run crop.
        red_image_crop_2nd = red_image_regist_1st(1:380,:,:);
        green_image_crop_2nd = green_image_regist_1st(1:380,:,:);
        
        red_image_crop_2nd=uint16(double(red_image_crop_2nd).*Mask);
        green_image_crop_2nd=uint16(double(green_image_crop_2nd).*Mask);
        
        %% writ nii file.
        file_path_crop_2_red = fullfile(file_path_red,'crop_red_nii_2');
        file_path_crop_2_green = fullfile(file_path_green,'crop_green_nii_2');

        crop_2_red_name_out = ['crop_red_2_',num2str(ii),'.nii'];
        crop_2_green_name_out = ['crop_green_2_',num2str(ii),'.nii'];

        niftiwrite(red_image_crop_2nd,fullfile(file_path_crop_2_red,crop_2_red_name_out));
        niftiwrite(green_image_crop_2nd,fullfile(file_path_crop_2_green,crop_2_green_name_out));
    
    end
    
end
    