function nii2mat(file_path,save_path,prefix_name_in,prefix_name_out)

    tifstruct = dir(fullfile(file_path,[prefix_name_in,'*.nii']));
    alltifs = {tifstruct.name};

    if ~exist(save_path,'dir')
        mkdir(save_path);
    end

    for i = 1:length(alltifs)

        name_num = alltifs{i};
        num = str2double(name_num(isstrprop(name_num,"digit")));
 
        ObjRecon = niftiread(fullfile(file_path,[prefix_name_in,num2str(num),'.nii']));
        
        save(fullfile(save_path,[prefix_name_out,num2str(num),'.mat']),'ObjRecon');

        disp([prefix_name_out,num2str(num),'.mat have done.']);

    end

end