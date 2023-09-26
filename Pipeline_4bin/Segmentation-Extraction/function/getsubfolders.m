function [subfolders]=getsubfolders(path)
    file=dir(path);
    subfolders={file.name}';
    fileidx=[];
    for i =1:length(subfolders)
        fullpath=fullfile(path,subfolders{i});
        if(~isfolder(fullpath))
            fileidx=cat(1,fileidx,i);
        end
        if (isequal(subfolders{i},'..')||isequal(subfolders{i},'.'))
            fileidx=cat(1,fileidx,i);
        end
    end
    subfolders(fileidx)=[];
end

