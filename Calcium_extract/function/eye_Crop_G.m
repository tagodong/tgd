function eye_CROP_G(file_path,startFrame,stepSize,endFrame, replace)


%%%%%%%%%%%%%%%%%.

% Obj_P=zeros(210,308,400);
% % read Referenced standard atlas
% Ref=niftiread('Ref-zbb2.nii');

% creat sub-folders
% for LL=70:1:220
% % 
% MIP_PATH=[file_path 'Layer_' num2str(LL) '/']
% if exist(MIP_PATH)==0
%     mkdir(MIP_PATH)
% else
%     disp('MIP folder is exist!');
% end
% 
% end
%%%%%%%%%%%%
load('~/EyE_Crop3/Mask0824.mat');

for ii = startFrame:stepSize:endFrame

disp(ii);

%filename_in = ['Red_1stAffined_',num2str(ii),'.nii'];
filename_in = ['Green_1stAffined_',num2str(ii),'.nii'];
filename_out = ['Red_Cropped_',num2str(ii),'.nii'];

Obj = niftiread(fullfile(file_path,'c_regist_1_nii',filename_in));

% write MIPs
Obj_MIP = [max(Obj,[],3) squeeze(max(Obj,[],2));squeeze(max(Obj,[],1))' zeros(size(Obj,3),size(Obj,3))];
Obj_MIP = uint16(Obj_MIP);
imwrite(Obj_MIP,fullfile(file_path,'c_regist_1_mip',['MIP_Red','_',num2str(ii),'.tif']));

Obj = Obj(1:380,:,:);
Obj=uint16(double(Obj).*Mask);

niftiwrite(Obj,fullfile(file_path,'c_crop_2_nii',filename_out));
  if replace
    delete([file_path,filename_in]); % delete the input files to release space
  end

end

end
