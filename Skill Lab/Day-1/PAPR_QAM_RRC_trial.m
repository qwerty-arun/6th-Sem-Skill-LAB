% Parameters
M_list    = [4, 16, 64, 256, 1024];   % QAM orders
numSym    = 1e5;                      % Symbols per trial
numTrials = 50;                       % Trials for averaging
rolloff   = 0.35;                     % RRC roll-off factor
span      = 6;                        % Filter span (symbols)
sps       = 8;                        % Samples per symbol (oversampling)
fs        = 1e6;                      % Baseband sampling rate (Hz)
fc        = 1000e6;                    % Carrier frequency (Hz)

% Design RRC filter
rrcFilter = rcosdesign(rolloff, span, sps, 'sqrt');

% Preallocate
PAPR_dB = zeros(length(M_list),1);

for idx = 1:length(M_list)
    M = M_list(idx);
    papr_vals = zeros(numTrials,1);

    for t = 1:numTrials
        % 1) Data generation & modulation
        data  = randi([0 M-1], numSym, 1);
        x_bb  = qammod(data, M, 'UnitAveragePower', true);

        % 2) Pulse-shaping
        x_os  = upfirdn(x_bb, rrcFilter, sps, 1);          % Oversampled baseband

        % 3) Time vector for passband
        T_sym = 1/fs;                                      % Symbol period at baseband rate
        t_vec = (0:length(x_os)-1)*T_sym;                  % Time axis

        % 4) Upconvert to real RF
        s_rf  = real(x_os .* exp(1j*2*pi*fc*t_vec.'));

        % 5) Instantaneous power
        p_inst = s_rf.^2;

        % 6) PAPR (linear then dB)
        papr_lin    = max(p_inst) / mean(p_inst);          
        papr_vals(t)= 10*log10(papr_lin);                  
    end

    % 7) Average over trials
    PAPR_dB(idx) = mean(papr_vals);
end

% Display
T = table(M_list.', PAPR_dB, 'VariableNames', {'QAM_Order','PAPR_dB'});
disp('True RF PAPR after RRC pulse‑shaping:');
disp(T);