function ynew = DestroyPAC(Signal,fs,Amp_fs,Phase_fs, method)

%Amp_fs are the boundary for amplitude noise contamination band sample Delta band [0,4] hz
%Phase_fs are the boundary for phase noise contamination band sample Gamma [32,55] hz
% find sample numbers
N = length(Signal);
% find frequency resolution of the fft
f_res = fs/N;
yf = fft(Signal);
yf_amp = abs(yf);
yf_phase = angle(yf);
%frequencies
Freqs = (0:(N-1))*f_res;
% move all frequencies that are greater than fs/2 to the negative side of the axis
Freqs(Freqs >= fs/2) = Freqs(Freqs >= fs/2) - fs;
% find amplitude and phase band indexes
if(~isempty(Amp_fs))
    Amp_idx = find(abs(Freqs)>=Amp_fs(1) & abs(Freqs)<=Amp_fs(2));
end
if(exist('Phase_fs','var')&&~isempty(Phase_fs))
    Phase_idx = find(abs(Freqs)>=Phase_fs(1) & abs(Freqs)<=Phase_fs(2));
end
if method == "Reverse"
    if(~isempty(Amp_fs))
        yf_amp(Amp_idx) = yf_amp(Amp_idx(end:-1:1));  %Reverse
    end
    if(exist('Phase_fs','var')&&~isempty(Phase_fs))
        yf_phase(Phase_idx) = yf_phase(Phase_idx(end:-1:1)); % Reverse
    end
end
if method == "Noise"
    if(~isempty(Amp_fs))
       yf_amp(Amp_idx) = yf_amp(Amp_idx)+ randn(1,length(Amp_idx))* mean(yf_amp(Amp_idx)); % Noise
    end
    if(exist('Phase_fs','var')&&~isempty(Phase_fs))
%         mean(yf_phase(Phase_idx))
       yf_phase(Phase_idx) = yf_phase(Phase_idx)+  randn(1,length(Phase_idx)).*yf_phase(Phase_idx); % Noise
    end
end
if method == "Scramble"
    if(~isempty(Amp_fs))
       yf_amp(Amp_idx) = yf_amp(Amp_idx(randperm(length(Amp_idx)))); % Scramble
    end
    if(exist('Phase_fs','var')&&~isempty(Phase_fs))
       yf_phase(Phase_idx) = yf_phase(Phase_idx(randperm(length(Phase_idx)))); % Scramble
    end
end
if method == "Zero"
    if(~isempty(Amp_fs))
       yf_amp(Amp_idx) = 0; 
    end
    if(exist('Phase_fs','var')&&~isempty(Phase_fs))
       yf_phase(Phase_idx) = 0;
    end
end
% reconstruct the signal
yfnew = yf_amp.*exp(1i*yf_phase);
ynew = ifft(yfnew,'symmetric');


end



% fs = 1000;
% 
% 
% t = 1/fs:1/fs:100;
% N = length(t);
% 
% y = chirp(t,0,100,250);
% pspectrum(y,fs,'spectrogram','OverlapPercent',99)
% yf = fft(y);

% yfamp = abs(yf);
% 
% f =  fs*(0:(N/2))/N;
% 
% plot(f,yfamp((N+1)/2:end));

