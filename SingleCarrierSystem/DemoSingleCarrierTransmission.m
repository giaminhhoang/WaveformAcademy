clearvars; close all;

%% Parameters
% Data
qam_order = 16;
tx_data = ['Waveform Academy! ' utils.rand_str(2502)];

% Communication System
fs = 1000;
fc = 100;

% Channel
snr = 10;

%% QAM Modulation
tx_bits = utils.text2bits(tx_data);
bits_per_symbol = log2(qam_order);
n_symbols = length(tx_bits) / bits_per_symbol;

tx_symbols = qammod(reshape(tx_bits, bits_per_symbol, n_symbols), ...
    qam_order, "gray", "InputType", "bit", "UnitAveragePower", true);

figure;
axlim = max(max(abs(tx_symbols))) + 0.05;
plot(tx_symbols, '.', 'MarkerSize', 25, 'Color', '#233ce6');
xlabel("In-phase"); ylabel("Quadrature");
xlim([-axlim axlim]); ylim([-axlim axlim]);

%% Upconversion
time = (0 : n_symbols * fs - 1) / fs;

carrier_I = cos(2 * pi * fc * time);
carrier_Q = -sin(2 * pi * fc * time);

tx_symbols = repelem(tx_symbols, fs);
tx_waveform = real(tx_symbols) .* carrier_I + imag(tx_symbols) .* carrier_Q;

figure;
tiledlayout(2, 1);

nexttile;
plot(time(1 : 100), tx_waveform(1 : 100), 'Color', '#233ce6');
xlabel('Time [s]'); ylabel('Amplitude');

nexttile;
n_samples = length(tx_waveform);
freq = (-n_samples / 2 : n_samples / 2 - 1) / n_samples * fs;
plot(freq, abs(fftshift(fft(tx_waveform))) / n_samples, 'Color', '#233ce6');
xlim([-fc - 50 fc + 50]);
xlabel('Frequency [Hz]'); ylabel('Magnitude');

%% Channel
rx_waveform = awgn(tx_waveform, snr, "measured");

%% Downconversion
rx_baseband_I = 2 * rx_waveform .* carrier_I;
rx_baseband_Q = 2 * rx_waveform .* carrier_Q;
rx_baseband = rx_baseband_I + 1i * rx_baseband_Q;

figure;
plot(freq, abs(fftshift(fft(rx_baseband))) / n_samples, 'Color', '#ff5757');
xlabel('Frequency [Hz]'); ylabel('Magnitude');

%% Low-pass Filter
lp_filter = fir1(64, 0.1);
rx_baseband = filter(lp_filter, 1, rx_baseband);

figure;
plot(freq, abs(fftshift(fft(rx_baseband))) / n_samples, 'Color', '#ff5757');
xlabel('Frequency [Hz]'); ylabel('Magnitude');

%% Decimation
rx_symbols = rx_baseband(fs / 2 + 1 : fs : end);

figure;
plot(rx_symbols, '.', 'MarkerSize', 25, 'Color', '#ff5757');
xlabel("In-phase"); ylabel("Quadrature");
xlim([-axlim axlim]); ylim([-axlim axlim]);

%% QAM Demodulation
rx_bits = qamdemod(rx_symbols, qam_order, "gray", ...
    "OutputType", "bit", 'UnitAveragePower', true);
rx_bits = rx_bits(:).';

n_errors = sum(rx_bits ~= tx_bits);
ber = n_errors / length(rx_bits);
disp("BER: " + ber);

rx_data = utils.bits2text(rx_bits);
disp("TX Data: " + tx_data(1 : 40));
disp("RX Data: " + rx_data(1 : 40));