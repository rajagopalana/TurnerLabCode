function [inst_choice_ratio,inst_income_ratio,ave_choice_ratio,fig_count,ave_reward_ratio,gotofig] = inst_CR_mult_conts(fig_count,protocol_100_0,choice_order,reward_order,lookback,conts,pre_sum,baiting,reward,gotofig)
    
    
    inst_choice_ratio = [];
    
    % inst_CR is calculated as rolling window of current and past 5 trials
    
    for j = 1:length(choice_order)
        if j < lookback
            num_O_choices = length(find(choice_order(1:j) == 2));
            num_M_choices = length(find(choice_order(1:j) == 1));
            if num_O_choices ~= 0 && num_M_choices ~= 0
                inst_choice_ratio(j) = rad2deg(atan(num_O_choices/num_M_choices));
            elseif num_O_choices == 0
                inst_choice_ratio(j) = 0;
            elseif num_M_choices == 0 
                inst_choice_ratio(j) = 90;
            end    
        else
            num_O_choices = length(find(choice_order(j-(lookback-1):j) == 2));
            num_M_choices = length(find(choice_order(j-(lookback-1):j) == 1));
            if num_O_choices ~= 0 && num_M_choices ~= 0
                inst_choice_ratio(j) = rad2deg(atan(num_O_choices/num_M_choices));
            elseif num_O_choices == 0
                inst_choice_ratio(j) = 0;
            elseif num_M_choices == 0 
                inst_choice_ratio(j) = 90;
            end   
        end
    end 
    
    num_O_choices = length(find(choice_order(1 : end) == 2));
    num_M_choices = length(find(choice_order(1 : end) == 1));
    ave_choice_ratio = rad2deg(atan(num_O_choices/num_M_choices));
    

    num_O_rewarded = 0;
    num_M_rewarded = 0;
    % HACKY CODE TO CALCULATE AVE_REWARD_SLOPE BECAUSE reward was
    % incorrectly saved when acquiring data
    if conts > 1
        a_O = sum(reward(1,:));
        b_O = sum(baiting(1,:));
        c_O = 0;
        for i = 1:length(baiting)-1
            if baiting(1,i:i+1) == [0,1]
            c_O = c_O + 1;
            end
        end
        num_O_rewarded = a_O -b_O + c_O
        a_M = sum(reward(2,:));
        b_M = sum(baiting(2,:));
        c_M = 0;
        for i = 1:length(baiting)-1
            if baiting(2,i:i+1) == [0,1]
            c_M = c_M + 1;
            end
        end
        num_M_rewarded = a_M -b_M + c_M
        
           
            

    end
    
    ave_reward_ratio = rad2deg(atan(num_O_rewarded/num_M_rewarded));
    if conts == 1
        ave_reward_ratio = 45;
    end    
    
    inst_income_ratio = [];
    if protocol_100_0 ~= 1 
        
        for j = 1:length(reward_order)
            if conts == 1
                inst_income_ratio(j) = 45;
                continue   
            elseif j>0 && j< lookback    
                num_O_rewards = length(find(reward_order(1:j) == 2));
                num_M_rewards = length(find(reward_order(1:j) == 1));
                if num_O_rewards ~= 0 && num_M_rewards ~= 0
                    inst_income_ratio(j) = (((0 + lookback-j)*rad2deg(atan(num_O_rewards/num_M_rewards)))+((j)*45))/lookback;
                elseif num_O_rewards == 0
                    inst_income_ratio(j) = (((0 + lookback-j)*0)+((j)*45))/lookback;
                elseif num_M_rewards == 0 
                    inst_income_ratio(j) = (((0 + lookback-j)*90)+((j)*45))/lookback;
                end    
            else
                num_O_rewards = length(find(reward_order(j-(lookback-1):j) == 2));
                num_M_rewards = length(find(reward_order(j-(lookback-1):j) == 1));
                if num_O_rewards ~= 0 && num_M_rewards ~= 0
                    inst_income_ratio(j) = rad2deg(atan(num_O_rewards/num_M_rewards));
                elseif num_O_rewards == 0
                    inst_income_ratio(j) = 0;
                elseif num_M_rewards == 0 
                    inst_income_ratio(j) = 90;
                end   
            end
        end
    end    
        
    if conts == 1
        fig_count = fig_count+1
        gotofig = fig_count;
        figure(fig_count)
    else
        figure(gotofig)
    end
    
    plot(pre_sum+1 : pre_sum + length(inst_choice_ratio),inst_choice_ratio,'LineWidth',4,'Color','b')
    hold on
    if protocol_100_0 ~= 1 
        plot(inst_income_ratio,'LineWidth',4,'Color','k')
        if protocol_100_0 == 2
            plot(pre_sum+1:pre_sum + length(choice_order),ones(1,length(choice_order))*ave_reward_ratio,'LineWidth',6,'Color','k')
        elseif protocol_100_0 == 3
            plot(pre_sum+1:pre_sum + length(choice_order),ones(1,length(choice_order))*ave_reward_ratio,'LineWidth',6,'Color','k')
    
        end
    else
        plot(pre_sum+1:pre_sum + length(choice_order),ones(1,length(choice_order))*90,'LineWidth',6,'Color','k')
    end
    plot(pre_sum+1:pre_sum + length(choice_order),ones(1,length(choice_order))*ave_choice_ratio,'LineWidth',6,'Color','r')
end