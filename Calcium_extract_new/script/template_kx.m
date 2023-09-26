
file_Path_Red = '/media/user/Fish-free2/221207_23dpf/R/dual_Crop';

% file_Path_Red = '/home/d2/g8s_lssm_huc-chri_7dpf_2023-04-18_16-21-34/new_r11/r11/regist_red';

% file_Path_Red = '/home/d1/Seizure221211/red/exp/regist_red';
tifstruct = dir(fullfile(file_Path_Red,'red*.nii'));
alltifs = {tifstruct.name};

for i = 1:length(alltifs)

    name_num = split(alltifs{i},'.');
    name_num = name_num{1};
    num_flag(i) = str2num(name_num(4:end));

end
false_num = [1,150,300,450,600,750,900,1050,1199,1350,1500,1650];
% false_num=[];
template(file_Path_Red,1,1,2403,1,num_flag,false_num);
