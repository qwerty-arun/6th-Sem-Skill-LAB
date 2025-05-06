clear variables;
clc;
M=16; % Modulation alphabet size
q=qammod(0:1:M-1,M); % Generate M-QAM alphabet
signal=repmat(q,1,10^5); 
Fs= 500e6; % Sampling frequency
B_PLL = 100e3; % PLL bandwidth
L0 = -95; % Inband noise in dBc/Hz
L_floor = -150; % Noise floor in dBc/Hz
f_corner = 1e3; % Flicker noise corner frequency in Hz


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 1
% To generate the phase noise profile with given parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L0_lin = 10^(L0/20);
L_floor_lin = 10^(L_floor/20);
count=0;
for fm=10^2:1000:10^8
    count=count + 1;
    L(count) = (B_PLL^2*L0_lin)/(B_PLL^2 + fm^2)* (1 + f_corner/fm) + L_floor_lin;
    L_dB(count) = 20*log10(L(count));
end

figure(1)
semilogx(10^2:1000:10^8, L_dB);
xlabel('Frequency offset (Hz)'); ylabel('Phase noise PSD (dBc/Hz)');
grid on;
hold on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 2
% To plot the time domain phase noise samples and its histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[signal_pn, pn] = LO_phasenoise(signal, Fs, B_PLL, L0, L_floor, f_corner); 
% signal_pn is the input 'signal' affected by phase noise ;
% pn is the time domain phase noise;

dt= 1/Fs;
time=0:dt:(length(signal) -1)*dt;

figure(2);
plot (time,pn)
xlabel('Time in s'); ylabel('Phase noise (rad)');
grid on;
hold on;


figure(3);
histfit(pn);
title('Histogram of phase noise sample values')
grid on; hold on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 3
% To find the SNR due to phase noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta=rms(pn);  % EVM
snr_pn=10*log10(1/theta^2);
disp(snr_pn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 4
% To recover the PSD from the generated time samples of phase noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N1=length(pn);
pndft=fft(pn);
pndft = pndft(1:N1/2+1);
psdpn=(1/(Fs*N1)) * abs(pndft).^2;
psdpn(2:end-1) = 2*psdpn(2:end-1);
psdpn=periodogram(pn,rectwin(length(pn)),length(pn),Fs);  %This is buitin
% function to compute the PSD from time samples
% https://in.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
% see above link for details
freq = 0:Fs/length(pn):Fs/2;
figure(4)
semilogx(freq,10*log10(psdpn),'LineWidth',2.0);
ylabel('Recovered PSD (dB)'); xlabel('f (log scale)');
grid on;
hold on;

