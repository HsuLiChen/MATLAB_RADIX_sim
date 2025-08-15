function codeword = conv_hardware_213_rest(msg_source)
    s1 = 0; s2 = 0;
    N  = length(msg_source);
    codeword = zeros(1, 2*N);
    cnt = 0;
    for i = 1:N
        if(cnt == 16)
            s1 = 0; s2 = 0;
            cnt = 0;
        end
        u0 = xor(msg_source(i), s2);
        u1 = xor(xor(msg_source(i), s1), s2);
        s2 = s1;
        s1 = msg_source(i);
        codeword(2*i-1) = u0;
        codeword(2*i)   = u1;
        cnt = cnt +1;
    end
end