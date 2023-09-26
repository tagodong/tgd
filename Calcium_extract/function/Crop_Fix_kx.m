function Crop_Fix_kx(file_Path, ExpLogs)
    %% function summary: crop the backgroup and rotate the fish to standard.
        %  input:
        %   file_path --- the directory path of input and output.
        %   startFrame --- the first frame number.
        %   stepSize --- the step size of frame number.
        %   endFrame --- the end of frame number.
    
        %   2022.11.30 by tgd according to SC.
    
    %% 
    %%%%%%%%%%%%%%%%%
    % Obj_P=zeros(210,308,400);
    % % read Referenced standard atlas
    % Ref=niftiread('Ref-zbb2.nii');
    
    % creat sub-folders
    % for LL=70:1:220
    % % 
    % MIP_PATH=[file_path 'Layer_' num2str(LL) '/']
    % if exist(MIP_PATH)==0
    %     mkdir(MIP_PATH)
    % else
    %     disp('MIP folder is exist!');
    % end
    % 
    % end
    %%%%%%%%%%%%
    
    % waittext(0,'init');
    crop_size = [308,400,210];
    
    % create directory of red MIPs and green MIPs.

    Crop_Mip_Path = fullfile(file_Path,'Crop_MIPs');
    % mkdir the mip directory.
    if ~exist(Crop_Mip_Path)
        mkdir(Crop_Mip_Path);
    end
    
    recon_path = fullfile(file_Path,'recon');
    recon_mat = dir(fullfile(recon_path,'*.mat'));
    
    for ii = 1:length(recon_mat)
        
        % read ObjRecon file.
        filename_in = recon_mat(ii).name;
        frame_num = str2num(filename_in(1:6));
        frame_index = find(ExpLogs.frameNum==frame_num);
        load(fullfile(recon_path,filename_in),'ObjRecon');

        % flip the fish
        ObjRecon = flip(ObjRecon,3);
    
    %% firstly rotate the fish to vertical in XY plane
        real_rotate_xy = ExpLogs.rotationAngleX(frame_index);
        ObjRecon=imrotate(ObjRecon,-real_rotate_xy,'bicubic', 'crop');
        
    %% secondly check the fish right vertival, if not flip it.
        BW_ObjRecon = ObjRecon > mean(mean(mean(ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
        statsX = regionprops3(BW_ObjRecon,'volume','Centroid');
        propX = cell2mat(table2cell(statsX));
        [~, index]=max(propX(:,1));
        CentroID = propX(index,2:4);
        [~,Y,~] = size(ObjRecon);
        
        % if CentroID(2) < (Y/2)
        %     ObjRecon = imrotate(ObjRecon, 180,'bicubic', 'crop');
        % end
        
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
        
        Obj_interp = uint16(interp3(ObjRecon,X,Y,Z,'spline'));
        
        % write the image to nift file.
        if flag == 1
            Obj_interp = Obj_interp(6:crop_size(2)+5,6:crop_size(1)+5,1:crop_size(3));
        else
            if flag == 2
                Obj_interp = Obj_interp(6:crop_size(2)+5,6:crop_size(1)+5,7:crop_size(3)+6);
            else
                Obj_interp = Obj_interp(6:crop_size(2)+5,6:crop_size(1)+5,4:crop_size(3)+3);
            end
        end
        
        niftiwrite(Obj_interp,fullfile(file_Path,['Obj',num2str(frame_index),'.nii']));
        
        % write the MIP of RescaledRed to ./MIPs/*.tif for check them convenient.
        RescaledObj_Mip = [max(Obj_interp,[],3) squeeze(max(Obj_interp,[],2));squeeze(max(Obj_interp,[],1))' zeros(size(Obj_interp,3),size(Obj_interp,3))];
        RescaledObj_Mip = uint16(RescaledObj_Mip);
        imwrite(RescaledObj_Mip,fullfile(Crop_Mip_Path,['MIP_Obj','_',num2str(frame_index),'.tif']));
       
        % waittext(((ii-startFrame)/stepSize+1)/(floor((endFrame-startFrame)/stepSize)+1)*100,'percent');

        disp(ii);
    end
    
    end