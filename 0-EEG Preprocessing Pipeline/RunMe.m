%% EEG loading
% So, for example, 1 means the time when sham 1-min resting started, 21 (20+1)
% is when visual cue was given in sham condition.  Likewise, 7 means the time 
% when 1-min resting started while GVS7 was given to the participant, and 
% 27 (20+7) is when visual cue was given in the same stimulation condition 
% (i.e., GVS7)

clear
clc;
if (ispc)
    Sep = '\';
else
    Sep = '/';
end

eegChan = 1:29;
earChan = [16 19];
eegChan(earChan) = [];


dataFolder = uigetdir(pwd, 'Pick Data Directory');
% dataFolderBH = uigetdir(pwd, 'Pick Behavioral Data Directory');

%% Load and Bandpass Filter 0.5- 55hz
%------------------------------- Healthy
disp('=============================')
disp('Loading HC data:')
dataPath = dir(dataFolder);
dataPath = dataPath(~cellfun('isempty', {dataPath.date}));
dataPath = dataPath(contains({dataPath.name},'GEN'));
dataHC   = cell(1,length(dataPath)); 
for subj = 1:length(dataPath)
    subjName      = dataPath(subj).name;
    disp(subjName)
    subjPath      = dir([dataPath(subj).folder,Sep,subjName]);
    subjPath      = subjPath([subjPath.isdir]);
    subjPath      = subjPath(contains({subjPath.name},'offmed'));
    for condIdx = 1:length(subjPath)
        condName    = subjPath(condIdx).name;
        condPath    = [subjPath(condIdx).folder,Sep,condName];
        list = dir([condPath,Sep,'*.dap']);
        list = list(~contains({list.name},'._'));
        if(length(list)~=1)
            error(['File does not exist: ', list.folder,Sep,list.name])
        end
        eeg = loadcurry([list.folder,Sep,list.name]);
        eeg.data = double(eeg.data);
        eeg.eegChanelNames = eeg.chanlocs(eegChan);
        eeg.dataFiltered = PreprocessingFilter(eeg.data(eegChan,:),eeg.srate); % Filter parameters are set inside the function
        winSize = eeg.srate;
        eeg.dataFiltered = ArtifactRemover(eeg.dataFiltered,winSize);
    end
    dataHC{subj} = eeg; 
end
%------------------------------- PD off med
disp('=============================')
disp('Loading PD1 data:')
dataPath = dir(dataFolder);
dataPath = dataPath(~cellfun('isempty', {dataPath.date}));
dataPath = dataPath(contains({dataPath.name},'GEP'));
dataPD1   = cell(1,length(dataPath)); 
for subj = 1:length(dataPath)
    subjName      = dataPath(subj).name;
    disp(subjName)
    subjPath      = dir([dataPath(subj).folder,Sep,subjName]);
    subjPath      = subjPath([subjPath.isdir]);
    subjPath      = subjPath(contains({subjPath.name},'offmed'));
    for condIdx = 1:length(subjPath)
        condName    = subjPath(condIdx).name;
        condPath    = [subjPath(condIdx).folder,Sep,condName];
        list = dir([condPath,Sep,'*.dap']);
        list = list(~contains({list.name},'._'));
        if(length(list)~=1)
            error(['File does not exist: ', list.folder,Sep,list.name])
        end
        eeg = loadcurry([list.folder,Sep,list.name]);
        eeg.data = double(eeg.data);
        eeg.eegChanelNames = eeg.chanlocs(eegChan);
        eeg.dataFiltered = PreprocessingFilter(eeg.data(eegChan,:),eeg.srate); % Filter parameters are set inside the function
        winSize = eeg.srate;
        eeg.dataFiltered = ArtifactRemover(eeg.dataFiltered,winSize);
    end
    dataPD1{subj} = eeg; 
