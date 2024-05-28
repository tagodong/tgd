clear
clc

%% Set your parameters.
path = '/home/d1/Learn/2024-01-08-Gcamp8s_Lss_11dpf_learn';
interp_thresh = 10;
Fragment_len_thresh = 100;
subsample_size = [34,356;40,274;8,176];

if ~exist(fullfile(path,'cnmf_data','plane'),'dir')
    mkdir(fullfile(path,'cnmf_data','plane'));
    mkdir(fullfile(path,'cnmf_data','plane','ratio'));
    mkdir(fullfile(path,'cnmf_data','plane','max_tif'));
    mkdir(fullfile(path,'cnmf_data','plane','zoom_ratio'));
    mkdir(fullfile(path,'cnmf_data','result'));
end

load(fullfile(path,'cnmf_data','mean_trace.mat'),'fittedmodel_g','fittedmodel_r');
load(fullfile(path,'cnmf_data','Detrend_Mask.mat'),'Mask')
Cal_index = load(fullfile(path,'CalTrace','Cal_index.mat')).Cal_index;
Cal_index = sort(Cal_index);
load(fullfile(path,'cnmf_data','select_name.mat'),'select_name');
median_detredn_image_g = load(fullfile(path,'cnmf_data','detrend_median_g.mat')).median_detredn_image_g;

%% Compute the median of detrend G using subsample G.
% detrend_image_g = zeros([subsample_size(1,2)-subsample_size(1,1)+1,subsample_size(2,2)-subsample_size(2,1)+1,subsample_size(3,2)-subsample_size(3,1)+1,length(select_name)],"uint16");
% for i = 1:length(select_name)
%     cur_image_g = double(load(fullfile(path,'Green_Demons',['Green_Demons_',num2str(select_name(i)),'.mat'])).ObjRecon);
%     cur_image_g = cur_image_g(subsample_size(1,1):subsample_size(1,2),subsample_size(2,1):subsample_size(2,2),subsample_size(3,1):subsample_size(3,2));
%     detrend_image_g(:,:,:,i) = uint16(cur_image_g/raw_value_g*fittedmodel_g(select_name(i))*100);

%     if mod(i,ceil(length(select_name)/20))==0
%         disp(['Loading detrend image g and r: ',num2str(i/length(select_name))]);
%     end
% end
% median_detredn_image_g = single(median(detrend_image_g,4))/100;
% save(fullfile(path,'cnmf_data','detrend_median_g.mat'),'median_detredn_image_g');
% niftiwrite(median_detredn_image_g,fullfile(path,'cnmf_data','detrend_median_g.nii'));
% clear detrend_image_g;

%% Identify it is odd or even.
% odd_num = 0;
% for i = 1:length(Cal_index)
%     if mod(Cal_index(i),2)==1
%         odd_num = odd_num + 1;
%     end
% end

% odd_flag = 0;
% if odd_num > floor(length(Cal_index)/2)
%     odd_flag = 1;
%     disp('odd');
% else
%     disp('even');
% end

% if odd_flag
%     start_num = floor(Cal_index(1)/2)*2+1;
% else
%     start_num = ceil(Cal_index(1)/2)*2;
% end

% interp_step = zeros(length(start_num:2:Cal_index(end)),1);
% num = 1;
% for i = start_num:2:Cal_index(end)
%     while i > Cal_index(num)
%         num = num + 1;
%     end
%     if i == Cal_index(num)
%         interp_step((i-start_num)/2+1) = 0;
%     else
%         interp_step((i-start_num)/2+1) = Cal_index(num)-Cal_index(num-1);
%     end
% end
% disp(['Bad interp ratio is: ',num2str(1 - sum(interp_step<interp_thresh)/length(interp_step))]);
% disp(['Bad interp frame number is: ',num2str(length(interp_step) - sum(interp_step<interp_thresh))]);

% %% mkdir matfile.
% % for i = subsample_size(3,1):subsample_size(3,2)
% %     mf = matfile(fullfile(path,'cnmf_data','plane','ratio',['Ratio_detrend_',num2str(i),'.mat']),'Writable',true);
% %     mf.data = zeros([subsample_size(2,2)-subsample_size(2,1)+1,subsample_size(1,2)-subsample_size(1,1)+1,sum(interp_step<interp_thresh)],"single");
% % end

% %% interp the ratio data.
% num = 1;
% Cal_id = zeros(length(start_num:2:Cal_index(end)),1);
% sequences = [];
% flag = 1; % whether is discontinuous.
% raw_value_g = fittedmodel_g(start_num);
% raw_value_r = fittedmodel_r(start_num);

% for i = start_num:2:Cal_index(end)
%     while i > Cal_index(num)
%         num = num + 1;
%     end
%     if i == Cal_index(num)
%         cur_g = gpuArray(single(load(fullfile(path,'Green_Demons',['Green_Demons_',num2str(i),'.mat'])).ObjRecon));
%         cur_g = cur_g*raw_value_g/fittedmodel_g(i);
%         cur_r = gpuArray(single(load(fullfile(path,'Red_Demons',['Red_Demons_',num2str(i),'.mat'])).ObjRecon));
%         cur_r = imgaussfilt3(cur_r,1,'FilterSize',[5,5,5],'Padding','symmetric','FilterDomain','spatial');
%         cur_r = cur_r*raw_value_r/fittedmodel_r(i);

%         ratio = cur_g./cur_r;
%         ratio(~isfinite(ratio)) = 0;
%         ratio(~Mask) = 0;
%         ratio = gather(permute(ratio,[3 2 1]));

