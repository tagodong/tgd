file_Path_Red = 'F:\210804_tif\r_210804\r_210804_con2';
file_Path_Green = 'F:\210804_tif\g_210804\g_201804_con2';
PSF_path_red = 'F:\210804_tif\PSF\PSFr210825.mat';
PSF_path_green = 'F:\210804_tif\PSF\PSFg210825.mat';
tifstruct = dir(fullfile(file_Path_Red,'./*.tif'));
red_alltifs = {tifstruct.name};
tifstruct = dir(fullfile(file_Path_Green,'./*.tif'));
green_alltifs = {tifstruct.name};
start = 1;
load('F:\210804_tif\0924Fit.mat');
for i = 1:4
    
    file_Path_Red_name = fullfile(file_Path_Red,red_alltifs{i});
    file_Path_Green_name = fullfile(file_Path_Green,green_alltifs{i});
    reConstruction(file_Path_Red_name,file_Path_Green_name,PSF_path_red,PSF_path_green,start,1,i,1,tform);
    
end