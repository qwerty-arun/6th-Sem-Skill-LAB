clear variables;
clc;

alpha=0.19;  % Transmit gain imbalance
theta_deg=12; % Transmit phase imbalance
theta=theta_deg*pi/180; % Conversion to radians


alpha_rx=cos(theta/2) + 1i*alpha/2*sin(theta/2);  
beta_rx=-alpha/2*cos(theta/2) - 1i*sin(theta/2);


M=16;  % QAM order
s=qammod(0:1:M-1, M); % QAM symbol generation
s_IQ=alpha_rx.*s + beta_rx.*conj(s);  % IQI affected constellation

f=500; % Pilot sinusoid frequency
omega=2*pi*f;
Fs=5*f;  % Sampling frequency
Ts=1/Fs;  % Sampling instants
A = (1-alpha/2); B=(1+alpha/2);  % A and B by definition

n=0:1:100;  % Number of samples

%%
I_hat = (A/2)*(cos(omega*n*Ts-theta/2)+sin(omega*n*Ts-theta/2));
Q_hat = (B/2)*(sin(omega*n*Ts+theta/2)-cos(omega*n*Ts+theta/2));
alpha_rx_hat = 2*sum((Q_hat.^2-I_hat.^2))/(length(Q_hat)); %estimated alpha value
J1 = alpha_rx_hat/2;
J2 = (1/16)*(1-alpha_rx_hat^2/4)*(1+0.5*(cos(4*omega*n*Ts)-cos(2*theta)));
J2_avg = sum(J2/length(J2));
theta_rx_hat = (1/2)*acosd(2-(32*J2_avg/(1-J1^2))); %estimated theta value

%z_dcfree = A^2/4*cos(2*omega*n*Ts) + A*B/4*(cos(2*omega*n*Ts - theta) - cos(2*omega*n*Ts + theta)) - B^2/4*cos(2*omega*n*Ts);
%S_theta = sum(sin(2*omega*n*Ts).*z)/(length(n));
%theta_hat = asin(4*S_theta/(1-alpha_hat^2/4));  % Estimate for theta
%theta_hat_deg=theta_hat*180/pi;

%%


fprintf('gain_imbalance_rx = %.4f\n', alpha);
fprintf('gain_imbalance_hat = %.4f\n', alpha_rx_hat);
fprintf(' phase_imbalance = = %.4f\n', theta_deg);
fprintf('phase_imbalance_hat = %.4f\n', theta_rx_hat);
theta_rx_hat_rad = theta_rx_hat*pi/180;
gain_rx_hat = alpha_rx_hat;
alpha_rx_hat=cos(theta_rx_hat_rad/2) + 1i*gain_rx_hat/2*sin(theta_rx_hat_rad/2);
beta_rx_hat=-gain_rx_hat/2*cos(theta_rx_hat_rad/2) - 1i*sin(theta_rx_hat_rad/2);
%Correction
%After estimating the two parameters we need to figure out what operation
%(matrix multiplication) to perform to be able to get the corrected output
%For each constellation symbol we will have its IQI affected output that
%has to be transformed to get back the corrected output
g=[];
g_array = [];
gamma = alpha_rx;
gamma1 = beta_rx;
for i=1:M  % For; each of the constellation symbols, obtain g
%s_iq = gamma * s(i) + gamma1 * conj(s(i));
J = [alpha_rx_hat*s(i) beta_rx_hat*s(i)'; beta_rx_hat'*s(i) alpha_rx_hat'*s(i)'];  
g_vec = J\[s(i); conj(s(i))]; %We know J*g_vec = s conj(s) g_vec is the operator that needs to be used
g=[g g_vec(1)];
g_array = [g_array g_vec];
end
r=log2(M);
Es = norm(s)^2/M;
bits = 0;
times = 0;
count = 0;
ber = zeros(1,length(0:2:20));
ber_without_iqi = zeros(1,length(0:2:20));

s_IQ=alpha_rx.*s + beta_rx.*conj(s);  % IQI affected constellation
%scatter(real(s_IQ), imag(s_IQ),'ko');
%grid on; hold on;
%scatter(real(s), imag(s), 'k*');
%xlabel('In-phase Amplitude'); ylabel('Quadrature Amplitude');


for snr=0:2:20  %Find ber vs snr relationship
    SNR=(10^(snr/10));% SNR linear
    No=Es/SNR;        % Noise variance
    count=count+1;    
    error=0;times=0;
    error_awgn = 0; error_without_compensation = 0;
    error_without_iqi = 0;
    numbits=0;
    if (snr <=12)
        max_bits=1e5;  %For how many bits we want to parse through to find error this 
                        % has to increase if SNR increases (if BER =1e-6 we need atleast 1e6 bits)
   % elseif(snr<=20)
   %     max_bits=1e6;
    else
    %    max_bits =1e8;
        max_bits = 1e6;
    
    end
    bits=0;
    while bits<= max_bits
        bits = bits + r;   %Each symbol has log(M) bits
        data=randi([0 1],1,r);
        x=s(bi2de(data)+1);   %Randomly choose a symbol  
        n=(randn+1i*randn)*sqrt(No/2);  %Complex Gaussian noise
        s_rx = repmat([alpha_rx*(x+n) beta_rx*(x+n)'],1,1);
        y = s_rx;
        y_without_iqi = x+n;
        s_hat = s_rx*g_array;
        z=s_hat- s; 
      
        [kk, idx] = min(abs(z));       % ML (maximum likelihood detection) 
        datarx= de2bi(idx-1,r);       
        error=error+sum(data~=datarx); %% number of bits in error
        times=times+1;
        %disp([snr])
    end
    ber(count)=error/times/r;  
end

%figure('DefaultAxesFontSize', 18);  %comment this code to get comparison wrt 2a and run 2a first then 2d
semilogy(0:2:20, ber,'-*g','DisplayName', 'With compensation','LineWidth',2);
xlabel('SNR in dB'); ylabel('BER');
%legend('ber after compensation','location','best');
grid on;
hold on;
set(findall(gcf,'-property','FontSize'),'FontSize',22)