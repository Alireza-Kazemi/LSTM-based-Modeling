function SubbandData(EEG,fs,FileName)

    filtDelta = lowpassDelta;
    filtTheta = lowpassTheta;
    filtAlpha = lowpassAlpha;
    filtBeta  = lowpassBeta;
    filtGamma = lowpassGamma;

    bandDelta   = cell(size(EEG));
    bandTheta   = cell(size(EEG));
    bandAlpha   = cell(size(EEG));
    bandBeta    = cell(size(EEG));
    bandGamma   = cell(size(EEG));
    bandDeltaFiltered   = cell(size(EEG));
    bandThetaFiltered   = cell(size(EEG));
    bandAlphaFiltered   = cell(size(EEG));
    bandBetaFiltered    = cell(size(EEG));
    bandGammaFiltered   = cell(size(EEG));
    for sID = 1:length(EEG)
        X = shiftdim(EEG{sID},1);
        X(isnan(X))=0;
        bandDelta{sID}   = zeros(size(X));
        bandTheta{sID}   = zeros(size(X));
        bandAlpha{sID}   = zeros(size(X));
        bandBeta{sID}    = zeros(size(X));
        bandGamma{sID}   = zeros(size(X));
        bandDeltaFiltered{sID}   = zeros(size(X));
        bandThetaFiltered{sID}   = zeros(size(X));
        bandAlphaFiltered{sID}   = zeros(size(X));
        bandBetaFiltered {sID}   = zeros(size(X));
        bandGammaFiltered{sID}   = zeros(size(X));
        for i=1:size(X,3)
            bandDelta{sID}(:,:,i)   = bandpass(X(:,:,i),[.5,4],fs);
            bandTheta{sID}(:,:,i)   = bandpass(X(:,:,i),[4,8],fs);
            bandAlpha{sID}(:,:,i)   = bandpass(X(:,:,i),[8,13],fs);
            bandBeta{sID}(:,:,i)    = bandpass(X(:,:,i),[13,32],fs);
            bandGamma{sID}(:,:,i)   = bandpass(X(:,:,i),[32,100],fs);

            bandDeltaFiltered{sID}(:,:,i)   = filtDelta.filter(bandDelta{sID}(:,:,i));
            bandThetaFiltered{sID}(:,:,i)   = filtTheta.filter(bandTheta{sID}(:,:,i));
            bandAlphaFiltered{sID}(:,:,i)   = filtAlpha.filter(bandAlpha{sID}(:,:,i));
            bandBetaFiltered{sID}(:,:,i)    = filtBeta.filter(bandBeta{sID}(:,:,i));
            bandGammaFiltered{sID}(:,:,i)   = filtGamma.filter(bandGamma{sID}(:,:,i));
        end

        bandDelta{sID} = shiftdim(bandDelta{sID},2);
        bandTheta{sID} = shiftdim(bandTheta{sID},2);
        bandAlpha{sID} = shiftdim(bandAlpha{sID},2);
        bandBeta{sID}  = shiftdim(bandBeta{sID},2);
        bandGamma{sID} = shiftdim(bandGamma{sID},2);

        bandDeltaFiltered{sID} = shiftdim(bandDeltaFiltered{sID},2);
        bandThetaFiltered{sID} = shiftdim(bandThetaFiltered{sID},2);
        bandAlphaFiltered{sID} = shiftdim(bandAlphaFiltered{sID},2);
        bandBetaFiltered{sID}  = shiftdim(bandBetaFiltered{sID},2);
        bandGammaFiltered{sID} = shiftdim(bandGammaFiltered{sID},2);
    end
    
    save(['Data',FileName,'.mat'],...
      'bandDelta',...
      'bandTheta',...
      'bandAlpha',...
      'bandBeta',...
      'bandGamma',...
      'bandDeltaFiltered',...
      'bandThetaFiltered',...
      'bandAlphaFiltered',...
      'bandBetaFiltered',...
      'bandGammaFiltered');
end