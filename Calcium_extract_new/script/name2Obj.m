path_green = '/media/user/Fish-free1/new_0721/new_green/00/regist_green_mat_3/';

path_red = '/media/user/Fish-free1/new_0721/new_red/regist_red_mat_3/';

input_green = 'green_regist_3_';
input_red = 'red_regist_3_';

tif_struct = dir(fullfile(path_red,[input_red,'*.mat']));

for i =1:length(tif_struct)
    load(fullfile(path_red,tif_struct(i).name));
    ObjRecon = regist_3_red_image;
    save(fullfile('/media/user/Fish-free1/new_0721/new_red/00',tif_struct(i).name),'ObjRecon');
    disp(i);
end
