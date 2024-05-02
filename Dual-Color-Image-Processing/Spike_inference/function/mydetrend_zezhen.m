function [Cal_detrend,Detrend_trace,Cal_weight_mean,myfit] = mydetrend_zezhen(trace,seg_regions)

    Cal_weight_mean = zeros(1,size(trace,2),'double');
    all_pixels = full(sum(seg_regions,'all'));
    for i = 1:size(seg_regions,2)
        num_pixels = full(sum(seg_regions(:,i)));
        Cal_weight_mean = Cal_weight_mean + double(trace(i,:))*num_pixels/all_pixels;
    end
%     baseline =
    baseline = [];
    win_size = 800;
    for i = win_size/2+1:length(Cal_weight_mean)-win_size/2+1
        baseline(i,1) = prctile(Cal_weight_mean(i-win_size/2:i+win_size/2-1),15);
    end

    myfittype = fittype('a*exp(-(t)/c)+d',...
    'dependent',{'y'},'independent',{'t'},...
    'coefficients',{'a','c','d'});

    myfit = fit([win_size/2+1:5601]',baseline(win_size/2+1:5601),myfittype,'Start', [0,size(baseline(win_size/2+1:end),1),mean(baseline(win_size/2+1:5601))],'Lower',[0,17630/2,0]);
    base_trend = [myfit(1:6000)',myfit(9631:17630)'];

    figure;
    hold on;
    plot(Cal_weight_mean);
    plot(baseline);
    plot(base_trend);
    

    
    base_trend = base_trend./base_trend(1);

    Detrend_trace = Cal_weight_mean./base_trend;
    Cal_detrend = trace./base_trend;
    plot(Detrend_trace);
    
end