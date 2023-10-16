function [seg_regions, water_corMap, info_data] = rectSegGenerate(file_path, pre_name, value_name, start_frame, end_frame, rect_size)
    %% Generate rect segmentation mask to extract the trace.

     %% Initialize parameters.
     input_extend = '.mat';
     filename_in = [pre_name,num2str(start_frame),input_extend];
     load(fullfile(file_path,filename_in),value_name);
     dx = size(eval(value_name),1);
     dy = size(eval(value_name),2);
     dz = size(eval(value_name),3);
     SD = zeros(dx,dy,dz,'single');
     Y_mean = zeros(dx,dy,dz,'single');
     
     %% First, calculate Y_mean, F_max, F_min
     for i=start_frame+1:end_frame
         filename_in = [pre_name,num2str(i),input_extend];
         load(fullfile(file_path,filename_in),value_name);
         Y_mean = Y_mean + single(eval(value_name));
     end
     Y_mean = Y_mean/(end_frame-start_frame+1);
     disp('calculate Y_mean done.');
     
     %% Second, calculate SD.
     for i=start_frame:end_frame
         filename_in = [pre_name,num2str(i),input_extend];
         load(fullfile(file_path,filename_in),value_name);
         Y_shift = bsxfun(@minus,single(eval(value_name)),Y_mean);
         SD = SD + Y_shift.*Y_shift;
     end
     SD = sqrt(SD/(end_frame-start_frame+1));
     disp('calculate SD done.');
     
     % output some info data for extract red trace more convenient.
     info_data.F_mean = Y_mean;
     info_data.SD = SD;

     %% Compute the segmentation mask.
     water_corMap = zeros(size(eval(value_name)),"uint16");
     region_id = 0;
     for i = 2:rect_size(1):size(water_corMap,1)-rect_size(1)
        for j = 2:rect_size(2):size(water_corMap,2)-rect_size(2)
            for k = 3:rect_size(3):size(water_corMap,3)-rect_size(3)
                region_id = region_id + 1;
                water_corMap(i:i+rect_size(1),j:j+rect_size(2),k:k+rect_size(3)) = region_id;
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