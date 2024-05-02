function SNR_info = SNR_statistal(new_neurons,path,start_num)
    all_snr = {};
    files = dir(fullfile(path,'cnmfe_results_*.mat'));
    for i = 1:10
        all_snr{i} = load(fullfile(path,['cnmfe_results_',num2str(start_num+i-1),'.mat'])).SNR;
    end
    neuron_info = tabulate(sum(new_neurons>0,2));
    SNR_info = zeros(size(neuron_info,1),1);
    len_num = zeros(size(neuron_info,1),1);
    for i = 1:size(new_neurons,1)
        len = sum(new_neurons(i,:)>0);
        layers = find(new_neurons(i,:)>0);
        for j = 1:len
            cur_SNR = all_snr{layers(j)};
            len_num(len) = len_num(len) + 1;
            SNR_info(len,len_num(len)) = cur_SNR(new_neurons(i,layers(j)));
        end
    end
end