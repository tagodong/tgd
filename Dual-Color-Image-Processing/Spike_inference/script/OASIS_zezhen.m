clear
clc;

load('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/CalTrace_new/G_trace.mat');
load('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/CalTrace_new/R_trace.mat');
load('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/CalTrace_new/seg_regions.mat');

sequences = [1 6000;6001 14000];
fs = 10;
time = 120;
% real_sequences = [3370 9369; 13000 20999];

% [Cal_detrend_G,Detrend_G,Cal_weight_mean_G,myfit_G] = mydetrend_zezhen(G_trace,seg_regions);

% [Cal_detrend_R,Detrend_R,Cal_weight_mean_R,baseline_R] = mydetrend(R_trace,seg_regions,sequences);

detrend_ca = zeros(size(R_trace));
for i = 1:size(sequences,1)
    detrend_ca(:,sequences(i,1):sequences(i,2)) = prctfilt(R_trace(:,sequences(i,1):sequences(i,2)),15,fs*time,1,0);
end

ratio_trend = detrend_ca./detrend_ca(:,1);
detrend_R = R_trace./ratio_trend;


detrend_ca_G = zeros(size(G_trace));
for i = 1:1
    detrend_ca_G(:,sequences(i,1):sequences(i,2)) = prctfilt(G_trace(:,sequences(i,1):sequences(i,2)),15,fs*time,1,0);
end

myfittype = fittype('a*exp(-(t)/c)+d',...
    'dependent',{'y'},'independent',{'t'},...
    'coefficients',{'a','c','d'});
for i = 1:size(G_trace,1)
    myfit = fit([1:6000]',[detrend_ca_G(i,1:6000)]',myfittype,'Start', [0,7000,mean(detrend_ca_G(i,1:6000))],'Lower',[0,14000/4,0]);
    detrend_G_fit(i,1:14000) = myfit([1:6000,9631:17630]);
end
detrend_G_fit_ratio = detrend_G_fit./detrend_G_fit(:,1);
detren_G = G_trace./detrend_G_fit_ratio;

Cal_Ratio = detren_G./detrend_R;
f0 = prctile(Cal_Ratio(:,1:6000),20,2);
F0(:,1:14000) = repmat(f0,1,14000);
DRoR = (Cal_Ratio - F0)./F0;
% [DRoR] = DFoF_compute(Cal_Ratio,sequences);

bad_region = [];
for i = 1:size(DRoR,1)
    if sum(DRoR(i,:)==inf)
        bad_region = [bad_region,i];
    end
end
DRoR(bad_region,:) = [];
%% Deconvolute the Calcium trace.
lambda_value = 0.5;
[Cal_spike,Cal_denoise,g,sn,lam,b] = deconv_OASIS(DRoR,sequences,lambda_value);


