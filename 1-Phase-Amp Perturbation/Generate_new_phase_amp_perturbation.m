load DataHC_StimIndex8.mat

% bandDelta[.5,4]
% bandTheta[4,8]
% bandAlpha[8,13]
% bandBeta[13,32]
% bandGamma[32,100]

Method = "Noise";
            
for i = 1 : 22
    sig27_1000_10 = bandDelta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[],[0.5 4],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandDelta_PhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandTheta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[],[4 8],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandTheta_PhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandAlpha{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[],[8 13],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandAlpha_PhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandBeta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[],[13 32],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandBeta_PhaseFiltered{1,i} = sigs_chs;
end
            
for i = 1 : 22
    sig27_1000_10 = bandGamma{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[],[32 55],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandGamma_PhaseFiltered{1,i} = sigs_chs;
end
%-------------------------------------------------------
for i = 1 : 22
    sig27_1000_10 = bandDelta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[0.5 4],[],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandDelta_AmpFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandTheta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[4 8],[],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandTheta_AmpFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandAlpha{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[8 13],[],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandAlpha_AmpFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandBeta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[13 32],[],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandBeta_AmpFiltered{1,i} = sigs_chs;
end
            
for i = 1 : 22
    sig27_1000_10 = bandGamma{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[32 55],[],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandGamma_AmpFiltered{1,i} = sigs_chs;
end

%-------------------------------------------------------
for i = 1 : 22
    sig27_1000_10 = bandDelta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[0.5 4],[0.5 4],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandDelta_AmpPhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandTheta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[4 8],[4 8],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandTheta_AmpPhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandAlpha{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[8 13],[8 13],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandAlpha_AmpPhaseFiltered{1,i} = sigs_chs;
end

            
for i = 1 : 22
    sig27_1000_10 = bandBeta{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[13 32],[13 32],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandBeta_AmpPhaseFiltered{1,i} = sigs_chs;
end
            
for i = 1 : 22
    sig27_1000_10 = bandGamma{1,i};
    sigs_chs = [];
    for ch = 1:27
        sigs_tr = [];
        for tr = 1 : 10
            temp1 = sig27_1000_10(ch,:,tr);
            temp2 = DestroyPAC(temp1,1000,[32 55],[32 55],Method);
            sigs_tr = cat(3,sigs_tr, temp2);
        end
        sigs_chs = cat(1, sigs_chs, sigs_tr);
    end
    bandGamma_AmpPhaseFiltered{1,i} = sigs_chs;
end
%-----------------------------------------------


save(strcat("DataHC_StimIndex8_", Method, "Filtered.mat"),... 
                                                    "bandDelta_PhaseFiltered", ...
                                                    "bandTheta_PhaseFiltered", ...
                                                    "bandAlpha_PhaseFiltered", ...
                                                    "bandBeta_PhaseFiltered", ...
                                                    "bandGamma_PhaseFiltered", ...
                                                    "bandDelta_AmpFiltered", ...
                                                    "bandTheta_AmpFiltered", ...
                                                    "bandAlpha_AmpFiltered", ...
                                                    "bandBeta_AmpFiltered", ...
                                                    "bandGamma_AmpFiltered", ...
                                                    "bandDelta_AmpPhaseFiltered", ...
                                                    "bandTheta_AmpPhaseFiltered", ...
                                                    "bandAlpha_AmpPhaseFiltered", ...
                                                    "bandBeta_AmpPhaseFiltered", ...
                                                    "bandGamma_AmpPhaseFiltered", ...                                              
                                                    "bandAlpha",...
                                                    "bandBeta",...
                                                    "bandDelta", ...
                                                    "bandTheta",...
                                                    "bandGamma")