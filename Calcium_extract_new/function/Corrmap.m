%% parameters
clear;
% thresh_Var = 0.1;
thresh_Fmax = 9;
thresh_Fmin = 2;
min_size = 27;
adjacent_distance = 3;
adjacent_distance2 = 2; % sqrt(adjacent_distance^2/3)
file_path = 'D:\\cygwin64\\home\\USER\\20_01_08_05\\';
input_filename = 'affine';
input_extend = '.nii';
frame_start = 1;
frame_end = 200;
filename_in = [input_filename,num2str(frame_start),input_extend];
ObjRecon = niftiread([file_path,filename_in]);
dx = size(ObjRecon,1);
dy = size(ObjRecon,2);
dz = size(ObjRecon,3);

%%
Corr = zeros(dx,dy,dz);
SD = zeros(dx,dy,dz);
Y_mean = zeros(dx,dy,dz);
F_max = zeros(dx,dy,dz);
F_min = ObjRecon;
% DFoF_max = zeros(dx,dy,dz);

%% first round: calculate Y_mean, F_max, F_min
Y_mean = Y_mean + ObjRecon;
for f=frame_start+1:frame_end
    filename_in = [input_filename,num2str(f),input_extend];
    ObjRecon = niftiread([file_path,filename_in]);
    Y_mean = Y_mean + ObjRecon;
    clear temp;
    temp(:,:,:,1) = ObjRecon;
    temp(:,:,:,2) = F_max;
    F_max = squeeze(max(temp,[],4));
    temp(:,:,:,2) = F_min;
    F_min = squeeze(min(temp,[],4));
end
Y_mean = Y_mean/(frame_end-frame_start+1);
Y_mean(F_max<thresh_Fmax) = 0; % mask by thresh_Fmax
Y_mean(F_min<thresh_Fmin) = 0; % mask by thresh_Fmin

%% second round: calculate SD,
for f=frame_start:frame_end
    filename_in = [input_filename,num2str(f),input_extend];
    ObjRecon = niftiread([file_path,filename_in]);
    Y_shift = bsxfun(@minus,ObjRecon,Y_mean);
    SD = SD + Y_shift.*Y_shift;
end
SD = sqrt(SD/(frame_end-frame_start+1));
SD(F_max<thresh_Fmax) = 0; % mask by thresh_Fmax
SD(F_min<thresh_Fmin) = 0; % mask by thresh_Fmin

%% third round: calculate Corr,
for f=frame_start:frame_end
    % tic;
    filename_in = [input_filename,num2str(f),input_extend];
    ObjRecon = niftiread([file_path,filename_in]);
    Y_shift = bsxfun(@minus,ObjRecon,Y_mean);
    Y_shift = Y_shift./SD;
    Y_shift(SD==0) = 0;
    Y_shift(F_max<thresh_Fmax) = 0; % mask by thresh_Fmax
    Y_shift(F_min<thresh_Fmin) = 0; % mask by thresh_Fmin
    for i=1+adjacent_distance:dx-adjacent_distance
        for j=1+adjacent_distance:dy-adjacent_distance
            for k=1+adjacent_distance:dz-adjacent_distance
                % c1 = Y_shift(i,j,k)*Y_shift(i+1,j,k);
                % c2 = Y_shift(i,j,k)*Y_shift(i,j+1,k);
                % c3 = Y_shift(i,j,k)*Y_shift(i,j,k+1);
                % c4 = Y_shift(i,j,k)*Y_shift(i-1,j,k);
                % c5 = Y_shift(i,j,k)*Y_shift(i,j-1,k);
                % c6 = Y_shift(i,j,k)*Y_shift(i,j,k-1);
                % Cov(i,j,k) = Cov(i,j,k)+c1+c2+c3+c4+c5+c6;
                % Cov(i,j,k) = Cov(i,j,k) + (Y_shift(i+1,j,k)+Y_shift(i,j+1,k)+Y_shift(i,j,k+1)+Y_shift(i-1,j,k)+Y_shift(i,j-1,k)+Y_shift(i,j,k-1))*Y_shift(i,j,k);
                % adjacent_points = computeAdjacentPoints(i,j,k,adjacent_distance,dx,dy,dz);
                % num_adjacent_points = size(adjacent_points,1);
                % adjacent_points = [i-adjacent_distance, j, k; i+adjacent_distance, j, k; i, j-adjacent_distance, k; i, j+adjacent_distance, k; i, j, k-adjacent_distance; i, j, k+adjacent_distance];
                temp = Y_shift(i-adjacent_distance, j, k) + Y_shift(i+adjacent_distance, j, k) + Y_shift(i, j-adjacent_distance, k) + Y_shift(i, j+adjacent_distance, k) + Y_shift(i, j, k-adjacent_distance) + Y_shift(i, j, k+adjacent_distance);
                temp = temp + Y_shift(i+adjacent_distance2, j+adjacent_distance2, k+adjacent_distance2) + Y_shift(i-adjacent_distance2, j+adjacent_distance2, k+adjacent_distance2);
                temp = temp + Y_shift(i+adjacent_distance2, j-adjacent_distance2, k+adjacent_distance2) + Y_shift(i-adjacent_distance2, j-adjacent_distance2, k+adjacent_distance2);
                temp = temp + Y_shift(i+adjacent_distance2, j+adjacent_distance2, k-adjacent_distance2) + Y_shift(i-adjacent_distance2, j+adjacent_distance2, k-adjacent_distance2);
                temp = temp + Y_shift(i+adjacent_distance2, j-adjacent_distance2, k-adjacent_distance2) + Y_shift(i-adjacent_distance2, j-adjacent_distance2, k-adjacent_distance2);
                Corr(i,j,k) = Corr(i,j,k) + temp*Y_shift(i,j,k);
            end
        end
    end
    % DFoF = Y_shift./Y_mean;
    % clear temp;
    % temp(:,:,:,1) = DFoF;
    % temp(:,:,:,2) = DFoF_max;
    % DFoF_max = squeeze(max(temp,[],4));
    % f
    % toc
