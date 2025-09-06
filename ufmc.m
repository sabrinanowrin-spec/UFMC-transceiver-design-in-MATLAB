%% UFMC Perfect Transceiver (TX -> Channel -> RX)
%  - Subband FIR filtering (TX/RX matched)
%  - AWGN channel (toggle multipath)
%  - Perfect timing/CFO, 1-tap EQ per subcarrier
%  - BER reported vs. original bits
clear; clc;
rng(211);                                    % reproducibility

%% ---------------- Parameters ----------------
N           = 64;                             % IFFT size
numSubbands = 4;                              % number of subbands
subbandSize = N/numSubbands;                  % subcarriers per subband
modOrder    = 16;                             % QAM order
LenFilter   = 16;                             % subband FIR length (prototype)
numBlocks   = 40;                             % number of UFMC blocks per subband
SNRdB       = 30;                             % AWGN SNR in dB

useMultipath = false;                         % set true to add a tiny multipath

% Sanity
assert(mod(N, numSubbands)==0, 'N must be divisible by numSubbands.');
bitsPerSym   = log2(modOrder);
numSymbols   = numBlocks * subbandSize;       % symbols per subband

%% ---------------- TX: Bit gen & QAM mapping ----------------
dataBits = randi([0 1], numSubbands, numSymbols * bitsPerSym);   % [bands x bits]

subbandSyms = zeros(numSubbands, numSymbols);
for b = 1:numSubbands
    subbandSyms(b,:) = qammod(dataBits(b,:).', modOrder, ...
        'InputType','bit','UnitAveragePower',true).';
end

%% ---------------- TX: Map to IFFT bins blockwise ----------------
% Arrange per-subband symbols into blocks of subbandSize (S/P)
S2P = zeros(numSubbands, subbandSize, numBlocks);
for b = 1:numSubbands
    S2P(b,:,:) = reshape(subbandSyms(b,:), subbandSize, []);
end

% Build N-size frequency bins per block, then IFFT to time domain
txTimeSub = zeros(numSubbands, N, numBlocks);
for blk = 1:numBlocks
    X = zeros(N,1);
    for sb = 1:numSubbands
        k0 = (sb-1)*subbandSize + 1;
        k1 = sb*subbandSize;
        X(k0:k1) = S2P(sb,:,blk).';           % place subband into its bin group
    end
    x = ifft(X, N);                            % composite IFFT (equivalent to OFDM block)
    % Split out each subband's time signal as if individually IFFT-padded
    % (for UFMC, we filter each subband’s time signal; here we approximate by
    % taking the per-subband IFFT via the same mapping)
    for sb = 1:numSubbands
        Xsb = zeros(N,1);
        k0 = (sb-1)*subbandSize + 1; k1 = sb*subbandSize;
        Xsb(k0:k1) = S2P(sb,:,blk).';
        txTimeSub(sb,:,blk) = ifft(Xsb, N).';
    end
end

%% ---------------- TX: Subband FIR filtering & sum ----------------
% Simple prototype (lowpass) — UFMC uses per-subband FIRs (frequency-shifted).
% We use same prototype for all subbands for clarity; matched at RX.
h = fir1(LenFilter-1, 1/numSubbands);         % linear-phase prototype

% Filter each subband stream across concatenated blocks (keeps transients local)
txSubSerial = zeros(numSubbands, N*numBlocks);
for sb = 1:numSubbands
    tmp = reshape(txTimeSub(sb,:,:), 1, []);  % serialize blocks
    txSubSerial(sb,:) = conv(tmp, h, 'same'); % subband UFMC filtering
end

ufmcTx = sum(txSubSerial, 1);                  % composite UFMC TX signal

%% ---------------- Channel ----------------
if useMultipath
    hChan = [1, 0.35, 0.2];                   % small multipath
else
    hChan = 1;
end
rxChan = conv(ufmcTx, hChan, 'same');

% AWGN
sigPow   = bandpower(rxChan);
noisePow = sigPow / (10^(SNRdB/10));
w        = sqrt(noisePow/2) * (randn(size(rxChan)) + 1j*randn(size(rxChan)));
rxSig    = rxChan + w;

%% ---------------- RX: Matched subband filtering ----------------
% RX uses the same prototype FIR (perfectly known) as a simple matched filter
rxSubSerial = zeros(numSubbands, length(rxSig));
for sb = 1:numSubbands
    rxSubSerial(sb,:) = conv(rxSig, h, 'same');   % same for each subband
end

% NOTE: In a textbook UFMC, per-subband filters are frequency-localized.
% Here, using the same prototype at RX acts as smoothing/matched filtering.

%% ---------------- RX: Slice into N-sample blocks ----------------
% Perfect timing: slice exactly each N samples (ignore tiny ISI due to FIR)
rxBlocks = reshape(rxSig(1:N*numBlocks), N, numBlocks);

%% ---------------- RX: FFT, subband extraction, equalization ----------------
% Channel frequency response (for 1-tap EQ)
Hk = fft([hChan zeros(1, N-numel(hChan))].', N);   % [N x 1]

rxEstSyms = zeros(numSubbands, numSymbols);

for blk = 1:numBlocks
    Y = fft(rxBlocks(:,blk), N);                   % composite spectrum (all subbands)
    for sb = 1:numSubbands
        k0 = (sb-1)*subbandSize + 1;
        k1 = sb*subbandSize;
        Ysb = Y(k0:k1);
        Hsb = Hk(k0:k1);

        % 1-tap per-subcarrier equalizer (ZF)
        Xhat = Ysb ./ Hsb;

        idx0 = (blk-1)*subbandSize + 1;
        idx1 = blk*subbandSize;
        rxEstSyms(sb, idx0:idx1) = Xhat.';
    end
end

%% ---------------- RX: QAM demod & BER ----------------
rxBits = zeros(size(dataBits));
for sb = 1:numSubbands
    rxBits(sb,:) = qamdemod(rxEstSyms(sb,:).', modOrder, ...
        'OutputType','bit','UnitAveragePower',true).';
end

[numErr, BER] = biterr(dataBits(:), rxBits(:));

%% ---------------- Plots (quick sanity) ----------------
figure;
subplot(3,1,1);
plot(real(ufmcTx)); title('UFMC TX signal (time)'); xlabel('Sample'); ylabel('Re\{x[n]\}');

subplot(3,1,2);
plot(abs(fftshift(fft(ufmcTx)))); title('UFMC TX spectrum (|FFT|)'); xlabel('Freq bin'); ylabel('Magnitude');

subplot(3,1,3);
stem(0:length(h)-1, h, 'filled'); title('Prototype subband FIR (TX/RX matched)'); xlabel('n'); ylabel('h[n]');

figure;
plot(rxEstSyms(1,1:min(400,numSymbols)), '.'); grid on; axis equal;
title(sprintf('Constellation (Subband 1) | SNR=%d dB | BER=%.3g | Err=%d', SNRdB, BER, numErr));

fprintf('\nUFMC Perfect Transceiver Results\n');
fprintf('  N=%d, Subbands=%d, SubbandSize=%d, Mod=%d-QAM, FilterLen=%d\n', ...
    N, numSubbands, subbandSize, modOrder, LenFilter);
fprintf('  Channel: %s, SNR(dB)=%.1f\n', string(useMultipath), SNRdB);
fprintf('  Bit errors: %d  |  BER=%.4g\n\n', numErr, BER);
