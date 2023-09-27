%% Find candidate templates.
cd ../;
adpath;
% file_path="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/g";
% red_flag = 0; %%
if ~exist('inter_step','var')
    inter_step = 100;
end

if red_flag
    file_path = path_r;
else
    file_path = path_g;
end
MIPs_path = fullfile(file_path,'dual_MIPs');

zbb_fish = uint16(niftiread('/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii'));
zbb_MIP = max(zbb_fish,[],3);
thresh_pixels = 0.85;
isoRm_flag = 1;

[candidate_templates,NR_scores,pixels_thresh] = canTemplateFind(MIPs_path,inter_step,thresh_pixels,zbb_MIP,isoRm_flag,red_flag);

