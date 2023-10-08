function reConstruction(file_Path_Red,file_Path_Green,PSF_path_red,PSF_path_green,startFrame,stepSize,endFrame,tform,gpu_index)

    if nargin == 8
        gpu_index = [1 2 3 4];
    end
    num = length(gpu_index);
    delete(gcp('nocreate'));
    parpool(num);
    tifstruct = dir(fullfile(file_Path_Red,'./*.tif'));
    alltifs = {tifstruct.name};
    tifstruct = dir(fullfile(file_Path_Green,'./*.tif'));
    alltifs_g = {tifstruct.name};
    spmd_num = ceil((endFrame-startFrame+1)/stepSize/num);

    %parallel.gpu.enableCUDAForwardCompatibility(true);
    % global PSF;
    red_PSF = load(PSF_path_red).PSF_1;
    green_PSF = load(PSF_path_green).PSF_1;
    spmd
        gpuDevice(spmdIndex);
        for i = startFrame+spmd_num*(spmdIndex-1)*stepSize:stepSize:startFrame+(spmd_num*spmdIndex-1)*stepSize

            j=i;
            
            if j <= endFrame
                tic;
                name = alltifs_g{j};
                cur_num = str2double(name(isstrprop(name,"digit")));
                red_file_Name = fullfile(file_Path_Red,alltifs{j});
                green_file_Name = fullfile(file_Path_Green,alltifs_g{j});

                % if exist(fullfile(file_Path_Green,'dual_Crop',['Green',num2str(num),'.nii']),'file');
                %     continue;
                % end

                disp(['frame ',alltifs{j},' start.']);
                % reconstruct the red.
                disp(red_file_Name);
                imstack = tif2mat(red_file_Name);
                % imstack=flipud(imstack);
                red_ObjRecon = reConstruct(imstack,red_PSF);
                % red_ObjRecon =flipud(red_ObjRecon);
                % reconstruct the green.
                disp(green_file_Name);
                imstack = tif2mat(green_file_Name);
                green_ObjRecon = reConstruct(imstack,green_PSF);
                % green_ObjRecon = flip(green_ObjRecon,1);

                % sameAsInput = affineOutputView(size(red_ObjRecon),tform,'BoundsStyle','SameAsInput');
                % green_ObjRecon = imwarp(green_ObjRecon,tform,'linear','OutputView',sameAsInput);
                
                % dual crop the ObjRecon.
                disp('dual crop start.');
                dual_Crop(red_ObjRecon,green_ObjRecon,file_Path_Red,file_Path_Green,cur_num);
                % disp(['frame ',num2str(cur_num),' end.']);
                toc;
            end
            
        end
        
    end
    delete(gcp('nocreate'));

    disp('All done!')
end