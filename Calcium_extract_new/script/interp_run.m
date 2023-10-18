
file_path='/media/user/Fish-free1/new_0721/new_green/regist_green_MIPs_3/';
% file_pathS=file_path(1:size(file_path,2)-4);
% % % movefile([file_pathS,'MIP_affine*.tif'],file_path);

input_filename = 'regist_green_MIP_3_';
input_extend = '.tif';
start = 1;
Frames = 3824; 
%EOG(Energy Of Gradient) 
A1 = zeros(1,Frames);  % ֵ
for ii=start:Frames
    filename_in = [file_path,input_filename,num2str(ii),input_extend];
    I=double(imread(filename_in));
    [M,N]=size(I);
    FI=0;
    for x= 1:M-1
        for y=1:N-1
            % compute the gradient.ֵ
            FI=FI+(I(x+1,y)-I(x,y))*(I(x+1,y)-I(x,y))+(I(x,y+1)-I(x,y))*(I(x,y+1)-I(x,y));
        end
    end
    
    A1(1,ii) = FI;
    disp(ii)
end

Iq=A1;
m1=mean(Iq);
% figure;plot(Iq(1:Frames))

%% get the bad index and interp it.
bad_index=find(Iq<=Iq(852));

% interp bad.
file_path_green = '/media/user/Fish-free1/new_0721/new_green/regist_green_mat_3/';
file_path_red = '/media/user/Fish-free1/new_0721/new_red/00/';

pre_name_red = 'red_regist_3_';
pre_name_green = 'green_regist_3_';

mip_dir_name_red = 'regist_red_MIPs_3';
mip_dir_name_green = 'regist_green_MIPs_3';

num = 0;
i = start;
while i <= length(bad_index)

    if i < length(bad_index)
        if bad_index(i) == bad_index(i+1)-1
            num = num +1;
            i = i+1;
            continue;
        end
    end
    disp(bad_index(i-num));
    disp(bad_index(i));
    interp_bad(file_path_red,pre_name_red,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_red,3);
    % interp_bad(file_path_green,pre_name_green,bad_index(i-num)-1,bad_index(i)+1,mip_dir_name_green,0);
    num = 0;
    i = i+1;

end


