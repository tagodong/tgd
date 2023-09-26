function dualCrop(red_ObjRecon,green_ObjRecon,file_path_red,file_path_green,num,atlas,crop_size,x_shift)
%% function summary: Crop the black background and rotate the two ObjRecons. 

%  input:
%   red_ObjRecon --- the ObjRecon of reconstructed red frame.
%   green_ObjRecon --- the ObjRecon of reconstructed green frame.
%   file_path_red --- the directory path of red frames.
%   file_path_green --- the directory path of green frames.
%   num --- the number of current frame name.

%  write: This function will generate four directories under both file_path_red and 
% file_path_green.
%   recon_mat --- contain the reconstructed images in mat format.
%   recon_MIPs --- contain the maximum intensity projections in three directions of the reconstructed images.
%   dual_Crop --- Contain images in nii format which were cropped and rotated.
%   dual_MIPs --- contain the maximum intensity projections in three directions of the images in dual_Crop.

%   update 2022.11.30.

%% Make derectories.
    % red directory.
    red_recon_path = fullfile(file_path_red,'recon_mat');
    red_recon_MIP_path = fullfile(file_path_red,'recon_MIPs');
    red_dual_path = fullfile(file_path_red,'dual_Crop');
    red_dual_MIP_path = fullfile(file_path_red,'dual_MIPs');

    % green directory.
    green_recon_path = fullfile(file_path_green,'recon_mat');
    green_recon_MIP_path = fullfile(file_path_green,'recon_MIPs');
    green_dual_path = fullfile(file_path_green,'dual_Crop');
    green_dual_MIP_path = fullfile(file_path_green,'dual_MIPs');

    % create the new directory.
    if ~exist(red_recon_MIP_path,"dir")
        mkdir(red_recon_path);
        mkdir(red_recon_MIP_path);
        mkdir(red_dual_path);
        mkdir(red_dual_MIP_path);
        
        mkdir(green_recon_path);
        mkdir(green_recon_MIP_path);
        mkdir(green_dual_path);
        mkdir(green_dual_MIP_path); 
    end
    
%% Rotate the image reference the atlas.
    % Flip the fish because there is a filp transform in our system. 
    red_ObjRecon = flip(red_ObjRecon,3);
    green_ObjRecon = flip(green_ObjRecon,3);
    
    % write the MIP of reconstructed images.
    red_MIP=[max(red_ObjRecon,[],3) squeeze(max(red_ObjRecon,[],2));squeeze(max(red_ObjRecon,[],1))' zeros(size(red_ObjRecon,3),size(red_ObjRecon,3))];
    red_MIP_name = fullfile(red_recon_MIP_path,['red_MIP',num2str(num),'.tif']);
    imwrite(uint16(red_MIP),red_MIP_name);
    green_MIP=[max(green_ObjRecon,[],3) squeeze(max(green_ObjRecon,[],2));squeeze(max(green_ObjRecon,[],1))' zeros(size(green_ObjRecon,3),size(green_ObjRecon,3))];
    green_MIP_name = fullfile(green_recon_MIP_path,['green_MIP',num2str(num),'.tif']);
    imwrite(uint16(green_MIP),green_MIP_name);

    % write the reconstructed images.
    red_ObjRecon = gather(red_ObjRecon);
    green_ObjRecon = gather(green_ObjRecon);
    red_recon_name = fullfile(red_recon_path,['red_recon',num2str(num),'.mat']);
    save(red_recon_name,'red_ObjRecon');
    green_recon_name = fullfile(green_recon_path,['green_recon',num2str(num),'.mat']);
    save(green_recon_name,'green_ObjRecon');

%% First, rotate the fish to vertical in XY plane
    atlas = gpuArray(uint16(atlas));
    red_ObjRecon = gpuArray(red_ObjRecon);
    green_ObjRecon = gpuArray(green_ObjRecon);
    mean_thresh = 20;

    red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
    if sum(red_BW_ObjRecon,'all') > 10^6
        [cor_x,cor_y,cor_z] = ind2sub(size(red_BW_ObjRecon),find(red_BW_ObjRecon));
        cor_coef = pca([cor_x,cor_y,cor_z]);
        [azimuth,elevation] = cart2sph(cor_coef(1,1),cor_coef(2,1),cor_coef(3,1));
        red_ObjRecon = imrotate(red_ObjRecon,-(gather(azimuth)/pi*180),'bicubic','crop');
        green_ObjRecon = imrotate(green_ObjRecon,-(gather(azimuth)/pi*180),'bicubic','crop');

        red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
        red_ObjRecon = imrotate(red_ObjRecon,-(gather(elevation)/pi*180),'bicubic','crop');
        red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
        green_ObjRecon = permute(green_ObjRecon,[1 3 2]);
        green_ObjRecon = imrotate(green_ObjRecon,-(gather(elevation)/pi*180),'bicubic','crop');
        green_ObjRecon = permute(green_ObjRecon,[1 3 2]);

    %% second, check if the fish is right vertival whose head in the top using template matching, if not flip it.
        red_xy_MIP = max(red_ObjRecon,[],3);
        zbb_xy_MIP = max(atlas,[],3); %%
        % zbb_xy_MIP = atlas;
        cross_corr = normxcorr2(zbb_xy_MIP,red_xy_MIP);

        zbb_xy_MIP_flip = max(imrotate(atlas,180,'bicubic', 'crop'),[],3); %%
        % zbb_xy_MIP_flip = imrotate(atlas,180,'bicubic', 'crop');
        flip_corr = normxcorr2(zbb_xy_MIP_flip,red_xy_MIP);

        if max(flip_corr,[],'all') > max(cross_corr,[],'all')
            red_ObjRecon = imrotate(red_ObjRecon,180,'bicubic', 'crop');
            green_ObjRecon = imrotate(green_ObjRecon,180,'bicubic', 'crop');
        end

        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
        [cor_x,cor_y,cor_z] = ind2sub(size(red_BW_ObjRecon),find(red_BW_ObjRecon));
        CentroID = mean([cor_x,cor_y,cor_z],1);
        intial_size = size(red_BW_ObjRecon);
    else
        intial_size = size(red_ObjRecon);
        CentroID = round(intial_size/2);
    end

    %% Third, crop the background of the initial size (600*600*300 for us) to cropped size (308*400*210 for us).

    % get the first dimension size.
    CentroID(1) = CentroID(1) - x_shift; %% %% could be changed for different fish 80.
    if CentroID(1) < crop_size(1)/2
        CentroID(1) = crop_size(1)/2;
    else
        if CentroID(1) > intial_size(1)-crop_size(1)/2
            CentroID(1) = intial_size(1)-crop_size(1)/2;
        end
    end

    % get the second dimension size.
    if CentroID(2) < crop_size(2)/2
        CentroID(2) = crop_size(2)/2;
    end
    if CentroID(2) > intial_size(2)-crop_size(2)/2
        CentroID(2) = intial_size(2)-crop_size(2)/2;
    end

    % get the boundary of fish.
    if CentroID(3) < crop_size(3)/2
        image_size = [round(CentroID(1)-crop_size(1)/2),round(CentroID(1)+crop_size(1)/2), ...
            round(CentroID(2)-crop_size(2)/2),round(CentroID(2)+crop_size(2)/2),...
            0,crop_size(3)];
    else
        if CentroID(3) > intial_size(3)-crop_size(3)/2
            image_size = [round(CentroID(1)-crop_size(1)/2),round(CentroID(1)+crop_size(1)/2), ...
                round(CentroID(2)-crop_size(2)/2),round(CentroID(2)+crop_size(2)/2),...
                intial_size(3)-crop_size(3),intial_size(3)];
        else
            image_size = [round(CentroID(1)-crop_size(1)/2),round(CentroID(1)+crop_size(1)/2), ...
                round(CentroID(2)-crop_size(2)/2),round(CentroID(2)+crop_size(2)/2),...
                round(CentroID(3)-crop_size(3)/2),round(CentroID(3)+crop_size(3)/2)];
        end
    end

    red_ObjRecon = red_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));
    green_ObjRecon = green_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));

