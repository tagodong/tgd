function mat2nii(red_file_path,green_file_path)

    tifstruct = dir(fullfile(red_file_path,'red_regist_3_*.mat'));
    alltifs = {tifstruct.name};

    green_save_path = fullfile(green_file_path,'nii');
    red_save_path = fullfile(red_file_path,'nii');
    if ~exist(red_save_path,'dir')
        mkdir(green_save_path);
        mkdir(red_save_path);
    end

    for i = 1:50

        name_num = split(alltifs{i},'.');
        name_num = split(name_num{1},'_');
        name_num = name_num{4};
        num = str2num(name_num);
        red_ObjRecon = load(fullfile(red_file_path,['red_regist_3_',num2str(num),'.mat'])).regist_3_red_image;
        green_ObjRecon = load(fullfile(green_file_path,['green_regist_3_',num2str(num),'.mat'])).regist_3_green_image;
        niftiwrite(red_ObjRecon,fullfile(red_save_path,['red_regist_3_',num2str(num),'.nii']));
        niftiwrite(green_ObjRecon,fullfile(green_save_path,['green_regist_3_',num2str(num),'.nii']));
        disp(['green_regist_3_',num2str(num),'.mat have done.']);

    end

end