function ACC = ML_testtrain(trainX,trainY,testX,testY)
%% Train Supervised Standard Classifiers

Mod_KNN = fitcknn(trainX, trainY, ...
                    'Distance', 'Euclidean', ...
                    'Exponent', [], ...
                    'NumNeighbors', 5, ...
                    'DistanceWeight', 'SquaredInverse', ...
                    'Standardize', false);
Mod_RF = TreeBagger(30,trainX, trainY,'OOBPrediction','On',...
    'Method','classification');


%% Test Classifiers 

Labs_KNN = predict(Mod_KNN,testX);
Labs_RF = predict(Mod_RF,testX);
Labs_RF = str2double(Labs_RF);

cm = confusionmat(testY,Labs_KNN);
Accuracy_KNN = sum(diag(cm))/sum(sum(cm))*100;

cm = confusionmat(testY,Labs_RF);
Accuracy_RF = sum(diag(cm))/sum(sum(cm))*100;
% plotconfusion(categorical(testY),categorical(Labs_RF));

ACC = [Accuracy_KNN ,Accuracy_RF];

% ACC= [0,0];
end

                
