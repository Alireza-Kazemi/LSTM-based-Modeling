function eeg = PreprocessingFilter(eeg,fs)

fcL = 45;
fcH = .5;

lpFilt = designfilt('lowpassfir','PassbandFrequency',fcL, ...
         'StopbandFrequency',fcL+2,'PassbandRipple',fcL+2, ...
         'StopbandAttenuation',65,'DesignMethod','kaiserwin','SampleRate',fs);
% fvtool(lpFilt)  

hpFilt = designfilt('highpassfir','StopbandFrequency',fcH-.25, ...
         'PassbandFrequency',fcH,'PassbandRipple',fcH, ...
         'StopbandAttenuation',65,'DesignMethod','kaiserwin','SampleRate',fs);
     
eeg = filtfilt(hpFilt,eeg');
eeg = filtfilt(lpFilt,eeg);     
eeg = eeg';
end


%% For testing filter design
% lpFilt = designfilt('lowpassfir','PassbandFrequency',55, ...
%          'StopbandFrequency',57,'PassbandRipple',57, ...
%          'StopbandAttenuation',65,'DesignMethod','kaiserwin','SampleRate',1000);
% % fvtool(lpFilt)  
% 
% hpFilt = designfilt('highpassfir','StopbandFrequency',0.25, ...
%          'PassbandFrequency',0.5,'PassbandRipple',0.5, ...
%          'StopbandAttenuation',65,'DesignMethod','kaiserwin','SampleRate',1000);
% fvtool(hpFilt)
% bpFilt = designfilt('bandpassfir','FilterOrder',70, ...
%          'CutoffFrequency1',.5,'CutoffFrequency2',55, ...
%          'SampleRate',1000);
% fvtool(bpFilt)
% 
% f0 = .1;
% f1 = .3;
% f2 = .5;
% f3 = 1;
% f4 = 250;
% t = 0:1/1000:100;
% A = sin(2*pi*t*f0)+sin(2*pi*t*f1)+sin(2*pi*t*f2)+sin(2*pi*t*f3)+sin(2*pi*t*f4);
% % B = filtfilt(bpFilt,A);
% B = filtfilt(hpFilt,A);
% B = filtfilt(lpFilt,B);
% 
% subplot 311
% pwelch(A,[],[],[],1000)
% xlim([0,20])
% subplot 312
% pwelch(B,[],[],[],1000)
% xlim([0,20])
% subplot 313
% plot(A)
% hold on
% plot(B)
% xlim([0,2e4])