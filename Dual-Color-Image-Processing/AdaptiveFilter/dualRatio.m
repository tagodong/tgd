%% function summary: To Calculate \delta Ratio/Ratio of Green & Red channel Signals

%  input:
%   Green_Trace --- Green channel signal
%   Red_Trace --- Red channel signal

function correctedDFoF = dualRatio(Green_Trace, Red_Trace)

% Low Pass Filter for denoising
[b, a] = butter(5,0.35,'low');
Green_Trace=filtfilt(b,a,Green_Trace);

[b, a] = butter(5,0.35,'low');
Red_Trace=filtfilt(b,a,Red_Trace);

correctedDFoF = getDFoF(Green_Trace./Red_Trace);

% threshold cutoff on DFoF
correctedDFoF = thresholdDenoise3(correctedDFoF, mean(correctedDFoF)*0.05, 0.05);
% wavelet Denoise on DFoF
correctedDFoF = waveletDenoise(correctedDFoF);

end