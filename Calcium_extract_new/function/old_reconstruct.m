function ObjRecon = old_reconstruct(fileName,info,PSF1,PSF2,num)
    %% Input parameters:
    Bkg = 160; 
    
    imstack=zeros(info(1).Height,info(1).Width,1);
    if info(1).BitDepth==8
        imstack=uint8(imstack);
    else
        imstack=uint16(imstack);
    end

    imstack=imread(fileName,'Info',info(num));
    imstack=uint16(max(imstack-Bkg,0));

    %ImgMultiView=imread('test.tif');
    RatioAB=0.9351;
    ItN=25;
    ROISize=300;

    NxyExt=201;
    Nxy=size(PSF1,1)+NxyExt*2;
    Nz=size(PSF1,3);
    Nf=size(imstack,3);

    for i=1:Nf   %%%%from 1st frame to last frame
        ImgMultiView=flip(imstack(:,:,i),1);

        PSF_A=padarray(PSF1,[NxyExt NxyExt 0],0,'both');
        PSF_B=padarray(PSF2,[NxyExt NxyExt 0],0,'both');
        PSF_A=gpuArray(PSF_A);
        PSF_B=gpuArray(PSF_B);

        NxyAdd=round((Nxy/RatioAB-Nxy)/2);
        NxySub=round(Nxy*(1-RatioAB)/2)+NxyAdd;

        gpuTmp1=gpuArray(complex(single(zeros(Nxy+NxyAdd*2,Nxy+NxyAdd*2))));
        gpuTmp2=single(gpuTmp1);
        gpuTmp3=zeros(Nxy,Nxy,'single','gpuArray');
        gpuObjReconTmp=zeros(Nxy,Nxy,'single','gpuArray');
        gpuObjRecon=gpuArray(ones(2*ROISize,2*ROISize,Nz,'single'));

        ImgExp=gpuArray(padarray(single(ImgMultiView),[NxyExt NxyExt],0,'both'));
        ImgEst=zeros(Nxy,Nxy,'single','gpuArray');
        Ratio=zeros(Nxy,Nxy,'single','gpuArray');
        for ii=1:ItN
            display(['iteration: ' num2str(ii)]);
            tic;
            ImgEst=ImgEst*0;
            for jj=1:Nz
                gpuObjReconTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize)=gpuObjRecon(:,:,jj);
                gpuTmp1(NxyAdd+1:end-NxyAdd,NxyAdd+1:end-NxyAdd)=fftshift(fft2(gpuObjReconTmp));
                gpuTmp2=abs(ifft2(ifftshift(gpuTmp1)));
                ImgEst=ImgEst+max(real(ifft2(fft2(ifftshift(single(PSF_A(:,:,jj)))).*fft2(gpuObjReconTmp))),0)...
                    +max(real(ifft2(fft2(ifftshift(single(PSF_B(:,:,jj)))).*fft2(gpuTmp2(NxyAdd+1:end-NxyAdd,NxyAdd+1:end-NxyAdd)))),0);
            end
            gpuTmp4=ImgExp(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)./(ImgEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)+eps);
            Ratio=Ratio*0+single(mean(gpuTmp4(:))*(ImgEst>(max(ImgEst(:))/200)));
            Ratio(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)=ImgExp(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)./(ImgEst(NxyExt+1:end-NxyExt,NxyExt+1:end-NxyExt)+eps);
            gpuTmp2=gpuTmp2*0;
            for jj=1:Nz
                gpuTmp1(NxyAdd+1:end-NxyAdd,NxyAdd+1:end-NxyAdd)=fftshift(fft2(Ratio).*conj(fft2(ifftshift(single(PSF_B(:,:,jj))))));
                gpuTmp2(NxySub+1:end-NxySub,NxySub+1:end-NxySub)=abs(ifft2(ifftshift(gpuTmp1(NxySub+1:end-NxySub,NxySub+1:end-NxySub))));
                gpuObjReconTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize)=gpuObjRecon(:,:,jj);
                gpuTmp3=gpuObjReconTmp.*(max(real(ifft2(fft2(Ratio).*conj(fft2(ifftshift(single(PSF_A(:,:,jj))))))),0)+gpuTmp2(NxyAdd+1:end-NxyAdd,NxyAdd+1:end-NxyAdd))/2;
                gpuObjRecon(:,:,jj)=gpuTmp3(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize);
            end
            toc;
            % draw max projection views of restored 3d volume  
            % figure(1);
            % subplot(1,3,1);
            % imagesc(squeeze(max(gpuObjRecon,[],3)));
            % title(['iteration ' num2str(ii) ' xy max projection']);
            % xlabel('x');
            % ylabel('y');
            % axis equal;

            % subplot(1,3,2);
            % imagesc(squeeze(max(gpuObjRecon,[],2)));
            % title(['iteration ' num2str(ii) ' yz max projection']);
            % xlabel('z');
            % ylabel('y');
            % axis equal;

            % subplot(1,3,3);
            % imagesc(squeeze(max(gpuObjRecon,[],1)));
            % title(['iteration ' num2str(ii) ' xz max projection']);
            % xlabel('z');
            % ylabel('x');
            % axis equal;
            % drawnow
        end
        ObjRecon = gather(gpuObjRecon);

    end
end