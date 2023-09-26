function cropEye_Unet(file_path_red,file_path_green,start_frame,step_size,end_frame,num_index,net)
    %% function summary: crop the fish eyes using the mask.
    
    %  input:
    %   file_path_red/green --- the nii format image directory path of affine registed red/green images.
    %   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
    %   num_index --- the transform between template name number and index.
    %   net --- the unet. 
    
    %  write: this function will generate 2 directories under both file_path_red and file_path_green.
    %   red/green_crop --- contain eyes cropped red/green image in mat format.
    %   red/green_crop_MIPs --- contain the maximum intensity projections in three directions of the eyes cropped images.
    
    %   Update on 2022.12.02.
    
    %% Run.
        for i = start_frame:step_size:end_frame
    
            ii = num_index(i);
            disp(['frame ',num2str(ii),' start.']);
    
            % read the images.
            red_image = niftiread(fullfile(file_path_red,['regist_red_1_',num2str(ii),'.nii']));
            green_image = niftiread(fullfile(file_path_green,['regist_green_1_',num2str(ii),'.nii']));
            
            % run crop.
            red_image_resize = imresize3(red_image, [200,152,104]);
            green_image_resize = imresize3(green_image, [200,152,104]);
            [Crop_Mask,~] = semanticseg(red_image_resize,net,'MiniBatchSize',1);
            Crop_Mask = uint16(Crop_Mask) - 1;

            % apply Mask
            red_image_crop = red_image_resize.*Crop_Mask;
            green_image_crop = green_image_resize.*Crop_Mask;

            % resize to normal
            red_image_crop_resize = imresize3(red_image_crop, size(red_image));
            green_image_crop_resize = imresize3(green_image_crop, size(red_image));

            red_crop_image = uint16(red_image_crop_resize(1:380,:,:));
            green_crop_image = uint16(green_image_crop_resize(1:380,:,:));
    
            % imwrite images.
            red_crop_path = fullfile(file_path_red,'red_crop');
            red_crop_name = ['crop_red_2_',num2str(ii),'.mat'];
            save(fullfile(red_crop_path,red_crop_name),'red_crop_image');
            red_crop_MIPs_path = fullfile(file_path_red,'red_crop_MIPs');
            red_crop_MIPs_name = ['crop_red_2_MIP_',num2str(ii),'.tif'];
            green_crop_MIP = [max(red_crop_image,[],3) squeeze(max(red_crop_image,[],2));squeeze(max(red_crop_image,[],1))' zeros(size(red_crop_image,3),size(red_crop_image,3))];
            green_crop_MIP = uint16(green_crop_MIP);
            imwrite(green_crop_MIP,fullfile(red_crop_MIPs_path,red_crop_MIPs_name));
            
            green_crop_name = ['crop_green_2_',num2str(ii),'.mat'];
            green_crop_path = fullfile(file_path_green,'green_crop');
            save(fullfile(green_crop_path,green_crop_name),'green_crop_image');
            green_crop_MIPs_path = fullfile(file_path_green,'green_crop_MIPs');
            green_crop_MIPs_name = ['crop_green_2_MIP_',num2str(ii),'.tif'];
            green_crop_MIP = [max(green_crop_image,[],3) squeeze(max(green_crop_image,[],2));squeeze(max(green_crop_image,[],1))' zeros(size(green_crop_image,3),size(green_crop_image,3))];
            green_crop_MIP = uint16(green_crop_MIP);
            imwrite(green_crop_MIP,fullfile(green_crop_MIPs_path,green_crop_MIPs_name));
    
        end
        
    end
        