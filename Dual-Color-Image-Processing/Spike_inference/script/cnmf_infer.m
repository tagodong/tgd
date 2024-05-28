path = '/home/d1/Learn/cnmf_data';
load(fullfile(path,'result','interp_info.mat'));

load(fullfile(path,'result','neurons.mat'));

Ca_trace = merge_C(merge_SNR>2,:);
% Ca_trace_nor = zscore(Ca_trace,1,2);

lambda_value = 0.5;
parpool(60);
[sMatrix_total,denoise_ca,g,sn,lam,b] = deconv_OASIS(Ca_trace,Fragments,lambda_value);
denoise_ca = single(denoise_ca);

Ca_sequence = zeros(size(Fragments));
start_index = 1;
new_C = zeros(size(denoise_ca));
for i = 1:size(Fragments,1)
    new_C(:,Fragments(i,1):Fragments(i,2)) = Ca_trace_nor(:,Fragments(i,1):Fragments(i,2));
    Ca_sequence(i,1:2) = [start_index,start_index+length(Fragments(i,1):Fragments(i,2))-1];
    start_index = start_index+length(Fragments(i,1):Fragments(i,2));
end
new_C = single(new_C);
Ca_SNR = merge_SNR(merge_SNR>2);
Ca_A = foot_A(:,merge_SNR>2);


save(fullfile(path,'result','neurons_infer2.mat'),'denoise_ca','new_C','Ca_SNR','Ca_A','g','b','sn','lam','Cal_id','Ca_SNR','Ca_A','Ca_sequence','-v7.3');


