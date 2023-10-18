function imageWrite(file_obj_path,file_Mip_path,obj_name,obj_MIP_name,ObjRecon,pattern)

    %% save obj in different format.
    if pattern==1
        save(fullfile(file_obj_path,obj_name),'ObjRecon');
    else
        niftiwrite(obj,fullfile(file_obj_path,obj_name));
    end

    %% save obj MIP.
    obj_MIP = [max(obj,[],3) squeeze(max(obj,[],2));squeeze(max(obj,[],1))' zeros(size(obj,3),size(obj,3))];
    imwrite(obj_MIP,fullfile(file_Mip_path,obj_MIP_name));
    
end