function [red, green] = myload(red_recon_path,red_recon_name,green_recon_path,green_recon_name)

    load(fullfile(red_recon_path,red_recon_name),'ObjRecon');
    red = ObjRecon;

    load(fullfile(green_recon_path,green_recon_name),'ObjRecon');
    green = ObjRecon;

end