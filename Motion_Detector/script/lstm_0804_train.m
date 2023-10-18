%% Initialize the environment 
clear
clc

%% Construct Dataset
load('Data/Caltrace_0804_3.mat');
load('Data/sample_0804.mat');
load('Data/0804_3_dist.mat');

sample_data = [p_sample;n_sample];
sample_data(:,3) = [ones(length(p_sample),1);zeros(length(n_sample),1)];

%% resample the sample.
s_signal = reSample(CalTrace3_green,sample_data,20,170,10);

%% add mindist feature.
for i = 1:length(s_signal.index)
    s_signal.dist(i,1) = dist_edge(s_signal.index(i,1));
end

%% shuffle and generate the train and test set
train_per = 0.8;
val_per = 0.1;
len = size(s_signal.signal,1);
train_len = round(len*train_per);
val_len = round(len*val_per);

rand_id = randperm(len);
s_signal = s_signal(rand_id,:);
signal_train = s_signal(1:train_len,:);
signal_val = s_signal((train_len+1):(train_len+val_len),:);
signal_test = s_signal((train_len+val_len+1):len,:);

%% Wavelet Scatterging transform the signal feature.
Fs=10;
sf = waveletScattering('SignalLength',size(s_signal.signal,2),'SamplingFrequency',Fs,'InvarianceScale',10);
train_feature = sf.featureMatrix(signal_train.signal');
val_feature = sf.featureMatrix(signal_val.signal');
test_feature = sf.featureMatrix(signal_test.signal');

Npaths = size(train_feature,2);
train_feature = permute(train_feature,[2 3 1]);
train_feature = reshape(train_feature,size(train_feature,1)*size(train_feature,2),[]);
val_feature = permute(val_feature,[2 3 1]);
val_feature = reshape(val_feature,size(val_feature,1)*size(val_feature,2),[]);
test_feature = permute(test_feature,[2 3 1]);
test_feature = reshape(test_feature,size(test_feature,1)*size(test_feature,2),[]);

dist_feature = repelem(s_signal.dist,Npaths);
train_feature_cell = mat2cell([train_feature,dist_feature(1:length(train_feature))],ones(size(train_feature,1),1),34);
val_feature_cell = mat2cell([val_feature,dist_feature(length(train_feature)+1:length(train_feature)+length(val_feature))],ones(size(val_feature,1),1),34);
test_feature_cell = mat2cell([test_feature,dist_feature(length(train_feature)+length(val_feature)+1:end)],ones(size(test_feature,1),1),34);

% repeat the lables.
train_lable = categorical(repelem(signal_train.class,Npaths));
val_lable = categorical(repelem(signal_val.class,Npaths));

%% LSTM training on Matlab
numHiddenUnits = 180;
numClasses = numel(unique(train_lable));
maxEpochs = 120000;
miniBatchSize= 1024;
classes = categorical([0 1]);

layers = [ ...
    sequenceInputLayer(1)
    lstmLayer(numHiddenUnits,'OutputMode','last','InputWeightsInitializer','he')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'InitialLearnRate',0.0033752,...
    'MaxEpochs',maxEpochs, ...
    'VerboseFrequency',miniBatchSize/2,...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','shortest', ...
    'Shuffle','once',...
    'Plots','training-progress',...
    'ValidationData',{val_feature_cell,val_lable},...
    'ValidationFrequency',miniBatchSize,...
    'L2Regularization',7.2759e-5);

disp('start train');
net = trainNetwork(train_feature_cell,train_lable,layers,options);
    
%% Bayesian optimization
% optVars = [
%     optimizableVariable('InitialLearnRate',[1e-5, 1e-1],'Transform','log')
%     optimizableVariable('NumHiddenUnits',[10, 1000],'Type','integer')
%     optimizableVariable('L2Regularization',[1e-5, 1e-1],'Transform','log')
%     ];
% ObjFcn = helperBayesOptLSTM(train_feature_cell,train_lable,val_feature_cell,categorical(signal_val.class),Npaths);
% BayesObject = bayesopt(ObjFcn,optVars,...
%             'MaxObjectiveEvaluations',15,...
%             'IsObjectiveDeterministic',false,...
%             'UseParallel',true,...
%             'GPActiveSetSize',2000);

%% plot the LSTM results
YPred = classify(net,test_feature_cell,'MiniBatchSize',miniBatchSize,'SequenceLength','shortest');
Pred_lable = reshape(YPred,Npaths,length(signal_test.class));
ClassCounts = countcats(Pred_lable);
[~,idx] = max(ClassCounts);
Pred_lable_vote = classes(idx);
accuracy = sum(Pred_lable_vote' == categorical(signal_test.class))./numel(signal_test.class)*100;
confusionchart(categorical(signal_test.class), Pred_lable_vote', "RowSummary", "row-normalized");
title("Accuracy: " + accuracy + "%");
