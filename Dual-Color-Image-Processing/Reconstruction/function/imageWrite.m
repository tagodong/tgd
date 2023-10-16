function imageWrite(file_obj_path,file_Mip_path,prename_obj,prename_MIP,num,obj,pattern)
    %% save the image to mat format.
    if ~exist(file_obj_path,"dir")
        mkdir(file_obj_path);
        mkdir(file_Mip_path);
    end

    %% save obj in different format.
    if pattern==1
        file_name = [prename_obj,num2str(num),'.mat'];
        save(fullfile(file_obj_path,file_name),'obj');
    else
        file_name = [prename_obj,num2str(num),'.nii'];
        niftiwrite(obj,fullfile(file_obj_path,file_name));
    end


    %% save obj MIP.
    obj_MIP = [max(obj,[],3) squeeze(max(obj,[],2));squeeze(max(obj,[],1))' zeros(size(obj,3),size(obj,3))];
    file_MIP_name = [prename_MIP,num2str(num),'.tif'];
    imwrite(obj_MIP,fullfile(file_Mip_path,file_MIP_name));
end