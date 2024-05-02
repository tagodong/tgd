function ObjRecon = reConstruct(imstack,PSF)
%% function summary: reconstruct a frame using RLD.

%  input:
%   imstack --- the mat format from origion tif format.(the output of tif2mat.m)
%   PSF --- the mat format of PSF file.

%  output:
%   ObjRecon --- the mat format of reconstructed image.

%  update on 2023.01.06.

%% Basic parameters.
    ItN=27;
    BkgMean=120;
    ROISize=300;
    SNR=200;
    NxyExt=128;
    Nxy=size(PSF,1)+NxyExt*2;
    Nz=size(PSF,3);

%% Initialize the variables and transform to GPU.
    BkgFilterCoef=0.0;
    x=-Nxy/2:1:Nxy/2-1;
    [x, y]=meshgrid(x,x);
    R=sqrt(x.^2+y.^2);
    Rlimit=20;
    RWidth=20;

    BkgFilter=gpuArray(single(ifftshift((cos((R-Rlimit)/RWidth*pi)/2+1/2).*(R>=Rlimit).*(R<=(Rlimit+RWidth))+(R<Rlimit))));
    PSF=gpuArray(uint16(padarray(PSF,[NxyExt NxyExt],0,'both')));
    gpuObjReconTmp=zeros(Nxy,Nxy,'single','gpuArray');
    ImgEst=zeros(Nxy,Nxy,'single','gpuArray');
    Ratio=ones(Nxy,Nxy,'single','gpuArray');

    Img=imstack;
    ImgMultiView=Img-BkgMean;
    ImgExp=gpuArray(padarray(single(ImgMultiView),[NxyExt NxyExt],0,'both'));
    gpuObjRecon=gpuArray(ones(2*ROISize,2*ROISize,Nz,'single'));

%% Run RLD
    for ii=1:ItN

        ImgEst=ImgEst*0;
        for jj=1:Nz
            gpuObjReconTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize)=gpuObjRecon(:,:,jj);
            ImgEst=ImgEst+max(real(ifft2(fft2(ifftshift(single(PSF(:,:,jj)))).*fft2(gpuObjReconTmp)))/sum(sum(PSF(:,:,jj))),0);
        end

        BkgEst=single(uint16(real(ifft2(fft2(ImgExp-ImgEst).*BkgFilter))*BkgFilterCoef));
        ImgExpEst=single(uint16(ImgExp-BkgEst));

        Tmp=median(ImgEst(:));
        Ratio=Ratio*0+1;
        Ratio(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)=ImgExpEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)./(ImgEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)+Tmp/SNR);
        
        for jj=1:Nz
            gpuTmp=max(real(ifft2(fft2(Ratio).*conj(fft2(ifftshift(single(PSF(:,:,jj)))))))/sum(sum(PSF(:,:,jj))),0);
            gpuObjRecon(:,:,jj)=gpuObjRecon(:,:,jj).*gpuTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize);
        end

    end
    
    ObjRecon=uint16(gpuObjRecon);

end