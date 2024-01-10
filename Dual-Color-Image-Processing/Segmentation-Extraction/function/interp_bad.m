function interp_bad(file_path,pre_name,index_pre,index_post,red_flag,step)
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

    load(fullfile(file_path,index_pre_name),'ObjRecon');
    ObjRecon_pre = ObjRecon;
    load(fullfile(file_path,index_post_name),'ObjRecon');
    ObjRecon_post = ObjRecon;

    for i=index_pre+step:step:index_post-step
        a = (i - index_pre)/(index_post - index_pre); % the weight
        ObjRecon = uint16((1-a)*single(ObjRecon_pre) + a*single(ObjRecon_post));

        % write the interpolated images and add bp labels for original images.
        eval(['!mv ',fullfile(file_path,[pre_name,num2str(i),'.mat']),' ',fullfile(file_path,['bp_',pre_name,num2str(i),'.mat'])]);

        save(fullfile(file_path,[pre_name,num2str(i),'.mat']),'ObjRecon');
        
        % Write MIP.
        MIP=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
        MIP=uint16(MIP);
        if red_flag == 1
            imwrite(MIP,fullfile(file_path,'..','Red_Demons_MIP',['Red_Demons_MIP_',num2str(i),'.tif']));
        else
            imwrite(MIP,fullfile(file_path,'..','Green_Demons_MIP',['Green_Demons_MIP_',num2str(i),'.tif']));
        end
        
    end

end
