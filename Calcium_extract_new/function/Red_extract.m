function Red_extract(path,A3_path,input_filename,startnumber)

    load(fullfile(A3_path,'Coherence3.mat'));
    input_extend = '.mat';
    %% extract CalTrace again
    [K,T] = size(CalTrace3_original);
    e = size(A3,1);
    % % % T = frame_end - frame_start + 1;

    FoldInfo = dir(path);
    A=[];
    for i=1:size(FoldInfo,1)
        if FoldInfo(i).isdir==0
            A=[A,i];
        end
    end
    FoldInfo(A)=[];
    FoldInfo(1:2)=[]; % exclude '.' and '..'
    sub_path = '';
    for i=1:size(FoldInfo,1)
        B=FoldInfo(i).name;
        sub_path(i,:)=[path,B,'/'];
    end

    b=size(sub_path,1);
    batch_size = 1;
    CalTrace3 = zeros(K,T);
    stepSize = 1;
    d = zeros(1,b);
    g = 0;
    for m=1:b
        d(m) = size(dir([sub_path(m,:),input_filename,'*',input_extend]),1);
        for ff=1:batch_size:d(m)
            tic;
            % % % for ff=frame_start:batch_size:frame_end
            Y_r = zeros(e,min([d(m),ff+batch_size-1])-ff+1); % load a batch
            for f=ff:min([d(m),ff+batch_size-1])
            fff = (f - 1)*stepSize + startnumber(m);
    % % %             single(ObjRecon) = niftiread([file_path,input_filename,num2str(f),input_extend]);
            filename_in = [input_filename,num2str(fff),input_extend];
            load([sub_path(m,:),filename_in]);
                Y_r(:,f-ff+1) = reshape(single(regist_3_red_image),[e,1]);
            end
            for k=1:K
                temp = Y_r(A3(:,k)>0,:);
    % % %             CalTrace(k,ff:min([d(m),ff+batch_size-1])) = mean(temp,1);
                CalTrace3(k,g+ff:g+min([d(m),ff+batch_size-1])) = mean(temp,1);
            end
            disp CalciumTrace3
            disp(m)
            disp(fff)
            toc;
        end
        g = g + d(m);
    end
    save([path,'red_Caltrace3.mat'],'CalTrace3');
end