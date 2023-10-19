function mat2Nii(file_path,prefix_name,red_flag)

    tifstruct = dir(fullfile(file_path,[prefix_name,'*.mat']));
    alltifs = {tifstruct.name};

    file_nii_path = fullfile(file_path,'nii');
    if ~exist(file_nii_path,'dir')
        mkdir(file_nii_path);
    end

    for i = 1:length(alltifs)

        name_num = alltifs{i};
        name_num = split(name_num,'_');
        name_num = name_num{end};
        num = str2double(name_num(isstrprop(name_num,"digit")));

        if red_flag
            load(fullfile(file_path,[prefix_name,num2str(num),'.mat']),'red_demons');
            niftiwrite(red_demons,fullfile(file_nii_path,[prefix_name,num2str(num),'.nii']));
        else
            load(fullfile(file_path,[prefix_name,num2str(num),'.mat']),'green_demons');
            niftiwrite(green_demons,fullfile(file_nii_path,[prefix_name,num2str(num),'.nii']));
        end
        
        disp([prefix_name,num2str(num),'.mat have done.']);

    end

end