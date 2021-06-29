clear;
clc;
close all;
%%
% LSTM Bands:
% Delta, Alpha
% 
% ——————————————-
% Bands Confirmed in Regression:
% 
% ——-RSP——————
% Delta
% 
% ——-HP——————
% Alpha
% 
% ——-BTS Amp.——————
% Alpha
% 
% ——-BTS Phase——————
% Alpha
% 
% ======================================================
% LSTM Channels:
% Alpha:  1, 4, 5, 7     			---> FeatureIdx[5,6,14,19,24,39,40,41,49,50,51]
% Delta:  1, 14, 18, 19, 24			---> FeatureIdx[1,2,12,17,22,35,36,45,46]
% ——————————————-
% Channels Confirmed in Regression:
% 
% ——-RSP—————— 
% Alpha:  1,4,5,7
% Delta: 1
% 
% ——-HP——————
% Alpha: -
% Delta: 1,18
% 
% ——-BTS Amp.——————
% Alpha: 1,4,5
% Delta: 18,19,24
% 
% ——-BTS Phase——————
% Alpha: 4,7
% Delta: 18,19,24

%% 
load NormalizedFeatures.mat
load TestOutIDs.mat

normalizedFeats = normalizedFeats(normalizedFeats.Stim=="Sham",:);
testOutIDs = testOutIDs+1;

SIDs = normalizedFeats.SID;
uniqueSIDs = unique(normalizedFeats.SID);
channels = normalizedFeats.Channel;
trials = normalizedFeats.Trial;
runs = size(testOutIDs,1);

itt=1;
ACC = [];
RUN = [];
RES = [];
Method = [];
Subspace = [];
channelNum = 27;

for RTRes = 3:3 %2:4
discretizedRT = floor(normalizedFeats.RT*(RTRes-1e-5));
Feats = table2array(normalizedFeats(:,7:end));
%% Main loop single channels

ACCs = zeros(runs,2,channelNum);

