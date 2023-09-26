function  imstack = tif2mat(file_path,binsize)
%% function summary: read the tif file.

%  input:
%   file_path --- the file path of tif multi-view light field image.

%  output:
%   imstack --- the uint16 format image.

%  update on 2023.01.06.

Bkg = 0;
disp('loading...');

info=imfinfo(file_path);
imstack=zeros(info(1).Height,info(1).Width,size(info,1));

if info(1).BitDepth==8
    imstack=uint8(imstack);
else
    
    imstack=uint16(imstack);
end

for i=1:size(info)
    imstack(:,:,i)=imread(file_path,'Info',info(i));
end

imstack = gpuArray(imstack);

imstack=uint16(max(imstack-Bkg,0));
imstack = imageBin(imstack,binsize,2);
end
