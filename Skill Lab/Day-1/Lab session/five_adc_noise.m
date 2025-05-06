clear variables;
clc;
fo=100; %100Hz signal
Fs=4*fo;
Aclip=1;  
nb=5;  %ENOB of quantizer
delta_q=2*Aclip/(2^nb-1);
t=0:1/(Fs):2;
x=sin(2*pi*fo*t);
figure(1);
plot(x);
axis([0 100 -1 1]);

%Quantization process
for n=1:length(x)
    if (x(n) <= -Aclip+delta_q/2)
        xq(n)=-Aclip;
    elseif ((x(n) > -Aclip+ delta_q/2) && x(n) <= Aclip-delta_q/2 )
        xq(n)=round(x(n)/delta_q +0.5)*delta_q -delta_q/2;
    else
        xq(n)=Aclip;
    end
end

nfft=length(x);
f=Fs*(-nfft/2:nfft/2-1)/nfft;
figure(2);
plot(f,20*log10(abs(fftshift(fft(x,nfft)))/nfft));
grid on; hold on; 
plot(f,20*log10(abs(fftshift(fft(xq,nfft)))/nfft));
xlabel('frequency'); ylabel('PSD (dB)');
axis([-300 300 -100 1]);

% Compute SQNR through EVM
nr = (1/length(x))* norm(x-xq)^2;
dr = (1/length(x))* norm(x)^2;
evm = sqrt(nr/dr);
sqnr_evm = 10 * log10(1/(evm)^2)

% SQNR theroretic
sqnr_theoretic = 6.02*nb + 1.76


%PSD1=fftshift(PSD);
