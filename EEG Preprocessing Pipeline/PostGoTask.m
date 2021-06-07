function dataTask = PostGoTask(dataEEG,postTask,stims)

dataTask = cell(length(stims),length(dataEEG));
for subj = 1:length(dataEEG)
    eeg = dataEEG{subj}.dataFiltered;
    fs = dataEEG{subj}.srate;
    events = geteventinfo(dataEEG{subj}.event);
    for stimIdx = 1:length(stims)
        trials = events(events(:,1)==stims(stimIdx),2);
		
        if (isempty(trials))
            disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
            disp(['Data task not found for Subject: ',num2str(subj),' in stimulus:', num2str(stimIdx)])
        end
        dataTask{stimIdx,subj} = zeros(size(eeg,1),postTask*fs,length(trials));
        for trialIdx = 1:length(trials)
            idxStart   = trials(trialIdx);
            idxEnd = idxStart + postTask*fs-1;
            dataTask{stimIdx,subj}(:,:,trialIdx) = eeg(:,idxStart:idxEnd);
        end
    end
end

end