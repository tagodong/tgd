function dual_Crop_Fix(file_Path_Red,file_Path_Green,startFrame,stepSize,endFrame)
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
    
    waittext(0,'init');
    crop_size = [308,400,210];
    
    % create directory of red MIPs and green MIPs.

    red_Mip_Path = fullfile(file_Path_Red,'MIPs');
    green_Mip_Path = fullfile(file_Path_Green,'MIPs');

    % mkdir the mip directory.
    if ~exist(red_Mip_Path)
        mkdir(red_Mip_Path);
        mkdir(green_Mip_Path);
    end
    
    for ii = startFrame:stepSize:endFrame
        
        % read ObjRecon file.
        filename_in = ['ObjRecon',num2str(ii),'.mat'];
        red_Filename_Out = ['Red',num2str(ii),'.nii'];
        green_Filename_Out = ['Green',num2str(ii),'.nii'];
        load(fullfile(file_Path_Green,filename_in),'ObjRecon');
        green_ObjRecon = ObjRecon;
        % flip the green image
        % green_ObjRecon = fliplr(green_ObjRecon);
        load(fullfile(file_Path_Red,filename_in),'ObjRecon');
        red_ObjRecon = ObjRecon;

        % flip the fish
        red_ObjRecon = flip(red_ObjRecon,3);
        green_ObjRecon = flip(green_ObjRecon,3);
        
    
    %% firstly rotate the fish to vertical in XY plane
        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
        stats = regionprops3(red_BW_ObjRecon, 'Volume','Orientation');
        prop = cell2mat(table2cell(stats));
        [max_v, index]=max(prop(:,1));
        if max_v < 10^6
            fprintf('the maximium connection volume is %d.\n',max_v);
            disp('the maximium connection volume is too small, it might not be the fish, need to check in person !!!')
            break;
        end
        RotateAngle= prop(index,2:4);
        
        red_ObjRecon=imrotate(red_ObjRecon,-RotateAngle(1),'bicubic', 'crop');
        green_ObjRecon=imrotate(green_ObjRecon,-RotateAngle(1),'bicubic', 'crop');
        
    %% secondly check the fish right vertival, if not flip it.
        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
        statsX = regionprops3(red_BW_ObjRecon,'volume','Centroid');
        propX = cell2mat(table2cell(statsX));
        [~, index]=max(propX(:,1));
        CentroID = propX(index,2:4);
        [~,Y,~] = size(red_ObjRecon);
        
        % if CentroID(2) < (Y/2)
        %     red_ObjRecon = imrotate(red_ObjRecon, 180,'bicubic', 'crop');
        %     green_ObjRecon = imrotate(green_ObjRecon, 180,'bicubic', 'crop');
        % end
        
    %% thirdly rotate the fish vertical in XZ plane.
        red_BW_ObjRecon = red_ObjRecon > mean(mean(mean(red_ObjRecon,'omitnan')+8,'omitnan'),'omitnan');
        statsX = regionprops3(red_BW_ObjRecon,'volume', 'Orientation');
        propX = cell2mat(table2cell(statsX));
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
        
        niftiwrite(red_interp,fullfile(file_Path_Red,red_Filename_Out));
        niftiwrite(green_interp,fullfile(file_Path_Green,green_Filename_Out));
        
        % write the MIP of RescaledRed to ./MIPs/*.tif for check them convenient.
        RescaledRed_Mip = [max(red_interp,[],3) squeeze(max(red_interp,[],2));squeeze(max(red_interp,[],1))' zeros(size(red_interp,3),size(red_interp,3))];
        RescaledRed_Mip = uint16(RescaledRed_Mip);
        imwrite(RescaledRed_Mip,fullfile(red_Mip_Path,['MIP_Red','_',num2str(ii),'.tif']));
        RescaledGreen_Mip = [max(green_interp,[],3) squeeze(max(green_interp,[],2));squeeze(max(green_interp,[],1))' zeros(size(green_interp,3),size(green_interp,3))];
        RescaledGreen_Mip = uint16(RescaledGreen_Mip);
        imwrite(RescaledGreen_Mip,fullfile(green_Mip_Path,['MIP_Green','_',num2str(ii),'.tif']));
        
        waittext(((ii-startFrame)/stepSize+1)/(floor((endFrame-startFrame)/stepSize)+1)*100,'percent');
    end
    
    end