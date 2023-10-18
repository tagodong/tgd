% file path.
data_path = '/home/d2/20221129_1628_g8s-lssm-huc-chri_7dpf/highYelloLaser/';

sub_name = ["10","11","12","13","14","15","16","17","18"];

thread_num = 9;

parpool('local',thread_num);

% read the rotationxy angle.
ExpLogs =  readExpLogsFromTXT(fullfile('/home/d2/20221129_1628_g8s-lssm-huc-chri_7dpf/20221129_1628_g8s-lssm-huc-chri_7dpf.txt'));

% multi thread.
spmd

    %% Crop_Fix_kx.m
    Crop_Fix_kx(fullfile(data_path,sub_name(labindex)),ExpLogs);

    %% regid_Fix_1st_kx.m
    regid_Fix_1st_kx(fullfile(data_path,sub_name(labindex)));

    %% crop_Fix_2nd_kx.m(file_path)
    crop_Fix_2nd_kx(fullfile(data_path,sub_name(labindex)));

    %% 

end

delete(gcp('nocreate'));





