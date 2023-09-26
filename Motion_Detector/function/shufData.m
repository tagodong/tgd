function [train_set,val_set,test_set]=shufData(ori_set,per_set)
    [m,~] = size(ori_set);
    rand_id = randperm(m);
    train_len = round(m*per_set(1));
    val_len = round(m*per_set(2));
    train_set = ori_set(rand_id(1:train_len),:);
    val_set = ori_set(rand_id(1+train_len:train_len+val_len),:);
    test_set = ori_set(rand_id(train_len+val_len+1:end),:);
end