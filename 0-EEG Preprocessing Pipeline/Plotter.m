
load('dataOnlyBpFiltered.mat')
dataEEG = dataHC;
subj = 1;
eeg = dataEEG{subj}.dataFiltered;
fs = dataEEG{subj}.srate;
events = geteventinfo(dataEEG{subj}.event);
plot(1/fs:1/fs:size(eeg,2)/fs,eeg(1,:))
text(events(:,2)/fs,repmat(500,size(events,1),1),string(events(:,1)))