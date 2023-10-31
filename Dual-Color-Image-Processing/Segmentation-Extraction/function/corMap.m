function [CalTrace,Coherence,seg_regions,water_corMap_filter,info_data] = corMap(file_path,pre_name,value_name,start_frame,end_frame,name_num,ad_dist,thresh,min_size)
    %% function summary: Segment brain regions using Correlation Map.
    
    %  input:
    %   file_path --- the mat format image directory path.
    %   pre_name --- the prefix name of image.
    %   value_name --- the name of value in the image.
    %   start_frame, end_frame --- the number of start frame and end frame.
    %   ad_dist --- 
    %   thresh --- a struct which contain the max and min intensity threshold.
    %   min_size --- the minimum size of segmented regions. 
    
    %  output: 
    %   CalTrace --- Extracted calcium trace and was saved under file_path.
    %   Coherence --- Coherence of segmented regions.
    %   This function will also generate the segmented regions map in tif format.
    
    %% Initialize parameters.
    coord_shift = round(sqrt(ad_dist^2/3));
    input_extend = '.mat';
    filename_in = [pre_name,num2str(name_num(start_frame)),input_extend];
    load(fullfile(file_path,filename_in),value_name);
    dx = size(eval(value_name),1);
    dy = size(eval(value_name),2);
    dz = size(eval(value_name),3);
    Corr = zeros(dx,dy,dz,'single');
    SD = zeros(dx,dy,dz,'single');
    Y_mean = zeros(dx,dy,dz,'single');
    F_max = zeros(dx,dy,dz,'single');
    F_min = single(eval(value_name));
    
    %% First, calculate Y_mean, F_max, F_min
    for j=start_frame+1:end_frame
        i = name_num(j);
        filename_in = [pre_name,num2str(i),input_extend];
        load(fullfile(file_path,filename_in),value_name);
        Y_mean = Y_mean + single(eval(value_name));
        clear temp;
        temp(:,:,:,1) = single(eval(value_name));
        temp(:,:,:,2) = F_max;
        F_max = squeeze(max(temp,[],4));
        temp(:,:,:,2) = F_min;
        F_min = squeeze(min(temp,[],4));
    end
    Y_mean = Y_mean/(end_frame-start_frame+1);
    Y_mean(F_max<thresh.max) = 0; % mask by thresh.max
    Y_mean(F_min<thresh.min) = 0; % mask by thresh.min
    disp('calculate Y_mean, F_max, F_min done.');
    
    %% Second, calculate SD.
    for j=start_frame:end_frame
        i = name_num(j);
        filename_in = [pre_name,num2str(i),input_extend];
        load(fullfile(file_path,filename_in),value_name);
        Y_shift = bsxfun(@minus,single(eval(value_name)),Y_mean);
        SD = SD + Y_shift.*Y_shift;
    end
    SD = sqrt(SD/(end_frame-start_frame+1));
    SD(F_max<thresh.max) = 0; % mask by thresh.max
    SD(F_min<thresh.min) = 0; % mask by thresh.min
    disp('calculate SD done.');
    
    % output some info data for extract red trace more convenient.
    info_data.F_mean = Y_mean;
    info_data.SD = SD;
    
    %% Third, calculate Corr,
    for j=start_frame:end_frame
        n = name_num(j);
        filename_in = [pre_name,num2str(n),input_extend];
        load(fullfile(file_path,filename_in),value_name);
        Y_shift = bsxfun(@minus,single(eval(value_name)),Y_mean);
        Y_shift = Y_shift./SD;
        Y_shift(SD==0) = 0;
        Y_shift(F_max<thresh.max) = 0; % mask by thresh.max
        Y_shift(F_min<thresh.min) = 0; % mask by thresh.min
        for i=1+ad_dist:dx-ad_dist
            for j=1+ad_dist:dy-ad_dist
                for k=1+ad_dist:dz-ad_dist
                    temp = Y_shift(i-ad_dist, j, k) + Y_shift(i+ad_dist, j, k) + Y_shift(i, j-ad_dist, k) + Y_shift(i, j+ad_dist, k) + Y_shift(i, j, k-ad_dist) + Y_shift(i, j, k+ad_dist);
                    temp = temp + Y_shift(i+coord_shift, j+coord_shift, k+coord_shift) + Y_shift(i-coord_shift, j+coord_shift, k+coord_shift);
                    temp = temp + Y_shift(i+coord_shift, j-coord_shift, k+coord_shift) + Y_shift(i-coord_shift, j-coord_shift, k+coord_shift);
                    temp = temp + Y_shift(i+coord_shift, j+coord_shift, k-coord_shift) + Y_shift(i-coord_shift, j+coord_shift, k-coord_shift);
                    temp = temp + Y_shift(i+coord_shift, j-coord_shift, k-coord_shift) + Y_shift(i-coord_shift, j-coord_shift, k-coord_shift);
                    Corr(i,j,k) = Corr(i,j,k) + temp*Y_shift(i,j,k);
                end
            end
        end
    end
    
    % Only select 14 points.
    Corr = Corr/(end_frame-start_frame+1)/14;
    clear Y_shift;
    clear eval(value_name);
    min_Corr = min(Corr(:));
    max_Corr = max(Corr(:));
    Corr = (Corr-min_Corr)/(max_Corr-min_Corr);
    disp('Calculate correlation done.');
    
    % Segment the Correlation Map using watershed.
    water_corMap = watershed(1-Corr);
    water_corMap(F_max<thresh.max) = 0;
    water_corMap(F_min<thresh.min) = 0;
    water_corMap = bwareaopen(water_corMap,min_size,6);
    water_corMap = bwlabeln(gather(water_corMap),6);
    num_components_keep = max(water_corMap(:));
    seg_regions = sparse(dx*dy*dz,num_components_keep);
    for k=1:num_components_keep
        temp  = water_corMap==k;
        seg_regions(:,k) = sparse(reshape(temp,[dx*dy*dz,1]));
    end
    
    clear Corr;
    clear F_max;
    clear F_min;
    clear temp;
    
    disp('Segmentation done.');
    
    %% extract Calcium traces
    % set the batchsize.
    batch_size = 1;
    [~,Coherence] = traceExtract(file_path,pre_name,value_name,seg_regions,water_corMap,info_data,start_frame,batch_size,end_frame,name_num);
    disp('First extraction done.');
    
    %% Filter regions according to Coherence thresh.
    % set Coherence threshold.
    thresh_Coherence = 0.5;
    
    % if save the water_corMap_filter.

    [seg_regions,water_corMap_filter] = coherenceFilter(Coherence,water_corMap,min_size,thresh_Coherence);
    disp('water_corMap_filter done.');
    
    %% extract Calcium traces again.
    % set the batchsize.
    batch_size = 1;
    [CalTrace,Coherence] = traceExtract(file_path,pre_name,value_name,seg_regions,water_corMap_filter,info_data,start_frame,batch_size,end_frame,name_num);
    disp('Second extraction done.');
    
end