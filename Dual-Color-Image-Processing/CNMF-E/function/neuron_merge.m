function [neurons,neuron_corr,Cost] = neuron_merge(path,siz,dist_thresh,corr_thresh,start_layers)
%% Merge neurons on different planes.
    files = dir(fullfile(path,'*.mat'));
    per_A = load(fullfile(path,['cnmfe_results_',num2str(start_layers),'.mat'])).A;
    per_C = load(fullfile(path,['cnmfe_results_',num2str(start_layers),'.mat'])).C;
    Cost = zeros(length(files)-1,1);
    neurons = zeros(size(per_C,1),length(files));
    neurons(1:size(per_C,1),1) = 1:size(per_C,1);
    per_idx_neurons = 1:size(per_C,1);
    neuron_corr = zeros(size(per_C,1),1);
    for i = 2:length(files)
        post_A = load(fullfile(path,['cnmfe_results_',num2str(start_layers+i-1),'.mat'])).A;
        post_C = load(fullfile(path,['cnmfe_results_',num2str(start_layers+i-1),'.mat'])).C;
        costMat = costGet(per_A,per_C,post_A,post_C,siz,dist_thresh,corr_thresh);
        [match_neuron, Cost(i-1,1)] = munkres(costMat');
        
        for j = 1:length(match_neuron)
            if match_neuron(j) == 0
                neurons(size(neurons,1)+1,i) = j;
                post_idx_neurons(j,1) = size(neurons,1);
                neuron_corr(size(neurons,1),i) = 0;
            else
                neurons(per_idx_neurons(match_neuron(j)),i) = j;
                post_idx_neurons(j,1) = per_idx_neurons(match_neuron(j));
                neuron_corr(per_idx_neurons(match_neuron(j)),i) = costMat(match_neuron(j),j);
            end
        end
        clear per_idx_neurons;
        per_idx_neurons = post_idx_neurons;
        per_A = post_A;
        per_C = post_C;
        clear post_idx_neurons;
        if mod(i,ceil((length(files))/20))==0
            disp(['Merging the neurons: ',num2str(i/(length(files)))]);
        end
    end

end