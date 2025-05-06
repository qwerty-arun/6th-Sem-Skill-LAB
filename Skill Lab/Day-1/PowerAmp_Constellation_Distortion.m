clc;
clear all;

%% Simulated Power Amplifier Data
Pin_sim=[-25,-22,-19,-16,-13,-10,-7,-4,  -1,   0,   3];
AM_AM_sim=[-6,-3, 0,  3,  6, 7.5,10,12.1,12.2,12.2,12.2];
AM_PM_sim=[0.8,0.8,1.2,1.8,3.2,5,10,14, 20,  21.59, 25.85];
Ain_sim= sqrt(2*50*(10.^((Pin_sim-30)/10)));
AM_AM_lin_sim= sqrt(2*50*(10.^((Pin_sim-30)/10)));
SNR_dB=20;
%% Saleh’s Model Parameters (Obtained from Saleh_Curve_Fitting.m Code)
alpha1 = 8.75; beta1 = 10.78;   % AM/AM parameters
alpha2 = 11.61; beta2 = 20.78;  % AM/PM parameters

mod_orders = [4];
for i = 1:length(mod_orders)
    M = mod_orders(i);
    k = log2(M);
    data = randi([0 M-1], 10000, 1);
    sym = qammod(data, M, 'UnitAveragePower', true);
    
    % Small amplitude
    small_in = 0.1 * sym; % -10dBm of Input Power Reference to 50 Ohms
    A = abs(small_in);
    phi = angle(small_in);
    amp_out = (alpha1 * A) ./ (1 + beta1 * A.^2);
    phase_out = phi + (alpha2 * A.^2) ./ (1 + beta2 * A.^2);
    y_small_1 = amp_out .* exp(1j * phase_out);
    y_small = awgn(y_small_1, SNR_dB, 'measured');
    
    % Large amplitude
    large_in = 0.75 * sym; % 7.5dBm of Input Power Reference to 50 Ohms
    A = abs(large_in);
    phi = angle(large_in);
    amp_out = (alpha1 * A) ./ (1 + beta1 * A.^2);
    phase_out = phi + (alpha2 * A.^2) ./ (1 + beta2 * A.^2);
    y_large_1 = amp_out .* exp(1j * phase_out);
    y_large = awgn(y_large_1, SNR_dB, 'measured');
    
    figure;
    scatter(real(sym), imag(sym),'go','DisplayName', 'Original Constellation');
    hold on;
    scatter(real(y_small), imag(y_small),'ro','DisplayName', 'Constellation with Small Amplitudes'); 
    hold on;
    scatter(real(y_large), imag(y_large),'b*','DisplayName', 'Constellation with Large Amplitudes'); 
    title('Overlay: Constellation');
    xlabel('In-Phase'); ylabel('Quadrature');
    legend;
    grid on;
    box on;
    ax = gca;
    ax.LineWidth = 2;
    ax.XColor = 'k';
    ax.YColor = 'k';
end