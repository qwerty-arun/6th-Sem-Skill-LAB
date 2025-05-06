clear variables;
clc;
M=16; % Modulation alphabet size
q=qammod(0:1:M-1,M); % Generate M-QAM alphabet
signal=repmat(q,1,10^3); 
Fs= 500e6; % Sampling frequency
B_PLL = 100e3; % PLL bandwidth
L0 = -95; % Inband noise in dBc/Hz
L_floor = -150; % Noise floor in dBc/Hz
f_corner = 1e3; % Flicker noise corner frequency in Hz


[signal_pn, pn] = LO_phasenoise(signal, Fs, B_PLL, L0, L_floor, f_corner); 
% signal_pn is the input 'signal' affected by phase noise ;
% pn is the time domain phase noise;

dt= 1/Fs;
time=0:dt:(length(signal) -1)*dt;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Experiment 1
%  To study the effect of phase noise on the M-QAM constellation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure(1);
scatter(real(signal_pn), imag(signal_pn));
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
grid on;
hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 2
% To study the effect of phase noise + AWGN on M-QAM constellation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snr= 15; % SNR in dB
SNR = 10^(snr/10); % SNR in linear scale
Es = norm(q)^2/M; % Average energy of the constellation
No = Es/SNR; 
n=(randn(1,length(signal))+1i*randn(1, length(signal)))*sqrt(No/2); % Generate noise of variance No
y = signal_pn +n; % signal corrupted by the phase noise + AWGN

figure(2);
scatter(real(y), imag(y));
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
grid on;
hold on;





