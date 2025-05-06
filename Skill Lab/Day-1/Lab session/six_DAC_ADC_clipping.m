function [signal_quantized]  = DAC_ADC_clipping(signal, MAX_PAPR, Nbits, Vpp)
% =========================================================================
% Book title: RF analog impairments modeling for communication systems
% simulation, Application to OFDM-based transceivers
% Author: Lydi SMAINI
% Editor: John Wiley & Sons
% Date: 2012
% =========================================================================
%
% DAC and ADC rectangular clipping and quantization modeling
%
% INPUT PARAMATERS
% signal            : Input complex I&Q signal
% MAX_PAPR          : Difference in dB (ratio in linear) beween the clipping level and the signal RMS
% Nbits             : DAC or ADC resolution (ENOB)
% Vpp               : DAC output or ADC input full range
%
% OUTPUT SIGNAL
% signal_quantized  : Complex I&Q signal quantized and clipped

Clipp_level = Vpp/2;
q = Vpp/(2^Nbits - 1);
P_I = 10*log10(var(real(signal)));
P_Q = 10*log10(var(imag(signal)));

% rectangular clipping and quantization
sI = 10^((20*log10(Clipp_level)- MAX_PAPR - P_I)/20) .*  real(signal);
sQ = 10^((20*log10(Clipp_level)- MAX_PAPR - P_Q)/20) .*  imag(signal);

sI_clipp = min(max(sI, -Clipp_level), Clipp_level);
sQ_clipp = min(max(sQ, -Clipp_level), Clipp_level);

signal_quantized = q*(round(sI_clipp/q) + 1i*round(sQ_clipp/q));