function Hd = lowpassGamma
%GETFILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.6 and DSP System Toolbox 9.8.
% Generated on: 22-Feb-2020 17:31:47

Fpass = 57;   % Passband Frequency
Fstop = 60;   % Stopband Frequency
Apass = 1;     % Passband Ripple (dB)
Astop = 60;    % Stopband Attenuation (dB)
Fs    = 1000;  % Sampling Frequency

h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);

Hd = design(h, 'cheby1', ...
    'MatchExactly', 'passband', ...
    'SOSScaleNorm', 'Linf');


