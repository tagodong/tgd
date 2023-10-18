function templateMean(file_path,num_index,false_num,mode)
%% function summary: Average the all templates to generate the mean template.

%  input:
%   file_path --- the directory path of templates.
%   num_index --- the transform between template name number and index.
%   false_num --- the template name number that will be ignored.
%   mode --- 1. Average the nii tempalate 2. Average the mat template.

%  write: write under file_path.
%   mean_template --- the average template over all templates except false_num templates.

%   update on 2023.2.28.

%% Run.
    % For nii format.
    if mode == 1
        num = 0;
        OBJ_sum = 0;

        for i = 1:length(num_index)

            % Check if the num_index is empty..
            if isempty(num_index)
                disp('Error, your num_index is empty.')
                break;
            end

            % Ignore the false_num template.
            name_num = num_index(i);
            if ismember(name_num,false_num)
                continue;
            end

            ObjRecon = niftiread(fullfile(file_path,['template',num2str(name_num),'.nii']));
            OBJ_sum = OBJ_sum +ObjRecon;
            num = num + 1;
            disp(name_num);
        end

        ObjRecon_mean = OBJ_sum./num;
        niftiwrite(ObjRecon_mean,fullfile(file_path,'mean_template.nii'));
        disp([fullfile(file_path,'mean_template.nii.gz'),' done!']);

    else
        if mode == 2
            num = 0;
            OBJ_sum = 0;

            for i = 1:length(num_index)

                % Check if the num_index is empty..
                if isempty(num_index)
                    disp('Error, your num_index is empty.')
                    break;
                end

                % Ignore the false_num template.
                name_num = num_index(i);
                if ismember(name_num,false_num)
                    continue;
                end
                
                % %
                load(fullfile(file_path,['demons_red_3_',num2str(name_num),'.mat']),'red_demons');
                OBJ_sum = OBJ_sum +red_demons;
                num = num + 1;
                disp(name_num);

            end

            ObjRecon = OBJ_sum./num;
            niftiwrite(ObjRecon,fullfile(file_path,'mean_template.nii'));
            disp([fullfile(file_path,'mean_template.nii'),' done!']);

        end
    end


end



