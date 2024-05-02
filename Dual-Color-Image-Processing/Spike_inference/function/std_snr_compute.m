%% std of snr
function std_snr = std_snr_compute(detrend_ca)
nC = size(detrend_ca,1);
std_snr = zeros(nC,1);
for i = 1:nC
snr_curve = snr_compute(detrend_ca(i,:));
std_snr(i) = std(snr_curve);
end