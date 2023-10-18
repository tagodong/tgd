function crop_Fix_2nd(file_path_red,file_path_green,startFrame,stepSize,endFrame)
    %% function summary: crop the fish eyes using the mask.
    %  input:
    %   file_path_red --- the directory path of red fish.
    %   file_path_green --- the directory path of green fish.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    
    %   output: in the file_Path_Red and file_Path_Green directory.
    %   crop_red/green_mat_2 --- the mat directory of croped red/green fish.

    %   2022.12.02 by tgd.


    load('~/EyE_Crop3/Mask0824.mat','Mask');
    
    for ii = startFrame:stepSize:endFrame

        crop_2_green_name_out = ['crop_green_2_',num2str(ii),'.mat'];
        file_path_crop_2_green = fullfile(file_path_green,'crop_green_mat_2');

        if ~exist(fullfile(file_path_red,['regist_red_1_',num2str(ii),'.nii']),"file")
            continue;
        end

        disp(ii);

        % file_path_regist_1_green = fullfile(file_path_green,'regist_green_nii_1');
        % file_path_regist_1_red = fullfile(file_path_red,'regist_red_nii_1');

        red_image_regist_1st = niftiread(fullfile(file_path_red,['regist_red_1_',num2str(ii),'.nii']));
        green_image_regist_1st = niftiread(fullfile(file_path_green,['regist_green_1_',num2str(ii),'.nii']));
        
        % run crop.
        red_image_crop_2nd = red_image_regist_1st(1:380,:,:);
        green_image_crop_2nd = green_image_regist_1st(1:380,:,:);
        
        red_image_crop_2nd=uint16(double(red_image_crop_2nd).*Mask);
        green_image_crop_2nd=uint16(double(green_image_crop_2nd).*Mask);
        
        %% save mat file.
        file_path_crop_2_red = fullfile(file_path_red,'crop_red_mat_2');
        

        crop_2_red_name_out = ['crop_red_2_',num2str(ii),'.mat'];

        save(fullfile(file_path_crop_2_red,crop_2_red_name_out),'red_image_crop_2nd');
        save(fullfile(file_path_crop_2_green,crop_2_green_name_out),'green_image_crop_2nd');
    
    end
    
end
    