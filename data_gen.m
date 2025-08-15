% gen_10e7_bits_asv.m
clear; clc;

outFile    = 'bits_56g.asv';
targetBits = 56 * 1000000000;        % 總共要寫入的 bits 數
chunkBits  = 1e6;        % 每次產生並寫入 1e6 bits

fid = fopen(outFile, 'w');
if fid < 0
    error('無法開啟檔案 %s 以寫入。', outFile);
end

written = 0;
fprintf('開始產生 %d bits 的隨機 0/1 資料…\n', targetBits);
while written < targetBits
    thisBits = min(chunkBits, targetBits - written);
    % 產生 thisBits 個隨機 0/1，轉成 char
    bits = char(randi([0 1], 1, thisBits) + '0');
    fwrite(fid, bits, 'char');
    written = written + thisBits;
    fprintf('\r已寫入 %d / %d bits', written, targetBits);
end
fprintf('\n完成！檔案存成：%s\n', outFile);

fclose(fid);
