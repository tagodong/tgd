function crop_Fish(red_file_path,green_file_path,crop_size)

    tifstruct = dir(fullfile(red_file_path,'Red*.nii'));
    alltifs = {tifstruct.name};

    green_save_path = fullfile(green_file_path,'crop');
    red_save_path = fullfile(red_file_path,'crop');
    if ~exist(red_save_path,'dir')
        mkdir(green_save_path);
        mkdir(red_save_path);
    end

    for i = 1:length(alltifs)

        name_num = split(alltifs{i},'.');
        name_num = name_num{1};
        num = str2num(name_num(4:end));
        red_ObjRecon = niftiread(fullfile(red_file_path,['Red',num2str(num),'.nii']));
        red_ObjRecon = red_ObjRecon(1:crop_size(2),1:crop_size(1),1:crop_size(3));
        green_ObjRecon = niftiread(fullfile(green_file_path,['Green',num2str(num),'.nii']));
        green_ObjRecon = green_ObjRecon(1:crop_size(2),1:crop_size(1),1:crop_size(3));
        save(fullfile(red_save_path,['Red',num2str(num),'.mat']));
        save(fullfile(green_save_path,['Green',num2str(num),'.mat']));
        disp(['Green',num2str(num),'.mat have done.']);
    end

end