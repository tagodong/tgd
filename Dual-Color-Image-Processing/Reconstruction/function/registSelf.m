function [green_ObjRecon, red_ObjRecon] = registSelf(path_g,path_r,green_ObjRecon,red_ObjRecon,num,red_flag,red_have,global_number)

    cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/function
    niftiwrite(gather(green_ObjRecon), fullfile(path_g,'Rigid_pre',['Green_Recon_',num2str(num),'.nii']));
    if red_have
        niftiwrite(gather(red_ObjRecon), fullfile(path_r,'Rigid_pre',['Red_Recon_',num2str(num),'.nii']));
    end
    
    if ~exist(fullfile(path_g,'..',['Global_',num2str(global_number),'.nii']),'file')

        if red_flag
            ObjRecon = load(fullfile(path_r,'..','back_up','Red_Recon',['Red_Recon_',num2str(global_number),'.mat'])).ObjRecon;
            niftiwrite(ObjRecon, fullfile(path_r,'..',['Global_',num2str(global_number),'.nii']));
        else
            ObjRecon = load(fullfile(path_g,'..','back_up','Green_Recon',['Green_Recon_',num2str(global_number),'.mat'])).ObjRecon;
            niftiwrite(ObjRecon, fullfile(path_g,'..',['Global_',num2str(global_number),'.nii']));
        end
        
        % eval(['!bash registGlobal.sh ',path_g,' ',path_r,' ',num2str(red_flag),' ',num2str(global_number)]);
    end

    eval(['!bash registSelf.sh ',path_g,' ',path_r,' ',num2str(red_flag),' ',num2str(red_have),' ',num2str(num),' ',num2str(global_number)]);
    green_ObjRecon = niftiread(fullfile(path_g,'Rigid_post',['Green_Rigid_',num2str(num),'.nii']));
    if red_have
        red_ObjRecon = niftiread(fullfile(path_r,'Rigid_post',['Red_Rigid_',num2str(num),'.nii']));
    else
        red_ObjRecon = [];
    end

end