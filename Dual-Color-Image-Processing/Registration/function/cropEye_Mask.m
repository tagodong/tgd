function cropEye_Mask(file_path_red,file_path_green,start_frame,step_size,end_frame,num_index,Mask)
%% function summary: crop the fish eyes using the mask.

%  input:
%   file_path_red/green --- the nii format image directory path of affine registed red/green images.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   num_index --- the transform between template name number and index.
%   mask --- the reference image mask. 

%  write: this function will generate 2 directories under both file_path_red and file_path_green.
%   red/green_crop --- contain eyes cropped red/green image in mat format.
%   red/green_crop_MIPs --- contain the maximum intensity projections in three directions of the eyes cropped images.

%   Update on 2022.12.02.

%% Run.
    for i = start_frame:step_size:end_frame

        ii = num_index(i);
        disp(['frame ',num2str(ii),' start.']);

        % read the images.
        red_image = niftiread(fullfile(file_path_red,['Red_Affine_',num2str(ii),'.nii']));
        green_image = niftiread(fullfile(file_path_green,['Green_Affine_',num2str(ii),'.nii']));

        % Run Mask to crop eyes.
        green_mask_image=green_image.*Mask;
        red_mask_image=red_image.*Mask;

        % imwrite images.
        red_mask_path = fullfile(file_path_red,'Red_Mask');
        red_mask_name = ['Red_Mask_',num2str(ii),'.mat'];
        red_mask_MIP_path = fullfile(file_path_red,'..','..','back_up','Red_Mask_MIP');
        red_mask_MIP_name = ['Red_Mask_MIP_',num2str(ii),'.tif'];
        imageWrite(red_mask_path,red_mask_MIP_path,red_mask_name,red_mask_MIP_name,red_mask_image,1);

        green_mask_path = fullfile(file_path_green,'Green_Mask');
        green_mask_name = ['Green_Mask_',num2str(ii),'.mat'];
        green_mask_MIP_path = fullfile(file_path_green,'..','..','back_up','Green_Mask_MIP');
        green_mask_MIP_name = ['Green_Mask_MIP_',num2str(ii),'.tif'];
        imageWrite(green_mask_path,green_mask_MIP_path,green_mask_name,green_mask_MIP_name,green_mask_image,1);

    end
    
end
    