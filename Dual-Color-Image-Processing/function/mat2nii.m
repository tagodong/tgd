function mat2nii(file_path,prefix_name)

    tifstruct = dir(fullfile(file_path,[prefix_name,'*.mat']));
    alltifs = {tifstruct.name};

    file_nii_path = fullfile(file_path,'nii');
    if ~exist(file_nii_path,'dir')
        mkdir(file_nii_path);
    end

    for i = 1:length(alltifs)

        name_num = alltifs{i};
        num = str2double(name_num(isstrprop(name_num,"digit")));
 
        load(fullfile(file_path,[prefix_name,num2str(num),'.mat']),'ObjRecon');
        
        niftiwrite(ObjRecon,fullfile(file_nii_path,[prefix_name,num2str(num),'.nii']));

        disp([prefix_name,num2str(num),'.mat have done.']);

    end

end