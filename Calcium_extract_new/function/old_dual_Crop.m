function old_dual_Crop(ObjRecon,file_Path,num)
    %% function summary: crop the backgroup and rotate the fish to standard.
        %  input:
        %   red_ObjRecon --- the ObjRecon mat of reconstructed red frame.
        %   green_ObjRecon --- the ObjRecon mat of reconstructed green frame.
        %   file_Path_Red --- the path of red frames directory.
        %   file_Path_Green --- the path of green frames directory.
        %   num --- the current frame num.
    
        %   2022.11.30 by tgd according to SC.
    
    crop_size = [308,400,210];
    % red directory.
    Recon_Mip_path = fullfile(file_Path,'recon_MIPs');
    Dual_Mip_path = fullfile(file_Path,'dual_MIPs');
    Dual_path = fullfile(file_Path,'dual_Crop');

    % mkdir the new directory.
    if ~exist(Recon_Mip_path)
        mkdir(Recon_Mip_path);
        mkdir(Dual_path);
        mkdir(Dual_Mip_path);
    end
    
    % flip the fish
    % display(['flip closed.']);
    % ObjRecon = flip(ObjRecon,3);
    
    % write the MIP of the reconstruct file.
    MIP=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
    MIP_name = fullfile(Recon_Mip_path,['MIP',num2str(num),'.tif']);
    imwrite(uint16(MIP),MIP_name);

%% firstly rotate the fish to vertical in XY plane
    BW_ObjRecon = ObjRecon > mean(mean(mean(ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    stats = regionprops3(BW_ObjRecon, 'Volume','Orientation');
    prop = cell2mat(table2cell(stats));
    [max_v, index]=max(prop(:,1));
    if max_v < 10^6
        fprintf('the maximium connection volume is %d.\n',max_v);
        disp('the maximium connection volume is too small, it might not be the fish, need to check in person !!!')
    end
    RotateAngle= prop(index,2:4);
    
    ObjRecon=imrotate(ObjRecon,-RotateAngle(1),'bicubic', 'crop');
    
%% secondly check the fish right vertival, if not flip it.
    % BW_ObjRecon = ObjRecon > mean(mean(mean(ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    % statsX = regionprops3(BW_ObjRecon,'volume','Centroid');
    % propX = cell2mat(table2cell(statsX));
    % [~, index]=max(propX(:,1));
    % CentroID = propX(index,2:4);
    % [~,Y,~] = size(ObjRecon);
    
    
%% thirdly rotate the fish vertical in XZ plane.
    BW_ObjRecon = ObjRecon > mean(mean(mean(ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    statsX = regionprops3(BW_ObjRecon,'volume', 'Orientation');
    propX = cell2mat(table2cell(statsX));
    [~, index]=max(propX(:,1));
    RotateAngle = propX(index,2:4);
    
    ObjRecon=permute(ObjRecon,[3 1 2]);
    ObjRecon = imrotate(ObjRecon,-RotateAngle(2),'bicubic', 'crop');
    ObjRecon=permute(ObjRecon,[2 3 1]);

%% fourthly crop the background of the 600*600*250 to 400*308*210.
    BW_ObjRecon = ObjRecon > mean(mean(mean(ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
    statsX = regionprops3(BW_ObjRecon,'volume','Centroid');
    propX = cell2mat(table2cell(statsX));
    [~, index]=max(propX(:,1));
    CentroID = propX(index,2:4);
    CentroID(2) = CentroID(2) - 40;
    if CentroID(2) < 205
        CentroID(2)=205;
    end
    if CentroID(1) < 159
        CentroID(1) = 159;
    else
        if CentroID(1) > 441
            CentroID(1) = 441;
        end
    end


    % the bounding of fish. Warn: the x coordinates is different with row.
    if CentroID(3) < 110
        image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
            round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
            1,216];
        flag = 1;
    else
        if CentroID(3) > 140
            image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
                round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
                35,250];
            flag = 2;
        else
            image_size = [round(CentroID(1)-crop_size(1)/2-4),round(CentroID(1)+crop_size(1)/2+5), ...
                round(CentroID(2)-crop_size(2)/2-4),round(CentroID(2)+crop_size(2)/2+5),...
                round(CentroID(3)-crop_size(3)/2-2),round(CentroID(3)+crop_size(3)/2+3)];
            flag = 3;
        end
    end
    
    % Warn: the image correspond X and Y is different.
    ObjRecon = ObjRecon(image_size(3):image_size(4),image_size(1):image_size(2),image_size(5):image_size(6));
    
    [X_bound,Y_bound,Z_bound] = size(ObjRecon);
    % Warn: the image correspond X and Y is different.
    [X,Y,Z] = meshgrid(linspace(1,Y_bound,crop_size(1)+10),linspace(1,X_bound,crop_size(2)+10),linspace(1,Z_bound,crop_size(3)+6));
    
    interp = uint16(interp3(ObjRecon,X,Y,Z,'spline'));
    
    % write the image to nift file.
    if flag == 1
        interp = interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
    else
        if flag == 2
            interp = interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
        else
            interp = interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
        end
    end
    
    % write the nii file.
    Filename_Out = ['Green',num2str(num),'.nii'];
    niftiwrite(interp,fullfile(Dual_path,Filename_Out));
    
    % write the MIP file.
    RescaledRed_Mip = [max(interp,[],3) squeeze(max(interp,[],2));squeeze(max(interp,[],1))' zeros(size(interp,3),size(interp,3))];
    RescaledRed_Mip = uint16(RescaledRed_Mip);
    imwrite(RescaledRed_Mip,fullfile(Dual_Mip_path,['MIP','_',num2str(num),'.tif']));
    
end