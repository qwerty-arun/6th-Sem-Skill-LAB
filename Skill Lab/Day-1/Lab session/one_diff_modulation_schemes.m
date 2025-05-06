clear variables;
close all;
clc;

%%
M=16;  % QAM order
s=qammod(0:1:M-1, M); % QAM symbol generation

M = 16;% QPSK order
data = randi([0 M-1], 1000, 1);
y = pskmod(data, M);



figure
scatter(real(s), imag(s), 'go','LineWidth',10);
grid on; hold on;
scatter(real(s), imag(s),'b*','LineWidth',10);
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');

figure
scatter(real(y), imag(y), 'go','LineWidth',10);
grid on; hold on;
scatter(real(y), imag(y),'b*','LineWidth',10);
xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
title('qpsk mod');

W=1e6; % Bandwidth
Ts=1/W; % Sampling period
N=64; % number of subcarriers
delta_f = W/N; % Subcarrier spacing

M=16; % Modulation alphabet size
s=qammod(0:1:M-1,M);
figure
for i=1:100  % OFDM symbol index
    
    r=randi([1 M], N);
    for j=1:N % Constellation symbols within one OFDM symbol
        X(j)=s(r(j));
    end
    x=sqrt(N)*ifft(X.');  %IFFT Before transmitting
    y=x;
    Y=fft(y)/sqrt(N);  %FFT at receiver end
    
    scatter(real(Y), imag(Y), 'k','filled');
    grid on; hold on;
    xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
    title('OFDM')

end


clear variables;
clc;

W=1e6; % Bandwidth
Ts=1/W; % Sampling period
N=64; % number of subcarriers
delta_f = W/N; % Subcarrier spacing

M=64; % Modulation alphabet size
s=qammod(0:1:M-1,M);

snr=60; % SNR in dB
SNR=10^(snr/10);

Es=norm(s)^2/M;
No=Es/SNR;


for i=1:100  % OFDM symbol index
    
    r=randi([1 M], N);
    for j=1:N % Constellation symbols within one OFDM symbol
        X(j)=s(r(j));
    end
    x=sqrt(N)*ifft(X.');
    
    y=x; %Received OFDM signal in the abssence of CFO (ideal case)
    
    Y=fft(y)/sqrt(N);
    
    scatter(real(Y), imag(Y), 'k','filled');
    grid on; hold on;
    xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');
    title('OFDM')

end



