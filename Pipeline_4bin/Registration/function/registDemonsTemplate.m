function registDemonsTemplate(template_path,start_frame,step_size,end_frame,num_index,refer_image)
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
        template_crop_path = fullfile(template_path,'template_eyes_crop');
        template_crop_name = ['template_eyes_crop',num2str(i),'.mat'];
        load(fullfile(template_crop_path,template_crop_name),'template_image');

        % Apply demons transformation.
        template_image = gpuArray(template_image);
        refer_image = gpuArray(refer_image);

        [~,demons_template] = imregdemons(template_image,refer_image,[200 200 150 150 100],'PyramidLevels',5,'AccumulatedFieldSmoothing',3.0,'DisplayWaitbar',false);
        
        % Write the MIP.
        template_demons_MIP = [max(demons_template,[],3) squeeze(max(demons_template,[],2));squeeze(max(demons_template,[],1))' zeros(size(demons_template,3),size(demons_template,3))];
        template_demons_MIP_path = fullfile(template_path,'template_demons_MIPs');
        imwrite(uint16(template_demons_MIP),fullfile(template_demons_MIP_path,['template_demons',num2str(i),'.tif']));
        demons_template = gather(demons_template);
        demons_template_path = fullfile(template_path,'template_demons');
        demons_template_name = ['template_demons',num2str(i),'.nii'];
        niftiwrite(demons_template,fullfile(demons_template_path,demons_template_name));

        disp(['demons_green_3','_',num2str(i),'.tif done!']);
        toc;

    end
    
end