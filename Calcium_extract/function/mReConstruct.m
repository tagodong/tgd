function mReConstruct(fileFolder,PSF_mat,gpu_index)

    if nargin == 2
        gpu_index = [1 2 3 4];
    end
    num = length(gpu_index);
    parpool(num);
    tifstruct = dir(fullfile(fileFolder,'./*.tif'));
    alltifs = {tifstruct.name};
    for i=1:num:length(alltifs)
        spmd
            if i+labindex-1 <= length(alltifs)
                curname = split(alltifs(i+labindex-1),'.');
                curpath = fullfile(fileFolder,curname{1});
                disp(curpath);
                mkdir(curpath);
                fileName = fullfile(fileFolder,alltifs{i+labindex-1});
                % tif to mat
                imstack = tif2mat(fileName);
                reConstruct(imstack,PSF_mat,curpath,gpu_index(labindex));
            end
        end
    end
    delete(gcp('nocreate'));

end