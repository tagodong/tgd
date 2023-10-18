%% Initialize the environment 
clear
clc

%% Construct Dataset
load('Data/0721_ge_Fra.mat');
per_set = [0,0.9,0.1];
sam_fragments.t.class = ones(length(sam_fragments.t.dist),1);
sam_fragments.f.class = zeros(length(sam_fragments.f.dist),1);
[sig_train,sig_val,sig_test] = shufData([sam_fragments.t;sam_fragments.f],per_set);

load('Data/auto_ge_0804.mat');
per_set = [1,0,0];
sam_fragments.t.class = ones(length(sam_fragments.t.dist),1);
sam_fragments.f.class = zeros(length(sam_fragments.f.dist),1);
[cal_train,cal_val,cal_test] = shufData([sam_fragments.t;sam_fragments.f],per_set);

train_sig = [sig_train;cal_train];
val_sig = [sig_val;cal_val];
test_sig = [sig_test;cal_test];

%% Wavelet Scatterging Netwrok Initialization
Fs=10;
sf = waveletScattering('SignalLength',size(train_sig.signal,2),'SamplingFrequency',Fs,'InvarianceScale',10);
train_feature = sf.featureMatrix(train_sig.signal');
val_feature = sf.featureMatrix(val_sig.signal');
test_feature = sf.featureMatrix(test_sig.signal');

Npaths = size(train_feature,2);
train_feature = permute(train_feature,[2 3 1]);
train_feature = reshape(train_feature,size(train_feature,1)*size(train_feature,2),[]);
val_feature = permute(val_feature,[2 3 1]);
val_feature = reshape(val_feature,size(val_feature,1)*size(val_feature,2),[]);
test_feature = permute(test_feature,[2 3 1]);
test_feature = reshape(test_feature,size(test_feature,1)*size(test_feature,2),[]);

train_dist = repelem(train_sig.dist,Npaths);
train_feature_cell = mat2cell([train_feature,train_dist],ones(size(train_sig,1),1)*6,34);
val_dist = repelem(val_sig.dist,Npaths);
val_feature_cell = mat2cell([val_feature,val_dist],ones(size(val_sig,1),1)*6,34);
test_dist = repelem(test_sig.dist,Npaths);
test_feature_cell = mat2cell([test_feature,test_dist],ones(size(test_sig,1),1)*6,34);

% repeat the lables.
train_lable = categorical(train_sig.class);
val_lable = categorical(val_sig.class);

%% LSTM training on Matlab
numHiddenUnits = 300;
numClasses = numel(unique(train_lable));
maxEpochs = 2000;
miniBatchSize= 1024;
classes = categorical([0 1]);


% layers = [ ...
%     sequenceInputLayer(1)
%     lstmLayer(numHiddenUnits,'OutputMode','last','InputWeightsInitializer','he')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer];
% 
% options = trainingOptions('adam', ...
%     'InitialLearnRate',0.00013266,...
%     'MaxEpochs',maxEpochs, ...
%     'VerboseFrequency',miniBatchSize/2,...
%     'MiniBatchSize',miniBatchSize, ...
%     'SequenceLength','shortest', ...
%     'Shuffle','once',...
%     'Plots','training-progress',...
%     'ValidationData',{val_feature_cell,val_lable},...
%     'ValidationFrequency',miniBatchSize,...
%     'L2Regularization',6.9118e-5);
% 
% disp('start train');
% net = trainNetwork(train_feature_cell,train_lable,layers,options);
    
% %% Bayesian optimization
optVars = [
    optimizableVariable('InitialLearnRate',[1e-6, 1e-1],'Transform','log')
    optimizableVariable('NumHiddenUnits',[10, 1000],'Type','integer')
    optimizableVariable('L2Regularization',[1e-5, 1e-1],'Transform','log')
    ];
ObjFcn = helperBayesOptLSTM(train_feature_cell,train_lable,val_feature_cell,val_lable);
BayesObject = bayesopt(ObjFcn,optVars,...
            'MaxObjectiveEvaluations',15,...
            'IsObjectiveDeterministic',false,...
            'UseParallel',true,...
            'GPActiveSetSize',1000);

%% plot the LSTM results
% YPred = classify(net,test_feature_cell,'MiniBatchSize',miniBatchSize,'SequenceLength','shortest');
% Pred_lable = reshape(YPred,Npaths,length(signal_test.class));
% ClassCounts = countcats(Pred_lable);
% [~,idx] = max(ClassCounts);
% Pred_lable_vote = classes(idx);
% accuracy = sum(Pred_lable_vote' == categorical(signal_test.class))./numel(signal_test.class)*100;
% confusionchart(categorical(signal_test.class), Pred_lable_vote', "RowSummary", "row-normalized");
% title("Accuracy: " + accuracy + "%");
