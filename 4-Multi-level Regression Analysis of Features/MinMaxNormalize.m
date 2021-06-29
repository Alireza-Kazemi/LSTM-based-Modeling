
% Import ForMatlabNormalization.csv

for sid = unique(dat.SID)'
    for stim = unique(dat.Stim)'
        for ch = unique(dat.Channel)'
            temp = table2array(dat(dat.SID==sid & dat.Stim==stim & dat.Channel==ch,6:68));
            temp = (temp-repmat(min(temp),size(temp,1),1))./(repmat(max(temp),size(temp,1),1)-repmat(min(temp),size(temp,1),1));
            dat(dat.SID==sid & dat.Stim==stim & dat.Channel==ch,6:68) = array2table(temp);
        end
    end
end

writetable(dat,"normalizedFeats.csv");