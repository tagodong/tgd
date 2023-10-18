function cropEyesTemplate(template_path,start_frame,step_size,end_frame,num_index,Mask)
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

    affine_template_path = fullfile(template_path,'affine_template');
    for i = start_frame:step_size:end_frame

        ii = num_index(i);
        disp(['frame ',num2str(ii),' start.']);

        % read the images.
        template_image = niftiread(fullfile(affine_template_path,['Can_template_affine',num2str(ii),'.nii']));

        % run crop.
        template_image=template_image.*Mask;

        % imwrite images.
        template_crop_MIPs_path = fullfile(template_path,'template_eyes_crop_MIPs');
        template_crop_MIPs_name = ['template_eyes_crop_MIP',num2str(ii),'.tif'];
        template_eyes_crop_MIP = [max(template_image,[],3) squeeze(max(template_image,[],2));squeeze(max(template_image,[],1))' zeros(size(template_image,3),size(template_image,3))];
        template_eyes_crop_MIP = uint16(template_eyes_crop_MIP);
        imwrite(template_eyes_crop_MIP,fullfile(template_crop_MIPs_path,template_crop_MIPs_name));
        
        template_crop_path = fullfile(template_path,'template_eyes_crop');
        template_crop_name = ['template_eyes_crop',num2str(ii),'.mat'];
        save(fullfile(template_crop_path,template_crop_name),'template_image');
        
    end
    
end
        