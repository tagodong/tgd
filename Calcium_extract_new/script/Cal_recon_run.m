file_Path_Red = 'F:\210804_tif\r_210804\r_210804_con1';
file_Path_Green = 'F:\210804_tif\g_210804\g_211804_con1';
PSF_path_red = 'F:\210804_tif\PSF\PSFr210825.mat';
PSF_path_green = 'F:\210804_tif\PSF\PSFg210825.mat';
tifstruct = dir(fullfile(file_Path_Red,'./*.tif'));
red_alltifs = {tifstruct.name};
tifstruct = dir(fullfile(file_Path_Green,'./*.tif'));
green_alltifs = {tifstruct.name};

for i = 1:5
    if i == 1
        start = 62;
    else
        start = 1;
    end
    file_Path_Red_name = fullfile(file_Path_Red,red_alltifs{i});
    file_Path_Green_name = fullfile(file_Path_Green,green_alltifs{i});
    reConstruction(file_Path_Red_name,file_Path_Green_name,PSF_path_red,PSF_path_green,start,1,i,1);
end