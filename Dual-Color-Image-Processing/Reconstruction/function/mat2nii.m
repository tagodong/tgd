function mat2nii(red_file_path,green_file_path)

    tifstruct = dir(fullfile(red_file_path,'red_recon*.mat'));
    alltifs = {tifstruct.name};

    green_save_path = fullfile(green_file_path,'nii2');
    red_save_path = fullfile(red_file_path,'nii2');
    if ~exist(red_save_path,'dir')
        mkdir(green_save_path);
        mkdir(red_save_path);
    end

    for i = 1:length(alltifs)

        name_num = alltifs{i};
        num = str2num(name_num(isstrprop(name_num,"digit")));
        if num <44000
            continue;
        end
 
        red_ObjRecon = load(fullfile(red_file_path,['red_recon',num2str(num),'.mat'])).red_ObjRecon;
        green_ObjRecon = load(fullfile(green_file_path,['green_recon',num2str(num),'.mat'])).green_ObjRecon;
        niftiwrite(red_ObjRecon,fullfile(red_save_path,['red_recon',num2str(num),'.nii']));
        niftiwrite(green_ObjRecon,fullfile(green_save_path,['green_recon',num2str(num),'.nii']));
        disp(['green_recon',num2str(num),'.mat have done.']);

    end

end