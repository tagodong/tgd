file_Path = '/home/d2/new_r11/r11/';

PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';

% tifstruct = dir(fullfile(file_Path,'./*.tif'));
% alltifs = {tifstruct.name};
% start = 7212;
% 4448;
a = 1;
for i = 1:length(alltifs)

    len = length(dir([file_Path,'*.tif']));
    old_reConstruction(file_name,file_Path,PSF_path_red,1,1)
end
