file_path_green = '/home/d1/fish221207/G/';
file_path_red = '/home/d1/fish221207/R/';
% pre_name_red = 'red_regist_3';
% pre_name_green = 'green_regist_3';
% nii2mat(file_path_red,pre_name_red);
% nii2mat(file_path_green,pre_name_green);

% interp bad.
% file_path_green = '/home/d1/fish201125/data/regist_1_1/00/regist_green_mat_3/';
% file_path_green = '/home/d1/Seizure221211/green/control/dual_Crop/green_regist_3/';
pre_name_red = 'red_regist_3_';
pre_name_green = 'green_regist_3_';


% mip_dir_name_red = 'regist_red_MIPs_3';
% mip_dir_name_green = '../regist_green_MIPs_3';


% bad_index = [11:13,23,40,41,50,51,66,81,92,93,104:107,118,119,132:141,160:162,198:199,211,212,224:226,244:255,288,307:310,325:327,361:363,379,380,...
% 390,391,410,411,417:422,459,460,468:470,481:485,502:520,547:549,614:617,626:629,634:653];
% bad_index = [1137:1185,1211,1213:1217,1566:1573,1591];
% bad_index = [8122,8151,8156,8186,8197,8198,8213,8214,8235,8209];

% num = 0;
% i = 1;
% while i <= length(bad_index)

%     if i < length(bad_index)
%         if bad_index(i) == bad_index(i+1)-1
%             num = num +1;
%             i = i+1;
%             continue;
%         end
%     end
%     disp(bad_index(i-num));
%     disp(bad_index(i));
%     interp_bad(file_path_red,pre_name_red,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_red,1);
%     interp_bad(fullfile(file_path_green,'00/'),pre_name_green,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_green,0);
%     num = 0;
%     i = i+1;

% end

startnumber = [8216,17125,28414];
% interp_bad(fullfile(file_path_green,'00/'),pre_name_green,34054,34059,mip_dir_name_green,0);
% interp_bad(file_path_red,pre_name_red,34054,34059,mip_dir_name_red,1);
% static_segmentation(file_path_green,pre_name_green,startnumber);
Red_extract(file_path_red,file_path_green,pre_name_red,startnumber);
