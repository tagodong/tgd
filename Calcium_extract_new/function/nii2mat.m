function nii2mat(file_path,pre_name)
    % nii2mat - Convert *.nii to *.mat
    % file_path - the nii file path
    % pre_name - the directory name of mat file to save.(the directory path is file_path/../pre_name)

    % by tgd, 2023-01-02
    
    tifstruct = dir(fullfile(file_path,'./*.nii'));
    tif_names = {tifstruct.name};

    if ~exist(fullfile(file_path,'..',pre_name))
        mkdir(fullfile(file_path,'..',pre_name));
    end

    %waittext(0,'init');

    for i = 1:length(tif_names)

        ObjRecon = niftiread(fullfile(file_path,tif_names{i}));
    
        name_prex = split(tif_names{i},'.');
        name_prex = split(name_prex{1},'_');
        name_num = name_prex{4};

        Mat_name = [pre_name,'_',name_num,'.mat'];

        save(fullfile(file_path,'..',pre_name,Mat_name),'ObjRecon');
        % display the progress
        % option = struct('indicator','=','prefix','progress:');
        %waittext(i/length(tif_names)*100,'percent');
        disp(i/length(tif_names)*100);
    end
        
end