%         for j = subsample_size(3,1):subsample_size(3,2)
%             mf = matfile(fullfile(path,'cnmf_data','plane','ratio',['Ratio_detrend_',num2str(j),'.mat']),'Writable',true);
%             mf.data(1:235,1:323,(i-start_num)/2+1) = squeeze(ratio(j,subsample_size(2,1):subsample_size(2,2),subsample_size(1,1):subsample_size(1,2)));
%         end

%         Cal_id((i-start_num)/2+1) = i;
%         if flag == 1
%             start = i;
%             flag = 0;
%         end
        
%     else
%         if Cal_index(num)-Cal_index(num-1) < interp_thresh
%             weight = (i-Cal_index(num-1))/(Cal_index(num)-Cal_index(num-1));
%             per_g = load(fullfile(path,'Green_Demons',['Green_Demons_',num2str(Cal_index(num-1)),'.mat'])).ObjRecon;
%             post_g = load(fullfile(path,'Green_Demons',['Green_Demons_',num2str(Cal_index(num)),'.mat'])).ObjRecon;
%             cur_g = weight*post_g + (1-weight)*per_g;
%             cur_g = gpuArray(single(cur_g));
%             cur_g = cur_g*raw_value_g/fittedmodel_g(i);

%             per_r = load(fullfile(path,'Red_Demons',['Red_Demons_',num2str(Cal_index(num-1)),'.mat'])).ObjRecon;
%             post_r = load(fullfile(path,'Red_Demons',['Red_Demons_',num2str(Cal_index(num)),'.mat'])).ObjRecon;
%             cur_r = weight*post_r + (1-weight)*per_r;
%             cur_r = gpuArray(single(cur_r));
%             cur_r = imgaussfilt3(cur_r,1,'FilterSize',[5,5,5],'Padding','symmetric','FilterDomain','spatial');
%             cur_r = cur_r*raw_value_r/fittedmodel_r(i);
    
%             ratio = cur_g./cur_r;
%             ratio(~isfinite(ratio)) = 0;
%             ratio(~Mask) = 0;
%             ratio = gather(permute(ratio,[3 2 1]));
    
%             for j = subsample_size(3,1):subsample_size(3,2)
%                 mf = matfile(fullfile(path,'cnmf_data','plane','ratio',['Ratio_detrend_',num2str(j),'.mat']),'Writable',true);
%                 mf.data(1:235,1:323,(i-start_num)/2+1) = squeeze(ratio(j,subsample_size(2,1):subsample_size(2,2),subsample_size(1,1):subsample_size(1,2)));
%             end

%             Cal_id((i-start_num)/2+1) = i;

%             if flag == 1
%                 start = i;
%                 flag = 0;
%             end
%         else
%             if flag == 0
%                 sequences = [sequences;start,i-2];
%                 flag = 1;
%             end

%         end
%     end

%     if mod(i,ceil(length(start_num:2:Cal_index(end))/20))==0
%         disp(['Interping Demons Mat Data: ',num2str(i/Cal_index(end))]);
%     end

% end

% if flag == 0
%     sequences = [sequences;start,i];
% end

% fragments = zeros(size(sequences));
% for i = 1:size(sequences,1)
%     fragments(i,1:2) = [find(Cal_id==sequences(i,1)),find(Cal_id==sequences(i,2))];
% end

% save(fullfile(path,'cnmf_data','interp_info_raw.mat'),'sequences','Cal_id','Cal_index',"fragments");


% %% Filter the fragments.
% Cal_id = [];
% Sequences = [];
% Fragments = [];
% frag_len = fragments(:,2) - fragments(:,1) + 1;
% for i = 1:size(frag_len,1)
%     if frag_len(i)>=Fragment_len_thresh
%         Cal_id = [Cal_id,sequences(i,1):2:sequences(i,2)];
%         Sequences = [Sequences;sequences(i,1),sequences(i,2)];
%         Fragments = [Fragments;fragments(:,1),fragments(:,2)];
%     end
% end

% save(fullfile(path,'cnmf_data','interp_info.mat'),'Sequences','Cal_id','Fragments','Cal_index');

% disp(['Final frame number is: ',num2str(length(Cal_id))]);
% disp(['Loss frame number is: ',num2str(length(start_num:2:Cal_index(end))-length(Cal_id))]);
% disp('Done.');

%% Zoom the median detrend ratio image.
start_num = 322;
ratio_r = fittedmodel_r(start_num:2:Cal_index(end))/fittedmodel_r(start_num);
ratio_r = reshape(ratio_r,[1,1,length(ratio_r)]);
ratio_g = fittedmodel_g(start_num:2:Cal_index(end))/fittedmodel_g(start_num);
ratio_g = reshape(ratio_g,[1,1,length(ratio_g)]);
median_detredn_image_g = permute(median_detredn_image_g,[3 2 1]);
for j = subsample_size(3,1):subsample_size(3,2)
    mf = matfile(fullfile(path,'cnmf_data','plane','ratio',['Ratio_detrend_',num2str(j),'.mat']));
    cur_data = mf.data;
    cur_data = cur_data.*ratio_r.*ratio_r./ratio_g./ratio_g;
    cur_median_ratio = median(cur_data,3);
    zoom_ratio = cur_data.*(squeeze(median_detredn_image_g(j-subsample_size(3,1)+1,:,:))./cur_median_ratio);
    zoom_ratio(~isfinite(zoom_ratio))=0;

    cur_image = max(zoom_ratio,[],3);
    cur_image = permute(cur_image,[2 1]);
    imwrite(uint16(cur_image),fullfile(path,'cnmf_data','plane','max_tif2',['Ratio_detrend_zoom_max_',num2str(j),'.tif']));
    save(fullfile(path,'cnmf_data','plane','zoom_ratio2',['Ratio_detrend_zoom_',num2str(j),'.mat']),"zoom_ratio",'-v7.3');
    disp(['Ratio_detrend_zoom_',num2str(j),'.mat has done.']);
end