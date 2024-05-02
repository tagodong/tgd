function dual_Crop_norm(red_ObjRecon,green_ObjRecon,heart_flag,file_path_red,file_path_green,num,atlas,crop_size,x_shift)
    %% function summary: Crop the black background and rotate the two ObjRecons. 
    
    %  input:
    %   red_ObjRecon --- the ObjRecon of reconstructed red frame.
    %   green_ObjRecon --- the ObjRecon of reconstructed green frame.
    %   heart_flag --- whether has heart fluorescence.
    %   file_path_red --- the directory path of red frames.
    %   file_path_green --- the directory path of green frames.
    %   num --- the number of current frame name.
    %   atlas --- the registered template.
    %   crop_size --- the image size of cropped.
    %   x_shift --- the x direction shift.
    
    %  write: This function will generate four directories under both file_path_red and 
    % file_path_green.
    %   Green/Red_Crop --- Contain images in nii format which were cropped and rotated.
    %   Green/Red_Crop_MIPs --- Contain the maximum intensity projections in three directions of the images in Green/Red_Crop.
    
    %   update 2023.10.17.
        
    atlas = gpuArray(atlas);
    
    %% If have heart expression, cut the heart.
        if heart_flag
            % red_ObjRecon = red_ObjRecon(:,:,1:225);
            % green_ObjRecon = green_ObjRecon(:,:,1:225);

            red_ObjRecon(1:165,:,271:300) = 0;
            green_ObjRecon(1:165,:,271:300) = 0;
        end
    
    %% First, rotate the fish to vertical in XY plane
        atlas = uint16(atlas);
        mean_thresh = 20;
    
        rotation_flag = 0;
        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
        if sum(red_BW_ObjRecon,'all') > 10^6
            rotation_flag = 1;
            [cor_x,cor_y,cor_z] = ind2sub(size(red_BW_ObjRecon),find(red_BW_ObjRecon));
            cor_coef = pca([cor_x,cor_y,cor_z]);
            [angle_azimuth,angel_elevation] = cart2sph(cor_coef(1,1),cor_coef(2,1),cor_coef(3,1));
            angle_azimuth = gather(angle_azimuth);
            angel_elevation = gather(angel_elevation);
            red_ObjRecon = imrotate(red_ObjRecon,-(angle_azimuth/pi*180),'bicubic','crop');
            green_ObjRecon = imrotate(green_ObjRecon,-(angle_azimuth/pi*180),'bicubic','crop');
    
            red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
            red_ObjRecon = imrotate(red_ObjRecon,-(angel_elevation/pi*180),'bicubic','crop');
            red_ObjRecon = permute(red_ObjRecon,[1 3 2]);
            green_ObjRecon = permute(green_ObjRecon,[1 3 2]);
            green_ObjRecon = imrotate(green_ObjRecon,-(angel_elevation/pi*180),'bicubic','crop');
            green_ObjRecon = permute(green_ObjRecon,[1 3 2]);
    
    %% second, check if the fish is right vertival whose head in the top using template matching, if not flip it.
            flip_flag = 0;
            red_xy_MIP = max(red_ObjRecon,[],3);
            zbb_xy_MIP = max(atlas,[],3);
            cross_corr = normxcorr2(zbb_xy_MIP,red_xy_MIP);
    
            zbb_xy_MIP_flip = max(imrotate(atlas,180,'bicubic', 'crop'),[],3);
            flip_corr = normxcorr2(zbb_xy_MIP_flip,red_xy_MIP);
    
            if max(flip_corr,[],'all') > max(cross_corr,[],'all')
                red_ObjRecon = imrotate(red_ObjRecon,180,'bicubic', 'crop');
                green_ObjRecon = imrotate(green_ObjRecon,180,'bicubic', 'crop');
                flip_flag = 1;
            end

        %% Third, rotate the fish in xz plane.
            red_yz_MIP = squeeze(max(red_ObjRecon,[],1));
            red_yz_bw_MIP = red_yz_MIP > mean_thresh;
            [cor_y,cor_z] = ind2sub(size(red_yz_bw_MIP),find(red_yz_bw_MIP));
            cor_coef = pca([cor_y,cor_z]);
            yz_angle = atan(cor_coef(2,1)/cor_coef(1,1))/pi*180;
            yz_angle = gather(yz_angle);
            if abs(yz_angle) > 90
                yz_angle = yz_angle - 180;
            end

            red_ObjRecon = permute(red_ObjRecon,[2 3 1]);
            red_ObjRecon = imrotate(red_ObjRecon,-yz_angle,'bicubic','crop');
            red_ObjRecon = permute(red_ObjRecon,[3 1 2]);

            green_ObjRecon = permute(green_ObjRecon,[2 3 1]);
            green_ObjRecon = imrotate(green_ObjRecon,-yz_angle,'bicubic','crop');
            green_ObjRecon = permute(green_ObjRecon,[3 1 2]);
    
            red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
            [cor_x,cor_y,cor_z] = ind2sub(size(red_BW_ObjRecon),find(red_BW_ObjRecon));
            CentroID = gather(mean([cor_x,cor_y,cor_z],1));
            intial_size = size(red_BW_ObjRecon);
        else
            intial_size = size(red_ObjRecon);
            CentroID = round(intial_size/2);
        end
    
    %% Fourth, crop the background of the initial size (600*600*300 for us) to cropped size (400*308*210 for us).
    
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
    
    %% Write the results.
    
        % For Red.
        red_crop_path = fullfile(file_path_red,'Red_Crop');
        red_crop_MIP_path = fullfile(file_path_red,'..','back_up','Red_Crop_MIP');
        red_crop_name = ['Red_Crop_',num2str(num),'.nii'];
        red_crop_mip_name = ['Red_Crop_MIP_',num2str(num),'.tif'];
        imageWrite(red_crop_path,red_crop_MIP_path,red_crop_name,red_crop_mip_name,red_ObjRecon,2);
    
        % For Green.
        green_crop_path = fullfile(file_path_green,'Green_Crop');
        green_crop_MIP_path = fullfile(file_path_green,'..','back_up','Green_Crop_MIP');
        green_crop_name = ['Green_Crop_',num2str(num),'.nii'];
        green_crop_mip_name = ['Green_Crop_MIP_',num2str(num),'.tif'];
        imageWrite(green_crop_path,green_crop_MIP_path,green_crop_name,green_crop_mip_name,green_ObjRecon,2);
    
        % For parameters.
        parameter_path = fullfile(file_path_red,'..','back_up','Parameters');
    
        if rotation_flag == 1
            save(fullfile(parameter_path,['Crop_parameter_',num2str(num),'.mat']),'angle_azimuth','angel_elevation','flip_flag','image_size','rotation_flag','yz_angle');
        else
            save(fullfile(parameter_path,['Crop_parameter_',num2str(num),'.mat']),'image_size','rotation_flag');
        end
        
    end