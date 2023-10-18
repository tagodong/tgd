function min_frame = minMipCrop(file_path_red,file_path_green,num_flag,min_thresh)
    %% find the min x length, and crop the other frame with this frame.

    red_mat_path = fullfile(file_path_red,'red_demons');
    green_mat_path = fullfile(file_path_green,'green_demons');
 
    len = length(dir(fullfile(green_mat_path,'demons_green_3_*.mat')));

    cur_min = 380;
    min_frame = 0;
    for i = 1:len
        load(fullfile(green_mat_path,['demons_green_3_',num2str(num_flag(i)),'.mat']),'green_demons');
        green_BW_ObjRecon = green_demons > mean(green_demons,'omitnan');
        green_BW_MIP = [max(green_BW_ObjRecon,[],3) squeeze(max(green_BW_ObjRecon,[],2));squeeze(max(green_BW_ObjRecon,[],1))' zeros(size(green_BW_ObjRecon,3),size(green_BW_ObjRecon,3))];
        cur_image = max(green_BW_ObjRecon,[],3);
        [cur_x, ~] = find(cur_image>0);
        if all([cur_min > max(cur_x),max(cur_x) >= min_thresh,sum(green_BW_MIP,'all') > 1.2*10^6])
            cur_min = max(cur_x);
            min_frame = num_flag(i);
        end
    end

    disp(['min x is ',num2str(cur_min)]);
    disp(['min frame is ', ['demons_green_3_',num2str(min_frame),'.mat']]);

    %% crop the image.
    new_red_mat_path = fullfile(file_path_red,'crop_red_demons');
    new_green_mat_path = fullfile(file_path_green,'crop_green_demons');
    regist_3_red_Mip_Path = fullfile(file_path_red,'crop_red_demons_MIPs');
    regist_3_green_Mip_Path = fullfile(file_path_green,'crop_green_demons_MIPs');
    if ~exist(regist_3_red_Mip_Path,"dir")
        mkdir(new_red_mat_path);
        mkdir(new_green_mat_path);
        mkdir(regist_3_red_Mip_Path);
        mkdir(regist_3_green_Mip_Path);
    end

    cur_image = load(fullfile(green_mat_path,['demons_green_3_',num2str(min_frame),'.mat'])).green_demons;
    Mask = cur_image>0;
    for i = 1:len
        load(fullfile(green_mat_path,['demons_green_3_',num2str(num_flag(i)),'.mat']),'green_demons');
        load(fullfile(red_mat_path,['demons_red_3_',num2str(num_flag(i)),'.mat']),'red_demons');
        green_demons = uint16(double(green_demons).*Mask);
        red_demons = uint16(double(red_demons).*Mask);
        save(fullfile(new_green_mat_path,['demons_green_3_',num2str(num_flag(i)),'.mat']),'green_demons');
        save(fullfile(new_red_mat_path,['demons_red_3_',num2str(num_flag(i)),'.mat']),'red_demons');

        % write the MIP of second non-regid registed fish image for check them convenient.
        regist_3_Red_Mip = [max(red_demons,[],3) squeeze(max(red_demons,[],2));squeeze(max(red_demons,[],1))' zeros(size(red_demons,3),size(red_demons,3))];
        regist_3_Red_Mip = uint16(regist_3_Red_Mip);
        imwrite(regist_3_Red_Mip,fullfile(regist_3_red_Mip_Path,['demons_red_3','_',num2str(num_flag(i)),'.tif']));
        
        regist_3_green_Mip = [max(green_demons,[],3) squeeze(max(green_demons,[],2));squeeze(max(green_demons,[],1))' zeros(size(green_demons,3),size(green_demons,3))];
        regist_3_green_Mip = uint16(regist_3_green_Mip);
        imwrite(regist_3_green_Mip,fullfile(regist_3_green_Mip_Path,['demons_green_3','_',num2str(num_flag(i)),'.tif']));
    end


end