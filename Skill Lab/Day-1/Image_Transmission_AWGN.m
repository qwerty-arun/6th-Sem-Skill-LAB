%This Code transmits an jpeg/png image through an AWGN Channel
%Change the SNR_dB to check the corruption of the image for a given SNR
%Change the SNR_dB for a given constellation to see the trend of image
%corruption using higher order constellation
%--------------------------------------------------------------------------------

clc;
clear all;

%% Parameters
M = 64;  % 64-QAM
k = log2(M);  % Bits per symbol
SNR_dB = 35;  % Target SNR
img = imread('Mark Rodwell Poster.jpeg');

% If indexed PNG
if ndims(img) == 2
    img = repmat(img, 1, 1, 3);  % Convert to fake RGB for uniformity
end

img_size = size(img);  % Preserve for reshaping

%% Convert image to 1D bitstream
img_vec = img(:);  % uint8 values
bitstream = de2bi(img_vec, 8, 'left-msb');  % Each pixel to 8 bits
bitstream = bitstream'; bitstream = bitstream(:);  % Column vector

%% Pad bitstream if not multiple of k
num_bits = length(bitstream);
pad_len = mod(k - mod(num_bits, k), k);
bitstream_padded = [bitstream; zeros(pad_len, 1)];

%% 64-QAM Modulation
sym_indices = bi2de(reshape(bitstream_padded, k, []).', 'left-msb');
tx_symbols = qammod(sym_indices, M, 'gray', 'UnitAveragePower', true);

%% Add AWGN Noise
rx_symbols = awgn(tx_symbols, SNR_dB, 'measured');

%% Demodulation
rx_indices = qamdemod(rx_symbols, M, 'gray', 'UnitAveragePower', true);
rx_bits = de2bi(rx_indices, k, 'left-msb');
rx_bits = rx_bits.'; rx_bits = rx_bits(:);

% Remove padding
rx_bits = rx_bits(1:num_bits);

%% Convert bitstream back to image
rx_bytes = reshape(rx_bits, 8, []).';
rx_img_vec = uint8(bi2de(rx_bytes, 'left-msb'));

% Reshape to original image size
rx_img = reshape(rx_img_vec, img_size);

%% Display
figure;
subplot(1,2,1);
imshow(img);
title('Original Image');

subplot(1,2,2);
imshow(rx_img);
title(sprintf('Received Image (SNR = %d dB)', SNR_dB));

% Plot Constellation
figure;
subplot(1,2,1);
scatter(real(tx_symbols), imag(tx_symbols), 'bo'); grid on;
title('Transmitted Constellation'); xlabel('In-Phase'); ylabel('Quadrature');

subplot(1,2,2);
scatter(real(rx_symbols), imag(rx_symbols), 'rx'); grid on;
title(['Received Constellation (SNR = ', num2str(SNR_dB), ' dB)']);
xlabel('In-Phase'); ylabel('Quadrature');
grid on;
box on;
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';

