%% Note: You must run the adpath.m script firstly, then run this code under Registeration path.

%% Run demons registration.

% Set environment.
% cd ../;
% adpath;

% set the red and green directory path of affine registed images.
path_g = '/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving';
path_r = '/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving';
path_files_g = getsubfolders(path_g);
path_files_r = getsubfolders(path_r);

for j = 3:size(path_files_r,1)

    file_path_red = fullfile(path_r,path_files_r{j},'r','regist_red');

    file_path_green = fullfile(path_g,path_files_g{j},'g','regist_green');

    % %
    file_path_template = fullfile(file_path_green,'green_demons');

    % extract the name number of affine registed images.
    tif_struct = dir(fullfile(file_path_red,'regist_red_1_*.nii'));
    all_tifs = {tif_struct.name};
    len = size(tif_struct,1);
    num_index = zeros(len,1);
    for i = 1:len
        name_num = split(all_tifs{i},'.');
        name_num = split(name_num{1},'_');
        name_num = name_num{4};
        num_index(i) = str2double(name_num);
    end

    % Check the number of bad templates in person and write the name number here.
    % Note: it is same as the template_run, so only check it once.
    if j == 2
        false_num = [6161,6221,6301];
    else
        if j==3
            false_num = [8880,8930,9530,9630,9980];
        else
            false_num = [12296,12396,12446];
        end
    end

    start_num = 1;
    end_num = length(dir(fullfile(file_path_red,'regist_red_1_*.nii')));

    % unet_path = '../data/Unet/Unet.mat';
    mask_path = '/home/user/tgd/Pipeline_4bin/Registration/data/Mask/Mask.mat';

    % for Unet method, it will auto select gpu or cpu. If have gpu, the thread_num must be setted as the number of gpus.
    % Here, we have four gpus.
    thread_num = 4;

    % for Mask method, it could only run on cpus and the thread_num could be setted as the number of cpu thread.
    % Here, we have 28 threads.
    % thread_num = 28;

    % for atlas template.
    template_path_1 = '/home/user/tgd/Pipeline_4bin/Registration/data/Atlas/atlas2_bin.nii';
    step_size_1 = 20; %(recommend 100)

    % for mean template.
    step_size_2 = 1;

    % crop the eyes.
    % eyesCrop_Unet(file_path_red,file_path_green,start_num,step_size_2,end_num,num_index,unet_path,thread_num);
    eyesCrop_Mask(file_path_red,file_path_green,start_num,step_size_2,end_num,num_index,mask_path,thread_num);

    % Set gpu index for demonRegist(if have multi-gpus, use a vector.).
    gpu_index = [1,2,3,4];
    mode = 2;

    % demons registration for atlas.
    demonRegist(file_path_red,file_path_green,start_num,step_size_1,end_num,num_index,template_path_1,gpu_index);

    % mean the template.
    templateMean(file_path_template,num_index(start_num:step_size_1:end_num),false_num,mode);

    % %
    % demons registration for mean template.
    % template_path_2 = fullfile(path_r,path_files_r{j},'r','regist_red','red_demons','mean_template.nii');
    template_path_2 = fullfile(path_g,path_files_g{j},'g','regist_green','green_demons','mean_template.nii');
    
    demonRegist(file_path_red,file_path_green,start_num,step_size_2,end_num,num_index,template_path_2,gpu_index);

    % find the min x length, and crop the other frame with this frame.
    min_thresh = 160;
    min_frame = minMipCrop(file_path_red,file_path_green,num_index,min_thresh);

    disp([fullfile(path_r,path_files_r{j}), ' done!']);
end


