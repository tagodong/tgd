
% % % clear all;
close all;
clc;

%% binning scale
scalePSF=1/4;
%% Input parameters:
gpuDevice(1);% reset gpu device
tic;
disp(['start read PSF....'])
PSF_1=load('C:\Users\USER\Nutstore\1\online-Zebrafish-Opto-Tools\PSFr_221009.mat','PSF_1');
PSF_1=PSF_1.PSF_1;
BkgMean=140;
PSF_1=single(PSF_1);
% PSF_1=PSF_1(:,:,25:end-26);
PSF_1=imresize3(PSF_1,scalePSF);
OTF_1=fft2(PSF_1);
toc;

%% basic parameters
ItN=20;
ROISize=100;
SNR=200; 
NxyExt=0;
Nxy=size(PSF_1,1)+NxyExt*2;
Nz=size(PSF_1,3);

% filtering parameters
BkgFilterCoef=0.0;
x=[-Nxy/2:1:Nxy/2-1];
[x y]=meshgrid(x,x);
R=sqrt(x.^2+y.^2);
Rlimit=20;
RWidth=20;

BkgFilter=gpuArray(single(ifftshift((cos((R-Rlimit)/RWidth*pi)/2+1/2).*(R>=Rlimit).*(R<=(Rlimit+RWidth))+(R<Rlimit))));
PSF=gpuArray(uint16(padarray(PSF_1,[NxyExt NxyExt],0,'both')));
OTF=gpuArray(padarray(OTF_1,[NxyExt NxyExt],0,'both'));
ImgEst=zeros(Nxy,Nxy,'single','gpuArray');
Ratio=ones(Nxy,Nxy,'single','gpuArray');
BkgEst=zeros(Nxy,Nxy,'uint16','gpuArray');
gpuObjRecon=gpuArray(ones(Nxy,Nxy,Nz,'single'));
gpuObjRecROI=gpuArray(ones(ROISize*2,ROISize*2,Nz,'single'));


%%
% [FileName,rootPath,FilterIndex] = uigetfile({'*.*','All Files (*.*)'},'MultiSelect','on');
rootPath='E:\g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16\red\beforeRecon\';
subfolders=getsubfolders(rootPath);

for aa=1:length(subfolders)

    rawPath=[rootPath,subfolders{aa},'\'];

    objPath=[rawPath,'recon20/'];
    if ~exist(objPath,'dir')
        mkdir(objPath);
    end
    mipPath=[rawPath,'MIP20/'];
    if ~exist(mipPath,'dir')
        mkdir(mipPath);
    end

    FileNames=dir(fullfile(rawPath,'*.tif'));
    disp(['find ',num2str(length(FileNames)), ' files'])
    for kk=1:length(FileNames)
        FileName=FileNames(kk).name;
        a = find('.'==FileName);
        iname=FileName(1:a-1);

        % savePath=[rootPath iname '/']
        % if ~exist(savePath,'dir')
        %     mkdir(savePath);
        % end
        % MIPSavePath=[savePath 'MIP' '/']
        % if ~exist(MIPSavePath,'dir')
        %     mkdir(MIPSavePath);
        % end
        % ObjSavePath=[savePath 'beforeRotation' '/']
        % if ~exist(ObjSavePath,'dir')
        %     mkdir(ObjSavePath);
        % end


        if iscell(FileName)==1
            numframe=size(FileName,2);
        else
            numframe=1;
        end



        for pp=1:1:numframe
        % % % for pp=1:1:100
            if numframe==1
            name=FileName;
            else
            name=FileName{pp};
            end
            info=imfinfo([rawPath name]);

            % fid=fopen('2Xtime.txt','w');
            for qq=1:size(info,1)
                Img=imread([rawPath name],qq);
                Img=imresize(Img,scalePSF);
                ImgMultiView=Img-BkgMean;
                tic;
                ImgExp=gpuArray(padarray(single(ImgMultiView),[NxyExt NxyExt],0,'both'));
                gpuObjRecon(:)=1;
                gpuObjRecROI(:)=0;
                Ratio(:)=1;

                for ii=1:ItN
                    ImgEst=sum(max(real(ifftshift(ifft2(OTF.*fft2(gpuObjRecon)))),0),3);

                    Tmp=median(ImgEst(:));
                    Ratio(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)=ImgExp(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)./(ImgEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)+Tmp/SNR);
                    fftRatio = repmat(fft2(Ratio),[1,1,Nz]);
                    gpuObjRecon = gpuObjRecon.*max(real(ifftshift(ifftshift(ifft2(fftRatio.*conj(OTF)),1),2)),0);
                end
                toc;
                gpuObjRecROI=gpuObjRecon(round(Nxy/2-ROISize+1:Nxy/2+ROISize),round(Nxy/2-ROISize+1:Nxy/2+ROISize),:);
                ObjRecon=gather(gpuObjRecROI);
                MIPs=show_mipn(ObjRecon);
                if size(info,1)==1
                    imwrite(uint16(MIPs),[mipPath,iname,'_MIP_',num2str(pp,'%04d'),'.tif']);
                    imstackwrite([objPath,iname,'_Obj_',num2str(pp,'%04d'),'.tif'],uint16(ObjRecon));
                else
                    imwrite(uint16(MIPs),[mipPath,iname,'_MIP_',num2str(qq,'%04d'),'.tif']);
                    imstackwrite([objPath,iname,'_Obj_',num2str(qq,'%04d'),'.tif'],uint16(ObjRecon));

                end
                save([objPath,iname ,'_ObjRecon_',num2str(qq,'%04d'),'.mat'],'ObjRecon');
                % eval(['save(''ObjRecon',num2str(qq),'.mat'',''ObjRecon'');'])%cym
            end

        end
        disp(FileNames(kk).name)
    end
end