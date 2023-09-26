function  imstack = tif2mat(fileName)

Bkg = 0;
disp('loading...');

info=imfinfo(fileName);
imstack=zeros(info(1).Height,info(1).Width,size(info,1));

if info(1).BitDepth==8
    imstack=uint8(imstack);
else
    
    imstack=uint16(imstack);
end

for i=1:size(info)
    imstack(:,:,i)=imread(fileName,'Info',info(i));
end

imstack=uint16(max(imstack-Bkg,0));

end
