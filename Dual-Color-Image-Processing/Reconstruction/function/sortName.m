function tif_name = sortName(file_path)
    tif_files = dir(fullfile(file_path,'*.tif'));
    name_num = zeros(length(tif_files),1);
    for i = 1:length(tif_files)
        cur_name = tif_files(i).name;
        cur_num = str2double(cur_name(isstrprop(cur_name,"digit")));
        name_num(i) = cur_num;
    end
    [~,idx] = sort(name_num);

    tif_name{1} = '';
    for i = 1:length(tif_files)
        tif_name{i} = tif_files(idx(i)).name;
    end
end