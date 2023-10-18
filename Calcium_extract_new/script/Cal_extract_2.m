file_path_green = '/media/user/Fish-free2/221207_23dpf/G/regist_green/green_mat_33/';
file_path_red = '/media/user/Fish-free2/221207_23dpf/R/regist_red/red_33/';
% pre_name_red = 'red_regist_3';
% pre_name_green = 'green_regist_3';
% nii2mat(file_path_red,pre_name_red);
% nii2mat(file_path_green,pre_name_green);

% interp bad.
% file_path_green = '/home/d1/fish201125/data/regist_1_1/00/regist_green_mat_3/';
% file_path_green = '/home/d1/Seizure221211/green/control/dual_Crop/green_regist_3/';
pre_name_red = 'red_regist_3_';
pre_name_green = 'green_regist_3_';


mip_dir_name_red = 'regist_red_MIPs_3';
mip_dir_name_green = '../regist_green_MIPs_3';


% bad_index_seizure = [347:365,491,351:363,503:522];
% bad_index = [3,15,16,32:38,53:55,66,110,111,293:299,305,310:316,319,321,329,330,370:377,379:382,403:406,419,430,439,440,453,463,...
% 481:482,487:489,670:672,679:682,684:695,697:702,708:720];
bad_index = [1606,1622,1623,1630:1632,1641,1642,1685,1686,1690,1738:1743,1745:1827,1829:1831,1868:1872,1874:1876,1879:1881,1883:1886,1889,1893,1894,1905:1909,1912,1920,1921,1927,1928,1939,1940,1943,1946:1950,1953:1975,1977:1988,1990,...
1993:1997,2004:2010,2012:2022,2029:2030,2041,2064,2070:2074,2077,2082,2095,2099:2101,2106,2111,2115:2119,2131,2136,2140,2145,2148,2153,2156,2160,2164,2167:2169,2179,2180,2190,2191,2278,2303,2311,2313,2317:2320,2328:2331,2339:2341,2349:2354,...
2362:2365];
bad_index = bad_index -1602;

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
    disp(bad_index(i-num));
    disp(bad_index(i));
    interp_bad(file_path_red,pre_name_red,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_red,1);
    interp_bad(fullfile(file_path_green,'00/'),pre_name_green,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_green,0);
    num = 0;
    i = i+1;

end


% startnumber = 8216;
startnumber = 28414;
% startnumber = 17125;
% % interp_bad(fullfile(file_path_green,'00/'),pre_name_green,34054,34059,mip_dir_name_green,0);
% % interp_bad(file_path_red,pre_name_red,34054,34059,mip_dir_name_red,1);
static_segmentation(file_path_green,pre_name_green,startnumber);
Red_extract(file_path_red,file_path_green,pre_name_red,startnumber);
