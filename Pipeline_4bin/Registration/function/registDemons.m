function registDemons(file_path_red,file_path_green,red_flag,start_frame,step_size,end_frame,num_index,refer_image)
%% function summary: muti thread regist the fish image using demons method.

%  input:
%   file_path_red/green --- the nii format image directory path of affine registed red/green images.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   num_index --- the transform between template name number and index.
%   refer_image --- template.

%  write: this function will generate 2 directories under both file_path_red and file_path_green.
%   red/green_demons --- contain demon registed red/green images in mat format.
%   red/green_demons_MIPs --- contain the maximum intensity projections in three directions of the demon registed images.

%   Update on 2022.12.02.

%% Run.
    for ii = start_frame:step_size:end_frame

        tic;
        i = num_index(ii);
        if i < 6374 || i>9322
            continue;
            % red_flag = 1;
        end
        disp(['frame ',num2str(i),' start.']);

        % Read image.
        red_crop_path = fullfile(file_path_red,'red_eyes_crop');
        red_crop_name = ['red_eyes_crop_',num2str(i),'.mat'];
        load(fullfile(red_crop_path,red_crop_name),'red_crop_image');

        green_crop_path = fullfile(file_path_green,'green_eyes_crop');
        green_crop_name = ['green_eyes_crop_',num2str(i),'.mat'];
        load(fullfile(green_crop_path,green_crop_name),'green_crop_image');

        % apply affine transformation.
        red_crop_image = gpuArray(red_crop_image);
        refer_image = gpuArray(refer_image);
        green_crop_image = gpuArray(green_crop_image);

        if red_flag
            [D,red_demons] = imregdemons(red_crop_image,refer_image,[200 200 150 150 100],'PyramidLevels',5,'AccumulatedFieldSmoothing',3.0,'DisplayWaitbar',false);
            green_demons = imwarp(green_crop_image,D,'linear');

        else
            [D,green_demons] = imregdemons(green_crop_image,refer_image,[200 200 150 150 100],'PyramidLevels',5,'AccumulatedFieldSmoothing',3.0,'DisplayWaitbar',false);
            red_demons = imwarp(red_crop_image,D,'linear');
        end
        
        % write the MIP.
        red_demons_MIP = [max(red_demons,[],3) squeeze(max(red_demons,[],2));squeeze(max(red_demons,[],1))' zeros(size(red_demons,3),size(red_demons,3))];
        red_demons_MIP = uint16(red_demons_MIP);
        red_demons_MIP_path = fullfile(file_path_red,'red_demons_MIPs');
        imwrite(red_demons_MIP,fullfile(red_demons_MIP_path,['demons_red_3','_',num2str(i),'.tif']));
        green_demons_MIP = [max(green_demons,[],3) squeeze(max(green_demons,[],2));squeeze(max(green_demons,[],1))' zeros(size(green_demons,3),size(green_demons,3))];
        green_demons_MIP = uint16(green_demons_MIP);
        green_demons_MIP_path = fullfile(file_path_green,'green_demons_MIPs');
        imwrite(green_demons_MIP,fullfile(green_demons_MIP_path,['demons_green_3','_',num2str(i),'.tif']));

        % write the registed image.
        red_demons = gather(red_demons);
        green_demons = gather(green_demons);
        red_demons_path = fullfile(file_path_red,'red_demons');
        green_demons_path = fullfile(file_path_green,'green_demons');
        red_demons_name = ['demons_red_3_',num2str(i),'.mat'];
        green_demons_name = ['demons_green_3_',num2str(i),'.mat'];
        save(fullfile(red_demons_path,red_demons_name),'red_demons');
        save(fullfile(green_demons_path,green_demons_name),'green_demons');

        disp(['demons_green_3','_',num2str(i),'.tif done!']);
        toc;

    end
    
end