function [CalTrace_save,Coherence]=traceExtract(file_path,pre_name,value_name,seg_regions,water_corMap,info_data,start_frame,batch_size,end_frame,write_flag)
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
    input_extend = '.mat';

    %% Calculate the mean of brain regions as the calcium trace.
    CalTrace = zeros(num_regions,T,"single");
    for ff=start_frame:batch_size:end_frame
        tic;
        Y_r = zeros(num_voxels,min([end_frame,ff+batch_size-1])-ff+1,"single"); % load a batch
        for i=ff:min([end_frame,ff+batch_size-1])
            load(fullfile(file_path,[pre_name,num2str(i),input_extend]),value_name);
            Y_r(:,i-ff+1) = reshape(single(eval(value_name)),[num_voxels,1]);
        end
        for k=1:num_regions
            temp = Y_r(seg_regions(:,k)>0,:);
            CalTrace(k,(ff:min([end_frame,ff+batch_size-1]))-start_frame+1) = mean(temp,1);
        end
        toc;
        disp(ff);
    end
    CalTrace_save = CalTrace;
    disp('CalTrace has been extracted.')

    clear temp;
    clear Y_r;
    
    %% calculate the coherence map
    load(fullfile(file_path,[pre_name,num2str(start_frame),input_extend]),value_name);

    %% normalize CalTrace
    CalTrace = CalTrace - mean(CalTrace,2);
    SD_CalTrace = sqrt(sum(CalTrace.*CalTrace,2)/T);
    SD_CalTrace = repmat(SD_CalTrace, 1,T);
    CalTrace = CalTrace./SD_CalTrace;
    
    %% calculate coherence.
    Coherence = zeros(size(eval(value_name)),"single");
    % [d1,d2,d3] = size(eval(value_name));
    for t=1:T
        load(fullfile(file_path,[pre_name,num2str(t+start_frame-1),input_extend]),value_name);
        temp = zeros(size(Coherence),'single');
        temp(water_corMap~=0) = CalTrace(water_corMap(water_corMap~=0),t);
        
        % temp = zeros(size(Coherence));
        % disp(isgpuarray(temp));
        % for i=1:d1
        %     for j=1:d2
        %         for k=1:d3
        %             if water_corMap(i,j,k)==0
        %                 temp(i,j,k) = 0;
        %             else
        %                 temp(i,j,k) = CalTrace(water_corMap(i,j,k),t);
        %             end
        %         end
        %     end
        % end
        % disp(isgpuarray(temp));
        % disp(sum(temp == temp1,"all"));

        Coherence = Coherence + (single(eval(value_name))-info_data.F_mean).*temp;
    end
    Coherence = Coherence./info_data.SD;
    Coherence = Coherence/T;

    clear eval(value_name);
    
    if write_flag
        save(fullfile(file_path,'Coherence.mat'),'Coherence');
    end
    
    %% Show histogram
    % figure('Name','histogram of Coherence');
    % histogram(Coherence,'Normalization','pdf');

end