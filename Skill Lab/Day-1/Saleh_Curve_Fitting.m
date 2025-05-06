clc;
clear all;

% Given simulation/measured data
Pin_sim = [-25,-22,-19,-16,-13,-10,-7,-4,-1,0,3];  % in dBm
AM_AM_sim = [-6,-3,0,3,6,7.5,10,12.1,12.2,12.2,12.2];  % in dBm
AM_PM_sim = (pi/180)*[0.8,0.8,1.2,1.8,3.2,5,10,14,20,21.59,25.85];  % in degrees

% Convert input power in dBm to amplitude (Volts)
Ain_sim = sqrt(2 * 50 * 10.^((Pin_sim - 30) / 10));  % Volts

% Convert AM-AM output from dBm to linear voltage
AM_AM_lin_sim = sqrt(2 * 50 * 10.^((AM_AM_sim - 30) / 10));  % Volts

%% Fit Saleh AM/AM model: G(A) = alpha1*A / (1 + beta1*A^2)
am_am_model = @(params, A) (params(1)*A) ./ (1 + params(2)*A.^2);
params0_am = [1, 0.01];  % Initial guess
[params_am, ~] = lsqcurvefit(am_am_model, params0_am, Ain_sim, AM_AM_lin_sim);

alpha1 = params_am(1);
beta1  = params_am(2);

%% Fit Saleh AM/PM model: phi(A) = alpha2*A^2 / (1 + beta2*A^2)
am_pm_model = @(params, A) (params(1)*A.^2) ./ (1 + params(2)*A.^2);
params0_pm = [1, 0.01];
[params_pm, ~] = lsqcurvefit(am_pm_model, params0_pm, Ain_sim, AM_PM_sim);

alpha2 = params_pm(1);
beta2  = params_pm(2);

%% Display fitted parameters
fprintf('Estimated Saleh Model Parameters:\n');
fprintf('AM/AM: alpha1 = %.4f, beta1 = %.4f\n', alpha1, beta1);
fprintf('AM/PM: alpha2 = %.4f, beta2 = %.4f\n', alpha2, beta2);

%% Plot fitted curves vs actual data
A_fine = linspace(min(Ain_sim), max(Ain_sim), 500);
P_fine= 10*log10(0.5*(A_fine.^2)/50)+30; %Reference to  50 Ohms
AM_AM_fit1 = am_am_model(params_am, A_fine);
AM_PM_fit = (180/pi)*am_pm_model(params_pm, A_fine);

AM_AM_fit=10*log10(0.5*(AM_AM_fit1.^2)/50)+30; %Reference to  50 Ohms

figure;
subplot(1,2,1);
plot(Pin_sim, AM_AM_sim, 'bo', 'DisplayName', 'Measured AM/AM');
hold on;
plot(P_fine, AM_AM_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Fitted AM/AM');
xlabel('Input Power (dBm)'); ylabel('Output Power (dBm)');
title('AM/AM Curve'); legend; grid on;
grid on;
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';

subplot(1,2,2);
plot(Pin_sim, AM_PM_sim*180/pi, 'bo', 'DisplayName', 'Measured AM/PM');
hold on;
plot(P_fine, AM_PM_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Fitted AM/PM');
xlabel('Input Power (dBm)'); ylabel('Phase Shift (deg)');
title('AM/PM Curve'); legend; grid on;
grid on;
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';