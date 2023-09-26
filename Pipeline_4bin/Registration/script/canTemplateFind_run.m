%% Find candidate templates.
cd ../;
adpath;
% file_path="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/g";
% red_flag = 0; %%
if ~exist('inter_step','var')
    inter_step = 100;
end
MIPs_path = fullfile(file_path,'dual_MIPs');

thresh_pixels = 0.7;
isoRm_flag = 1;
[candidate_templates,NR_scores,pixels_thresh] = canTemplateFind(MIPs_path,inter_step,thresh_pixels,isoRm_flag,red_flag);

