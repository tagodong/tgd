function [foot_A,merge_C,merge_SNR] = spatialMerge(new_neurons,path,start_num,siz)
    all_A = {};
    all_snr = {};
    all_C = {};
    files = dir(fullfile(path,'cnmfe_results_*.mat'));
    for i = 1:length(files)
        all_A{i} = load(fullfile(path,['cnmfe_results_',num2str(start_num+i-1),'.mat'])).A;
        all_snr{i} = load(fullfile(path,['cnmfe_results_',num2str(start_num+i-1),'.mat'])).SNR;
        all_C{i} = load(fullfile(path,['cnmfe_results_',num2str(start_num+i-1),'.mat'])).C;
    end
    temp_C = all_C{1};
    foot_A = sparse(siz(1)*siz(2)*siz(3),size(new_neurons,1));
    merge_C = zeros(size(new_neurons,1),size(temp_C,2));
    merge_SNR = zeros(size(new_neurons,1),1);
    for i = 1:size(new_neurons,1)
        layers = find(new_neurons(i,:)>0);
        neuron_A = zeros(siz(1)*siz(2),length(layers));
        neuron_SNR = zeros(length(layers),1);
        neuron_C = zeros(length(layers),size(temp_C,2));
        for j = 1:length(layers)
             cur_A = all_A{layers(j)};
             neuron_A(:,j) = cur_A(:,new_neurons(i,layers(j)));
             cur_SNR = all_snr{layers(j)};
             neuron_SNR(j) = cur_SNR(new_neurons(i,layers(j)));
             cur_C = all_C{layers(j)};
             neuron_C(j,:) = cur_C(new_neurons(i,layers(j)),:);
        end
        % normalize the spatial weight.
        for j = 1:length(layers)
            cur_weight = neuron_SNR(j)/sum(neuron_SNR);
            neuron_A(:,j) = neuron_A(:,j)*cur_weight;
            index = find(neuron_A(:,j)>0);
            [x,y] = ind2sub([siz(1),siz(2)],index);
            % disp(['neuron:',num2str(i),' layers:',num2str(layers(j))]);
            % disp(x);
            % disp(y);
            new_index = sub2ind(siz,x,y,repmat(layers(j),length(x),1));
            foot_A(new_index,i) = neuron_A(index,j);
            merge_C(i,:) = merge_C(i,:) + cur_weight*neuron_C(j,:);
            merge_SNR(i,1) = merge_SNR(i,1) + cur_weight*neuron_SNR(j);
        end
        if mod(i,ceil(size(new_neurons,1)/20))==0
            disp(['Merging spatial footprint: ',num2str(i/size(new_neurons,1))]);
        end
    end
end