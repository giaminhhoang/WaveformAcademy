clearvars; close all;

%% Parameters
symbols = [1 + 1i, -1 - 1i, 0.5 - 0.5i, -0.5 + 0.5i];
symbol_mapping = ["00", "01", "10", "11"];
codeword = ["01", "11", "00", "10"];

%% Constellation Diagram
axlim = 1.2;
color = '#FF5757';

figure;
hold on;

for i = 1 : 4
    txt = symbol_mapping(i);
    text(real(symbols(i)) - 0.05, imag(symbols(i)) + 0.12, txt);
end
plot(symbols, '.', 'MarkerSize', 50, 'Color', color);
hold off;
ylim([-axlim axlim]); xlim([-axlim axlim]);
set(gca, 'XAxisLocation', 'origin'); set(gca, 'YAxisLocation', 'origin');
ax = gca; ax.XAxis.LineWidth = 2; ax.YAxis.LineWidth = 2;
yticks([]); xticks([]); axis square;

%% Modulated Signal
sampling_frequency = 1000;
time = (0 : 4 * sampling_frequency - 1) / sampling_frequency;

symbol_indices = arrayfun(@(x) find(symbol_mapping == x, 1), codeword);
tx_symbols = symbols(symbol_indices);

% Method 1
modulated_signal1 = zeros(size(time));
for i = 0 : 3
    segment_time = time(i * sampling_frequency + 1 : (i + 1) * sampling_frequency);
    phase_shift = angle(tx_symbols(i + 1));
    carrier_segment = cos(2 * pi * segment_time + phase_shift);

    modulated_symbol = carrier_segment * abs(tx_symbols(i + 1));
    modulated_signal1(i * sampling_frequency + 1 : (i + 1) * sampling_frequency) = ...
        modulated_symbol;
end

% Method 2
carrier_I = cos(2 * pi * time);
carrier_Q = -sin(2 * pi * time);

tx_symbols = repelem(tx_symbols, sampling_frequency);
modulated_signal2 = real(tx_symbols) .* carrier_I + imag(tx_symbols) .* carrier_Q;

%% Signal Plot
bits = strjoin(codeword, "");
bits = char(bits) - '0';
color = '#233ce6';

figure;
tiledlayout(3, 1);

nexttile;
x_values = 0 : length(bits);
x_values = repelem(x_values, 2);
x_values = x_values(2 : end - 1);
y_values = repelem(bits, 2);
plot(x_values, y_values, 'Color', color, 'LineWidth', 2);
xlabel('Bit Idx'); ylabel('Bit Value');
ylim([-0.2, 1.2]); xlim([0, x_values(length(x_values))]);

nexttile;
plot(time, modulated_signal1, 'Color', color, 'LineWidth', 2);
xticks(0 : 4); xlim([0, 4]); xlabel('Symbol Idx'); ylabel('Amplitude');

nexttile;
plot(time, modulated_signal2, 'Color', color, 'LineWidth', 2);
xticks(0 : 4); xlim([0, 4]); xlabel('Symbol Idx'); ylabel('Amplitude');
