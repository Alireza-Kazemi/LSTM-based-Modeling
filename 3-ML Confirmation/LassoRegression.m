clear;
clc;
close all;

%% 
load NormalizedFeatures.mat
load TestOutIDs.mat
load FeatLabels.mat

normalizedFeats = normalizedFeats(normalizedFeats.Stim=="Sham",:);
testOutIDs = testOutIDs+1;

SIDs = normalizedFeats.SID;
uniqueSIDs = unique(normalizedFeats.SID);
channels = normalizedFeats.Channel;
trials = normalizedFeats.Trial;
runs = size(testOutIDs,1);

CorrLasso = [];
FeatIdx1 = [];
FeatIdx2 = [];
channelNum = 27;

RTRes = 3;
discretizedRT = round(normalizedFeats.RT*(RTRes-1));
Feats = table2array(normalizedFeats(:,7:end));

featLabels = [];
for chIdx = 1:channelNum
    for featIdx = 1:length(CH_Lab)
        featLabels = cat(1,featLabels,"Channel:"+chIdx+"  "+CH_Lab{featIdx});
    end
end

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
    trainY  = normalizedFeats.RT(trainIdx & chIdxTemp);
    testY   = normalizedFeats.RT(testIdx & chIdxTemp);
    
    lambda = 1e-03;
    B = lasso(trainX,trainY,'Lambda',lambda,'Intercept',false);
    Y_p = testX*B;
%     scatter(testY,Y_p,'x');
    C1 = corrcoef(Y_p,testY);
    C1 = C1(1,2);
    Fidx1 = abs(sign(B)); 
    
    [B,FitInfo] = lasso(trainX,trainY,'CV',10,'Alpha',.75);
    idxLambdaMinMSE = FitInfo.IndexMinMSE;
    Y_p = testX*B(:,idxLambdaMinMSE)+FitInfo.Intercept(idxLambdaMinMSE);
%     scatter(testY,Y_p,'o');
    C2 = corrcoef(Y_p,testY);
    C2 = C2(1,2);
    Fidx2 = abs(sign(B(:,idxLambdaMinMSE)));
    
    CorrLasso = cat(1,CorrLasso,[C1,C2]);
    FeatIdx1 = cat(1,FeatIdx1,Fidx1'); 
    FeatIdx2 = cat(1,FeatIdx2,Fidx2'); 
end
close(f)

bar(sum(FeatIdx2,2))

Labs=[];
for i=1:40
    Labs = cat(2,Labs,{featLabels(logical(FeatIdx2(i,:)))});
end


bar(sum(FeatIdx1,2))

Labs=[];
for i=1:40
    Labs = cat(2,Labs,{featLabels(logical(FeatIdx1(i,:)))});
end
