function mat2Nii(path_mat,path_nii,value_name)

    file_mat = dir(fullfile(path_mat,'*.mat'));
    for i = 1:length(file_mat)
        load(fullfile(path_mat,file_mat(i).name),value_name);
        name = split(file_mat(i).name,'_');
        name = name{end};
        name_num = str2double(name(isstrprop(name,"digit")));
        niftiwrite(eval(value_name),fullfile(path_nii,[value_name,'_',num2str(name_num),'.nii']))
    end

end