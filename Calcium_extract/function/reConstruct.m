function reConstruct(imstack,PSF_mat,foldername_output,gpu_index)

    parallel.gpu.enableCUDAForwardCompatibility(true);
    gpuDevice(gpu_index);% reset gpu device
    tic;
    load(PSF_mat);
    BkgMean=110;
    toc;

    %% basic parameters
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
    BkgEst=zeros(Nxy,Nxy,'uint16','gpuArray');

    for qq=1:255
        
        if qq <= size(imstack,3)

            Img=imstack(:,:,qq);
            ImgMultiView=Img-BkgMean;
            ImgExp=gpuArray(padarray(single(ImgMultiView),[NxyExt NxyExt],0,'both'));
            gpuObjRecon=gpuArray(ones(2*ROISize,2*ROISize,Nz,'single'));

            for ii=1:ItN
                display(['Img:_' num2str(qq) '; iteration: ' num2str(ii)]);
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
                    gpuObjRecon(:,:,jj)=gpuObjRecon(:,:,jj).*gpuTmp(Nxy/2-ROISize+1:Nxy/2+ROISize,Nxy/2-ROISize+1:Nxy/2+ROISize);
                end
        %       draw max projection views of restored 3d volume
                toc;

            end
            ObjRecon=gather(gpuObjRecon);
            ObjRecon=flip(ObjRecon,2);
            %eval(['save(''ObjRecon',num2str(qq),'.mat'',''ObjRecon'');']) %cym
            filename_output = fullfile(foldername_output,['ObjRecon',num2str(qq),'.mat']);
            save(filename_output,'ObjRecon');

            %MIPs=show_mipn(ObjRecon);
            MIPs=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];

        %     if size(info,1)==1
        %    imwrite(uint16(MIPs),[PathName 'MIP_' name(1:end-4) '.tif']);
        % %   imstackwrite([PathName 'Obj_' name(1:end-4) '.tif'],uint16(ObjRecon));
        %     else
            MIP_name = fullfile(foldername_output,['MIP','_',num2str(qq),'.tif']);
            imwrite(uint16(MIPs),MIP_name);
        % % % %    imstackwrite(uint16(ObjRecon),[PathName 'stack' name(1:end-4) '_' num2str(qq) '.tif']);
        %    
        %     end
            disp('done!');
        end
    end

end