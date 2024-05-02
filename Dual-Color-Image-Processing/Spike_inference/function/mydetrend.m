function [Cal_detrend,Detrend_trace,Cal_weight_mean,baseline] = mydetrend(trace,seg_regions,sequences)

%     Cal_weight_mean = zeros(1,size(trace,2),'double');
%     all_pixels = full(sum(seg_regions,'all'));
%     for i = 1:size(seg_regions,2)
%         num_pixels = full(sum(seg_regions(:,i)));
%         Cal_weight_mean = Cal_weight_mean + double(trace(i,:))*num_pixels/all_pixels;
%     end
    for n = 1:size(trace,1)
        baseline = [];
        win_size = 800;
        for j = 1:size(sequences,1)
    
            for i = win_size/2+sequences(j,1):sequences(j,2)-win_size/2+1
                baseline(n,i) = prctile(trace(n,i-win_size/2:i+win_size/2-1),15);
            end
            baseline(n,sequences(j,1):sequences(j,1)+win_size/2-1) = baseline(n,win_size/2+sequences(j,1));
            baseline(n,sequences(j,2)-win_size/2+2:sequences(j,2)) = baseline(n,sequences(j,2)-win_size/2+1);
        end
    end


    figure;
    hold on;
    baseline = baseline./baseline(1,:);
    Detrend_trace = trace./baseline;
    
end