function x = helperBayesOptLSTM(X_train, Y_train, X_val, Y_val)
x = @valErrorFun;

    function [valError,cons, fileName] = valErrorFun(optVars)
        %% LSTM Architecture
        numClasses = numel(unique(Y_train));
        classes = categorical([0 1]);

        layers = [ ...
            sequenceInputLayer(6)
            lstmLayer(optVars.NumHiddenUnits,'OutputMode','last','InputWeightsInitializer','he') 
            fullyConnectedLayer(numClasses)
            softmaxLayer
            classificationLayer('ClassWeights',[0.6,0.4],'Classes',classes)];
        
        options = trainingOptions('adam', ...
            'InitialLearnRate',optVars.InitialLearnRate, ... 
            'MaxEpochs',1000, ...
            'MiniBatchSize',1024, ...
            'SequenceLength','shortest', ...
            'Shuffle','once', ...
            'Verbose', false,...
            'L2Regularization', optVars.L2Regularization,...
            'ExecutionEnvironment','auto');
        
        %% Train the network
        net = trainNetwork(X_train, Y_train, layers, options);
        %% Training accuracy voting integration.
        X_val_P = net.classify(X_val);
        C = confusionmat(Y_val,X_val_P,'Order',classes);
        % Precision = C(2,2)/sum(C(:,2));
        accuracy_training  = sum(X_val_P == Y_val)./numel(Y_val);
        % obj = 0.5*accuracy_training + 0.5*Precision;
        valError = -1*accuracy_training;
        error_str = num2str(valError);
        %% save results of network and options in a MAT file in the results folder along with the error value
        fileName = fullfile('/home/user/tgd/Motion_Detector/Data/', error_str(1:5) + ".mat");
        save(fileName,'net','valError','options');
        cons = [];
    end % end for inner function
end % end for outer function