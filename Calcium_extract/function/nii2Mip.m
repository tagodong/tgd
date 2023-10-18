function nii2Mip(file_path)
    %nii2Mip - Convert nii to MIP.tif
    % Syntax: Mips = nii2Mip(file_path)

    %   2023.2.28 by tgd.
    
    tifstruct = dir(fullfile(file_path,'./*.nii'));
    tif_names = {tifstruct.name};
    
    for i = 1:length(tif_names)

        % split the image num.
        name_prex = split(tif_names{i},'.');
        name_prex = split(name_prex{1},'_');
        name_num = name_prex{4};
        Mip_name = ['MIP','_',name_num,'.tif'];

        if exist(fullfile(file_path,'mip',Mip_name))
            continue;
        end
        
        % read the nii image.
        ObjRecon = niftiread(fullfile(file_path,tif_names{i}));
    
        % compute the MIP image.
        MIPs=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];

        Mip_name = ['MIP','_',name_num,'.tif'];
    
        imwrite(uint16(MIPs),fullfile(file_path,'mip',Mip_name));
        % display the progress
        % option = struct('indicator','=','prefix','progress:');
        disp(i/length(tif_names));
    end
    
    end