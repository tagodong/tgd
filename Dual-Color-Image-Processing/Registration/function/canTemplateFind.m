function [candidate_templates,NR_scores,pixels_thresh] = canTemplateFind(MIPs_path,inter_step,thresh_pixels,zbb_MIP,isoRm_flag,Red_flag,value_thresh)
    %% Generate candidate template from dataset.
    % MIPs_path --- the recon_crop_mip path.
    % inter_step --- how many frames to generate a template.
    % thresh_pixels --- if pixeles lower than threshold of thresh_pixels*median(MIPs), will be set 0.
    % zbb_MIP --- global best image.
    % isoRm_flag --- always be 1.
    % Red_flag --- wether use red channel image.
    % value_thresh --- used as thresh for whether is object.
    %% 2023,07,21
    
    Red_MIPs = dir(fullfile(MIPs_path,'*.tif'));
    %% Compute the None Reference score using LAPD: Diagonal Laplacian (Thelen2009).n
    sample_pixels = zeros(floor(size(Red_MIPs,1)/round(inter_step)),1);
    num = 0;
    for i = 1:round(inter_step):size(Red_MIPs,1)
        num = num + 1;
        red_MIP = imread(fullfile(MIPs_path,Red_MIPs(i).name));
        sample_pixels(num) = sum(red_MIP>value_thresh,'all');
    end
    pixels_thresh = median(sample_pixels(sample_pixels>value_thresh),'omitnan')*thresh_pixels;
    
    NR_scores = zeros(size(Red_MIPs,1),2);
    name_num = zeros(size(Red_MIPs,1),1);
    for i = 1:size(Red_MIPs,1)
        red_name = Red_MIPs(i).name;
        name_num(i) = str2double(red_name(isstrprop(Red_MIPs(i).name,'digit')));
        red_MIP = imread(fullfile(MIPs_path,Red_MIPs(i).name));
        num_pixels = sum(red_MIP>value_thresh,'all');
        if num_pixels < pixels_thresh
            continue;
        end
        
        NR_scores(i,1) = fmeasure(red_MIP, 'LAPD', [], value_thresh);
        NR_scores(i,2) = max(normxcorr2(red_MIP(1:400,1:308),zbb_MIP(1:400,1:308)),[],"all");
    end
    [sort_name_num,sort_name_idx] = sort(name_num);
    NR_scores = NR_scores(sort_name_idx,:);
    
    %% Abandon the outlier frames.
    NR_scores_filter = isoRm(NR_scores,0.5,2);

    %% Select local optimal NR_scores.
    step_num = floor(size(NR_scores_filter,1)/inter_step);
    inter_NR_scores = reshape(NR_scores_filter(1:step_num*inter_step,1),inter_step,[]);
    opt_inter_NR_score = prctile(inter_NR_scores,95);
    if isoRm_flag
        opt_inter_NR_score = isoRm(opt_inter_NR_score');
    end
    opt_inter_NR_id = zeros(1,1);
    template_num = 0;
    for i = 1:length(opt_inter_NR_score)
        if isnan(opt_inter_NR_score(i))
            continue;
        end
        template_num = template_num + 1;
        [~,index_temp] = min(abs(NR_scores_filter(1+inter_step*(i-1):inter_step*i,1)-opt_inter_NR_score(i)));
        opt_inter_NR_id(template_num) = inter_step*(i-1)+index_temp;
    end

    %% Select twice using cross correlation.
    opt_inter_NR_cor = NR_scores(opt_inter_NR_id,2);
    opt_inter_NR_cor = isoRm(opt_inter_NR_cor);
    opt_inter_NR_id = opt_inter_NR_id(~isnan(opt_inter_NR_cor));

    %% Save the candidate templates.
    tempalte_MIPs_path = fullfile(MIPs_path,'Can_Template_MIP');
    template_path = fullfile(MIPs_path,'..','..','template');

    for i = 1:length(opt_inter_NR_id)
        can_MIP = imread(fullfile(MIPs_path,Red_MIPs(name_num==sort_name_num(opt_inter_NR_id(i))).name));
        MIP_name = ['Can_Template_MIP_',num2str(sort_name_num(opt_inter_NR_id(i))),'.tif'];
        imwrite(can_MIP,fullfile(tempalte_MIPs_path,MIP_name));
        if Red_flag
            ObjRecon = niftiread(fullfile(MIPs_path,'..','..','r','Red_Crop',['Red_Crop_',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
            niftiwrite(ObjRecon,fullfile(template_path,['Can_template',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
        else
            ObjRecon = niftiread(fullfile(MIPs_path,'..','..','g','Green_Crop',['Green_Crop_',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
            niftiwrite(ObjRecon,fullfile(template_path,['Can_template',num2str(sort_name_num(opt_inter_NR_id(i))),'.nii']));
        end
    end
    
    candidate_templates = sort_name_num(opt_inter_NR_id);
    
end
