function tif_name = sortName(old_path)
    old_tif_files = dir(fullfile(old_path,'*.tif'));
    name_num = zeros(length(old_tif_files),1);
    for i = 1:length(old_tif_files)
        cur_name = old_tif_files(i).name;
        % cur_name = split(cur_name,'_');
        % cur_name = cur_name{5};
        cur_num = str2double(cur_name(isstrprop(cur_name,"digit")));
        name_num(i) = cur_num;
    end
    [~,idx] = sort(name_num);

    for i = 1:length(old_tif_files)
        tif_name{i} = old_tif_files(idx(i)).name;
    end
end