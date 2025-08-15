function decoded_msg = viterbi213_radix_2(conv_msg)
    D = 16;  
    decoded_msg = [];            
    survivors = cell(4,1);       
    new_survivors = cell(4,1);   
    path_metrics = [0;3;3;3];    
    for step = 1:length(conv_msg)/2
        idx = 2*step - 1;
        received_bits = conv_msg(idx:idx+1);
        new_metrics = [3;3;3;3];
        new_survivors = cell(4,1);
    
        %********* BMU *********
        hamming_dist_0 = sum(received_bits ~= [0,0]);
        hamming_dist_1 = sum(received_bits ~= [1,1]);
        hamming_dist_2 = sum(received_bits ~= [1,1]);
        hamming_dist_3 = sum(received_bits ~= [0,0]);
        hamming_dist_4 = sum(received_bits ~= [0,1]);
        hamming_dist_5 = sum(received_bits ~= [1,0]);
        hamming_dist_6 = sum(received_bits ~= [1,0]);
        hamming_dist_7 = sum(received_bits ~= [0,1]);

        %********* ACS *********
        metric_0 = path_metrics(1) + hamming_dist_0;
        metric_1 = path_metrics(1) + hamming_dist_1;
        metric_2 = path_metrics(2) + hamming_dist_2;
        metric_3 = path_metrics(2) + hamming_dist_3;
        metric_4 = path_metrics(3) + hamming_dist_4;
        metric_5 = path_metrics(3) + hamming_dist_5;
        metric_6 = path_metrics(4) + hamming_dist_6;
        metric_7 = path_metrics(4) + hamming_dist_7;
        
        % ========= ACS – 硬體式 4 個蝶形逐一寫死 =========
        
        %── next_state 0 :  (state0,in0) vs (state1,in0)
        if metric_0 <= metric_2
            cand0 = metric_0;  
            surv0 = 0;          % 來自 state0
            prev0 = 0;
        else
            cand0 = metric_2;  
            surv0 = 0;          % 來自 state1
            prev0 = 1;
        end
        %── next_state 1 :  (state2,in0) vs (state3,in0)
        if metric_4 <= metric_6
            cand1 = metric_4;  
            surv1 = 0;  
            prev1 = 2;
        else
            cand1 = metric_6;  
            surv1 = 0;  
            prev1 = 3;
        end
        %── next_state 2 :  (state0,in1) vs (state1,in1)
        if metric_1 <= metric_3
            cand2 = metric_1;  
            surv2 = 1;  
            prev2 = 0;
        else
            cand2 = metric_3;  
            surv2 = 1;  
            prev2 = 1;
        end
        %── next_state 3 :  (state2,in1) vs (state3,in1)
        if metric_5 <= metric_7
            cand3 = metric_5;  
            surv3 = 1;  
            prev3 = 2;
        else
            cand3 = metric_7;  
            surv3 = 1;  
            prev3 = 3;
        end
    
        
    
        new_metrics(1)   = cand0;
        new_survivors{1} = [survivors{prev0+1}, 0];
        new_metrics(2)   = cand1;
        new_survivors{2} = [survivors{prev1+1}, 0];
        new_metrics(3)   = cand2;
        new_survivors{3} = [survivors{prev2+1}, 1];
        new_metrics(4)   = cand3;
        new_survivors{4} = [survivors{prev3+1}, 1];

        path_metrics = new_metrics;
        survivors = new_survivors;
    
        row_lengths = cellfun(@length, survivors);
        if any(row_lengths >= D)
            [~, best_state] = min(path_metrics);
            best_path = survivors{best_state};
            decoded_msg = [decoded_msg, best_path];
            survivors = cell(4,1);
            % path_metrics = [0;3;3;3];
        end
    end
    
    [~, final_state] = min(path_metrics);
    remaining_bits = survivors{final_state};
    decoded_msg = [decoded_msg, remaining_bits];

end