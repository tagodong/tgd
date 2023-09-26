clear
clc

old_path = '/home/d2/220608/r/r220608_learning/';

new_path = '/home/d2/220608/r/new';
if ~exist(new_path,"dir")
    mkdir(new_path);
end

num = 0;
old_tif_files = dir(fullfile(old_path,'*.tif'));
name_num = zeros(length(old_tif_files),1);
for i = 1:length(old_tif_files)
    cur_name = old_tif_files(i).name;
    cur_name = split(cur_name,'_');
    cur_name = cur_name{3};
    cur_num = str2double(cur_name(isstrprop(cur_name,"digit")));
    name_num(i) = cur_num;
end
[~,idx] = sort(name_num);

for i = 1:length(old_tif_files)
    tif_name{i} = old_tif_files(idx(i)).name;
end


for i = 1:length(old_tif_files)
    cur_len = imfinfo(fullfile(old_path,tif_name{i}));
    for j = 1:length(cur_len)
        num = num + 1;
        cur_image = imread(fullfile(old_path,tif_name{i}),j);
        imwrite(cur_image,fullfile(new_path,['000',num2str(num),'.tif']));
    end
    disp(['rX',num2str(i),'.tif: ',num2str(num)]);
end