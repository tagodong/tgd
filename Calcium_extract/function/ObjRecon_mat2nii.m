function ObjRecon_mat2nii(file_path,startFrame,stepSize,endFrame, replace)


%%%%%%%%%%%%%%%%%

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

for ii = startFrame:stepSize:endFrame

disp(ii);

filename_in = ['ObjRecon',num2str(ii),'.mat'];
filename_out = ['ObjRecon',num2str(ii),'.nii'];
load(fullfile(file_path,filename_in));  
niftiwrite(ObjRecon,fullfile(file_path,filename_out));

    if replace
        delete(fullfile(file_path,filename_in)); % delete the input files to release space
    end

end

end