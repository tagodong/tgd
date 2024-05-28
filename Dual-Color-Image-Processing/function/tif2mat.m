clear
clc

path = '/home/d2/Recon/Check/r';
files = dir(fullfile(path,'*.tif'));

for index = 1:length(files)

    tif_name = files(index).name;
    num = str2double(tif_name(isstrprop(files(index).name,'digit')));

    % 获取图像信息
    info = imfinfo(fullfile(path,files(index).name));

    % 获取图像帧的总数
    numFrames = numel(info);

    % 预分配存储空间，假设所有帧的大小相同
    ObjRecon = zeros(info(1).Height, info(1).Width, numFrames, 'uint16');

    % 读取每一帧并存储在3D矩阵中
    for k = 1:numFrames
        ObjRecon(:, :, k) = imread(fullfile(path,files(index).name), k);
    end

    save(fullfile(path,['Red_Recon_',num2str(num),'.mat']),'ObjRecon');

    disp(['Frame ',num2str(num),' done.']);
end