%% Finaly, interp the image and save them.
    % [X_bound,Y_bound,Z_bound] = size(red_ObjRecon);
    % % Warn: the image correspond X and Y is different.
    % [X,Y,Z] = meshgrid(linspace(1,Y_bound,crop_size(1)+10),linspace(1,X_bound,crop_size(2)+10),linspace(1,Z_bound,crop_size(3)+6));
    
    % % interp the image.
    % red_interp = uint16(interp3(red_ObjRecon,X,Y,Z,'spline'));
    % green_interp = uint16(interp3(green_ObjRecon,X,Y,Z,'spline'));
    

    % % write the image to nii file.
    % if flag == 1
    %     red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
    %     green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
    % else
    %     if flag == 2
    %         red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
    %         green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
    %     else
    %         red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
    %         green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
    %     end
    % end

%% Write and save files.
    % Warn: the image correspond X and Y is different.
    % write the MIP file.
    RescaledRed_Mip = [max(red_ObjRecon,[],3) squeeze(max(red_ObjRecon,[],2));squeeze(max(red_ObjRecon,[],1))' zeros(size(red_ObjRecon,3),size(red_ObjRecon,3))];
    RescaledRed_Mip = uint16(RescaledRed_Mip);
    imwrite(RescaledRed_Mip,fullfile(red_dual_MIP_path,['MIP_Red','_',num2str(num),'.tif']));
    RescaledGreen_Mip = [max(green_ObjRecon,[],3) squeeze(max(green_ObjRecon,[],2));squeeze(max(green_ObjRecon,[],1))' zeros(size(green_ObjRecon,3),size(green_ObjRecon,3))];
    RescaledGreen_Mip = uint16(RescaledGreen_Mip);
    imwrite(RescaledGreen_Mip,fullfile(green_dual_MIP_path,['MIP_Green','_',num2str(num),'.tif']));

    red_ObjRecon = gather(red_ObjRecon);
    green_ObjRecon = gather(green_ObjRecon);
    red_Filename_Out = ['Red',num2str(num),'.nii'];
    green_Filename_Out = ['Green',num2str(num),'.nii'];
    niftiwrite(red_ObjRecon,fullfile(red_dual_path,red_Filename_Out));
    niftiwrite(green_ObjRecon,fullfile(green_dual_path,green_Filename_Out));

end