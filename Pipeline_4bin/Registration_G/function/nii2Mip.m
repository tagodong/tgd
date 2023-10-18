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
        
        % for regist_red_1_*.nii 
        % name_prex = split(tif_names{i},'.');
        % name_prex = split(name_prex{1},'_');
        % name_num = name_prex{4};

        % for template*.nii
        name_prex = split(tif_names{i},'.');
        name_num = name_prex{1};
        % name_num = num(i);
        % Mip_name = ['MIP','_',num2str(name_num),'.tif'];
        % Mip_name = ['MIP','_',name_num(14:end),'.tif'];
        Mip_name = ['MIP','_',name_num(9:end),'.tif'];
        
        % read the nii image.
        % file_name = ['regist_red_1_',num2str(name_num),'.nii'];
        % ObjRecon = niftiread(fullfile(file_path,file_name));
        ObjRecon = niftiread(fullfile(file_path,tif_names{i}));
    
        % compute the MIP image.
        MIPs=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
    
        imwrite(uint16(MIPs),fullfile(file_path,'mip',Mip_name));

        % display the progress
        % option = struct('indicator','=','prefix','progress:');
        disp(i/length(tif_names));
    end
    
end