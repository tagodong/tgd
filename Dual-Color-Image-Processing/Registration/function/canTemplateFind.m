function [candidate_templates,NR_scores,pixels_thresh] = canTemplateFind(MIPs_path,inter_step,thresh_pixels,zbb_MIP,isoRm_flag,Red_flag)
    %% Find candidate template from dataset.
    %% 2023,07,21
    
    Red_MIPs = dir(fullfile(MIPs_path,'*.tif'));
    %% Compute the None Reference score using LAPD: Diagonal Laplacian (Thelen2009).
    sample_pixels = zeros(floor(size(Red_MIPs,1)/round(inter_step/5)),1);
    num = 0;
    for i = 1:round(inter_step/5):size(Red_MIPs,1)
        num = num + 1;
        red_MIP = imread(fullfile(MIPs_path,Red_MIPs(i).name));
        sample_pixels(num) = sum(red_MIP>0,'all');
    end
    pixels_thresh = median(sample_pixels(sample_pixels>0),'omitnan')*thresh_pixels;
    
    NR_scores = zeros(size(Red_MIPs,1),2);
    name_num = zeros(size(Red_MIPs,1),1);
    for i = 1:size(Red_MIPs,1)
        red_MIP = imread(fullfile(MIPs_path,Red_MIPs(i).name));
        num_pixels = sum(red_MIP>0,'all');
        if num_pixels < pixels_thresh
            red_MIP = zeros(size(red_MIP),'uint16');
        end
        
        red_name = Red_MIPs(i).name;
        name_num(i) = str2double(red_name(isstrprop(Red_MIPs(i).name,'digit')));
        NR_scores(i,1) = fmeasure(red_MIP, 'LAPD');
        NR_scores(i,2) = max(normxcorr2(red_MIP(1:400,1:308),zbb_MIP),[],"all");
    end
    [sort_name_num,sort_name_idx] = sort(name_num);
    NR_scores = NR_scores(sort_name_idx,:);
    
    %% Select local optimal NR_scores.
    step_num = floor(size(NR_scores,1)/inter_step);
    inter_NR_scores = reshape(NR_scores(1:step_num*inter_step,1),inter_step,[]);
    opt_inter_NR_score = prctile(inter_NR_scores,90);
    if isoRm_flag
        opt_inter_NR_score = isoRm(opt_inter_NR_score);
    end
    opt_inter_NR_id = zeros(1,1);
    template_num = 0;
    for i = 1:length(opt_inter_NR_score)
        if isnan(opt_inter_NR_score(i))
            continue;
        end
        template_num = template_num + 1;
        [~,index_temp] = min(abs(NR_scores(1+inter_step*(i-1):inter_step*i,1)-opt_inter_NR_score(i)));
        opt_inter_NR_id(template_num) = inter_step*(i-1)+index_temp;
    end
    %% Select twice using mse.
    opt_inter_NR_mse = NR_scores(opt_inter_NR_id,2);
    if isoRm_flag
        opt_inter_NR_mse = isoRm(opt_inter_NR_mse);
    end
    opt_inter_NR_id = opt_inter_NR_id(~isnan(opt_inter_NR_mse));

    %% Select global optimal NR_scores.
    opt_NR_score = prctile(NR_scores(:,1),90);
    [~,opt_NR_id] = min(abs(NR_scores(NR_scores(:,2)<max(opt_inter_NR_mse,[],"omitnan"),1)-opt_NR_score));

    %% Save the candidate templates.
    tempalte_MIPs_path = fullfile(MIPs_path,'Can_Template_MIPs');
    template_path = fullfile(MIPs_path,'..','template');
    
    if ~exist(tempalte_MIPs_path,'dir')
        mkdir(tempalte_MIPs_path);
        mkdir(template_path);
    end

    for i = 1:length(opt_inter_NR_id)
        can_MIP = imread(fullfile(MIPs_path,Red_MIPs(name_num==sort_name_num(opt_inter_NR_id(i))).name));
        MIP_name = ['Can_template_MIP_',num2str(sort_name_num(opt_inter_NR_id(i))),'.tif'];
        imwrite(can_MIP,fullfile(tempalte_MIPs_path,MIP_name));
        if Red_flag
            ObjRecon = niftiread(fullfile(MIPs_path,'..','dual_Crop',['Red',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
            niftiwrite(ObjRecon,fullfile(template_path,['Can_template',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
        else
            ObjRecon = niftiread(fullfile(MIPs_path,'..','dual_Crop',['Green',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
            niftiwrite(ObjRecon,fullfile(template_path,['Can_template',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
        end
    end

    if Red_flag
        ObjRecon = niftiread(fullfile(MIPs_path,'..','dual_Crop',['Red',num2str(sort_name_num(opt_NR_id)),'.nii']));
        niftiwrite(ObjRecon,fullfile(template_path,'Best_Can_template.nii'));
    else
        ObjRecon = niftiread(fullfile(MIPs_path,'..','dual_Crop',['Green',num2str(sort_name_num(opt_NR_id)),'.nii']));
        niftiwrite(ObjRecon,fullfile(template_path,'Best_Can_template.nii'));
    end
    
    candidate_templates = sort_name_num(opt_inter_NR_id);
    save(fullfile(MIPs_path,'candidate_templates.mat'),'candidate_templates');

    disp('candidate_templates done!');
    
end
