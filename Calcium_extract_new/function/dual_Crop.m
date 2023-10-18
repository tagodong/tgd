function dual_Crop(red_ObjRecon,green_ObjRecon,file_Path_Red,file_Path_Green,num)
    %% function summary: crop the backgroup and rotate the fish to standard.
        %  input:
        %   red_ObjRecon --- the ObjRecon mat of reconstructed red frame.
        %   green_ObjRecon --- the ObjRecon mat of reconstructed green frame.
        %   file_Path_Red --- the path of red frames directory.
        %   file_Path_Green --- the path of green frames directory.
        %   num --- the current frame num.
    
        %   2022.11.30 by tgd according to SC.
    refer_image = niftiread("/home/d2/Ref-zbb2.nii");
    crop_size = [308,400,210];
    % red directory.
    red_Recon_Mip_path = fullfile(file_Path_Red,'recon_MIPs');
    red_Dual_Mip_path = fullfile(file_Path_Red,'dual_MIPs');
    red_Dual_path = fullfile(file_Path_Red,'dual_Crop');
    red_recon_path = fullfile(file_Path_Red,'red_recon_mat');
    % green directory.
    green_Recon_Mip_path = fullfile(file_Path_Green,'recon_MIPs');
    green_Dual_Mip_path = fullfile(file_Path_Green,'dual_MIPs');
    green_Dual_path = fullfile(file_Path_Green,'dual_Crop');
    green_recon_path = fullfile(file_Path_Green,'green_recon_mat');
    % mkdir the new directory.
    if ~exist(red_Recon_Mip_path,"dir")
        mkdir(red_Recon_Mip_path);
        mkdir(red_Dual_path);
        mkdir(red_Dual_Mip_path);
        mkdir(red_recon_path);
        mkdir(green_Recon_Mip_path);
        mkdir(green_Dual_Mip_path);
        mkdir(green_Dual_path);
        mkdir(green_recon_path);
    end
    
    % flip the fish
    red_ObjRecon = flip(red_ObjRecon,3);
    green_ObjRecon = flip(green_ObjRecon,3);
    
    % write the MIP of the reconstruct file.
    red_recon_name = fullfile(red_recon_path,['red_recon',num2str(num),'.mat']);
    save(red_recon_name,'red_ObjRecon');
    green_recon_name = fullfile(green_recon_path,['green_recon',num2str(num),'.mat']);
    save(green_recon_name,'green_ObjRecon');

    red_MIP=[max(red_ObjRecon,[],3) squeeze(max(red_ObjRecon,[],2));squeeze(max(red_ObjRecon,[],1))' zeros(size(red_ObjRecon,3),size(red_ObjRecon,3))];
    red_MIP_name = fullfile(red_Recon_Mip_path,['red_MIP',num2str(num),'.tif']);
    imwrite(uint16(red_MIP),red_MIP_name);
    green_MIP=[max(green_ObjRecon,[],3) squeeze(max(green_ObjRecon,[],2));squeeze(max(green_ObjRecon,[],1))' zeros(size(green_ObjRecon,3),size(green_ObjRecon,3))];
    green_MIP_name = fullfile(green_Recon_Mip_path,['green_MIP',num2str(num),'.tif']);
    imwrite(uint16(green_MIP),green_MIP_name);

%% firstly rotate the fish to vertical in XY plane
    red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    stats = regionprops3(red_BW_ObjRecon, 'Volume','Orientation');
    prop = cell2mat(table2cell(stats));
    if isempty(prop)
        prop = [1,1,1,1];
    end
    [max_v, index]=max(prop(:,1));
    if max_v < 10^6
        fprintf('the maximium connection volume is %d.\n',max_v);
        disp('the maximium connection volume is too small, it might not be the fish, need to check in person !!!')
    end
    RotateAngle= prop(index,2:4);
    
    red_ObjRecon=imrotate(red_ObjRecon,-RotateAngle(1),'bicubic', 'crop');
    green_ObjRecon=imrotate(green_ObjRecon,-RotateAngle(1),'bicubic', 'crop');
    
%% secondly check the fish right vertival, if not flip it.
    red_xy_MIP = max(red_ObjRecon,[],3);
    zbb_xy_MIP = max(refer_image,[],3);
    n_corr = normxcorr2(zbb_xy_MIP,red_xy_MIP);

    zbb_xy_MIP_flip = max(imrotate(refer_image,180,'bicubic', 'crop'),[],3);
    flip_corr = normxcorr2(zbb_xy_MIP_flip,red_xy_MIP);

    if max(flip_corr,[],'all') > max(n_corr,[],'all')
        red_ObjRecon = imrotate(red_ObjRecon,180,'bicubic', 'crop');
        green_ObjRecon = imrotate(green_ObjRecon,180,'bicubic', 'crop');
    end

%% thirdly rotate the fish vertical in XZ plane.
    red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    statsX = regionprops3(red_BW_ObjRecon,'volume', 'Orientation');
    propX = cell2mat(table2cell(statsX));
    if isempty(propX)
        propX = [1,1,1,1];
    end
    [~, index]=max(propX(:,1));
    RotateAngle = propX(index,2:4);
    
    red_ObjRecon=permute(red_ObjRecon,[3 1 2]);
    red_ObjRecon = imrotate(red_ObjRecon,-RotateAngle(2),'bicubic', 'crop');
    red_ObjRecon=permute(red_ObjRecon,[2 3 1]);
    green_ObjRecon=permute(green_ObjRecon,[3 1 2]);
    green_ObjRecon = imrotate(green_ObjRecon,-RotateAngle(2),'bicubic', 'crop');
    green_ObjRecon=permute(green_ObjRecon,[2 3 1]);

%% fourthly crop the background of the 600*600*250 to 400*308*210.
    red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    statsX = regionprops3(red_BW_ObjRecon,'volume','Centroid');
    propX = cell2mat(table2cell(statsX));
    if isempty(propX)
        propX = [1,1,1,1];
    end
    [~, index]=max(propX(:,1));
    CentroID = propX(index,2:4);
    CentroID(2) = CentroID(2) - 80;
    if CentroID(2) < 205
        CentroID(2) = 205;
    end
    if CentroID(2) > 395
        CentroID(2) = 395;
    end

    if CentroID(1) < 159
        CentroID(1) = 159;
    else
        if CentroID(1) > 441
            CentroID(1) = 441;
        end
    end

    % the bounding of fish. Warn: the x coordinates is different with row.
    if CentroID(3) < 108
        image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
            round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
            1,216];
        flag = 1;
    else
        if CentroID(3) > 192
            image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
                round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
                85,300];
            flag = 2;
        else
            image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
                round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
                round(CentroID(3)-crop_size(3)/2-2),round(CentroID(3)+crop_size(3)/2+3)];
            flag = 3;
        end
    end
    
    % Warn: the image correspond X and Y is different.
    red_ObjRecon = red_ObjRecon(image_size(3):image_size(4),image_size(1):image_size(2),image_size(5):image_size(6));
    green_ObjRecon = green_ObjRecon(image_size(3):image_size(4),image_size(1):image_size(2),image_size(5):image_size(6));
    
    [X_bound,Y_bound,Z_bound] = size(red_ObjRecon);
    % Warn: the image correspond X and Y is different.
    [X,Y,Z] = meshgrid(linspace(1,Y_bound,crop_size(1)+10),linspace(1,X_bound,crop_size(2)+10),linspace(1,Z_bound,crop_size(3)+6));
    
    red_interp = uint16(interp3(red_ObjRecon,X,Y,Z,'spline'));
    green_interp = uint16(interp3(green_ObjRecon,X,Y,Z,'spline'));
    
    % write the image to nift file.
    if flag == 1
        red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
        green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
    else
        if flag == 2
            red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
            green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
        else
            red_interp = red_interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
            green_interp = green_interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
        end
    end
    
    % write the nii file.
    red_Filename_Out = ['Red',num2str(num),'.nii'];
    green_Filename_Out = ['Green',num2str(num),'.nii'];
    niftiwrite(red_interp,fullfile(red_Dual_path,red_Filename_Out));
    niftiwrite(green_interp,fullfile(green_Dual_path,green_Filename_Out));
    
    % write the MIP file.
    RescaledRed_Mip = [max(red_interp,[],3) squeeze(max(red_interp,[],2));squeeze(max(red_interp,[],1))' zeros(size(red_interp,3),size(red_interp,3))];
    RescaledRed_Mip = uint16(RescaledRed_Mip);
    imwrite(RescaledRed_Mip,fullfile(red_Dual_Mip_path,['MIP_Red','_',num2str(num),'.tif']));
    RescaledGreen_Mip = [max(green_interp,[],3) squeeze(max(green_interp,[],2));squeeze(max(green_interp,[],1))' zeros(size(green_interp,3),size(green_interp,3))];
    RescaledGreen_Mip = uint16(RescaledGreen_Mip);
    imwrite(RescaledGreen_Mip,fullfile(green_Dual_Mip_path,['MIP_Green','_',num2str(num),'.tif']));
    
end