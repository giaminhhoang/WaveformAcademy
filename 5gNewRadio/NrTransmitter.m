clearvars; close all;

%% Configuration
numSubframes = 25;
fc = 3925e6;
bw = 10;
wavegenConfig = transmitter.config(numSubframes, fc, bw);

%% Generation
[txWaveform, waveInfo] = nrWaveformGenerator(wavegenConfig);

%% Plot
txOfdmInfo = waveInfo.ResourceGrids(1).Info;
nfft = txOfdmInfo.Nfft;

figure;
spectrogram(txWaveform, ones(nfft, 1), 0, nfft, 'centered',...
    txOfdmInfo.SampleRate, 'yaxis', 'MinThreshold', -130);

%% Save
save('signals\nrDlWaveform.mat', "txWaveform", "waveInfo", "wavegenConfig");
