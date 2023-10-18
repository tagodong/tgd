%% Note: You must run the adpath.m script firstly, then run this code under Segmentation-Extraction path.

%% Segment brain regions using Correlation Map method and extract the calcium trace.

% set path.
% crop_eyes;

path_g = '/home/d2/220608/g/nii2';
path_r = '/home/d2/220608/r/nii2';
CalTrace_path = fullfile(path_g,'..','CalTrace');
if ~exist(CalTrace_path,'dir')
    mkdir(CalTrace_path);
end

path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

boat_interval_good = 43999 + [66:73,77:84,88:102,109:135,142:157,165:174,181:213,220:143,255:263,299:304,307:309,328:330,334:336,345:352,462:471,481:489,493:509,513:528,534:553,556:575,580:606,612:624,634:653,663:672,705:725,732:748,757:761,769:776,784:796,841:850,859:865,872:893,898:912,942:949,955:963,967:979,1031:1046,1049:1058,1064:1068,1086:1095,1101:1110,1115:1133,1174:1208,1211:1240,1243:1269,1273:1287,1324:1341,1348:1367,1372:1399,1406:1433,1436:1449,1456:1469,1474:1497,1626:1652,1654:1657,1660:1664,1667:1668,1814:1834,1838:1850,1853:1863,1867:1876,1882:1890,1899:1911,1919:1930,1936:1947,1950:1961,1967:1979,1988:1997,2001:2016,2021:2042,2045:2066,2069:2085,2088:2099,2102:2112,2119:2143,2144:2149,2162:2194,2198:2211,2221:2227,2234:2244,2249:2262,2267:2281,2287:2304,2340:2346,2350:2352,2371:2376,2378:2390,2397:2398,2401:2408,2411:2434,2441:2451,2454:2470,2473:2488,2495:2500,2507:2527,2553:2569,2576:2595,2599:2614,2621:2631,2634:2644,2648:2672,2678:2704,2709:2726,2731:2751,2755:2770,2772:2777,2784:2801,2805:2826,2907:2914,2916:2939,2942:2962,2964:2967];
bad_index = 43999+[74	75	76	85	86	87	305	306	331	332	333	490	491	492	510	511	512	554	555	964	965	966	1047	1048	1209	1210	1241	1242	1270	1271	1272	1434	1435	1653	1658	1659	1665	1666	1835	1836	1837	1851	1852	1864	1865	1866	1948	1949	1998	1999	2000	2043	2044	2067	2068	2086	2087	2100	2101	2195	2196	2197	2347	2348	2349	2377	2399	2400	2409	2410	2452	2453	2471	2472	2596	2597	2598	2632	2633	2645	2646	2647	2752	2753	2754	2771	2802	2803	2804	2915	2940	2941	2963];
boat_interval_final = sort([boat_interval_good,bad_index]);

start_num = 1;
end_num = length(boat_interval_final);

small_start = 43999+[1174];
small_end = 43999+[1287];

for j = 1:1

    file_path_red = fullfile(path_r,'regist_red/red_demons2/');

    file_path_green = fullfile(path_g,'regist_green/green_demons2/');

    % set the prefix name and value name of images.
    pre_name_green = 'demons_green_3_';
    value_name_green = 'green_demons';
    pre_name_red = 'demons_red_3_';
    value_name_red = 'red_demons';

    % set the distance between two adjacent brain voxels for calculating correlation.
    ad_dist = 3;

    % set the max and min intensity threshold of dataset.
    thresh.max = 9;
    thresh.min = 2;

    % set the minimum size of segmented regions. 
    min_size = 14;

    % set the start and end.
    start_frame = start_num(j);
    end_frame = end_num(j);

    % extract the green trace.
    tic;
    % [G_trace,Coherence_G,seg_regions,water_corMap_filter,info_data] = corMap(file_path_green,pre_name_green,value_name_green,small_start,small_end,ad_dist,thresh,min_size);
    % save(fullfile(CalTrace_path,'G_trace.mat'),'G_trace');
    % save(fullfile(CalTrace_path,'seg_regions.mat'),'seg_regions');
    % save(fullfile(CalTrace_path,'water_corMap.mat'),'water_corMap_filter');
    % disp('Small Green trace done.');

    batch_size = 1;
    write_flag = 1;

    [G_trace,~] = traceExtract2(file_path_green,pre_name_green,value_name_green,seg_regions,water_corMap_filter,info_data,start_frame,batch_size,end_frame,write_flag,boat_interval_final);
    save(fullfile(CalTrace_path,'G_trace_good.mat'),'G_trace');
    disp('Green trace done.');
    
    % extract the red trace.
    [R_trace,Coherence_R] = traceExtract2(file_path_red,pre_name_red,value_name_red,seg_regions,water_corMap_filter,info_data,start_frame,batch_size,end_frame,write_flag,boat_interval_final);
    save(fullfile(CalTrace_path,'R_trace_good.mat'),'R_trace');
    disp('Red trace done.');
    toc;
end