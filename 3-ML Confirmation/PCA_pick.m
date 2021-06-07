function   [FeatsTrainnew,FeatsTestnew] = PCA_pick(FeatsTrain,FeatsTest,explainedVariance)

    [pcaCoefficients, pcaScores, ~, ~, explained, pcaCenters] = pca(FeatsTrain);
	numComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVariance, 1);
	pcaCoefficients = pcaCoefficients(:,1:numComponentsToKeep);
	FeatsTrainnew = pcaScores(:,1:numComponentsToKeep);
    FeatsTestnew = (FeatsTest-pcaCenters)*pcaCoefficients;
end