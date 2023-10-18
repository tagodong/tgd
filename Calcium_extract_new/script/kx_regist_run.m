file_Path_Green = '/media/user/Fish-free2/221207_23dpf/G/regist_green/';
file_Path_Red = '/media/user/Fish-free2/221207_23dpf/R/regist_red/';
tifstruct = dir(fullfile(file_Path_Red,'regist_red_1_*.nii'));
alltifs = {tifstruct.name};

for i = 1:length(alltifs)

    name_num = split(alltifs{i},'.');
    name_num = split(name_num{1},'_');
    name_num = name_num{4};
    num_flag(i) = str2num(name_num);

end

false_num = [8414,8464,8864,17475,33998,34198,34398,34348];
m_regid_fix_new(file_Path_Red,file_Path_Green,1,1,2402,2,num_flag);
m_regid_fix_new(file_Path_Red,file_Path_Green,1,50,2402,3,1,num_flag);
template(fullfile(file_Path_Red,'regist_red_mat_3'),1,50,2402,2,num_flag,false_num);
m_regid_fix_new(file_Path_Red,file_Path_Green,1,1,2402,3,2,num_flag);

