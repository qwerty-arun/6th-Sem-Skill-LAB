% This Code Computes the PAPR plot for M-QAM with and without RRC Filter
% and overlaps both the plots on the same graph. Also, it uses a
% theoretical formula for 4^M-QAM PAPR and overlapps it on the same plot to
% check the suitability of the theoretical formula with practical
% simulation from the MATLAB.

%-------------------------------------------------------------------------
clc; clear;

% QAM orders
M_list = [4, 16, 64, 256,1024];
k_list = log2(M_list);  % bits/symbol
k_list2= M_list.^(1/4); %Because the theoretical PAPR formula is valid for 4^M type constellations


%Theoretical PAPR Formula

PAPR_Theor_linear= 3* ((2.^k_list2-1)./ (2.^k_list2+1)); %Referenced from Oveisi and Heydari's Paper
PAPR_Theor_dB= 10*log10(PAPR_Theor_linear);


% Preallocate
PAPR_linear = zeros(size(M_list));
PAPR_dB = zeros(size(M_list));

for idx = 1:length(M_list)
    M = M_list(idx);

    % Generate constellation (no normalization!)
    symbols = qammod(0:M-1, M);

    % Instantaneous power
    power_vals = abs(symbols).^2;

    % Compute actual mean power and PAPR
    avg_power = mean(power_vals);
    max_power = max(power_vals);
    papr_lin = max_power / avg_power;
    papr_db = 10 * log10(papr_lin);

    PAPR_linear(idx) = papr_lin;
    PAPR_dB(idx) = papr_db;
end

PAPR_RRC_dB=[3.7367, 6.2861, 7.3902, 7.7895, 7.9356]; %This is generated from PAPR_QAM_RRC_trial.m MATLAB Code
% Smooth interpolation
k_fine = linspace(min(k_list), max(k_list), 300);
PAPR_dB_smooth = interp1(k_list, PAPR_dB, k_fine, 'spline');
PAPR_RRC_dB_smooth = interp1(k_list, PAPR_RRC_dB, k_fine, 'spline');
PAPR_Theor_dB_smooth= interp1(k_list, PAPR_Theor_dB, k_fine, 'spline');

% Plot
figure;
plot(k_fine, PAPR_dB_smooth, 'b-', 'LineWidth', 2); hold on;
plot(k_list, PAPR_dB, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r'); hold on;
plot(k_fine, PAPR_RRC_dB_smooth, 'k-', 'LineWidth', 2); hold on;
plot(k_list, PAPR_RRC_dB, 'mo', 'MarkerSize', 6, 'MarkerFaceColor', 'm'); hold on;
plot(k_fine, PAPR_Theor_dB_smooth, 'g-', 'LineWidth', 2); hold on;
plot(k_list, PAPR_Theor_dB, 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');


xlabel('Bits per Symbol (log_2 M)');
ylabel('PAPR (dB)');
title('Monotonic PAPR vs Modulation Order (Constellation-Based)');
grid on;
legend('Spline Fit', 'Actual PAPR','Spline Fit RRC', 'Actual PAPR RRC','Spline Fit Theor', 'Actual PAPR Theor' ,'Location', 'NorthWest');

% Add thick black border
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';