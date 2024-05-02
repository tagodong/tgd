% clear
% clc

%% Load Calcium trace data.
% Cal_red_path = '/data/motor/Calcium_trace/red_calTrace.mat';
% Cal_green_path = '/data/motor/Calcium_trace/green_calTrace.mat';
% 
% load(Cal_red_path,'CalTrace');
% Cal_R = CalTrace;
% 
% load(Cal_green_path,'CalTrace');
% Cal_G = CalTrace;
% 
% load('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/CalTrace/G_trace.mat');
% load('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/CalTrace/R_trace.mat');
% Cal_G = G_trace;
% Cal_R = R_trace;
fs = 10;
time = 30;

%% Compute Ratio.
Cal_Ratio = Cal_G./Cal_R;

%% Compute DFoF.
% load('/data/motor/Calcium_trace/DRoR.mat','DRoR');
% sequences = [1 size(Cal_Ratio,2)];
[DRoR] = DFoF_compute(Cal_Ratio,sequences);

%% Detrend the Calcium trace. 
detrend_ca = zeros(size(DRoR));
for i = 1:size(sequences,1)
    detrend_ca(:,sequences(i,1):sequences(i,2)) = prctfilt(DRoR(:,sequences(i,1):sequences(i,2)),40,fs*time);
end

%% Denoise the trace.
[detrend_ca] = denoise(detrend_ca);

%% Deconvolute the Calcium trace.
lambda_value = 0.5;
sequences = [1 size(DRoR,2)];
[Cal_spike,Cal_denoise,g,sn,lam,b] = deconv_OASIS(DRoR,sequences,lambda_value);

%% Save the resulte.
% save(fullfile('/data/motor/Calcium_trace/Red_OASIS.mat'),'Cal_spike','Red_denoise');

% save(fullfile('/data/zezhen/seizure_23_06_27_lss_g8s_8dpf/Result/s_exp.mat'),'Cal_spike','sequences','Cal_G','Cal_R','Cal_index','A3');

