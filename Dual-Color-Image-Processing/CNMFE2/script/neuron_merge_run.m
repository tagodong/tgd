clear
clc
path = '/home/d1/Learn/cnmf_data/result/matdata';
siz = [323,235,156];
dist_thresh = 5;
corr_thresh = 0.6;
start_layers = 8;
[neurons,neuron_corr,Cost] = neuron_merge(path,siz(1:2),dist_thresh,corr_thresh,start_layers);
thresh = 8;
new_neurons = [];
for i = 1:size(neurons,1)
    split_neurons = recursive_split(neurons(i,:), neuron_corr(i,:), thresh);
    new_neurons = [new_neurons;split_neurons];
    if mod(i,ceil(size(neurons,1)/20))==0
        disp(['Spliting the neurons: ',num2str(i/size(neurons,1))]);
    end
end

[foot_A,merge_C,merge_SNR] = spatialMerge(new_neurons,path,start_layers,siz);

save('/home/d1/Learn/cnmf_data/result/neurons.mat','foot_A','merge_C','merge_SNR','new_neurons','neurons','neuron_corr','Cost','-v7.3');
% SNR_info = SNR_statistal(new_neurons,path,start_layers);

% num = 70;
% C = load(fullfile(path,['cnmfe_results_',num2str(num),'.mat'])).C;
% corr_C = corrAnalysis(C);

