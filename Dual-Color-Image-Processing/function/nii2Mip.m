function nii2Mip(file_path)
    %nii2Mip - Convert nii to MIP.tif
    % Syntax: Mips = nii2Mip(file_path)

    %   2023.2.28 by tgd.
    if ~exist(fullfile(file_path,'mip'),"dir")
        mkdir(fullfile(file_path,'mip'));
    end

    tifstruct = dir(fullfile(file_path,'./*.nii'));
    tif_names = {tifstruct.name};

    for i = 1:length(tif_names)

        % split the image num.
        name = tif_names{i};
        name_num = name(isstrprop(name,"digit"));
        Mip_name = ['MIP','_',num2str(name_num),'.tif'];
        
        % read the nii image.
        ObjRecon = niftiread(fullfile(file_path,tif_names{i}));
    
        % compute the MIP image.
        MIPs=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
    
        imwrite(uint16(MIPs),fullfile(file_path,'mip',Mip_name));

        % display the progress
        disp(i/length(tif_names));
        
    end
    
end