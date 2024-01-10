%% Find candidate templates.
cd ../;
adpath;
% file_path="/home/d1/20230808_1638_8s-lssm-none_7dpf-fix/fix/g";
% red_flag = 0; %%
if ~exist('inter_step','var')
    inter_step = 100;
end

if ~exist('value_thresh','var')
    value_thresh = 15;
end

if red_flag
    MIPs_path = fullfile(path_r,'..','back_up','Red_Crop_MIP');
    global_MIP = imread(fullfile(MIPs_path,['Red_Crop_MIP_',num2str(global_number),'.tif']));
else
    MIPs_path = fullfile(path_g,'..','back_up','Green_Crop_MIP');
    global_MIP = imread(fullfile(MIPs_path,['Green_Crop_MIP_',num2str(global_number),'.tif']));
end

%% Save the candidate templates.
tempalte_MIPs_path = fullfile(MIPs_path,'Can_Template_MIP');
template_path = fullfile(MIPs_path,'..','..','template');

if ~exist(tempalte_MIPs_path,'dir')
    mkdir(tempalte_MIPs_path);
    mkdir(template_path);
end

if red_flag
    ObjRecon = niftiread(fullfile(MIPs_path,'..','..','r','Red_Crop',['Red_Crop_',num2str(global_number),'.nii']));
    niftiwrite(ObjRecon,fullfile(template_path,'Best_Can_template.nii'));
else
    ObjRecon = niftiread(fullfile(MIPs_path,'..','..','g','Green_Crop',['Green_Crop_',num2str(global_number),'.nii']));
    niftiwrite(ObjRecon,fullfile(template_path,'Best_Can_template.nii'));
end

% zbb_fish = uint16(niftiread('/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii'));
% zbb_MIP = max(zbb_fish,[],3);

thresh_pixels = 0.85;
isoRm_flag = 1;

tic;
    [candidate_templates,NR_scores,pixels_thresh] = canTemplateFind(MIPs_path,inter_step,thresh_pixels,global_MIP,isoRm_flag,red_flag,value_thresh);
toc;

disp('candidate_templates done!');