end
% Cov = Cov/(frame_end-frame_start+1);
Corr = Corr/(frame_end-frame_start+1)/14;
Corr_original = Corr;
clear Y_shift;
clear ObjRecon;

% min_Cov = min(Cov(:));
% max_Cov = max(Cov(:));
% Cov = (Cov-min_Cov)/(max_Cov-min_Cov);
min_Corr = min(Corr(:));
max_Corr = max(Corr(:));
Corr = (Corr-min_Corr)/(max_Corr-min_Corr);

% L = watershed(1-Cov);
L = watershed(1-Corr);

L_temp2 = L;
num_components = max(L(:));
% L_temp(Cov<thresh_Cov) = 0;
L_temp2(F_max<thresh_Fmax) = 0;
L_temp2(F_min<thresh_Fmin) = 0;
L_temp2 = bwareaopen(L_temp2,min_size,6);
L_temp2 = uint16(bwlabeln(L_temp2,6));
num_components_keep = max(L_temp2(:));
A = sparse(dx*dy*dz,1);
for k=1:num_components_keep
    temp  = (L_temp2==k);
    A(:,k) = sparse(reshape(double(temp),[dx*dy*dz,1]));
end

%% save A and L_temp2
Fmean = Y_mean;
save([file_path,'CorrMap.mat'],'A','L_temp2','L','SD','F_max','F_min','Fmean','Corr_original');

%% display
index_slice = 1:dz;
num_slices = length(index_slice);
cmap = parula;

max_Corr = max(Corr(:));

clear slices;
slices(:,:,1:num_slices) = Corr(:,:,index_slice);
clear picture;
clear RGB;
for l=1:num_slices
    picture(:,:,l) = uint8(slices(:,:,l)/max_Corr*63);
    RGB(:,:,:,l) = ind2rgb(squeeze(picture(:,:,l)),cmap);
    RGB(:,:,1,l) = RGB(:,:,1,l);
    RGB(:,:,2,l) = RGB(:,:,2,l);
    RGB(:,:,3,l) = RGB(:,:,3,l);
    % figure(l);hold off;imshow(picture);hold on;
end

imwrite(squeeze(RGB(:,:,:,1)),'CorrMap.tif');
for l=2:num_slices
    imwrite(squeeze(RGB(:,:,:,l)),'CorrMap.tif','WriteMode','append');
end
clear slices;
clear picture;
clear RGB;

temp = uint16(L);
imwrite(squeeze(temp(:,:,1)),'L.tif');
for l=2:num_slices
    imwrite(squeeze(temp(:,:,l)),'L.tif','WriteMode','append');
end

temp = uint16(L_temp2);
imwrite(squeeze(temp(:,:,1)),'L_temp2.tif');
for l=2:num_slices
    imwrite(squeeze(temp(:,:,l)),'L_temp2.tif','WriteMode','append');
end

clear Corr;
clear L;
clear F_max;
clear F_min;
clear Corr_original;
clear temp;
clear Y_mean;