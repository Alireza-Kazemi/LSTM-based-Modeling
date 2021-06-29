function SigsNew = ArtifactRemover(Sigs,Winsize)
% AmpNoise = std(Sig)*.5;
% Designed and Developed by Alireza Kazemi June 2019 Kazemi@ucdavis.edu
Step = round(Winsize/5);
SigsNew = zeros(size(Sigs));
for chIdx = 1:length(Sigs(:,1))
    Sig = Sigs(chIdx,:);
    AmpNoise = std(Sig)*.5;
    

    if(size(Sig,1)==1)
        Sig=Sig';
    end

    Y = Sig + randn(length(Sig),1)*AmpNoise;
    Endflag = 0;
    IndS = 1;
    IndE = Winsize;
    CC = zeros(size(Sig));
    while (Endflag==0)
        CC(IndS:IndE)=corr(Y(IndS:IndE),Sig(IndS:IndE));
        IndS = IndS+Step;
        IndE = IndS+Winsize-1;
        if(IndE>length(Sig))
            Endflag=1;
        end
    end
    CC(isnan(CC))=0;
    WaveletLvl = 4;
    Wavename = 'sym6';
    [C,L] = wavedec(Sig,WaveletLvl,Wavename);
    temp = wrcoef('a',C,L,Wavename,WaveletLvl);
    [envHigh, envLow] = envelope(CC,Step,'peak');
    CFilt = (2*envHigh+envLow)/3;
    CFilt = CFilt.*temp;
    SigNew = Sig-CFilt;
    
    SigsNew(chIdx,:) = SigNew';
end
