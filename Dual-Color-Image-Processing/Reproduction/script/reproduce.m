%% This is a reproduction script for back up data.
% 2023.10.18

file_dir = '/home/d1/fix/back_up';
start_num = -1;
end_num = -1;

path_g = fullfile(file_dir,'Red_Recon');
path_r = fullfile(file_dir,'Green_Recon');

load(fullfile(file_dir,'Parameters','base.mat'));

files_g = dir(fullfile(path_g,'Green_Recon_*.mat'));
[files_g_name,num_sort] = sortName(files_g);
files_r = dir(fullfile(path_r,'Red_Recon_*.mat'));
files_r_name = sortName(files_r);

if start_num == -1
    start_num = 1;
end
if end_num == -1
    end_num = size(files_g_name,1);
end

%% Mkdir the file directories.
% For crop.
red_crop_path = fullfile(file_dir,'Red_Crop');
green_crop_path = fullfile(file_dir,'Green_Crop');
mkdir(red_crop_path);
mkdir(green_crop_path);

% For affine.
if exist(fullfile(file_dir,'G2R_Affine'),'dir')
    G2R_path = fullfile(file_dir,'G2R');
    mkdir(G2R_path);
end
green_affine_path = fullfile(file_dir,'Green_Affine');
red_affine_path = fullfile(file_dir,'Red_Affine');
mkdir(green_affine_path);
mkdir(red_affine_path);

% For demons registration.
red_demons_path = fullfile(file_dir,'Red_Demons');
green_demons_path = fullfile(file_dir,'Green_Demons');
mkdir(red_demons_path);
mkdir(green_demons_path);

for i = start_num:1:end_num

    tic;
    num = num_sort(i);
    load(fullfile(path_g,files_g_name{i}),'ObjRecon');
    green_ObjRecon = ObjRecon;
    load(fullfile(path_r,files_r_name{i}),'ObjRecon');
    red_ObjRecon = ObjRecon;

    %% Synchronize the red and green.
    [red_ObjRecon,green_ObjRecon] = rgSyn(red_ObjRecon,green_ObjRecon);

    green_ObjRecon = imwarp(green_ObjRecon,tform,'linear','OutputView',imref3d(size(red_ObjRecon)));

    if heart_flag

        red_ObjRecon = red_ObjRecon(:,:,1:225);
        green_ObjRecon = green_ObjRecon(:,:,1:225);

    end

    %% Crop background.
    load(fullfile(file_dir,'Parameters',['Crop_parameter_',num2str(num),'.mat']));
    red_ObjRecon = imrotate(red_ObjRecon,-(angel_azimuth/pi*180),'bicubic','crop');
    green_ObjRecon = imrotate(green_ObjRecon,-(angel_azimuth/pi*180),'bicubic','crop');
    red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
    red_ObjRecon = imrotate(red_ObjRecon,-(angel_elevation/pi*180),'bicubic','crop');
    red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
    green_ObjRecon = permute(green_ObjRecon,[1 3 2]);
    green_ObjRecon = imrotate(green_ObjRecon,-(angel_elevation/pi*180),'bicubic','crop');
    green_ObjRecon = permute(green_ObjRecon,[1 3 2]);

    if flip_flag
        red_ObjRecon = imrotate(red_ObjRecon,180,'bicubic', 'crop');
        green_ObjRecon = imrotate(green_ObjRecon,180,'bicubic', 'crop');
    end

    red_ObjRecon = red_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));
    green_ObjRecon = green_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));

    % Save crop result.
    red_crop_name = ['Red_Crop_',num2str(num),'.nii'];
    niftiwrite(red_ObjRecon,fullfile(red_crop_path,red_crop_name));

    green_crop_name = ['Green_Crop_',num2str(num),'.nii'];
    niftiwrite(green_ObjRecon,fullfile(green_crop_path,green_crop_name));

    %% Affine registration.
    green_crop_image = fullfile(green_crop_path,green_crop_name);
    red_crop_image = fullfile(red_crop_path,red_crop_name);
    
    if exist(fullfile(file_dir,'G2R_Affine'),'dir')
        tform = fullfile(file_dir,'G2R_Affine',['affine',num2str(num),'.xform']);
        g2r = fullfile(G2R_path,['Green_Crop_G2R_',num2str(num),'.nii']);
        eval(['!bash ./function/myreformatx.sh ', green_crop_image,' ',red_crop_image,' ',tform,' ',g2r]);
        green_crop_image = g2r;
    end
    tform = fullfile(file_dir,'Affine',['affine',num2str(num),'.xform']);
    green_affine_image = fullfile(green_affine_path,['Green_Affine_',num2str(num),'.nii']);
    red_affine_image = fullfile(red_affine_path,[Red_Affine_,num2str(num),'.nii']);
    mean_image = fullfile(file_dir,'template','mean_template.nii');
    eval(['!bash ./function/myreformatx.sh ', green_crop_image,' ',mean_image,' ',tform,' ',green_affine_image]);
    eval(['!bash ./function/myreformatx.sh ', red_crop_image,' ',mean_image,' ',tform,' ',red_affine_image]);

    %% Mask eyes.
    Mask = niftiread(fullfile(file_dir,'template','zbb_SyN.nii.gz'));
    Mask = uint16(Mask>0);
    green_image = niftiread(green_affine_image);
    red_image = niftiread(red_affine_image);
    green_mask_image=green_image.*Mask;
    red_mask_image=red_image.*Mask;

    %% Demons registration.
    load(fullfile(file_dir,'Parameters',['D',num2str(num),'mat']),'D');
    green_demons = imwarp(green_mask_image,D,'linear');
    red_demons = imwarp(red_mask_image,D,'linear');

    red_demons_name = ['Red_Demons_',num2str(i),'.mat'];
    ObjRecon = red_demons;
    save(fullfile(red_demons_path,red_demons_name),'ObjRecon');

    green_demons_name = ['Green_Demons_',num2str(i),'.mat'];
    ObjRecon = green_demons;
    save(fullfile(green_demons_path,green_demons_name),'ObjRecon');
    
    toc;
    disp(['frame ',num2str(num),' done.']);
end
