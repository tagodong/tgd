input_filename = 'red_regist_3_';
path = '/home/d1/Seizure221211/red/exp/regist_red/regist_red_mat_3/00/';
input_extend = '.mat';
startnumber = 31082;
%% extract CalTrace again
K = size(A3,2);
e = size(A3,1);
% % % T = frame_end - frame_start + 1;
d = 384;
T = sum(d);
batch_size = 1;
CalTrace3 = zeros(K,T);
b = size(path,1);
stepSize = 1;
g = 0;

for m=1:b
    for ff=1:batch_size:d(m)
        tic;
        % % % for ff=frame_start:batch_size:frame_end
        Y_r = zeros(e,min([d(m),ff+batch_size-1])-ff+1); % load a batch
        for f=ff:min([d(m),ff+batch_size-1])
        fff = (f - 1)*stepSize + startnumber;
% % %             single(ObjRecon) = niftiread([file_path,input_filename,num2str(f),input_extend]);
        filename_in = [input_filename,num2str(fff),input_extend];
        load([path(m,:),filename_in]);
            Y_r(:,f-ff+1) = reshape(single(regist_3_red_image),[e,1]);
        end
        for k=1:K
            temp = Y_r(A3(:,k)>0,:);
% % %             CalTrace(k,ff:min([d(m),ff+batch_size-1])) = mean(temp,1);
            CalTrace3(k,g(m)+ff:g(m)+min([d(m),ff+batch_size-1])) = mean(temp,1);
        end
        disp CalciumTrace3
        disp(m)
        disp(fff)
        toc;
    end
end
save([path,'red_Caltrace3.mat'],'CalTrace3');