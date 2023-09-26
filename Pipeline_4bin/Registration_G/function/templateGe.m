function templateGe(file_path,atlas,num_index,mode)
    %% function summary: Average the all templates to generate the mean template.
    
    %  input:
    %   file_path --- the directory path of templates.
    %   num_index --- the transform between template name number and index.
    %   mode --- 1. Average the nii tempalate 2. Average the mat template.
    
    %  write: write under file_path.
    %   mean_template --- the average template over all templates except false_num templates.
    
    %   update on 2023.2.28.
    
    %% Run.
    % For nii format.
    if mode == 1
        min_score = inf;
        for i = 1:length(num_index)

            % Check if the num_index is empty..
            if isempty(num_index)
                disp('Error, your num_index is empty.')
                break;
            end

            % Ignore the false_num template.
            name_num = num_index(i);
            ObjRecon = niftiread(fullfile(file_path,['template',num2str(name_num),'.nii']));

            ObjRecon = gpuArray(ObjRecon);
            atlas = gpuArray(atlas);
            img_score = imScore(ObjRecon,atlas);
            if img_score < min_score
                min_score = img_score;
                optim_ObjRecon = ObjRecon;
                disp(name_num);
            end

        end

        niftiwrite(gather(optim_ObjRecon),fullfile(file_path,'mean_template.nii'));
        disp([fullfile(file_path,'mean_template.nii'),' done!']);

    else
        if mode == 2
            min_score = inf;
            for i = 1:length(num_index)

                % Check if the num_index is empty..
                if isempty(num_index)
                    disp('Error, your num_index is empty.')
                    break;
                end

                % Ignore the false_num template.
                name_num = num_index(i);
                
                ObjRecon = niftiread(fullfile(file_path,['template',num2str(name_num),'.nii']));
                ObjRecon = gpuArray(ObjRecon);
                atlas = gpuArray(atlas);
                img_score = imScore(ObjRecon,atlas);
                if img_score < min_score
                    min_score = img_score;
                    optim_ObjRecon = ObjRecon;
                    disp(name_num);
                end
            
            end

            niftiwrite(gather(optim_ObjRecon),fullfile(file_path,'mean_template.nii'));
            disp([fullfile(file_path,'mean_template.nii'),' done!']);

        end
    end
    
    
end
    
    
    
    