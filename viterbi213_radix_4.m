function decoded_msg = viterbi213_radix_4(conv_msg,D)

decoded_msg = [];   
Ngroup = length(conv_msg)/4;         % 32/4 = 8 組

% 初始化 Path‐Metric 與 Survivor 容器
path_metrics = [0; 5; 5; 5];
survivors = cell(4,1); 
new_metrics = zeros(4,1);

for g = 1:Ngroup
    idx       = 4*(g-1) + 1;
    four_bits = conv_msg(idx:idx+3);
    rx0       = four_bits(1:2);
    rx1       = four_bits(3:4);

    % ---- BMU: 取得 16 條 Hamming 距離 ----
    [hm_0,hm_1,hm_2,hm_3,hm_4,hm_5,hm_6,hm_7,hm_8,hm_9,hm_10,hm_11,hm_12,hm_13,hm_14,hm_15] = BMU(rx0,rx1);

    %********* ACS: 用 hm_* 更新 metric_0~metric_15 *********
        %********* ACS：展開 16 條 metric, 然後 4-to-1 選擇 *********
    m0  = path_metrics(1) + hm_0;
    m1  = path_metrics(1) + hm_1;
    m2  = path_metrics(1) + hm_2;
    m3  = path_metrics(1) + hm_3;
    m4  = path_metrics(2) + hm_4;
    m5  = path_metrics(2) + hm_5;
    m6  = path_metrics(2) + hm_6;
    m7  = path_metrics(2) + hm_7;
    m8  = path_metrics(3) + hm_8;
    m9  = path_metrics(3) + hm_9;
    m10 = path_metrics(3) + hm_10;
    m11 = path_metrics(3) + hm_11;
    m12 = path_metrics(4) + hm_12;
    m13 = path_metrics(4) + hm_13;
    m14 = path_metrics(4) + hm_14;
    m15 = path_metrics(4) + hm_15;

    %— Compare & Select (4-to-1 MUX) —
    [cand0, prev0] = bACS(m0,  m4,  m8,  m12);   % next-state 0
    [cand1, prev1] = bACS(m2,  m6,  m10, m14);   % next-state 1
    [cand2, prev2] = bACS(m1,  m5,  m9,  m13);   % next-state 2
    [cand3, prev3] = bACS(m3,  m7,  m11, m15);   % next-state 3
    
    new_metrics(1) = cand0;
    new_metrics(2) = cand1;    % ← 這裡用 cand1
    new_metrics(3) = cand2;    % ← 這裡用 cand2
    new_metrics(4) = cand3;


    new_survivors{1} = [ survivors{prev0},  0, 0 ];  % [ ... , bit1, bit2 ]
    new_survivors{2} = [ survivors{prev1},  1, 0 ];
    new_survivors{3} = [ survivors{prev2},  0, 1 ];
    new_survivors{4} = [ survivors{prev3},  1, 1 ];
    path_metrics = new_metrics;
    survivors = new_survivors;

    row_lengths = cellfun(@length, survivors);
    if any(row_lengths >= D)
        [~, best_state] = min(path_metrics);
        best_path = survivors{best_state}; 
        decoded_msg = [decoded_msg, best_path]; % 拼接
        survivors = cell(4,1);
        % path_metrics = [0; 5; 5; 5];
    end
end

% 最後把剩下的 survivors 裡最佳的那條也加上去
[~, best_state] = min(path_metrics);
decoded_msg  = [decoded_msg, survivors{best_state}];