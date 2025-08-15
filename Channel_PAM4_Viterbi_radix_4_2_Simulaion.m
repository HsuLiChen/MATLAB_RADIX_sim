%% BER 比較：MATLAB 內建 vs Radix-4 vs Radix-4 w/ reset vs Radix-2 vs Radix-2 w/ reset
close all; clear; clc;

%% 1. 參數設定
M           = 4;                              % 4-PAM
k           = log2(M);                        % bits/symbol
EsN0_dB     = -12:2:20;                       % Es/N0 (dB)
 % EsN0_dB     = 0:2:2;                       % Es/N0 (dB)

num_trials  = 1;                             % Monte-Carlo 次數
trellis     = poly2trellis(3,[5 7]);          % (2,1,3) convolutional
tb_depth    = 16;                             % traceback depth

%% 2. 產生資料 & 編碼
rawBits    = load('bits_56g.asv','-ascii').';   % 16000 bits
% rawBits    = rawBits(1:16000);
% inFile = 'bits_10e7.asv';
% fid    = fopen(inFile,'r');
% if fid<0
%     error('無法開啟 %s', inFile);
% end
% % 1) 用 fread 讀入所有字元
% A = fread(fid, inf, '*char')';  
% fclose(fid);
% 
% % 2) 把 '0'/'1' 轉成 0/1
% rawBits  = double(A) - double('0');   

fprintf('總共讀入 %d bits\n', numel(rawBits));
% (2,1,3) conv encode
convBits        = conv_hardware_213(rawBits);
convBits_rest   = conv_hardware_213_rest(rawBits);

% 4-PAM 調變
symIdxTx        = bi2de( reshape(convBits,      k, []).', 'left-msb' );
txSym           = pammod(symIdxTx, M, 0, 'gray');
symIdxTx_rest   = bi2de( reshape(convBits_rest, k, []).', 'left-msb' );
txSym_rest      = pammod(symIdxTx_rest, M, 0, 'gray');

%% 3. 初始化 BER 陣列
BER_builtin       = zeros(size(EsN0_dB));
BER_radix4        = zeros(size(EsN0_dB));
BER_radix4_reset  = zeros(size(EsN0_dB));
BER_radix2        = zeros(size(EsN0_dB));
BER_radix2_reset  = zeros(size(EsN0_dB));

%% 4. Monte-Carlo 主迴圈
blockBits       = 16;                % 每段 reset 的輸入 bits
codeBitsPerBlk  = blockBits * 2;     % 每段的輸出 bits
numBlocks       = length(rawBits)/blockBits;

for iSNR = 1:length(EsN0_dB)
    EbN0 = EsN0_dB(iSNR);
    
    acc_built     = 0;
    acc_4         = 0;
    acc_4_rst     = 0;
    acc_2         = 0;
    acc_2_rst     = 0;
    
    for tt = 1:num_trials
        % --- 加 AWGN ---
        rxSym      = awgn(txSym,      EbN0, 'measured');
        rxSym_rest = awgn(txSym_rest, EbN0, 'measured');
        
        % --- Demod → hard bits ---
        rxIdx       = pamdemod(rxSym,      M,0,'gray');
        recBits     = reshape( de2bi(rxIdx,      k,'left-msb').', 1, [] );
        rxIdx_rest  = pamdemod(rxSym_rest, M,0,'gray');
        recBits_rest= reshape( de2bi(rxIdx_rest, k,'left-msb').', 1, [] );
        
        % --- 1) MATLAB 內建 hard-decision Viterbi ---
        dec_built = vitdec(recBits, trellis, tb_depth, 'trunc', 'hard');
        
        % --- 2) 軟體 Radix-4 (no reset) ---
        dec_4     = viterbi213_radix_4(recBits,tb_depth);
        
        % --- 3) 軟體 Radix-2 (no reset) ---
        dec_2     = viterbi213_radix_2(recBits);
        
        % --- 4) 軟體 Radix-4 w/ reset 每 16 bit ---
        dec_4_rst = zeros(1,length(rawBits));
        for b = 1:numBlocks
            cstart = (b-1)*codeBitsPerBlk +1;
            cend   = b*codeBitsPerBlk;
            block  = recBits_rest(cstart:cend);
            dec_blk= viterbi213_radix_4(block,tb_depth);
            mstart = (b-1)*blockBits +1;
            mend   = b*blockBits;
            dec_4_rst(mstart:mend) = dec_blk;
        end
        
        % --- 5) 軟體 Radix-2 w/ reset 每 16 bit ---
        dec_2_rst = zeros(1,length(rawBits));
        for b = 1:numBlocks
            cstart = (b-1)*codeBitsPerBlk +1;
            cend   = b*codeBitsPerBlk;
            block  = recBits_rest(cstart:cend);
            dec_blk= viterbi213_radix_2(block);
            mstart = (b-1)*blockBits +1;
            mend   = b*blockBits;
            dec_2_rst(mstart:mend) = dec_blk;
        end
        
        % --- 累加 BER ---
        [~, b0]    = biterr(rawBits, dec_built);
        [~, b1]    = biterr(rawBits, dec_4);
        [~, b2]    = biterr(rawBits, dec_2);
        [~, b3]    = biterr(rawBits, dec_4_rst);
        [~, b4]    = biterr(rawBits, dec_2_rst);
        
        acc_built = acc_built + b0;
        acc_4     = acc_4     + b1;
        acc_2     = acc_2     + b2;
        acc_4_rst = acc_4_rst + b3;
        acc_2_rst = acc_2_rst + b4;
    end
    
    % 平均
    BER_builtin(iSNR)      = acc_built   / num_trials;
    BER_radix4(iSNR)       = acc_4       / num_trials;
    BER_radix2(iSNR)       = acc_2       / num_trials;
    BER_radix4_reset(iSNR) = acc_4_rst   / num_trials;
    BER_radix2_reset(iSNR) = acc_2_rst   / num_trials;
end

%% 5. 繪圖比較
figure; hold on; grid on;
semilogy(EsN0_dB, BER_builtin,       '-ok','LineWidth',1.5,'DisplayName','MATLAB vitdec');
semilogy(EsN0_dB, BER_radix4,        '-sr','LineWidth',1.5,'DisplayName','Radix-4');
semilogy(EsN0_dB, BER_radix4_reset,  '-^g','LineWidth',1.5,'DisplayName','Radix-4 reset');
semilogy(EsN0_dB, BER_radix2,        '-db','LineWidth',1.5,'DisplayName','Radix-2');
semilogy(EsN0_dB, BER_radix2_reset,  '-xm','LineWidth',1.5,'DisplayName','Radix-2 reset');

xlabel('E_s/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
legend('Location','southwest');
title('BER 比較：Built-in vs Radix-4 vs Radix-2 w/wo reset');
set(gca,'YScale','log');