end
%------------------------------- PD on med
disp('=============================')
disp('Loading PD2 data:')
dataPath = dir(dataFolder);
dataPath = dataPath(~cellfun('isempty', {dataPath.date}));
dataPath = dataPath(contains({dataPath.name},'GEP'));
dataPD2   = cell(1,length(dataPath)); 
for subj = 1:length(dataPath)
    subjName      = dataPath(subj).name;
    disp(subjName)
    subjPath      = dir([dataPath(subj).folder,Sep,subjName]);
    subjPath      = subjPath([subjPath.isdir]);
    subjPath      = subjPath(contains({subjPath.name},'onmed'));
    for condIdx = 1:length(subjPath)
        condName    = subjPath(condIdx).name;
        condPath    = [subjPath(condIdx).folder,Sep,condName];
        list = dir([condPath,Sep,'*.dap']);
        list = list(~contains({list.name},'._'));
        if(length(list)~=1)
            error(['File does not exist: ', list.folder,Sep,list.name])
        end
        eeg = loadcurry([list.folder,Sep,list.name]);
        eeg.data = double(eeg.data);
        eeg.eegChanelNames = eeg.chanlocs(eegChan);
        eeg.dataFiltered = PreprocessingFilter(eeg.data(eegChan,:),eeg.srate); % Filter parameters are set inside the function
        winSize = eeg.srate;
        eeg.dataFiltered = ArtifactRemover(eeg.dataFiltered,winSize);
    end
    dataPD2{subj} = eeg; 
end
save('dataOnlyBpFiltered.mat','dataHC','dataPD2','dataPD1','-v7.3')
%% Resting state Data
disp('=============================')
disp('Extracting Rest...')
%------------------------------- Healthy
stims = 1:12;
disp('For HC')

dataEEG = dataHC;
dataRest = cell(length(stims),length(dataEEG));
for subj = 1:length(dataEEG)
    eeg = dataEEG{subj}.dataFiltered;
    fs = dataEEG{subj}.srate;
    events = geteventinfo(dataEEG{subj}.event);
    for stimIdx = 1:length(stims)
        idxStart = max(events(events(:,1)==stims(stimIdx),2));
        idxEnd   = idxStart + 60*fs -1;
		
        if (isempty(idxStart) || size(eeg,2) <= idxEnd)
          idxEnd = size(eeg,2);
		  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		  disp(['Data rest not found for HC Subject: ',num2str(subj),' in stimulus:', num2str(stimIdx)])
        end
        dataRest{stimIdx,subj} = eeg(:,idxStart:idxEnd);
    end
end
dataHCRest = dataRest;

%------------------------------- PD off med
disp('For PD1')
dataEEG = dataPD1;
dataRest = cell(length(stims),length(dataEEG));
for subj = 1:length(dataEEG)
    eeg = dataEEG{subj}.dataFiltered;
    fs = dataEEG{subj}.srate;
    events = geteventinfo(dataEEG{subj}.event);
    for stimIdx = 1:length(stims)
        idxStart = max(events(events(:,1)==stims(stimIdx),2));
        idxEnd   = idxStart + 60*fs -1;
		
        if (isempty(idxStart) || size(eeg,2) <= idxEnd)
          idxEnd = size(eeg,2);
		  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		  disp(['Data rest not found for PD1 Subject: ',num2str(subj),' in stimulus:', num2str(stimIdx)])
        end
        dataRest{stimIdx,subj} = eeg(:,idxStart:idxEnd);
    end
end
dataPD1Rest = dataRest;

%------------------------------- PD on med
disp('For PD2')
dataEEG = dataPD2;
dataRest = cell(length(stims),length(dataEEG));
for subj = 1:length(dataEEG)
    eeg = dataEEG{subj}.dataFiltered;
    fs = dataEEG{subj}.srate;
    events = geteventinfo(dataEEG{subj}.event);
    for stimIdx = 1:length(stims)
        idxStart = max(events(events(:,1)==stims(stimIdx),2));
        idxEnd   = idxStart + 60*fs -1;
		
        if (isempty(idxStart) || size(eeg,2) <= idxEnd)
          idxEnd = size(eeg,2);
		  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		  disp(['Data rest not found for PD2 Subject: ',num2str(subj),' in stimulus:', num2str(stimIdx)])
        end
        dataRest{stimIdx,subj} = eeg(:,idxStart:idxEnd);
    end
