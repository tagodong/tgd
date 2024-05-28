function split_neurons = recursive_split(neurons, neuron_dist, thresh)
    % 检查输入的neuron的长度
    n = sum(neurons>0);
    
    % 如果长度小于或等于阈值，则直接返回
    if n <= thresh
        split_neurons = neurons;  % 将当前neurons封装在cell中返回
        return;
    else
        % 寻找最小相关性的索引
        [~, split_idx] = max(neuron_dist);
        
        % 分割neurons和neuron_corr
        neurons1 = zeros(1,length(neurons));
        neurons2 = zeros(1,length(neurons));
        neurons1(1:split_idx-1) = neurons(1:split_idx-1);
        neurons2(split_idx:end) = neurons(split_idx:end);
        
        neuron_corr1 = zeros(1,length(neurons));
        neuron_corr2 = zeros(1,length(neurons));
        neuron_corr1(1:split_idx-1) = neuron_dist(1:split_idx-1);
        neuron_corr2(split_idx+1:end) = neuron_dist(split_idx+1:end);
        
        % 递归调用自身来处理两个分割后的部分
        split1 = recursive_split(neurons1, neuron_corr1, thresh);
        split2 = recursive_split(neurons2, neuron_corr2, thresh);
        
        % 合并结果
        split_neurons = [split1; split2];
    end
end
