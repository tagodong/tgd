bad_index = [7579];

% interp bad.
file_path_green = '/home/d1/fish201125/data/regist_1_1/regist_green_mat_3/00/';
% file_path_red = '/media/user/Fish-free1/new_0721/new_red/00/';

% pre_name_red = 'red_regist_3_';
pre_name_green = 'green_regist_3_';

% mip_dir_name_red = 'regist_red_MIPs_3';
mip_dir_name_green = 'regist_green_MIPs_3';
start=1;
num = 0;
i = start;
while i <= length(bad_index)

    if i < length(bad_index)
        if bad_index(i) == bad_index(i+1)-1
            num = num +1;
            i = i+1;
            continue;
        end
    end
    disp(bad_index(i-num));
    disp(bad_index(i));
    % interp_bad(file_path_red,pre_name_red,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_red,3);
    interp_bad(file_path_green,pre_name_green,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_green,3);
    num = 0;
    i = i+1;

end


