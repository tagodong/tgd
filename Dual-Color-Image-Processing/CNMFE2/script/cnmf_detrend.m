clear
clc

path = '/home/d1/Learn/2024-01-08-Gcamp8s_Lss_11dpf_learn';
thresh_max = 10;
thresh_min_g = 3;
thresh_min_r = 3;

path_g = fullfile(path,'Green_Demons');
path_r = fullfile(path,'Red_Demons');
Cal_index = load(fullfile(path,'CalTrace','Cal_index.mat')).Cal_index;
Cal_index = sort(Cal_index);
load(fullfile(path,'cnmf_data','select_name.mat'),'select_name');

%% Find the detrend brain Mask.
max_image_g = load(fullfile(path_g,['Green_Demons_',num2str(select_name(1)),'.mat'])).ObjRecon;
min_image_r = load(fullfile(path_r,['Red_Demons_',num2str(select_name(1)),'.mat'])).ObjRecon;
min_image_g = max_image_g;
temp_image_g = zeros([size(max_image_g),2]);
temp_image_r = zeros([size(max_image_g),2]);

for i = 2:length(select_name)

    cur_image_r = load(fullfile(path_r,['Red_Demons_',num2str(select_name(i)),'.mat'])).ObjRecon;
    temp_image_r(:,:,:,1) = cur_image_r;
    temp_image_r(:,:,:,2) = min_image_r;
    min_image_r = squeeze(min(temp_image_r,[],4));

    cur_image_g = load(fullfile(path_g,['Green_Demons_',num2str(select_name(i)),'.mat'])).ObjRecon;
    temp_image_g(:,:,:,1) = cur_image_g;
    temp_image_g(:,:,:,2) = max_image_g;
    max_image_g = squeeze(max(temp_image_g,[],4));

    temp_image_g(:,:,:,2) = min_image_g;
    min_image_g = squeeze(min(temp_image_g,[],4));

    if mod(i,ceil(length(select_name)/10))==0
        disp(['Finding Max and Min: ',num2str(i/length(select_name))]);
    end
end

Mask = ones(size(max_image_g),"logical");
Mask(max_image_g<thresh_max) = 0;
Mask(min_image_g<thresh_min_g) = 0;
Mask(min_image_r<thresh_min_r) = 0;
save(fullfile(path,'cnmf_data','Mask.mat'),"Mask","max_image_g","min_image_g",'min_image_r','-v7.3');
disp('Find Max and Min Done!');


%% Compute the mean trace.
% mean_trace_g = zeros(1,length(Cal_index));
% mean_trace_r = zeros(1,length(Cal_index));
% for i = 1:length(Cal_index)
%     cur_image_g = load(fullfile(path_g,['Green_Demons_',num2str(Cal_index(i)),'.mat'])).ObjRecon;
%     mean_trace_g(i) = mean(cur_image_g(Mask),"all");

%     cur_image_r = load(fullfile(path_r,['Red_Demons_',num2str(Cal_index(i)),'.mat'])).ObjRecon;
%     mean_trace_r(i) = mean(cur_image_r(Mask),"all");

%     if mod(i,ceil(length(Cal_index)/20))==0
%         disp(['Computing the mean trace: ',num2str(i/length(Cal_index))]);
%     end
% end
% disp('Compute the mean trace Done!');

% save(fullfile(path,'cnmf_data','mean_trace_raw.mat'),"mean_trace_r","mean_trace_g",'Cal_index','-v7.3');