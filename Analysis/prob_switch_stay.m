% p(staying|Reward)


for i = 1:2100
    n_staying_g_reward = 0;
    t_num_trials = 0;
    for j = 2:240
        t_num_trials = t_num_trials + 1;
        if C1_list(i,j-1) == 1
            if I1_list(i,j-1) == 1
                if C1_list(i,j) == 1
                    n_staying_g_reward = n_staying_g_reward + 1;
                end
            end
        elseif C2_list(i,j-1) == 1  
            if I2_list(i,j-1) == 1
                if C2_list(i,j) == 1
                    n_staying_g_reward = n_staying_g_reward + 1;
                end
            end
        end    
    end 
    p_staying_g_reward(i) = n_staying_g_reward/t_num_trials;
end    
            


%%
% p(staying|NReward)


for i = 1:2100
    n_staying_g_Nreward = 0;
    t_num_trials = 0;
    for j = 2:240
        t_num_trials = t_num_trials + 1;
        if C1_list(i,j-1) == 1
            if I1_list(i,j-1) == 0
                if C1_list(i,j) == 1
                    n_staying_g_Nreward = n_staying_g_Nreward + 1;
                end
            end
        elseif C2_list(i,j-1) == 1  
            if I2_list(i,j-1) == 0
                if C2_list(i,j) == 1
                    n_staying_g_Nreward = n_staying_g_Nreward + 1;
                end
            end
        end    
    end  
    p_staying_g_Nreward(i) = n_staying_g_Nreward/t_num_trials;
end    
            

%%

% p(switching|NoReward)

for i = 1:2100
    n_switching_g_Nreward = 0;
    t_num_trials = 0;
    for j = 2:240
        t_num_trials = t_num_trials + 1;
        if C1_list(i,j-1) == 1
            if I1_list(i,j-1) == 0
                if C2_list(i,j) == 1
                    n_switching_g_Nreward = n_switching_g_Nreward + 1;
                end
            end
        elseif C2_list(i,j-1) == 1  
            if I2_list(i,j-1) == 0
                if C1_list(i,j) == 1
                    n_switching_g_Nreward = n_switching_g_Nreward + 1;
                end
            end
        end    
    end       
    p_switching_g_Nreward(i) = n_switching_g_Nreward/t_num_trials;
end



%%

% p(switching|Reward)

for i = 1:2100
    n_switching_g_reward = 0;
    t_num_trials = 0;
    for j = 2:240
        t_num_trials = t_num_trials + 1;
        if C1_list(i,j-1) == 1
            if I1_list(i,j-1) == 1
                if C2_list(i,j) == 1
                    n_switching_g_reward = n_switching_g_reward + 1;
                end
            end
        elseif C2_list(i,j-1) == 1  
            if I2_list(i,j-1) == 1
                if C1_list(i,j) == 1
                    n_switching_g_reward = n_switching_g_reward + 1;
                end
            end
        end    
    end
    
    p_switching_g_reward(i) = n_switching_g_reward/t_num_trials;

end

%% SAVING

