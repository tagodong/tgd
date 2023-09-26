function old2new(old_path)
    old_file = dir(fullfile(old_path,'*.tif'));
    num = 3;
    info=imfinfo(fullfile(old_path,old_file(num).name));
    disp(old_file(num).name);

    for i = 1:size(info,1)
        cur_tif = imread(fullfile(old_path,old_file(num).name),i);
        imwrite(cur_tif,fullfile(fullfile(old_path,['00',num2str((num-1)*255+i),'.tif'])));
        disp(['00',num2str((num-1)*255+i),'.tif']);
    end
end