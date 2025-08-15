function [hm_0,hm_1,hm_2,hm_3,hm_4,hm_5,hm_6,hm_7,hm_8,hm_9,hm_10,hm_11,hm_12,hm_13,hm_14,hm_15] = BMU(rx0,rx1)
    % ---- BMU: 計算 16 條 Hamming 距離 ----
    vec = [rx0, rx1];
    
    hm_0  = sum(vec ~= [0,0,0,0]);  % i=0, w=00
    hm_1  = sum(vec ~= [0,0,1,1]);  % i=0, w=01
    hm_2  = sum(vec ~= [1,1,0,1]);  % i=0, w=10
    hm_3  = sum(vec ~= [1,1,1,0]);  % i=0, w=11

    hm_4  = sum(vec ~= [1,1,0,0]);  % i=1, w=00
    hm_5  = sum(vec ~= [1,1,1,1]);  % i=1, w=01
    hm_6  = sum(vec ~= [0,0,0,1]);  % i=1, w=10
    hm_7  = sum(vec ~= [0,0,1,0]);  % i=1, w=11

    hm_8  = sum(vec ~= [0,1,1,1]);  % i=2, w=00
    hm_9  = sum(vec ~= [0,1,0,0]);  % i=2, w=01
    hm_10 = sum(vec ~= [1,0,1,0]);  % i=2, w=10
    hm_11 = sum(vec ~= [1,0,0,1]);  % i=2, w=11

    hm_12 = sum(vec ~= [1,0,1,1]);  % i=3, w=00
    hm_13 = sum(vec ~= [1,0,0,0]);  % i=3, w=01
    hm_14 = sum(vec ~= [0,1,1,0]);  % i=3, w=10
    hm_15 = sum(vec ~= [0,1,0,1]);  % i=3, w=11
end
