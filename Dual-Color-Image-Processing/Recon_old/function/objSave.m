function objSave(ObjRecon, file_path, red_flag, num)

    if red_flag
        
        red_recon_MIP_path = fullfile(file_path,'red_recon','mip');
        if ~exist(red_recon_MIP_path,"dir")
            mkdir(fullfile(file_path,'red_recon'));
            mkdir(red_recon_MIP_path);
        end
        
        red_ObjRecon = ObjRecon;
        red_MIP=[max(red_ObjRecon,[],3) squeeze(max(red_ObjRecon,[],2));squeeze(max(red_ObjRecon,[],1))' zeros(size(red_ObjRecon,3),size(red_ObjRecon,3))];
        red_MIP_name = fullfile(red_recon_MIP_path,['red_MIP',num2str(num),'.tif']);
        imwrite(uint16(red_MIP),red_MIP_name);

        % write the reconstructed images.
        red_recon_path = fullfile(file_path,'red_recon','recon');
        if ~exist(red_recon_path,"dir")
            mkdir(red_recon_path);
        end
        
        red_ObjRecon = gather(red_ObjRecon);
        red_recon_name = fullfile(red_recon_path,['red_recon',num2str(num),'.mat']);
        save(red_recon_name,'red_ObjRecon');
    else

        green_recon_MIP_path = fullfile(file_path,'green_recon','mip');
        if ~exist(green_recon_MIP_path,"dir")
            mkdir(fullfile(file_path,'green_recon'));
            mkdir(green_recon_MIP_path);
        end
        
        green_ObjRecon = ObjRecon;
        green_MIP=[max(green_ObjRecon,[],3) squeeze(max(green_ObjRecon,[],2));squeeze(max(green_ObjRecon,[],1))' zeros(size(green_ObjRecon,3),size(green_ObjRecon,3))];
        green_MIP_name = fullfile(green_recon_MIP_path,['green_MIP',num2str(num),'.tif']);
        imwrite(uint16(green_MIP),green_MIP_name);

        % write the reconstructed images.
        green_recon_path = fullfile(file_path,'green_recon','recon');
        if ~exist(green_recon_path,"dir")
            mkdir(green_recon_path);
        end
        
        green_ObjRecon = gather(green_ObjRecon);
        green_recon_name = fullfile(green_recon_path,['green_recon',num2str(num),'.mat']);
        save(green_recon_name,'green_ObjRecon');

    end

end