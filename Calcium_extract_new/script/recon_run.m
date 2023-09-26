for i =1:1
    if i==1
        file_Path_Red = '/home/d1/221207/new/R/';
        file_Path_Green = '/home/d1/221207/new/G';
        PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';
        PSF_path_green = '/home/d1/Seizure221211/PSF/PSFg221009.mat';
        load('~/EyE_Crop3/0924Fit.mat');
        len = length(dir('/home/d1/221207/new/R/*.tif'));
        reConstruction(file_Path_Red,file_Path_Green,PSF_path_red,PSF_path_green,1,1,len,tform);
    else
        if i==2
            file_Path_Red = '/home/d1/221207/221207_28814/R/';
            file_Path_Green = '/home/d1/221207/221207_28814/G';
            PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';
            PSF_path_green = '/home/d1/Seizure221211/PSF/PSFg221009.mat';
            load('~/EyE_Crop3/0924Fit.mat');
            len = length(dir(fullfile(file_Path_Red,'*.tif')));
            reConstruction(file_Path_Red,file_Path_Green,PSF_path_red,PSF_path_green,1,1,len,tform);
        else
            file_Path_Red = '/home/d2/20230416_1744_g8s-lssm-chriR_5dpf/r03';
            file_Path_Green = '/home/d2/20230416_1744_g8s-lssm-chriR_5dpf/g03';
            PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';
            PSF_path_green = '/home/d1/Seizure221211/PSF/PSFg221009.mat';
            load('~/EyE_Crop3/0924Fit.mat');
            len = length(dir('/home/d2/20230416_1744_g8s-lssm-chriR_5dpf/r03/*.tif'));
            reConstruction(file_Path_Red,file_Path_Green,PSF_path_red,PSF_path_green,1,1,len,tform);
        end
    end
end

% file_Path_Red = '/media/user/Fish-free2/221207_23dpf/R';
% file_Path_Green = '/media/user/Fish-free2/221207_23dpf/G';
% PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';
% PSF_path_green = '/home/d1/Seizure221211/PSF/PSFg221009.mat';
% load('~/EyE_Crop3/0924Fit.mat');


