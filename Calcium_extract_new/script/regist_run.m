% file_Path_Red = '/media/user/Fish-free1/new_0721/new_red/';
% file_Path_Green = '/media/user/Fish-free1/new_0721/new_green/';
% start = ;
% step = 1;
% stop = ;
cd /home/user/tgd/Calcium_extract_new
adpath

% file_Path_Red = '/home/d1/221207/221207_28814/R/regist_red';
% file_Path_Green = '/home/d1/221207/221207_28814/G/regist_green';

% file_Path_Red = '/home/d1/exp_221207/r/regist_red';
% file_Path_Green = '/home/d1/exp_221207/g/regist_green';

file_Path_Red = '/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/01/regist_red';
file_Path_Green = '/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/g/01/regist_green';
len = length(dir(fullfile(file_Path_Red,'regist_red_1_*.nii')));


tifstruct = dir(fullfile(file_Path_Red,'regist_red_1_*.nii'));
alltifs = {tifstruct.name};

for i = 1:length(alltifs)

    name_num = split(alltifs{i},'.');
    name_num = split(name_num{1},'_');
    name_num = name_num{4};
    num_flag(i) = str2num(name_num);

end

% false_num = [28414,28463,28513,28563,28631,28704,28771,28857,28937,29024];

% m_regid_fix_new(file_Path_Red,file_Path_Green,1,1,len,2,1,num_flag);
% m_regid_fix_new(file_Path_Red,file_Path_Green,1,1,len,3,1,num_flag);
% eval(['!mv ',fullfile(file_Path_Red,'regist_red_mat_3','red_regist_3_8210.mat'),' ',fullfile('/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/','red_regist_3_8210.mat')]);
% % template(fullfile(file_Path_Red),1,1,len,1,num_flag,false_num);
% m_regid_fix_new(file_Path_Red,file_Path_Green,1,1,len,3,2,num_flag);
min_frame = minMipCrop(file_Path_Red,file_Path_Green,num_flag);

% m_regid_Fix(file_Path_Red,file_Path_Green,12774,1,13272,2);
% m_regid_Fix(file_Path_Red,file_Path_Green,12774,50,13272,3,1);
% false_num = [];
% template(fullfile(file_Path_Red,'regist_red_mat_3'),12774,50,13272,2,[],false_num);
% m_regid_Fix(file_Path_Red,file_Path_Green,12774,1,13272,3,2);
