function interp_bad(file_path,pre_name,index_pre,index_post,red_flag)
    %% function summary: interp bad image using linear interpolation.
    
    %  input:
    %   file_path --- the directory path of data.
    %   pre_name --- the prefix name of image. 
    %   index_pre --- the index before the first bad frame.
    %   index_post --- the index after the last bad frame.
    %   red_flag --- 1 for red image and 0 for green image.
    
    %  write: This function will overwrite the bad frame and the original frame
    %  will be add bp labels, but the original MIP will not be save.
    
    % Update on 2023.03.06
    
    %% Run.
        index_pre_name = [pre_name,num2str(index_pre),'.mat'];
        index_post_name = [pre_name,num2str(index_post),'.mat'];
    
        if red_flag == 1
            load(fullfile(file_path,index_pre_name),'red_demons');
            ObjRecon_pre = red_demons;
            load(fullfile(file_path,index_post_name),'red_demons');
            ObjRecon_post = red_demons;
        else
            if red_flag == 0
                load(fullfile(file_path,index_pre_name),'green_demons');
                ObjRecon_pre = green_demons;
                load(fullfile(file_path,index_post_name),'green_demons');
                ObjRecon_post = green_demons;
            end
        end
    
        for i=index_pre+1:index_post-1
            a = (i - index_pre)/(index_post - index_pre); % the weight
            ObjRecon = (1-a)*ObjRecon_pre + a*ObjRecon_post;
    
            % write the interpolated images and add bp labels for original images.
            eval(['!mv ',fullfile(file_path,[pre_name,num2str(i),'.mat']),' ',fullfile(file_path,['bp_',pre_name,num2str(i),'.mat'])]);
            if red_flag
                red_demons = ObjRecon;
                save(fullfile(file_path,[pre_name,num2str(i),'.mat']),'red_demons'); 
            else
                green_demons = ObjRecon;
                save(fullfile(file_path,[pre_name,num2str(i),'.mat']),'green_demons');
            end
            
            % Write MIP.
            MIP=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
            MIP=uint16(MIP);
            if red_flag ~= 0
                imwrite(MIP,fullfile(file_path,'..','red_demons_MIPs',['demons_red_3','_',num2str(i),'.tif']));
            else
                imwrite(MIP,fullfile(file_path,'..','green_demons_MIPs',['demons_green_3','_',num2str(i),'.tif']));
            end
            
        end
    
end
