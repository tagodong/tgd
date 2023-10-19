%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Bad image interpolation.

% Set environment.
% cd ../;
% adpath;

% Set path.
path_g = '/home/d1/fix/20230928_1652_g8s-lssm-tph2-chri_9dpf/g';
path_r = '/home/d1/fix/20230928_1652_g8s-lssm-tph2-chri_9dpf/r';
CalTrace_path = fullfile(path_g,'..','back_up','CalTrace');
if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end
path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

for j = 1:1

    % file_path_red = fullfile(path_r,path_files_r{j},'regist_red/crop_red_demons/');
    file_path_red = fullfile(path_r,'Red_Registration','Red_Demons');

    % file_path_green = fullfile(path_g,path_files_g{j},'regist_green/crop_green_demons/');
    file_path_green = fullfile(path_g,'Green_Registration','Green_Demons');
 
    % Set prefix name of image.
    pre_name_red = 'Red_Demons_';
    pre_name_green = 'Green_Demons_';

    % Check the bad image index in person and write them down here.

    % bad_index = sort([1108,412,880,776,1048,1163,1188,811,491,861,737,547,1189,918,1144,598,843,1022,954,1010,413,1143]);
    % bad_index = sort([1012,954,902,705,1106,540,928,942,959,1102,991,958,1013]);
    % bad_index = sort([1116,736,974,737,1173,454,827,899]);
    % bad_index = sort([368 718 983 369 794 882 1080 482 1035 835 551 1143 719 629 671 834 1081 437 436]);
    % bad_index = 43999+sort([1209 1210 1241 1242 1270 1271 1272]);
    % bad_index = 43999+[74	75 76	85	86	87	305	306	331	332	333	490	491	492	510	511	512	554	555	964	965	966	1047	1048	1434	1435	1653	1658	1659	1665	1666	1835	1836	1837	1851	1852	1864	1865	1866	1948	1949	1998	1999	2000	2043	2044	2067	2068	2086	2087	2100	2101	2195	2196	2197	2347	2348	2349	2377	2399	2400	2409	2410	2452	2453	2471	2472	2596	2597	2598	2632	2633	2645	2646	2647	2752	2753	2754	2771	2802	2803	2804	2915	2940	2941	2963];
    
    % load(fullfile(path_g,'../bad_index.mat'),'bad_index_final');
    % bad_index = sort(bad_index_final);

    bad_index = [665 704 792 956 967 1378 1427];

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

    save(fullfile(CalTrace_path,'bad_index.mat'),'bad_index');
end