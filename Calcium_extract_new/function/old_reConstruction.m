function endFrame = old_reConstruction(file_name,file_Path,PSF_path,startFrame,stepSize,gpu_index)

    if nargin == 5
        gpu_index = [1 2 3 4];
    end
    num = length(gpu_index);
    parpool(num);
    info=imfinfo(file_name);
    len = size(info,1);
    spmd_num = ceil(len/stepSize/num);
    endFrame = startFrame + len - 1;
    %parallel.gpu.enableCUDAForwardCompatibility(true);
    % global PSF;
    PSF1 = load(PSF_path).PSF1;
    PSF2 = load(PSF_path).PSF2;

    spmd
        gpuDevice(labindex);
        for i = startFrame+spmd_num*(labindex-1)*stepSize:stepSize:startFrame+(spmd_num*labindex-1)*stepSize
            j=i;
            
            if j <= endFrame
                tic;
                num = j - startFrame + 1;
                disp(file_name);
                disp(['frame ',num2str(j),' start.']);
                % reconstruct the red.
                ObjRecon = old_reconstruct(file_name,info,PSF1,PSF2,num);
                
                % dual crop the ObjRecon.
                disp('dual crop start.');
                old_dual_Crop(ObjRecon,file_Path,j);
                disp(['frame ',num2str(j),' end.']);
                toc;
            end
            
        end
        
    end
    delete(gcp('nocreate'));

    disp('All done!');
end