end
dataPD2Rest = dataRest;

save('dataRest.mat','dataHCRest','dataPD1Rest','dataPD2Rest','-v7.3');

%% Task State Data PreGo
disp('=============================')
disp('Extracting Task...')
%------------------------------- Healthy
disp('For HC')
stims = (1:12)+20;

dataEEG = dataHC;
preTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataHCTaskPreGo = PreGoTask(dataEEG,preTask,stims);

%------------------------------- PD off med
disp('For PD1')
dataEEG = dataPD1;
preTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataPD1TaskPreGo = PreGoTask(dataEEG,preTask,stims);

%------------------------------- PD on med
disp('For PD2')
dataEEG = dataPD2;
preTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataPD2TaskPreGo = PreGoTask(dataEEG,preTask,stims);

save('dataTaskPreGo.mat','dataHCTaskPreGo','dataPD1TaskPreGo','dataPD2TaskPreGo','-v7.3');

%% Task State Data PostGo
disp('=============================')
disp('Extracting Task...')
%------------------------------- Healthy
disp('For HC')
stims = (1:12)+20;

dataEEG = dataHC;
postTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataHCTaskPostGo = PostGoTask(dataEEG,postTask,stims);

%------------------------------- PD off med
disp('For PD1')
dataEEG = dataPD1;
postTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataPD1TaskPostGo = PostGoTask(dataEEG,postTask,stims);

%------------------------------- PD on med
disp('For PD2')
dataEEG = dataPD2;
postTask = 1;% 1500ms+-500 jitter on fixation so we alteast have 1s fixation duration for everyone
dataPD2TaskPostGo = PostGoTask(dataEEG,postTask,stims);

save('dataTaskPostGo.mat','dataHCTaskPostGo','dataPD1TaskPostGo','dataPD2TaskPostGo','-v7.3');

%% Outlier Removal and Normalization
load dataTaskPreGo.mat
load dataTaskPostGo.mat
load dataRest.mat
chNum = 27;

%------------------HC
[dataHCRest,dataHCTaskPreGo,dataHCTaskPostGo] = ...
    NormalizeDataEEG(dataHCRest,dataHCTaskPreGo,dataHCTaskPostGo,chNum);

%------------------PD1
[dataPD1Rest,dataPD1TaskPreGo,dataPD1TaskPostGo] = ...
    NormalizeDataEEG(dataPD1Rest,dataPD1TaskPreGo,dataPD1TaskPostGo,chNum);

%------------------PD2
[dataPD2Rest,dataPD2TaskPreGo,dataPD2TaskPostGo] = ...
    NormalizeDataEEG(dataPD2Rest,dataPD2TaskPreGo,dataPD2TaskPostGo,chNum);
save('dataPreTaskNormalized.mat','dataHCTaskPreGo','dataPD1TaskPreGo','dataPD2TaskPreGo','-v7.3');
save('dataPostTaskNormalized.mat','dataHCTaskPostGo','dataPD1TaskPostGo','dataPD2TaskPostGo','-v7.3');
save('dataRestNormalized.mat','dataHCRest','dataPD1Rest','dataPD2Rest','-v7.3');

%% Subband Extraction
stims = (1:12)+20;
fs = 1000;
%------------------------------- Healthy
str = 'HCPreGo';
dataTask = dataHCTaskPreGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end
str = 'HCPostGo';
dataTask = dataHCTaskPostGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end
%------------------------------- PD off med
str = 'PDoffPreGo';
dataTask = dataPD1TaskPreGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end
str = 'PDoffPostGo';
dataTask = dataPD1TaskPostGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end
%------------------------------- PD on med
str = 'PDonPreGo';
dataTask = dataPD2TaskPreGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end
str = 'PDonPostGo';
dataTask = dataPD2TaskPostGo;
for stimIdx = 1:length(stims)
    EEG = dataTask(stimIdx,:);
    SubbandData(EEG,fs,[str,'_StimIndex',num2str(stimIdx)]); %data will be saved in the function
end