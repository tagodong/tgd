
% clear;
clc;
x_start=1500;
x_interval=5;
x_end=7200;

% load('0702_NoTotalVariation.mat');
% load('/home/tgd/matlab/Zebrafish_Motion/Data/Mat/Caltrace_0804_3.mat');
% load('Zebrafish_Motion/Data/Mat/AF-0804-3.mat');
% load('Zebrafish_Motion/Data/Mat/zbb4.mat');
load('/home/tgd/matlab/Spike_inference/data/Caltrace_201125.mat');

% ref = double(ObjRecon);
fs = 10;

CalTrace_plot = sMatrix_total;

for x = x_start:x_interval:x_end

    queryRegions = [x x+1 x+2 x+3 x+4];
%     queryRegions = [1517 55 2107];
    
    n = size(queryRegions,2);
    % check the brain area.
%     neuronsSpatialDistribution(queryRegions,A3,ref);

    figure(2);
    num = 1;
    for i = 1:n
        
        % plot the Denoised trace.
        subplot(n, 3, 3*i-2);
        plot(CalTrace3_original(queryRegions(i),:),'g'); hold on;
%         plot(Red_Detrend(i,:),'r'); hold on;
        title(num2str(queryRegions(i)));
%         legend('Green\_Detrend','Red\_Detrend');
        
%         % ratio the mean.
%         OASIS_Spike_mean = OASIS_Spike(i,:)./mean(CalTrace3_green(i,:));
% 
%         % plot the corrected trace.
        subplot(n, 3, 3*i-1);
        plot(CalTrace_plot(queryRegions(i),:),'b'); hold on;
% 
        subplot(n, 3, 3*i);
        plot(denoise_ca(queryRegions(i),:),'b'); hold on;
%         plot(Result{1}.deconv_Ca(queryRegions(i),:),'r'); hold on;
%         
%         plot(OASIS_Spike_mean,'r');hold on;
%         plot(Ratio(i,:),'b');
%         legend('AF\_Spike','OASIS\_Spike','Ratio\_Spike');
%         legend('AF\_Spike','OASIS\_Spike');
        
    end
    
    pause();
    close all;
end