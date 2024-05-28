function cropOnly(green_ObjRecon,red_ObjRecon,heart_flag,file_path_green,file_path_red,num,red_flag,red_have,x_shift,crop_size)

    %% If have heart expression, cut the heart.
    heart_size = [200,220];
    if heart_flag
        if red_have
            red_ObjRecon(1:heart_size(1),:,heart_size(2):300) = 0;
        end
        green_ObjRecon(1:heart_size(1),:,heart_size(2):300) = 0;
    end

    %% Crop the background.
    mean_thresh = 20;
    if red_flag
        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
        [cor_x,cor_y,cor_z] = ind2sub(size(red_BW_ObjRecon),find(red_BW_ObjRecon));
        CentroID = gather(mean([cor_x,cor_y,cor_z],1));
        intial_size = size(red_BW_ObjRecon);
    else
        green_BW_ObjRecon = green_ObjRecon > mean(mean(mean(green_ObjRecon,'omitnan')+mean_thresh,'omitnan'),'omitnan');
        [cor_x,cor_y,cor_z] = ind2sub(size(green_BW_ObjRecon),find(green_BW_ObjRecon));
        CentroID = gather(mean([cor_x,cor_y,cor_z],1));
        intial_size = size(green_BW_ObjRecon);
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

    if red_have
        red_ObjRecon = red_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));
    end
    green_ObjRecon = green_ObjRecon((1+image_size(1)):image_size(2),(1+image_size(3)):image_size(4),(1+image_size(5)):image_size(6));

    %% Write the results.
    % For Red.
    if red_have
        red_crop_path = fullfile(file_path_red,'Red_Crop');
        red_crop_MIP_path = fullfile(file_path_red,'..','back_up','Red_Crop_MIP');
        red_crop_name = ['Red_Crop_',num2str(num),'.nii'];
        red_crop_mip_name = ['Red_Crop_MIP_',num2str(num),'.tif'];
        imageWrite(red_crop_path,red_crop_MIP_path,red_crop_name,red_crop_mip_name,red_ObjRecon,2);
    end

    % For Green.
    green_crop_path = fullfile(file_path_green,'Green_Crop');
    green_crop_MIP_path = fullfile(file_path_green,'..','back_up','Green_Crop_MIP');
    green_crop_name = ['Green_Crop_',num2str(num),'.nii'];
    green_crop_mip_name = ['Green_Crop_MIP_',num2str(num),'.tif'];
    imageWrite(green_crop_path,green_crop_MIP_path,green_crop_name,green_crop_mip_name,green_ObjRecon,2);

    % For parameters.
    parameter_path = fullfile(file_path_red,'..','back_up','Parameters');
    save(fullfile(parameter_path,['Crop_parameter_',num2str(num),'.mat']),'image_size','heart_size');

end