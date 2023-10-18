function ObjRecon = reConstruct(imstack,PSF_1)
    %% function summary: reconstruct a frame.
        %  input:
        %   imstack --- the mat format from origion tif format.(the output of tif2mat.m)
        %   PSF_1 --- the mat format of PSF file.
        %   red_flag --- if the frame is red then is true, else false.

        %  output:
        %   ObjRecon --- the mat format of reconstructed image.
    
        %   2023.01.06 by tgd.

    %% basic parameters
    BkgMean=110;
    ItN=27;
    ROISize=300;
    SNR=200;
    NxyExt=128;
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
    gpuObjReconTmp=zeros(Nxy,Nxy,'single','gpuArray');
    ImgEst=zeros(Nxy,Nxy,'single','gpuArray');
    Ratio=ones(Nxy,Nxy,'single','gpuArray');

    Img=imstack;
    ImgMultiView=Img-BkgMean;
    ImgExp=gpuArray(padarray(single(ImgMultiView),[NxyExt NxyExt],0,'both'));
    gpuObjRecon=gpuArray(ones(2*ROISize,2*ROISize,Nz,'single'));

    for ii=1:ItN
        display(['iteration: ' num2str(ii)]);
        tic;
        ImgEst=ImgEst*0;
        for jj=1:Nz
            gpuObjReconTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize)=gpuObjRecon(:,:,jj);
            %             ImgEst=ImgEst+max(real(ifft2(fft2(ifftshift(single(PSF(:,:,jj)))).*fft2(gpuObjReconTmp)))/PSFPower,0);
            ImgEst=ImgEst+max(real(ifft2(fft2(ifftshift(single(PSF(:,:,jj)))).*fft2(gpuObjReconTmp)))/sum(sum(PSF(:,:,jj))),0);
            %             ImgEst=ImgEst+abs((ifft2(fft2(ifftshift(single(PSF(:,:,jj)))).*fft2(gpuObjReconTmp)))/sum(sum(PSF(:,:,jj))));
        end

        BkgEst=single(uint16(real(ifft2(fft2(ImgExp-ImgEst).*BkgFilter))*BkgFilterCoef));
        ImgExpEst=single(uint16(ImgExp-BkgEst));

        Tmp=median(ImgEst(:));
        Ratio=Ratio*0+1;
        Ratio(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)=ImgExpEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)./(ImgEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)+Tmp/SNR);
        %         figure(100);imagesc(Ratio);colorbar;caxis([0 100]);
        %         figure(101);imagesc(BkgEst);axis image;caxis([0 30]);
        %         drawnow
        %         k=gather(BkgEst);
        %         imwrite(uint16(k),['BkgEst_' num2str(ii) '.tif']);
        %         k2=gather(ImgEst);
        %         imwrite(uint16(k2),['ImgEst_' num2str(ii) '.tif']);

        for jj=1:Nz
            %             gpuTmp=max(real(ifft2(fft2(Ratio).*conj(fft2(ifftshift(single(PSF(:,:,jj)))))))/PSFPower,0);
            gpuTmp=max(real(ifft2(fft2(Ratio).*conj(fft2(ifftshift(single(PSF(:,:,jj)))))))/sum(sum(PSF(:,:,jj))),0);
            % gpuTmp=max(real(ifft2(fft2(Ratio).*(fft2(ifftshift(single(un_PSF(:,:,jj)))))))/sum(sum(un_PSF(:,:,jj))),0);
            gpuObjRecon(:,:,jj)=gpuObjRecon(:,:,jj).*gpuTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize);
        end
        %       draw max projection views of restored 3d volume
        toc;
    end
    ObjRecon=gather(gpuObjRecon);

end