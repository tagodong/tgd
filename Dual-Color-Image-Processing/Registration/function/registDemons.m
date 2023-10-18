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
        disp(['frame ',num2str(i),' start.']);

        % Read image.
        red_mask_path = fullfile(file_path_red,'Red_Mask');
        red_mask_name = ['Red_Mask_',num2str(i),'.mat'];
        load(fullfile(red_mask_path,red_mask_name),'ObjRecon');
        red_mask_image = ObjRecon;

        green_mask_path = fullfile(file_path_green,'Green_Mask');
        green_mask_name = ['Green_Mask_',num2str(i),'.mat'];
        load(fullfile(green_mask_path,green_mask_name),'ObjRecon');
        green_mask_image = ObjRecon;

        % apply affine transformation.
        red_mask_image = gpuArray(red_mask_image);
        refer_image = gpuArray(refer_image);
        green_mask_image = gpuArray(green_mask_image);

        if red_flag

            [D,red_demons] = imregdemons(red_mask_image,refer_image,[500 500 400 200],'PyramidLevels',4,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
            green_demons = imwarp(green_mask_image,D,'linear');

        else
            [D,green_demons] = imregdemons(green_mask_image,refer_image,[500 500 400 200],'PyramidLevels',4,'AccumulatedFieldSmoothing',2.5,'DisplayWaitbar',false);
            red_demons = imwarp(red_mask_image,D,'linear');

        end
        
        % Save the results.
        red_demons = gather(red_demons);
        green_demons = gather(green_demons);

        red_demons_path = fullfile(file_path_red,'Red_Demons');
        red_demons_MIPs_path = fullfile(file_path_red,'..','..','back_up','Red_Demons_MIP');
        red_demons_name = ['Red_Demons_',num2str(i),'.mat'];
        red_demons_MIPs_name = ['Red_Demons_MIP_',num2str(i),'.tif'];
        imageWrite(red_demons_path,red_demons_MIPs_path,red_demons_name,red_demons_MIPs_name,red_demons,1);

        green_demons_path = fullfile(file_path_green,'Green_Demons');
        green_demons_MIPs_path = fullfile(file_path_green,'..','..','back_up','Green_Demons_MIP');
        green_demons_name = ['Green_Demons_',num2str(i),'.mat'];
        green_demons_MIPs_name = ['Green_Demons_MIP_',num2str(i),'.tif'];
        imageWrite(green_demons_path,green_demons_MIPs_path,green_demons_name,green_demons_MIPs_name,green_demons,1);

        disp(['Green_Demons','_',num2str(i),'.tif done!']);
        toc;

    end
    
end