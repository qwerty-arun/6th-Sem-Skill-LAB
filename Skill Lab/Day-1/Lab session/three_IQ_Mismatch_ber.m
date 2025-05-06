%clear variables;
%close all;
%clc;

%%
M=16;  % QAM order
s=qammod(0:1:M-1, M); % QAM symbol generation
alpha = 0.15;
theta = 15;
theta_radian = theta*pi/180;
alpha_rx=cos(theta_radian/2) + 1i*(alpha/2)*sin(theta_radian/2);
beta_rx=-(alpha/2)*cos(theta_radian/2) - 1i*sin(theta_radian/2);
gamma = alpha_rx;
gamma1 = beta_rx;
Es = norm(s)^2/M;   %The noise gets added on the transmitted signal
r=log2(M);
max_bits = 1e5;
bits = 0;
times = 0;
count = 0;
ber = zeros(1,length(0:2:20));    %calculating ber for various values of snr with and without rx iqi
ber_without_iqi = zeros(1,length(0:2:20));
for snr=0:2:20
    SNR=(10^(snr/10));% SNR linear
    No=Es/SNR;        % Noise variance
    count=count+1;
    error=0;times=0;
    error_without_iqi = 0;
    numbits=0;
    if (snr <=12)  %as snr increase ber reduces so to observe a ber of 1e-6 you need to transmit atleast 1e6 bits
        max_bits=1e5;
   % elseif(snr<=20)
   %     max_bits=1e6;
    else
    %    max_bits =1e8;
        max_bits = 1e6;
    
    end
    while bits<= max_bits
        bits = bits + r;
        data=randi([0 1],1,r);
        x=s(bi2de(data)+1);   %You randomly choose a symbol
        n=(randn+1i*randn)*sqrt(No/2);  %add cyclical complex gaussian noise
        y = gamma*(x+n) + gamma1*(x'+n'); %Here the recieved signal contains x+n
        y_without_iqi = x+n;
        z=repmat(y,1,2^r) - s;  %just making the arrays compatible to perform mamimum likelihood detection 
        z_without_iqi = repmat(y_without_iqi,1,2^r) - s;
        [kk, idx] = min(abs(z));       % ML  
        [kk_iqi, idx_iqi] = min(abs(z_without_iqi));       % ML
        datarx= de2bi(idx-1,r);
        datarx_without_iqi= de2bi(idx_iqi-1,r);
        error=error+sum(data~=datarx); %% number of bits in error
        error_without_iqi = error_without_iqi + sum(data ~= datarx_without_iqi);
        times = times+1;
        %disp([snr]);
    end
    ber_1 = error/times/r;
    ber(count) = ber_1;
    ber_without_iqi(count) = error_without_iqi/times/r;
    bits = 0;
end
figure('DefaultAxesFontSize', 18);
semilogy(0:2:20, ber,0:2:20, ber_without_iqi,'-*b','LineWidth',2);
%legend('Interpreter', 'Latex' ,'Location', 'Best');
legend('ber with iqi', 'ber without iqi' ,'Location', 'Best');
xlabel('SNR in dB'); ylabel('BER');
grid on;
hold on;
set(findall(gcf,'-property','FontSize'),'FontSize',22);



