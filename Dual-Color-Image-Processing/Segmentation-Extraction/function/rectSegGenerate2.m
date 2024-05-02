function [seg_regions, water_corMap, info_data] = rectSegGenerate2(file_path,pre_name,start_frame,end_frame,rect_size,name_num)
    %% Generate rect segmentation mask to extract the trace.

     %% Initialize parameters.
     input_extend = '.nii';
     filename_in = [pre_name,num2str(name_num(start_frame)),input_extend];
     ObjRecon = niftiread(fullfile(file_path,filename_in));
     dx = size(ObjRecon,1);
     dy = size(ObjRecon,2);
     dz = size(ObjRecon,3);
     SD = zeros(dx,dy,dz,'single');
     Y_mean = zeros(dx,dy,dz,'single');
     
     %% First, calculate Y_mean, F_max, F_min
     for j=start_frame+1:end_frame
        i = name_num(j);
        filename_in = [pre_name,num2str(i),input_extend];
        ObjRecon = niftiread(fullfile(file_path,filename_in));
        Y_mean = Y_mean + single(ObjRecon);
     end
     Y_mean = Y_mean/(end_frame-start_frame+1);
     disp('calculate Y_mean done.');
     
     %% Second, calculate SD.
     for j=start_frame:end_frame
        i = name_num(j);
        filename_in = [pre_name,num2str(i),input_extend];
        ObjRecon = niftiread(fullfile(file_path,filename_in));
        Y_shift = bsxfun(@minus,single(ObjRecon),Y_mean);
        SD = SD + Y_shift.*Y_shift;
     end
     SD = sqrt(SD/(end_frame-start_frame+1));
     disp('calculate SD done.');
     
     % output some info data for extract red trace more convenient.
     info_data.F_mean = Y_mean;
     info_data.SD = SD;

     %% Compute the segmentation mask.
     water_corMap = zeros(size(ObjRecon),"uint16");
     region_id = 0;
     for i = 2:rect_size(1):size(water_corMap,1)-rect_size(1)
        for j = 2:rect_size(2):size(water_corMap,2)-rect_size(2)
            for k = 3:rect_size(3):size(water_corMap,3)-rect_size(3)
                region_id = region_id + 1;
                water_corMap(i:i+rect_size(1)-1,j:j+rect_size(2)-1,k:k+rect_size(3)-1) = region_id;
            end
        end
     end

     num_components_keep = max(water_corMap(:));
     seg_regions = sparse(dx*dy*dz,num_components_keep);
     for k=1:num_components_keep
         temp  = water_corMap==k;
         seg_regions(:,k) = sparse(reshape(temp,[dx*dy*dz,1]));
     end
     disp('Segmentation done.')
end