function [Detrend_trace,Cal_weight_mean,myfit] = mydetrend2(trace,seg_regions,sequences)

    Cal_weight_mean = zeros(1,size(trace,2),'double');
    all_pixels = full(sum(seg_regions,'all'));
    for i = 1:size(seg_regions,2)
        num_pixels = full(sum(seg_regions(:,i)));
        Cal_weight_mean = Cal_weight_mean + double(trace(i,:))*num_pixels/all_pixels;
    end
%     baseline =
    win_size = 800;
    num = 1;
    for j = 1:size(sequences,1)
        if j>1
            num = num + sequences(j-1,2)-sequences(j-1,1)+1;
        end
        for i = win_size/2+num:num+sequences(j,2)-sequences(j,1)-win_size/2+1
            baseline(i,1) = prctile(Cal_weight_mean(i-win_size/2:i+win_size/2-1),15);
        end
    end

    myfittype = fittype('a*exp(-(t-b)/c)+d',...
    'dependent',{'y'},'independent',{'t'},...
    'coefficients',{'a','b','c','d'});

    xx = [];
    x = [];
    for i = 1:size(sequences,1)
        xx = [xx,win_size/2+sequences(i,1):sequences(i,2)-win_size/2+1];
        x = [x,sequences(i,1):sequences(i,2)];
    end
    myfit = fit(xx',baseline(baseline>0),myfittype,'Start', [0,0,sequences(end,2)/2,mean(baseline(baseline>0))],'Lower',[0,-inf,sequences(end,2)/4,0]);
    
    base_trend = myfit(x');
    
    figure;
    hold on;
    plot(Cal_weight_mean);
    plot(baseline);
    plot(base_trend);
    

    
    base_trend = base_trend./base_trend(1);

    Detrend_trace = Cal_weight_mean'./base_trend;
    plot(Detrend_trace);
    
end