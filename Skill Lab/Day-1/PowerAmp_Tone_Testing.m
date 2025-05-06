%This Code Provides the Single and Two Tone Testing of Power Amplifier
%----------------------------------------------------------------------
clc;
clear all;

%% Simulated Power Amplifier Data
Pin_sim=[-25,-22,-19,-16,-13,-10,-7,-4,  -1,   0,   3];
AM_AM_sim=[-6,-3, 0,  3,  6, 7.5,10,12.1,12.2,12.2,12.2];
AM_PM_sim=[0.8,0.8,1.2,1.8,3.2,5,10,14, 20,  21.59, 25.85];
Ain_sim= sqrt(2*50*(10.^((Pin_sim-30)/10)));
AM_AM_lin_sim= sqrt(2*50*(10.^((Pin_sim-30)/10)));
%% Saleh’s Model Parameters (Obtained from Saleh_Curve_Fitting.m Code)
alpha1 = 8.75; beta1 = 10.78;   % AM/AM parameters
alpha2 = 11.61; beta2 = 20.78;  % AM/PM parameters

%% Sinusoidal Test - Time Domain and PSD 
fc = 1e9;
Fs = 50*fc;
t = 0:1/Fs:(100e-9)-1/Fs; 
% Small amplitude
x_small = 0.1 * sin(2*pi*fc*t); % -10dBm Input Power Signal
A = abs(x_small);
amp_out = (alpha1 * A) ./ (1 + beta1 * A.^2);
y_small = amp_out .* sign(x_small);

% Large amplitude
x_large = 0.75 * sin(2*pi*fc*t); % 7.5dBm Input Power Signal
A = abs(x_large); %Inherently Present in the Formula
amp_out = (alpha1 * A) ./ (1 + beta1 * A.^2);
y_large = amp_out .* sign(x_large); % To avoid the -ve peak becoming +ve

figure;
subplot(2,1,1); 
plot(t, x_small, 'b', t, y_small, 'r'); 
xlabel('time(sec)'); ylabel('Output Amplitude');
legend('Input', 'Output'); 
title('Small Amplitude');
subplot(2,1,2); 
plot(t, x_large, 'b', t, y_large, 'r'); 
xlabel('time(sec)'); ylabel('Output Amplitude');
legend('Input', 'Output'); 
title('Large Amplitude');

figure;
pwelch(y_small,[],[],[],Fs,'centered','power'); title('PSD - Small Amplitude');
figure;
pwelch(y_large,[],[],[],Fs,'centered','power'); title('PSD - Large Amplitude');