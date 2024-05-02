function [CalTrace_save]=traceExtract_rect(file_path,pre_name,seg_regions,start_frame,end_frame,name_num)
    %% function summary: extract calcium traces and calculate coherence.
    
    %  input:
    %   file_path --- the mat format image directory path.
    %   pre_name --- the prefix name of image.
    %   value_name --- the name of value in the image.
    %   seg_regions --- segmented regions.
    %   water_corMap --- the segmen.
    %   info_data --- contain F_mean: the mean of all images and SD: the standard of all images.
    %   start_frame, batch_size and end_frame --- the number of start frame, batch size and end frame.
    %   write_flag --- 1: save the water_corMap_filter. 2: don't save.
    
    %  output: 
    %   CalTrace --- Extracted calcium trace.
    %   Coherence --- Coherence of segmented regions.
    
        %% Initialize parameters
        num_voxels = size(seg_regions,1);
        num_regions = size(seg_regions,2);
        T = end_frame - start_frame + 1;
        input_extend = '.nii';
    
        %% Calculate the mean of brain regions as the calcium trace.
        CalTrace = zeros(num_regions,T,"single");
        for f=start_frame:end_frame
            ff = name_num(f);
            tic;
            ObjRecon = niftiread(fullfile(file_path,[pre_name,num2str(ff),input_extend]));
            Y_r = reshape(single(ObjRecon),[num_voxels,1]);

            for k=1:num_regions
                temp = Y_r(seg_regions(:,k)>0,:);
                CalTrace(k,f-start_frame+1) = mean(temp,1);
            end
            toc;
            disp(ff);
        end
        CalTrace_save = CalTrace;
        disp('CalTrace has been extracted.');
    
    end