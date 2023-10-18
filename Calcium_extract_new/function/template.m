function template(filepath,startframe,step,endframe,mod,num_flag,false_num)
    %% function summary: Average the all templates.
    %  input:
    %   filepath --- the directory path of templates.
    %   startFrame --- the first frame number.
    %   stepSize --- the step size of frame number.
    %   endFrame --- the end of frame number.
    %   mod --- mod: 1. Average the nii tempalate 2. Average the mat template.

    %   output: in the file_Path_Red and file_Path_Green directory.
    %   mean_template_1 --- the average template for nii template.
    %   mean_template_2 --- the average template for mat template.

    %   2023.2.28 by tgd.
    if nargin==5
        num_flag = startframe:step:endframe;
    end
    if mod == 1
        num = 0;
        OBJ_sum = 0;
        for ii = startframe:step:endframe
    
            i = num_flag(ii);

            if ~sum(i==false_num)
                continue;
            end
            ObjRecon = niftiread(fullfile(filepath,['regist_red_1_',num2str(i),'.nii']));
            OBJ_sum = OBJ_sum +ObjRecon;
            num = num + 1;
            disp(i);
        end
        ObjRecon = OBJ_sum./num;
        niftiwrite(ObjRecon,fullfile(filepath,'mean_template_1.nii'));

        disp([fullfile(filepath,'mean_template_1.nii'),' done!']);
    else
        if mod == 2
            num = 0;
            OBJ_sum = 0;
            for ii = startframe:step:endframe
                if ~isempty(num_flag)
                    i=num_flag(ii);
                end

                if ~sum(i==false_num)
                    continue;
                end
                
                load(fullfile(filepath,['red_regist_3_',num2str(i),'.mat']),'regist_3_red_image');
                OBJ_sum = OBJ_sum +regist_3_red_image;
                num = num + 1;
        
            end
            ObjRecon = OBJ_sum./num;
            niftiwrite(ObjRecon,fullfile(filepath,'mean_template_2.nii'));

            disp([fullfile(filepath,'mean_template_2.nii'),' done!']);

        end
    end


end



