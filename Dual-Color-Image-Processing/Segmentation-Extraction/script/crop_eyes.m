crop_mask = '/home/d2/220608/eyes_crop_mask.nii';

crop_mask = niftiread(crop_mask);

file_path_red = '/home/d2/220608/r/nii2/regist_red/red_demons/';
file_path_green = '/home/d2/220608/g/nii2/regist_green/green_demons/';
file_path_red_2 = '/home/d2/220608/r/nii2/regist_red/red_demons2/';
mkdir(file_path_red_2);
file_path_green_2 = '/home/d2/220608/g/nii2/regist_green/green_demons2/';
mkdir(file_path_green_2);

tif_struct = dir(fullfile(file_path_red,'demons_red_3_*.mat'));
all_tifs = {tif_struct.name};
len = size(tif_struct,1);
num_index = zeros(len,1);
for i = 1:len
    name_num = split(all_tifs{i},'.');
    name_num = split(name_num{1},'_');
    name_num = name_num{4};
    num_index(i) = str2double(name_num);
end

for i = 1:len
    load(fullfile(file_path_red,['demons_red_3_',num2str(num_index(i)),'.mat']),'red_demons');
    load(fullfile(file_path_green,['demons_green_3_',num2str(num_index(i)),'.mat']),'green_demons');
    red_demons = red_demons.*crop_mask;
    green_demons = green_demons.*crop_mask;
    save(fullfile(file_path_red_2,['demons_red_3_',num2str(num_index(i)),'.mat']),"red_demons");
    save(fullfile(file_path_green_2,['demons_green_3_',num2str(num_index(i)),'.mat']),"green_demons");
end