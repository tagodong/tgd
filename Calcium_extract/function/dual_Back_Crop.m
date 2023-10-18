function dual_Back_Crop(file_path,startFrame,stepSize,endFrame)


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
filename_out = ['Red',num2str(ii),'.nii'];

load(fullfile(file_path,filename_in));  

BWObjRecon = ObjRecon>nanmean((nanmean(nanmean(ObjRecon)+4)));

stats = regionprops3(BWObjRecon, 'Volume','Orientation');
%OrientationAngle 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prop = cell2mat(table2cell(stats));

[maxv, index]=max(prop(:,1));

RotateAngle= prop(index,2:4);

ObjReconRed=imrotate(ObjRecon,-RotateAngle(1),'bicubic', 'crop');



ObjReconRedBW = ObjReconRed>nanmean((nanmean(nanmean(ObjReconRed)+4)));

statsX = regionprops3(ObjReconRedBW,'volume','Centroid');

propX = cell2mat(table2cell(statsX));

[maxv, index]=max(propX(:,1));

CentroID = propX(index,2:4);

[X Y Z] = size(ObjReconRed);
flipmark = 0;

if CentroID(2) < (Y/2)
     disp(CentroID(1));
   disp(CentroID(2));
   if CentroID(2)<275
   ObjReconRed = imrotate(ObjReconRed, 180,'bicubic', 'crop');
   % ObjReconRed = flip(ObjReconRed,2);
  %  ObjReconRed = flip(ObjReconRed,3);
   else
  
    flipmark = 1;
   end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ObjReconRedBW = ObjReconRed>nanmean((nanmean(nanmean(ObjReconRed)+4)));

statsX = regionprops3(ObjReconRedBW,'volume', 'Orientation');

propX = cell2mat(table2cell(statsX));

[maxv, index]=max(propX(:,1));

RotationAngle = propX(index,2:4);



% disp(RotationAngle(3));
ObjReconRed=permute(ObjReconRed,[3 1 2]);
ObjReconRed = imrotate(ObjReconRed,-RotationAngle(2),'bicubic', 'crop');

ObjReconRed=permute(ObjReconRed,[2 3 1]);


ObjReconRed = imrotate(ObjReconRed,180,'bicubic', 'crop');

MIPs=[max(ObjReconRed,[],3) squeeze(max(ObjReconRed,[],2));squeeze(max(ObjReconRed,[],1))' zeros(size(ObjReconRed,3),size(ObjReconRed,3))];
        MIP=uint16(MIPs);
     imagesc(MIPs);
%%%%%%%%%%%%%%%%%%%%
        
ObjReconRedBW = ObjReconRed>nanmean((nanmean(nanmean(ObjReconRed)+4)));

statsX = regionprops3(ObjReconRedBW,'volume','Centroid');

propX = cell2mat(table2cell(statsX));

[maxv, index]=max(propX(:,1));

CentroID = propX(index,2:4);
disp(CentroID(1));

disp(CentroID(2));
disp(CentroID(3));

%if CentroID(2) < (280)
% change for 0924
if CentroID(2) < (300)
    if (CentroID(2)-150)>0 && (CentroID(1)-140)>0 && (CentroID(2)+250) < 600 && (CentroID(1) + 140) < 600 && (CentroID(2) -150 ) < 600 && (CentroID(1)-140 < 600)

    ObjReconRed = ObjReconRed(CentroID(2)-150:CentroID(2)+275, CentroID(1)-140:CentroID(1)+140, 20:250);
    ObjReconRed = imrotate(ObjReconRed, 180,'bicubic', 'crop');
    ObjReconRed = flip(ObjReconRed, 3);
    ObjReconRed = flip(ObjReconRed, 2);
    end
else

      ObjReconRed = imrotate(ObjReconRed, 180,'bicubic', 'crop');
  %  ObjReconRed = flip(ObjReconRed, 3);
  %  ObjReconRed = flip(ObjReconRed, 2);
ObjReconRed = ObjReconRed( CentroID(2)-275:CentroID(2)+150, CentroID(1)-140:CentroID(1)+140, 20:250);
 
end
MIPC=[max(ObjReconRed,[],3) squeeze(max(ObjReconRed,[],2));squeeze(max(ObjReconRed,[],1))' zeros(size(ObjReconRed,3),size(ObjReconRed,3))];
        MIPC=uint16(MIPC);
        
 figure(2); imagesc(MIPC);  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ref=niftiread('Ref-zbb2.nii');

[XObj YObj ZObj] = size(ObjReconRed);

% size of reference atlas
XRef = 380; YRef = 308; ZRef = 210;

[X,Y,Z] = meshgrid(1:YObj/YRef:YObj+1,1:XObj/XRef:XObj+1,1:ZObj/ZRef:ZObj);
RescaledRed = uint16(interp3(ObjReconRed,X,Y,Z,'cubic'));
RescaledRed = RescaledRed(1:XRef, 1:YRef, 1:ZRef);
if flipmark == 1
  
    RescaledRed=flip(RescaledRed,2);
      RescaledRed=flip(RescaledRed,3);
     %

end


niftiwrite(RescaledRed,[file_path,filename_out]);

% Obj_P=permute(RescaledRed,[3 2 1]);
% %Obj_P=Obj;
% 
% for LL=70:1:220
%     Ltmp=Obj_P(:,:,LL);
%     imwrite(Ltmp,[file_path '/Layer_' num2str(LL) '/L_' num2str(ii) '.tif']);
% end


end





end
