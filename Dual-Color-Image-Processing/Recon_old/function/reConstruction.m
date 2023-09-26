function reConstruction(file_path_red,file_path_green,red_PSF,green_PSF,atlas,crop_size,start_frame,step_size,end_frame,tform,gpu_index)
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
    if nargin == 10
        gpu_index = [1 2 3 4];
    end

%% Read the image and run reConstruct function to construct image.
    gpu_num = length(gpu_index);
    tif_struct = dir(fullfile(file_path_red,'00*.tif'));
    all_tifs = {tif_struct.name};
    tif_struct = dir(fullfile(file_path_green,'*.tif'));
    all_tifs_g = {tif_struct.name};
    spmd_num = ceil((end_frame-start_frame+1)/step_size/gpu_num);

    delete(gcp('nocreate'));
    parpool(gpu_num);
    spmd
        gpuDevice(spmdIndex);
        for i = start_frame+spmd_num*(spmdIndex-1)*step_size:step_size:start_frame+(spmd_num*spmdIndex-1)*step_size
            
            if i <= end_frame
                tif_name = all_tifs{i};

                % Extract the name num of the frame.
                num_index=isstrprop(tif_name,'digit');
                num = str2double(tif_name(num_index));

                red_file_Name = fullfile(file_path_red,all_tifs{i});
                green_file_Name = fullfile(file_path_green,all_tifs_g{num});
                disp(['frame ',all_tifs{i},' start.']);

                % Reconstruct the red.
                imstack = tif2mat(red_file_Name);
                red_ObjRecon = reConstruct(file_path_red,imstack,red_PSF,1,num);
                % for old data.
                % red_ObjRecon = reConstruct(imstack,flip(red_PSF,1),1);

                % Reconstruct the green.
                disp(green_file_Name);
                imstack = tif2mat(green_file_Name);
                green_ObjRecon = reConstruct(file_path_green,imstack,green_PSF,0,num);
                % for new data.
                green_ObjRecon = flip(green_ObjRecon,1);

                % Transform the green to register the red because of dissynchrony of dichroic mirrors.
                sameAsInput = affineOutputView(size(red_ObjRecon),tform,'BoundsStyle','SameAsInput');
                green_ObjRecon = imwarp(green_ObjRecon,tform,'linear','OutputView',sameAsInput);
                
                file_path_affine = fullfile(file_path_green,'affine_green');
                if ~exist(file_path_affine,"dir")
                    mkdir(file_path_affine);
                end
                objSave(green_ObjRecon, file_path_affine, 0, num);
                % % Crop the black background and rotate the two ObjRecons.
                % disp('dual crop start.');
                % tic;
                % dualCrop(red_ObjRecon,green_ObjRecon,file_path_red,file_path_green,num,atlas,crop_size);
                % toc;
                % disp(['frame ',num2str(num),' end.']);
            end
            
        end
        
    end
    delete(gcp('nocreate'));

    disp('All done!')
end
