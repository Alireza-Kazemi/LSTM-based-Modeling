function [dataRest,dataTaskPreGo,dataTaskPostGo]=NormalizeDataEEG(dataRest,dataTaskPreGo,dataTaskPostGo,chNum)

stimNum = size(dataRest,1);
subjNum = size(dataRest,2);
for subjIdx = 1:subjNum
    for chIdx = 1:chNum
        for stimIdx = 1:stimNum
            dat = squeeze(dataRest{stimIdx,subjIdx}(chIdx,:))';
            dat = [dat; reshape(squeeze(dataTaskPreGo{stimIdx,subjIdx}(chIdx,:,:)),[],1)];
            dat = [dat; reshape(squeeze(dataTaskPostGo{stimIdx,subjIdx}(chIdx,:,:)),[],1)];
            if(isempty(dat))
                continue;
            end
            
            SD3 = 3*std(dat);
            SD3 = max(SD3,150);
            M = mean(dat);
            dat = dat-M;
            dat(dat>SD3)=SD3;
            dat(dat<-SD3)=-SD3;
            Mx = max(dat);
            Mn = min(dat);

            dat = dataRest{stimIdx,subjIdx}(chIdx,:,:);
            dat = dat-M;
            dat(dat>SD3)=SD3;
            dat(dat<-SD3)=-SD3;
            dataRest{stimIdx,subjIdx}(chIdx,:) = (dat-Mn)/(Mx-Mn);

            dat = dataTaskPreGo{stimIdx,subjIdx}(chIdx,:,:);
            dat = dat-M;
            dat(dat>SD3)=SD3;
            dat(dat<-SD3)=-SD3;
            dataTaskPreGo{stimIdx,subjIdx}(chIdx,:,:) = (dat-Mn)/(Mx-Mn);
            
            dat = dataTaskPostGo{stimIdx,subjIdx}(chIdx,:,:);
            dat = dat-M;
            dat(dat>SD3)=SD3;
            dat(dat<-SD3)=-SD3;
            dataTaskPostGo{stimIdx,subjIdx}(chIdx,:,:) = (dat-Mn)/(Mx-Mn);
        end
    end
end