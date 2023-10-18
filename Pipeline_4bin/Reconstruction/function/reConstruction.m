function reConstruction(file_path_red,file_path_green,red_PSF,green_PSF,atlas,crop_size,start_frame,step_size,end_frame,tform,binsize,x_shift,gpu_index)
%% function summary: reconstruct frames.

%  input:
%   file_path_red/green --- the .tif format image directory path of red/green fish.
%   red/green_PSF --- the PSF of red/green .tif format image.
%   atlas --- the registered template.
%   start_frame, step_size, end_frame --- the number of start frame, step size and end frame.
%   tform --- the transform matrix from green image to red image.
%   gpu_index --- the gpu id. For multi-GPUs, use a vector.  

%  update on 2023.01.06.

%% Initialize the parameters.
    if nargin == 12
        gpu_index = [1 2 3 4];
    end

%% Read the image and run reConstruct function to construct image.
    gpu_num = length(gpu_index);
    all_tifs = sortName(file_path_red);
    all_tifs_g = sortName(file_path_green);
    disp(all_tifs_g);
    spmd_num = ceil((end_frame-start_frame+1)/step_size/gpu_num);

    delete(gcp('nocreate'));
    parpool(gpu_num);
    tic;
    spmd
        gpuDevice(spmdIndex);
        for i = start_frame+spmd_num*(spmdIndex-1)*step_size:step_size:start_frame+(spmd_num*spmdIndex-1)*step_size
            
            if i <= end_frame

                tif_name = all_tifs_g{i};
                num_index=isstrprop(tif_name,'digit');
                num = str2double(tif_name(num_index));

                red_file_Name = fullfile(file_path_red,all_tifs{i});
                green_file_Name = fullfile(file_path_green,all_tifs_g{i});
                if exist(fullfile(file_path_green,'dual_Crop',['Green',num2str(num),'.nii']),"file")
                    continue;
                end
                disp(['frame ',all_tifs{i},' start.']);

                % Reconstruct the red.
                imstack = tif2mat(red_file_Name,binsize);
                red_ObjRecon = reConstruct(imstack,red_PSF,1);
                % Reconstruct the green.
                disp(green_file_Name);
                imstack = tif2mat(green_file_Name,binsize);
                green_ObjRecon = reConstruct(imstack,green_PSF,0);
                green_ObjRecon = flip(green_ObjRecon,1);

                % Transform the green to register the red because of dissynchrony of dichroic mirrors.
                sameAsInput = affineOutputView(size(red_ObjRecon),tform,'BoundsStyle','SameAsInput');
                green_ObjRecon = imwarp(green_ObjRecon,tform,'linear','OutputView',sameAsInput);
                
                % Crop the black background and rotate the two ObjRecons.
                disp('dual crop start.');
                tic;
                dualCrop_G(red_ObjRecon,green_ObjRecon,file_path_red,file_path_green,num,atlas,crop_size,x_shift);
                toc;
                disp(['frame ',num2str(num),' end.']);
                % toc;
            end
            
        end
        
    end
    toc;
    delete(gcp('nocreate'));

    disp('All done!')
end
