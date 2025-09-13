clearvars; close all;

%% Parameters
fs = 1000;
fc = 10;
oversample_factor = 10;

%% Window Functions
windows = [rectwin(fs), hamming(fs), blackman(fs), chebwin(fs)];
labels = ["Rectangle", "Hamming", "Blackman", "Chebyshev"];

figure;
tiledlayout(2, 2);
for i = 1 : 4
    nexttile;
    plot(windows(:, i));
    xlabel("Samples"); ylabel("Amplitude");
    ylim([0 1.1]); title(labels(i));
end

%% Signal
time = (0 : fs - 1).' / fs;
x = sin(2 * pi * fc * time);

%% Windowing
x = repmat(x, 1, 4);
x = x .* windows;

figure;
tiledlayout(2, 2);
for i = 1 : 4
    nexttile;
    plot(time, x(:, i));
    xlabel("Time [s]"); ylabel("Amplitude");
    title(labels(i));
end

%% Spectrum
freq = (0 : fs * oversample_factor / 2 - 1) / oversample_factor;
X = fft(x, fs * oversample_factor, 1);
X = X(1 : end / 2, :);

figure;
tiledlayout(2, 2);
for i = 1 : 4
    nexttile;
    plot(freq, mag2db(abs(X(:, i) / max(abs(X(:, i))))));
    xlabel("Frequency [Hz]"); ylabel("Magnitude [dB]");
    ylim([-120 inf]); xlim([fc - 5 fc + 5]);
    title(labels(i));
end