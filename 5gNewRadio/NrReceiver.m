clearvars; close all;

%% Parameters
fc = 3925e6;
scsSsb = 30;
fs = 15.36e6;

thresholdPss = 0.9;

%% Load Signal
file = load('signals\nrDlWaveform.mat');
rxWaveform = file.txWaveform;

nfft = fs / scsSsb / 1e3;
maxBw = max(utils.availableBandwidths(fs));

%% Channel
cfo = scsSsb * 1e3 * 1.3;
rxWaveform = rxWaveform .* exp(1i * 2 * pi * cfo * ...
    (0 : length(rxWaveform) - 1).' / fs);

%% Plot Spectrum
spectrum = fft(rxWaveform);
len = length(rxWaveform);
freq = (-len / 2 : len / 2 - 1) / len * fs;

figure;
plot(freq, mag2db(abs(fftshift(spectrum))));
xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');

figure;
spectrogram(rxWaveform, ones(nfft, 1), 0, nfft, 'centered', ...
    fs, 'yaxis', 'MinThreshold', -130);

%% SSB Subcarrier Offset and CFO Detection
disp('--- SSB Subcarrier Offset and CFO Detection ---');
raster = utils.syncRaster(fc / 1e6, maxBw / 1e6, scsSsb);
cfoCandidates = -3 : 0.5 : 3;
fshifts = reshape(cfoCandidates.' + raster, 1, []);
fshifts = unique(fshifts);
[freqOffset, cor, nid2] = receiver.pssFreqSync(rxWaveform, scsSsb, fshifts, fs);

[~, idx] = min(abs(raster - freqOffset));
ssbSubcarOffset = raster(idx);
cfoEstim = freqOffset - ssbSubcarOffset;

rxWaveform = rxWaveform .* ...
    exp(-1i * 2 * pi * freqOffset * scsSsb * 1e3 .* ...
    (0 : numel(rxWaveform) - 1).' / fs);

figure;
plot(fshifts, abs(cor), '-o');
legend(["NID2 = 0", "NID2 = 1", "NID2 = 2"]);
xlabel('Frequency Offset'); ylabel('Correlation');

disp("   SSB Offset = " + ssbSubcarOffset);
disp("   CFO = " + cfoEstim + " = " + cfoEstim * scsSsb + "kHz");
disp("   NID2 = " + nid2);

%% PSS Timing Offset Correction
disp('--- PSS Timing Offset Correction ---');
timingOffsets = receiver.pssTimingOffset(rxWaveform, nid2, scsSsb, ...
    fs, thresholdPss);

%% Process SSBs
for i = 1 : length(timingOffsets)
    disp("  SSB " + i + "/" + length(timingOffsets));
    timingOffset = timingOffsets(i);

    ssbRxSymbols = receiver.extractSsb(rxWaveform, timingOffset, ...
        scsSsb, fs, fc);

    [nid1, ncellid] = receiver.detectSss(ssbRxSymbols, nid2);
    disp("   NID1 = " + nid1);
    disp("   NCellID = " + ncellid);
end