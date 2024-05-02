%% This is a parallel script.
% path_g = ;
% path_r = ;
% red_flag = ;

if ~exist('num_cpu','var')
    num_cpu = 20;
end

red_path = fullfile(path_r,'Red_Crop');
template_path = fullfile(path_g,'..','back_up','template');

if fix_flag == 1
    green_path = fullfile(path_g,'Green_Crop');
    file_name = dir(fullfile(green_path,'Green_Crop_*.nii'));
    else 
        if fix_flag ==0
            green_path = fullfile(path_g,'Green_Crop','G2R');
            file_name = dir(fullfile(green_path,'Green_Crop_G2R_*.nii'));
        end
end


% Iterate through frames in parallel.

spmd_num = ceil(length(file_name)/num_cpu);
delete(gcp('nocreate'));
parpool(num_cpu);
spmd
    for i = 1+spmd_num*(spmdIndex-1):1+(spmd_num*spmdIndex-1)
            
        if i <= length(file_name)

            image_name = file_name(i).name;
            image_name = split(image_name,'_');
            image_name = image_name{4};
            num_index=isstrprop(image_name,'digit');
            num = str2double(image_name(num_index));

            % if exist(fullfile(path_g,'Green_Registration',['Green_Affine_',num2str(num),'.nii']),"file")
            %     continue;
            % end

            myCMTK(path_g,path_r,red_flag,fix_flag,num,2,red_have);
        end

    end

end
disp("All frames processed");