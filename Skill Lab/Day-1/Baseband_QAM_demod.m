%This code uses complex baseband representation to showcase the impact of
%AWGN noise on the constellation diagram.Change the QAM order to see the
%impact of a finite SNR on a given constellation diagram.
%------------------------------------------------------------------------
clc;
clear all;

% Parameters
M = 64;                     % 64-QAM
k = log2(M);                % Bits per symbol
numSymbols = 30000;          % Number of QAM symbols
SNR_dB = 40;                % SNR in dB

Rs = 50e6;                  % Symbol rate (50 MHz)
sps = 8;                    % Samples per symbol
Fs = Rs * sps;              % Sampling frequency (400 MHz)
Ts = 1/Fs;

% --- Transmitter ---

% 1. Generate random data
data = randi([0 M-1], numSymbols, 1);

% 2. Modulate using 64-QAM (Gray coding)
txSymbols = qammod(data, M, 'UnitAveragePower', true);

% 3. Upsample
txUpsampled = upsample(txSymbols, sps);

% Interpolation filter (simple rectangular pulse shaping)
txSignal1 = conv(txUpsampled, ones(sps,1), 'same');
txSignal= txSignal1(1:end-4);

% Optional: Use pulse shaping (e.g., rcosdesign) here if needed

% --- Add AWGN ---
rxSignal = awgn(txSignal, SNR_dB, 'measured');

% --- Receiver ---

% 1. Downsample (no matched filter needed here)
rxSymbols = rxSignal(1:sps:end);

% 2. Plotting

% Plot 1: Received constellation alone
figure;
scatter(real(rxSymbols), imag(rxSymbols), 'b.');
axis equal; grid on;
title('Received Constellation (Complex Baseband)');
xlabel('In-Phase'); ylabel('Quadrature');
grid on;
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';

% Plot 2: Overlay with original constellation
figure;
hold on;
scatter(real(txSymbols), imag(txSymbols), 'go', 'DisplayName', 'Transmitted');
scatter(real(rxSymbols), imag(rxSymbols), 'r.', 'DisplayName', 'Received');
axis equal; grid on;
title('Overlay: Transmitted vs. Received Constellation');
xlabel('In-Phase'); ylabel('Quadrature');
legend;
grid on;
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';
