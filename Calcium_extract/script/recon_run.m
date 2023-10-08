




file_Path_Red = '/home/d1/old_beads/r/';
file_Path_Green = '/home/d1/old_beads/g/';
PSF_path_red = '~/Public/old_data/RG-corr/PSFr210825.mat';
PSF_path_green = '~/Public/old_data/RG-corr/PSFg210825.mat';
tifstruct = dir(fullfile(file_Path_Red,'./*.tif'));
red_alltifs = {tifstruct.name};
tifstruct = dir(fullfile(file_Path_Green,'./*.tif'));
green_alltifs = {tifstruct.name};
start = 1;
% load('F:\210804_tif\0924Fit.mat');
tform = [];
for i = 1:1
    
    file_Path_Red_name = fullfile(file_Path_Red,red_alltifs{i});
    file_Path_Green_name = fullfile(file_Path_Green,green_alltifs{i});
    reConstruction(file_Path_Red,file_Path_Green,PSF_path_red,PSF_path_green,1,50,300,tform);
    
end