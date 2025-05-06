clc;
clear all;

%% Parameters
M = 8;                      % 16-QAM
k = log2(M);                 
numSymbols = 2400;
Rs = 20e6;                    % Symbol rate = 1 Mbps
fc = 1e9;                   % IF carrier frequency (20 MHz)
fs = 4 *fc;               % Sampling rate = 40 MHz
sps = fs/Rs;                    % Samples per symbol


%% 1. Random bitstream and QAM modulation
data = randi([0 M-1], numSymbols, 1);
%x = qammod(data, M, UnitAveragePower=true);  % Baseband symbols (I+jQ)
x = qammod(data, M);  % Baseband symbols (I+jQ)

%% 2. Upsample and apply rectangular pulse shaping
x_upsampled = upsample(x, sps);                  % Insert zeros between symbols
pulse_shape = ones(sps,1);                       % Rectangular pulse
baseband_signal = conv(x_upsampled, pulse_shape);  % Baseband waveform (complex)

%% 3. Time vector and upconversion
t = (0:length(baseband_signal)-1)'/fs;
passband_signal = real(baseband_signal .* exp(1j*2*pi*fc*t));  % Real passband

%% 4. Plotting (Optional)
figure()
plot(real(x), imag(x), '*');
title('16-QAM Constellation');
xlabel('I'); ylabel('Q'); grid on;

figure()
plot(t, real(baseband_signal));
title('Baseband Signal (I-component)');

figure()
plot(t, passband_signal);
title('Passband Signal'); xlabel('Time'); ylabel('Amplitude');

%%
power_signal = abs(passband_signal).^2;
peak_power = max(power_signal);
avg_power = mean(power_signal);
PAPR_dB = 10 * log10(peak_power / avg_power);

%%
[pxx, f] = pwelch(passband_signal(1:4096), hamming(4096), 1024, 8192, fs);
figure;
plot(f/1e6, 10*log10(pxx));
xlabel('Frequency (MHz)');
ylabel('Power/Frequency (dB/Hz)');
title('PSD of Passband Signal (0 to fs/2)');