clear variables;
clc;

alpha=0.1;  % Transmit gain imbalance
theta_deg=1; % Transmit phase imbalance
theta=theta_deg*pi/180; % Conversion to radians


alpha_rx=cos(theta/2) + 1i*alpha/2*sin(theta/2);  
beta_rx=-alpha/2*cos(theta/2) - 1i*sin(theta/2);

f=500; % Pilot sinusoid frequency
fc = 1e5;
omega=2*pi*f;
omega_c = 2*pi*fc; %The mixer upconversion and down conversion frequency
Fs=10*fc;  % Sampling frequency
Ts=1/Fs;  % Sampling instants


n=0:1:100000;  % Number of samples
Xi = cos(omega*n*Ts);  %The Xi = cos and Xq is 90 degree phase shifted version of it
Xq = sin(omega*n*Ts);
transmistted_signal = cos(omega*n*Ts).*cos(omega_c.*n*Ts) - sin(omega.*n*Ts).*sin(omega_c.*n*Ts);
rx_IQ=(1-alpha/2)*(cos(omega_c.*n*Ts-theta/2)-1i*(1+alpha/2)*sin(omega_c.*n*Ts+theta/2)).*transmistted_signal + beta_rx.*conj(transmistted_signal);  %
Y = fft(rx_IQ);
N = length(Y);             % Number of points
f_axis = (0:N-1)*(Fs/N);   % Frequency axis (Hz)
plot(f_axis, abs(Y)/((N)));
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('FFT Magnitude Spectrum');

