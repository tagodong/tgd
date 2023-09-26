% fix fish regid pepline.

file_pre_Path_Red = '/home/d1/210804_tif/r_210804/r_210804_con/';
file_pre_Path_Green = '/home/d1/210804_tif/g_210804/g_210804_con/';

sub_name = ["00","01","02","03","04","05"];

for i = 1:length(sub_name)
    
    disp(i);
    file_Path_Red = fullfile(file_pre_Path_Red,sub_name(i));
    file_Path_Green = fullfile(file_pre_Path_Green,sub_name(i));

    if i ~= 6
        m_regid_Fix(file_Path_Red,file_Path_Green,1,1,255,1);
    else
        m_regid_Fix(file_Path_Red,file_Path_Green,1,1,156,1);
    end
    
end



m_regid_Fix('/home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/','/home/d1/210804_tif/g_210804/g_210804_con1/g_210804_con1/',62,1,255,3);