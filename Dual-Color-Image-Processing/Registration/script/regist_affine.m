%% This is a parallel script.
% path_g = ;
% path_r = ;
% red_flag = ;

if ~exist('num_cpu','var')
    num_cpu = 10;
end

red_path = fullfile(path_r,'Red_Crop');
green_path = fullfile(path_g,'Green_Crop');
template_path = fullfile(path_g,'..','template');

%% Regist to mean template.
% Set the output green chanel image directory path that is registered.
regist_red_path = fullfile(path_r,'Red_Registration');
regist_green_path = fullfile(path_g,'Green_Registration');

% Set the mean template path.
mean_template = fullfile(template_path,'mean_template.nii');

% Iterate through frames in parallel.
file_name = dir(fullfile(green_path,'Green_Crop_*.nii'));
spmd_num = ceil(length(file_name)/num_cpu);
delete(gcp('nocreate'));
parpool(num_cpu);
spmd
    for i = 1+spmd_num*(spmdIndex-1):1+(spmd_num*spmdIndex-1)
            
        if i <= length(file_name)
            myCMTK(path_g,path_r,red_flag,i-1);
        end

    end

end
disp("All frames processed");