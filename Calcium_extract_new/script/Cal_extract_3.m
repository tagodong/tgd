file_path_green = '/home/d2/20230416_1744_g8s-lssm-chriR_5dpf/g02/regist_green/regist_green_mat_3/';
file_path_red = '/home/d2/20230416_1744_g8s-lssm-chriR_5dpf/r02/regist_red/regist_red_mat_3/';

pre_name_red = 'red_regist_3_';
pre_name_green = 'green_regist_3_';

mip_dir_name_red = 'regist_red_MIPs_3';
mip_dir_name_green = '../regist_green_MIPs_3';


% bad_index = [347:365,491,351:363,503:522];

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

startnumber = 3189;
% interp_bad(fullfile(file_path_green,'00/'),pre_name_green,34054,34059,mip_dir_name_green,0);
% interp_bad(file_path_red,pre_name_red,34054,34059,mip_dir_name_red,1);
static_segmentation(file_path_green,pre_name_green,startnumber);
Red_extract(file_path_red,file_path_green,pre_name_red,startnumber);
