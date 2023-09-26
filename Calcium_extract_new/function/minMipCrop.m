function min_frame = minMipCrop(file_path_red,file_path_green,num_flag)
    %% find the min x length, and crop the other frame with this frame.

    red_mat_path = fullfile(file_path_red,'regist_red_mat_3');
    green_mat_path = fullfile(file_path_green,'regist_green_mat_3');
 
    len = length(dir(fullfile(green_mat_path,'green_regist_3_*.mat')));

    cur_min = 380;
    min_frame = 0;
    for i = 1:len
        if ismember(num_flag(i),[8235,8151])
            continue;
        end
        load(fullfile(green_mat_path,['green_regist_3_',num2str(num_flag(i)),'.mat']),'regist_3_green_image');
        cur_image = max(regist_3_green_image,[],3);
        [cur_x, ~] = find(cur_image>0);
        if cur_min > max(cur_x) && max(cur_x) >= 300
            cur_min = max(cur_x);
            min_frame = num_flag(i);
        end
    end

    disp(['min x is ',num2str(cur_min)]);
    disp(['min frame is ', ['green_regist_3_',num2str(min_frame),'.mat']]);

    %% crop the image.
    new_red_mat_path = fullfile(file_path_red,'new_regist_red_mat_3');
    new_green_mat_path = fullfile(file_path_green,'new_regist_green_mat_3');
    regist_3_red_Mip_Path = fullfile(file_path_red,'new_regist_red_MIPs_3');
    regist_3_green_Mip_Path = fullfile(file_path_green,'new_regist_green_MIPs_3');
    if ~exist(regist_3_red_Mip_Path,"dir")
        mkdir(new_red_mat_path);
        mkdir(new_green_mat_path);
        mkdir(regist_3_red_Mip_Path);
        mkdir(regist_3_green_Mip_Path);
    end

    cur_image = load(fullfile(green_mat_path,['green_regist_3_',num2str(8144),'.mat'])).regist_3_green_image;
    Mask = cur_image>0;
    for i = 1:len
        load(fullfile(green_mat_path,['green_regist_3_',num2str(num_flag(i)),'.mat']),'regist_3_green_image');
        load(fullfile(red_mat_path,['red_regist_3_',num2str(num_flag(i)),'.mat']),'regist_3_red_image');
        regist_3_green_image = uint16(double(regist_3_green_image).*Mask);
        regist_3_red_image = uint16(double(regist_3_red_image).*Mask);
        save(fullfile(new_green_mat_path,['green_regist_3_',num2str(num_flag(i)),'.mat']),'regist_3_green_image');
        save(fullfile(new_red_mat_path,['red_regist_3_',num2str(num_flag(i)),'.mat']),'regist_3_red_image');

        % write the MIP of second non-regid registed fish image for check them convenient.
        regist_3_Red_Mip = [max(regist_3_red_image,[],3) squeeze(max(regist_3_red_image,[],2));squeeze(max(regist_3_red_image,[],1))' zeros(size(regist_3_red_image,3),size(regist_3_red_image,3))];
        regist_3_Red_Mip = uint16(regist_3_Red_Mip);
        imwrite(regist_3_Red_Mip,fullfile(regist_3_red_Mip_Path,['regist_red_MIP_3','_',num2str(num_flag(i)),'.tif']));
        
        regist_3_green_Mip = [max(regist_3_green_image,[],3) squeeze(max(regist_3_green_image,[],2));squeeze(max(regist_3_green_image,[],1))' zeros(size(regist_3_green_image,3),size(regist_3_green_image,3))];
        regist_3_green_Mip = uint16(regist_3_green_Mip);
        imwrite(regist_3_green_Mip,fullfile(regist_3_green_Mip_Path,['regist_green_MIP_3','_',num2str(num_flag(i)),'.tif']));
    end

end