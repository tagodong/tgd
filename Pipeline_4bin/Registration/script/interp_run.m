%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Bad image interpolation.

% Set environment.
% cd ../;
% adpath;

% Set path.
path_g = '/home/d2/g8s_lssm_huc-chri_7dpf_2023-04-18_16-21-34/new_g11/';
path_r = '/home/d2/g8s_lssm_huc-chri_7dpf_2023-04-18_16-21-34/new_r11/';
path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

for j = 1:size(path_files_r,1)

    file_path_red = fullfile(path_r,path_files_r{j},'regist_red/crop_red_demons/');

    file_path_green = fullfile(path_g,path_files_g{j},'regist_green/crop_green_demons/');
 

    % Set prefix name of image.
    pre_name_red = 'demons_red_3_';
    pre_name_green = 'demons_green_3_';

    % Check the bad image index in person and write them down here.

    if j == 1
        bad_index = sort([12776,12784,12820,12825,12829,12832,12833,12837,12857,12858]);
    else
        bad_index = sort([3288,3313,3316:3317,3402,3509,3517:3519,3668:3675,3811:3813,4057]);
    end
    
    %% Interp the bad index.
    num = 0;
    i = 1;
    while i <= length(bad_index)
        if i < length(bad_index)
            if bad_index(i) == bad_index(i+1)-1
                num = num +1;
                i = i+1;
                continue;
            end
        end
        disp(['start continuous index: ', num2str(bad_index(i-num))]);
        disp(['end continuous index: ', num2str(bad_index(i))]);
        interp_bad(file_path_red,pre_name_red,bad_index(i-num)-1,bad_index(i)+1,1);
        interp_bad(file_path_green,pre_name_green,bad_index(i-num)-1,bad_index(i)+1,0);
        num = 0;
        i = i+1;
    end

    save(fullfile(file_path_green,'bad_index.mat'),'bad_index');
end