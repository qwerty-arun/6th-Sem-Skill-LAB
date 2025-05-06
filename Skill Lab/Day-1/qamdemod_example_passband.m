clc; clear; close all;

%% Parameters
M = 4;                      % Modulation order (2^M-QAM)
%k = log2(M);                 % Bits per symbol
numSymbols = 10000;           % Number of QAM symbols
Rsym = 50e6;                 % Symbol rate
Fs = 4e9;             % Sampling frequency (400 MHz)
Fc = 1e9;                    % Carrier frequency (1 GHz)
sps = Fs/Rsym;                     % Samples per symbol
SNR_dB = 10;                 % Desired SNR

%% Transmitter
data = randi([0 (2^M)-1], numSymbols, 1);
txSymbols = qammod(data, 2^M, 'UnitAveragePower', true);

% Upsample
txUpsampled = upsample(txSymbols, sps);

% Interpolation filter (simple rectangular pulse shaping)
txSignal1 = conv(txUpsampled, ones(sps,1), 'same');
txSignal= txSignal1(1:end-(sps/2));

% Modulate to passband
t = (0:length(txSignal)-1)'/Fs;
txPassband = real(txSignal .* exp(1j*2*pi*Fc*t));

%% Channel: Add AWGN
signalPower = mean(abs(txPassband).^2);
SNR_linear = 10^(SNR_dB/10);
noisePower = signalPower / SNR_linear;
rxPassband = txPassband + sqrt(noisePower) * randn(size(txPassband));

%% Receiver: Downconvert
rxBB = rxPassband .* exp(-1j*2*pi*Fc*t);  % Mix down

% Simple low-pass filter to remove 2xFc component
lpf = fir1(128, Rsym/(Fs/2));             % Cutoff at Rsym (normalized)
rxFiltered = filter(lpf, 1, rxBB);        % LPF output

% Downsample (no filter delay compensation, so take center slice)
rxDownsampled = downsample(rxFiltered, sps);

% Demodulate
rxSymbols = rxDownsampled(2:end);

%% Plot: Received constellation
figure;
plot(rxSymbols, '.');
title('Received 64-QAM Constellation after Downconversion and AWGN');
xlabel('In-Phase'); ylabel('Quadrature'); grid on; axis equal;

%% Plot: Overlay with transmitted symbols
figure;
plot(txSymbols, 'bo'); hold on;
plot(2*rxSymbols, 'r.');
legend('Original', 'Received');
title('Original vs Received Constellation');
xlabel('In-Phase'); ylabel('Quadrature'); grid on; axis equal;