clear variables;
close all;
clc;

%%
M=16;  % QAM order
s=qammod(0:1:M-1, M); % QAM symbol generation

deltaG_t=0.5;  %Gain imbalnce
deltaPhi_t_deg=0.3; %phase imbalance in degrees
delta_Phi_t= deltaPhi_t_deg*pi/180; % in radians

alpha_tx=cos(delta_Phi_t/2) + 1i*deltaG_t/2*sin(delta_Phi_t/2);
beta_tx=-deltaG_t/2*cos(delta_Phi_t/2) - 1i*sin(delta_Phi_t/2);

s_IQ=alpha_tx.*s + beta_tx.*conj(s);

figure
scatter(real(s_IQ), imag(s_IQ), 'go','LineWidth',10);
grid on; hold on;
scatter(real(s), imag(s),'b*','LineWidth',10);
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
title('With TX IQI')

alpha = 0.15;
theta = 15;
theta_radian = theta*pi/180;
alpha_rx=cos(theta_radian/2) + 1i*(alpha/2)*sin(theta_radian/2);
beta_rx=-(alpha/2)*cos(theta_radian/2) - 1i*sin(theta_radian/2);
gamma = alpha_rx;
gamma1 = beta_rx;
s_IQ_r = gamma.*s_IQ + gamma1.*conj(s_IQ);
figure
scatter(real(s_IQ_r), imag(s_IQ_r), 'go','LineWidth',10);
grid on; hold on;
scatter(real(s), imag(s),'b*','LineWidth',10);
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
title('With TX and RX IQI')


%clear variables;
%close all;
%clc;

%%

