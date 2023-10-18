function mat2MIP(green_file_path)

    tifstruct = dir(fullfile(green_file_path,'crop_green_2_*.mat'));
    alltifs = {tifstruct.name};

    green_save_path = fullfile(green_file_path,'nii');
    if ~exist(green_save_path,'dir')
        mkdir(green_save_path);
    end

    for i = 1:50

        name_num = split(alltifs{i},'.');
        name_num = split(name_num{1},'_');
        name_num = name_num{4};
        num = str2num(name_num);
        Mip_name = ['MIP','_',num2str(num),'.tif'];
        green_ObjRecon = load(fullfile(green_file_path,['crop_green_2_',num2str(num),'.mat'])).green_image_crop_2nd;
        MIPs=[max(green_ObjRecon,[],3) squeeze(max(green_ObjRecon,[],2));squeeze(max(green_ObjRecon,[],1))' zeros(size(green_ObjRecon,3),size(green_ObjRecon,3))];
        imwrite(uint16(MIPs),fullfile(green_file_path,'mip',Mip_name));
        disp(['crop_green_2_',num2str(num),'.mat have done.']);

    end

end