f = waitbar(0,'Single Channel Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('Single Channel Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    for chIdx = 1:channelNum
        trainX  = Feats(trainIdx & channels==chIdx,:);
        testX   = Feats(testIdx & channels==chIdx,:);
        trainY  = discretizedRT(trainIdx & channels==chIdx);
        testY   = discretizedRT(testIdx & channels==chIdx);
        ACCs(runIdx,:,chIdx) = ML_testtrain(trainX,trainY,testX,testY);
    end
end
close(f)

%% Main loop PCA ALL channels

ACCs_PCA = zeros(runs,2);

f = waitbar(0,'PCA ALL Channel Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('PCA ALL Channel Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    
    trainX = [];
    testX = [];
    for chIdx = 1:channelNum
        chIdxTemp = channels==chIdx;
        trainX = cat(2,trainX,Feats(trainIdx & chIdxTemp, :));
        testX = cat(2,testX,Feats(testIdx & chIdxTemp, :));
    end
    trainY  = discretizedRT(trainIdx & chIdxTemp);
    testY   = discretizedRT(testIdx & chIdxTemp);
    
    [trainX,testX] = PCA_pick(trainX,testX,.80);
%     trainX = trainX(:,[216,464]);
%     testX  = testX(:,[216,464]);
    ACCs_PCA(runIdx,:) = ML_testtrain(trainX,trainY,testX,testY);
end
close(f)

%% Main loop lasso ALL channels

ACCs_Lasso = zeros(runs,2);

f = waitbar(0,'Lasso ALL Channel Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('Lasso ALL Channel Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    
    trainX = [];
    testX = [];
    for chIdx = 1:channelNum
        chIdxTemp = channels==chIdx;
        trainX = cat(2,trainX,Feats(trainIdx & chIdxTemp, :));
        testX = cat(2,testX,Feats(testIdx & chIdxTemp, :));
    end
    trainY  = discretizedRT(trainIdx & chIdxTemp);
    testY   = discretizedRT(testIdx & chIdxTemp);
    
    [B,FitInfo] = lasso(trainX,trainY,'CV',10,'Alpha',.75);
    idxLambdaMinMSE = FitInfo.IndexMinMSE;
    BestFeats = (B(:,idxLambdaMinMSE)~=0);
    trainX = trainX(:,BestFeats);
    testX = testX(:,BestFeats);
    ACCs_Lasso(runIdx,:) = ML_testtrain(trainX,trainY,testX,testY);
end
close(f)

%% Main loop LSTM subspace All channels
desiredChIdx = [1, 4, 5, 7, 14, 18, 19, 24];
desiredFeatPerCh = {[1,2,12,17,22,35,36,45,46,5,6,14,19,24,39,40,41,49,50,51],... CH =1
                    [5,6,14,19,24,39,40,41,49,50,51],... CH =4
                    [5,6,14,19,24,39,40,41,49,50,51],... CH =5
                    [5,6,14,19,24,39,40,41,49,50,51],... CH =7
                    [1,2,12,17,22,35,36,45,46],... CH =14
                    [1,2,12,17,22,35,36,45,46],... CH =18
                    [1,2,12,17,22,35,36,45,46],... CH =19
                    [1,2,12,17,22,35,36,45,46]};%  CH =24
                    
ACCs_LSTM = zeros(runs,2);

f = waitbar(0,'LSTM Confirmed subspace Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('LSTM Confirmed subspace Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    trainX = [];
    testX = [];
    for chIdx = 1:length(desiredChIdx)
        chIdxTemp = channels==desiredChIdx(chIdx);
        trainX = cat(2,trainX,Feats(trainIdx & chIdxTemp, desiredFeatPerCh{chIdx}));
        testX = cat(2,testX,Feats(testIdx & chIdxTemp, desiredFeatPerCh{chIdx}));
    end
    
    trainY  = discretizedRT(trainIdx & chIdxTemp);
    testY   = discretizedRT(testIdx & chIdxTemp);
    
    ACCs_LSTM(runIdx,:) = ML_testtrain(trainX,trainY,testX,testY);
end
close(f)


%% Main loop LSTM feature channel 1  subspace
desiredChIdx = 1;
desiredFeatIdx = [5,6,14,19,24,39,40,41,49,50,51,1,2,12,17,22,35,36,45,46];
ACCs_LSTM_Ch1 = zeros(runs,2);

f = waitbar(0,'LSTM Ch1 subspace Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('LSTM Ch1 subspace Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    
    trainX = [];
    testX = [];
    for chIdx = 1:length(desiredChIdx)
        chIdxTemp = channels==desiredChIdx(chIdx);
        trainX = cat(2,trainX,Feats(trainIdx & chIdxTemp, desiredChIdx));
        testX = cat(2,testX,Feats(testIdx & chIdxTemp, desiredChIdx));
    end
    
    trainY  = discretizedRT(trainIdx & chIdxTemp);
    testY   = discretizedRT(testIdx & chIdxTemp);
    
    ACCs_LSTM_Ch1(runIdx,:) = ML_testtrain(trainX,trainY,testX,testY);
end
close(f)

%% Main loop LSTM Confirmed feature subspace

desiredChIdx = [1, 4, 5, 7, 14, 18, 19, 24];
desiredFeatPerCh = {[1,2,5,6,12,17,22,39,40,41],... CH =1
                    [5,6,39,40,41,49,50,51],... CH =4
                    [5,6,39,40,41],... CH =5
                    [5,6,49,50,51],... CH =7
                    [],... CH =14
                    [12,17,22,35,36,45,46],... CH =18
                    [35,36,45,46],... CH =19
                    [35,36,45,46]};%  CH =24
                    
ACCs_LSTM_Reg = zeros(runs,2);

f = waitbar(0,'LSTM Confirmed subspace Evaluation');
for runIdx = 1:runs
    waitbar(runIdx/runs,f,sprintf('LSTM Confirmed subspace Run = %d',runIdx));
    testIdx = false(size(Feats,1),1);
    for sIDx = 1:length(uniqueSIDs)
        testIdx = testIdx | (SIDs==uniqueSIDs(sIDx) & trials==testOutIDs(runIdx,sIDx));
    end
    trainIdx = ~testIdx;
    
    trainX = [];
    testX = [];
    for chIdx = 1:length(desiredChIdx)
        chIdxTemp = channels==desiredChIdx(chIdx);
        trainX = cat(2,trainX,Feats(trainIdx & chIdxTemp, desiredFeatPerCh{chIdx}));
        testX = cat(2,testX,Feats(testIdx & chIdxTemp, desiredFeatPerCh{chIdx}));
    end
    
    trainY  = discretizedRT(trainIdx & chIdxTemp);
    testY   = discretizedRT(testIdx & chIdxTemp);
    
    ACCs_LSTM_Reg(runIdx,:) = ML_testtrain(trainX,trainY,testX,testY);
end
close(f)

%% ------------ plot results
% figure
% for i=1:40
%     subplot(3,1,1)
%     plot(1:27,squeeze(ACCs(i,1,:)),'r.');
%     hold on
%     subplot(3,1,2)
%     plot(1:27,squeeze(ACCs(i,2,:)),'bo');
%     hold on
% end
% subplot(3,1,3)
% plot(1:27,mean(squeeze(ACCs(:,1,:)),1),'r.');
% hold on
% plot(1:27,mean(squeeze(ACCs(:,2,:)),1),'bo');
% legend('KNN','RF');
% subplot(3,1,1)
% title("RTRes = "+num2str(RTRes))

figure
plot(1:40,squeeze(mean(ACCs(:,1,:),3)),'r');
hold on
plot(1:40,squeeze(mean(ACCs(:,2,:),3)),'b');

plot(1:40,ACCs_LSTM(:,1));
plot(1:40,ACCs_LSTM(:,2));
plot(1:40,ACCs_LSTM_Ch1(:,1));
plot(1:40,ACCs_LSTM_Ch1(:,2));
plot(1:40,ACCs_LSTM_Reg(:,1));
plot(1:40,ACCs_LSTM_Reg(:,2));
legend('KNN','RF','KNN_LSTM','RF_LSTM','KNN_LSTM_Ch1','RF_LSTM_Ch1','KNN_LSTM_Reg','RF_LSTM_Reg','Interpreter', 'none');
title("RTRes = "+num2str(RTRes))

%% -------------- ttests
[~,P_KNN(itt)] = ttest(squeeze(mean(ACCs(:,1,:),3)),ACCs_LSTM(:,1));
[~,P_RF(itt)] = ttest(squeeze(mean(ACCs(:,2,:),3)),ACCs_LSTM(:,2));
[~,P_KNN_C(itt)] = ttest(squeeze(mean(ACCs(:,1,:),3)),ACCs_LSTM_Reg(:,1));
[~,P_RF_C(itt)] = ttest(squeeze(mean(ACCs(:,2,:),3)),ACCs_LSTM_Reg(:,2));

temp = ACCs_Lasso(:,1);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllChLasso",length(temp),1));

temp = ACCs_Lasso(:,2);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllChLasso",length(temp),1));

temp = ACCs_PCA(:,1);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllChPCA",length(temp),1));

temp = ACCs_PCA(:,2);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllChPCA",length(temp),1));

temp = squeeze(mean(ACCs(:,1,:),3));
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllperCh",length(temp),1));

temp = squeeze(mean(ACCs(:,2,:),3));
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("AllperCh",length(temp),1));

temp = ACCs_LSTM(:,1);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM",length(temp),1));

temp = ACCs_LSTM(:,2);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM",length(temp),1));

temp = ACCs_LSTM_Ch1(:,1);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM_Ch1",length(temp),1));

temp = ACCs_LSTM_Ch1(:,2);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM_Ch1",length(temp),1));

temp = ACCs_LSTM_Reg(:,1);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("KNN",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM_Reg",length(temp),1));

temp = ACCs_LSTM_Reg(:,2);
ACC = cat(1,ACC,temp);
RUN = cat(1,RUN,(1:length(temp))');
RES = cat(1,RES,repmat(RTRes,length(temp),1));
Method = cat(1,Method,repmat("RF",length(temp),1));
Subspace = cat(1,Subspace,repmat("LSTM_Reg",length(temp),1));

itt=itt+1;
end
T = table(RES,Subspace,Method,RUN,ACC);
writetable(T,"ML_Results.csv")
