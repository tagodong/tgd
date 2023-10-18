file_Path = '/media/user/Fish-free2/20_11_26/';

tifstruct = dir(fullfile(file_Path,'./*.tif'));
alltifs = {tifstruct.name};

for i = 1:length(alltifs)

    file_name = fullfile(file_Path,alltifs{i});
    info=imfinfo(file_name);
    len(i) = size(info,1);
end

