function [signal_pn, pn] = LO_phasenoise(signal, Fs, B_PLL, In_band_noise, Noise_floor, Flicker_corner)
% =========================================================================
% Book title: RF analog impairments modeling for communication systems
% simulation, Application to OFDM-based transceivers
% Author: Lydi SMAINI
% Editor: John Wiley & Sons
% Date: 2012
% =========================================================================
%
% PLL phase noise model
%
% INPUT PARAMATERS
% signal            : Input complex I&Q signal
% Fs                : Sampling frequency of the input signal (Hz)
% B_PLL             : PLL bandwidth (Hz)
% In_band_noise     : Noise level in PLL bandwidth (dBc/Hz)
% Noise_floor       : Noise floor level (dBc/Hz)
% Flicker_corner    : Flicker noise corner frequency (Hz)

% OUTPUT SIGNAL
% signal_pn         : Complex I&Q signal affected by phase noise

Ns = length(signal);
if ((Ns/2) ~= round(Ns/2))
        error('Signal length must be an integer multiple of 2')
end
N = floor(Ns/2);
df = (Fs/2)/N;
f = 0:df:(N-1)*df;

a = (Flicker_corner) * 10^(In_band_noise/10);   % Flicker noise coefficient
Flicker = a./f;                                 % Flicker noise (1/f)
Flicker(1) = 0;            
L = ((10^(In_band_noise/10)*B_PLL^2)./(f.^2+B_PLL^2))+10^(Noise_floor/10); % PLL phase noise shape (DSB) without Flicker

FiltrePLL = (B_PLL^2)./(f.^2+B_PLL^2);          % 2nd order PLL filtering effect 
L = (Flicker .* FiltrePLL ) + L;                % PLL phase noise shape with Flicker noise effect, dBc/Hz

% Transformation of the DSB phase noise to SSB in order to make an IFFT
mag = sqrt(L*df/2);
phi = pi*(2*rand(1,N)-1);
PN = mag.*exp(1i*phi);
PN(1) = 0;

Ns = 2*N;
PN_f = zeros(1, Ns);
PN_f(1:N) = PN(1:N);
PN_f(N+1:Ns) = fliplr(conj(PN(1:N)));

pn = Ns.*real(ifft(PN_f, 'symmetric'));   % Phase noise in temporal domain (in radians)

% LOCAL OSCILLATOR with phase noise (or jitter)
LO = exp(1i.*pn);
if (size(signal) ~= size(LO))
    LO = LO.';
end

% Output signal: Input signal multiplied by OL
signal_pn = signal(1:Ns) .* LO;
