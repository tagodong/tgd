function eye_CROP_R(file_path,startFrame,stepSize,endFrame, replace)


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
load('Mask0702.mat');

for ii = startFrame:stepSize:endFrame

disp(ii);

%filename_in = ['Red_1stAffined_',num2str(ii),'.nii'];
filename_in = ['Red_1stAffined_',num2str(ii),'.nii'];


filename_out = ['Red_Cropped_',num2str(ii),'.nii'];
Obj = niftiread([file_path filename_in]);


Obj=uint16(double(Obj).*Mask);

niftiwrite(Obj,[file_path filename_out]);
  if replace
            delete([file_path,filename_in]); % delete the input files to release space
        end

end

end
