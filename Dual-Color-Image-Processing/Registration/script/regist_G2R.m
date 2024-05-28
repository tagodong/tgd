%% This is a parallel script.
% path_g = ;
% path_r = ;
% red_flag = ;

if ~exist('num_cpu','var')
    num_cpu = 20;
end

green_path="/home/d2/Learn/0304/back_up/Green_Crop";
file_name = dir(fullfile(green_path,'Green_Crop_*.nii'));

red_path = fullfile(path_r,'Red_Crop');
green_path = fullfile(path_g,'Green_Crop');

mkdir(fullfile(path_g,'Green_Crop','G2R'));

% Iterate through frames in parallel.

spmd_num = ceil(length(file_name)/num_cpu);
delete(gcp('nocreate'));
parpool(num_cpu);
spmd
    for i = 1+spmd_num*(spmdIndex-1):1+(spmd_num*spmdIndex-1)
            
        if i <= length(file_name)

            image_name = file_name(i).name;
            num_index=isstrprop(image_name,'digit');
            num = str2double(image_name(num_index));

            if exist(fullfile(path_g,'Green_Crop','G2R',['Green_Crop_G2R_',num2str(num),'.nii']),"file")
                continue;
            end

            myCMTK(path_g,path_r,red_flag,0,num,1,1);
        end

    end

end
disp("All frames processed");