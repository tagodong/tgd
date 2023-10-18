%% run dual crop for fix fish after reconstruction.
file_pre_Path_Red = '/home/d1/210804_tif/r_210804/r_210804_con/';
file_pre_Path_Green = '/home/d1/210804_tif/g_210804/g_210804_con/';

sub_name = ["00","01","02","03","04","05"];

for i = 1:length(sub_name)

    disp(i);
    file_Path_Red = fullfile(file_pre_Path_Red,sub_name(i));
    delete(fullfile(file_Path_Red,'Red*.nii'));
    file_Path_Green = fullfile(file_pre_Path_Green,sub_name(i));
    delete(fullfile(file_Path_Green,'Green*.nii'));
    if i ~= 6
        dual_Crop_Fix(file_Path_Red,file_Path_Green,1,1,255);
    else
        dual_Crop_Fix(file_Path_Red,file_Path_Green,1,1,156);
    end
    
end