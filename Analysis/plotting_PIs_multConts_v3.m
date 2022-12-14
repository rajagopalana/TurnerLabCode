%% Analyse data generated by Y-maze
function [p_staying_g_Nreward,p_staying_g_reward,p_switching_g_Nreward,p_switching_g_reward] = plotting_PIs_multConts_v3(save_fig,lookback)


    % Select spreadsheet containing experiment names
    % example excel sheet included in repository
    % FOR MAC LAPTOP
    %   cd('/Users/adiraj95/Documents/MATLAB/TurnerLab_Code/') % Change directory to folder containing experiment lists
    % FOR WORK DESKTOP
    cd('/groups/turner/home/rajagopalana/Documents/Turner Lab/Y-Arena/')
    [FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off');
    [~, expts, ~] = xlsread([PathName, FileName]);
    acquisition_rate = 30; % Acquisition rate (in Hz)

    % Initialize variables
    individual_pi = [];
    arm_bias_expected_pi = [];
    count = 0;
    cpms = [];
    fig_count = 0;
    ave_choice_ratios = [];
    ave_reward_ratios = [];
    ave_choice_ratios_sec_half = [];
    ave_reward_ratios_sec_half = [];
    p_staying_g_Nreward = [];
    p_staying_g_reward = [];
    p_switching_g_Nreward = [];
    p_switching_g_reward =[];
    
    num_turns_away_rewarded = zeros(2,26,3);
    num_turns_away_unrewarded = zeros(2,26,3);
    time_turns_away_rewarded = [];
    time_turns_away_unrewarded = [];
    
    % set up color space for plots
    % cbrewer is a matlab code base that generates color spaces, included
    % in the repository
    color_vec = cbrewer('qual','Dark2',10,'cubic');
    Air_Color = 0*color_vec(6,:);
    O_A_Color = color_vec(1,:);
    O_M_Color = 0.6*color_vec(1,:);
    M_A_Color = color_vec(7,:);
    M_O_Color = 0.7*color_vec(7,:);

    protocol_100_0 = 2; % just setting this number to two for now it is an unneccesary variable but removing it requires too many code changes for now
    

    % Looping through experimental conditions such as genotypes, total
    % reward probability etc. These are specified in the excel sheet that
    % is loaded earlier
    for expt_n = 1:2%length(expts)
        expt_name = expts{expt_n, 1};
        cd(expt_name)
        conds = dir(expt_name);
        
        % Looping through individual flies in each experimental condition
        for cond_n =1:length(conds)
            % Skip the folders containing '.'
            if startsWith(conds(cond_n).name, '.')
                count = count+1;
                continue
                %SKIPPING INCOMPLETE/LOW MI EXPTS FOR GR64f
%             elseif expt_n == 1
%                 if ismember(cond_n,[1,4,5,7,8,9,11,13,14,15,16,17,18,22]+3)
%                     continue
%                 end
%             elseif expt_n == 2
%                 if ismember(cond_n,[4,5,6,9,11,12,13,15,16,17,18,19,20]+2)
%                     continue
%                 end

            end
              
            choice_order = [];
            reward_order = [];

            % Change directory to file containing flycounts 
            cond = strcat(expt_name, '/', conds(cond_n).name);
            cd(cond)
  
            gotofig = 0;
            gotofig2 = 0;
            
            % Identifying the number of blocks run in a given expt.
            % Each block's data is saved as a separate .mat file by the
            % Y-arena code
            conts = dir(cond);
            length_conts = 0;
            for ct = 1:length(conts)
                if endsWith(conts(ct).name,'.mat')
                    length_conts = length_conts + 1;
                end
            end    
            
            % If analysis is run on data that has already been analyzed
            % once before, other mat files may exist causing the the block
            % identifier to be incorrect. This is fixed below by
            % subtracting the number of incorrect mat files identified
            if length_conts == 9
                subt = 8;
            elseif length_conts == 12
                subt = 10;
            elseif length_conts == 16
                subt = 13;
            elseif length_conts == 15
                subt = 12;
            else    
                subt = 9;
            end  
            
            % Looping through blocks in an single fly experiment
            
            % UNCOMMENT THIS FOR LOOP IF A 4 BLOCK EXPT IS RUN
            % This experiment will have 4 data .mat files with names that
            % end in 1, 1.25, 1.75, 2.25
%             for conts = [1,1.25,1.75,2.25]
%                 conts_name = conts;
%                 conts = find([1,1.25,1.75,2.25]==conts_name);
            % UNCOMMENT THIS FOR LOOP IF A 2 BLOCK EXPT IS RUN
            % This experiment will have 2 data .mat files with names that
            % end in 1, 1.75
%             for conts = 1:0.75:1.75
            % UNCOMMENT THIS FOR LOOP IF A 3 BLOCK EXPT IS RUN
            % This experiment will have 4 data .mat files with names that
            % end in 1, 2, 3
          for conts = 1:length_conts-subt % this set of expts has 3 conts

            % Loading in data
            conts_name = conts;
            name = sprintf('all_variables_contingency_%d.mat',conts_name);
            if exist(name) == 2
                load(name)
            else
                conts = conts - 1
            end    
            exist reward
            if ans == 0 
                reward = [];
            end    

            % Analysis to identify and format fly position in Y, odor
            % associated with position, time associated with position,
            % deal with frames where fly was lost and calculate at what
            % timepoints choices were made. Additionally any bias the
            % flies may have for turning right or left is quantified
            % here.

            cps_first = find(air_arm==0);
            cps_first(length(cps_first)+1) = length(air_arm);
            [xy_no_minus_ones,timestamps_no_minus_ones] = no_minus_ones(xy,timestamps);
            [region_at_time] = region_time_vector(xy_no_minus_ones,binarymask1,binarymask2,binarymask3,binarymask4,binarymask5,binarymask6,binarymask7,binarymask8,binarymask9);
            [x_y_time_color] = plot_position_choices(region_at_time,xy_no_minus_ones,timestamps_no_minus_ones,air_arm,right_left,cps_first);

            if length(x_y_time_color.distance_up_arm) ~= length(x_y_time_color.time)
                x_y_time_color.distance_up_arm(length(x_y_time_color.distance_up_arm)+1:length(x_y_time_color.distance_up_arm)+1+(length(x_y_time_color.time)-length(x_y_time_color.distance_up_arm))) = x_y_time_color.distance_up_arm(length(x_y_time_color.distance_up_arm))*ones(1,(length(x_y_time_color.time)-length(x_y_time_color.distance_up_arm)));
            end    

            [pi,cps] = preference_index_multConts(air_arm,right_left,x_y_time_color);
            [a,b,c,d,arm_bias_pi] = arm_bias(air_arm,right_left);

            individual_pi(expt_n,cond_n-2,ceil(conts)) = pi;

            arm_bias_expected_pi(expt_n,cond_n-2,ceil(conts)) = arm_bias_pi;
            cpms(expt_n,cond_n-2,ceil(conts)) = choicesperminute(air_arm,time);



           % PLOTTING position vs time with different colors for different
           % odors in arm
            max_time = max(x_y_time_color.time);

            num_figs = ceil(max_time/1800);
            cont_switch(1) = 1;
            if num_figs > 1
                for yy = 2:num_figs
                    cont_switch(yy) = find(x_y_time_color.time > (yy-1)*1800,1);
                end

            end    
            cont_switch(num_figs+1) = length(x_y_time_color.time);
                for k = 1:num_figs
                    figure(fig_count+1)
                    fig_count = fig_count+1
                    hold on
                    for i  = cont_switch(k):cont_switch(k+1)-1
                        if sum(x_y_time_color.color(i) == Air_Color) == 3
                            if sum(x_y_time_color.color(i+1) == Air_Color) == 3
                                plot(x_y_time_color.time(i:i+1),-1*(x_y_time_color.distance_up_arm(i:i+1)),'LineWidth',3,'Color',x_y_time_color.color(i,:))
                            elseif sum(x_y_time_color.color(i+1) == Air_Color) ~= 3
                                plot(x_y_time_color.time(i:i+1),[-1*(x_y_time_color.distance_up_arm(i)),(x_y_time_color.distance_up_arm(i+1))],'LineWidth',3,'Color',x_y_time_color.color(i,:))
                            end    
                        else
                            if sum(x_y_time_color.color(i+1) == Air_Color) == 3
%                                 plot(x_y_time_color.time(i:i+1),[x_y_time_color.distance_up_arm(i),-1*(x_y_time_color.distance_up_arm(i))],'LineWidth',3,'Color',Air_Color)
                            else
                                plot(x_y_time_color.time(i:i+1),(x_y_time_color.distance_up_arm(i:i+1)),'LineWidth',3,'Color',x_y_time_color.color(i,:))
                            end    
                        end
                    end 
                    cc = 0;
                    timestamps_summed = [];
                    for tt  = cps(max(find(cps<cont_switch(k)+1))+1:max(find(cps<cont_switch(k+1))))
                        no_match = 1;
                        kk = 0;
                        while no_match == 1
                            kk = kk+1;
                            if sum(x_y_time_color.color(tt-kk,:) == M_A_Color )==3 ||sum(x_y_time_color.color(tt-kk,:) == M_O_Color )==3
                                dot_color = M_A_Color;
                                no_match = 0;
                            elseif sum(x_y_time_color.color(tt-kk,:) == O_A_Color)==3 ||sum(x_y_time_color.color(tt-kk,:) == O_M_Color)==3
                                dot_color = O_A_Color;
                                no_match = 0;
                            end 
                        end    
                        cc = cc+1; 
                        timestamps_summed(cc) = sum(timestamps_no_minus_ones(1:tt));
                        scatter(timestamps_summed(cc),460,200,'s','filled','MarkerEdgeColor',dot_color,'MarkerFaceColor',dot_color)

%                         scatter(timestamps_summed(cc),1,100,'s','filled','MarkerEdgeColor',dot_color,'MarkerFaceColor',dot_color)
                    end


                    xlabel('time (sec)');
                    ylabel('distance (pixels)');
                    hold off

                end  

% 

                % PLOTTING just choice rasters
                figure (fig_count+1)
                hold on
                fig_count = fig_count+1
                for tt  = cps(2:end)
                    no_match = 1;
                    kk = 0;
                    while no_match == 1
                        kk = kk+1;
                        if sum(x_y_time_color.color(tt-kk,:) == M_A_Color )==3 ||sum(x_y_time_color.color(tt-kk,:) == M_O_Color )==3
                            dot_color = M_A_Color;
                            no_match = 0;
                            cc = cc+1; 
                            timestamps_summed(cc) = sum(timestamps_no_minus_ones(1:tt));
                            scatter(timestamps_summed(cc),1,200,'s','filled','MarkerEdgeColor',dot_color,'MarkerFaceColor',dot_color)
                        elseif sum(x_y_time_color.color(tt-kk,:) == O_A_Color)==3 ||sum(x_y_time_color.color(tt-kk,:) == O_M_Color)==3
                            dot_color = O_A_Color;
                            no_match = 0;
                            cc = cc+1; 
                            timestamps_summed(cc) = sum(timestamps_no_minus_ones(1:tt));
                            scatter(timestamps_summed(cc),2,200,'s','filled','MarkerEdgeColor',dot_color,'MarkerFaceColor',dot_color)
                        end 
                    end 
                end    


                hold off

                [odor_crossing] = odor_crossings(region_at_time,air_arm,right_left,timestamps_no_minus_ones);



                % Plotting # choices over time
                if conts > 1
                    summed_choices_ends = [];
                    summed_choices_center = [];
                    summed_O_choices_ends = [];
                    summed_O_choices_center = [];
                    summed_M_choices_ends = []; 
                    summed_M_choices_center = [];
                    [summed_choices_ends, summed_choices_center,summed_O_choices_ends, summed_O_choices_center,summed_M_choices_ends, summed_M_choices_center,fig_count,net_summed_choices,CO,RO,gotofig] = summed_choices_mult_conts(cps,odor_crossing,x_y_time_color,fig_count,protocol_100_0,reward,ceil(conts),gotofig,pre_sumM,pre_sumO,baiting)

                else
                    [summed_choices_ends, summed_choices_center,summed_O_choices_ends, summed_O_choices_center,summed_M_choices_ends, summed_M_choices_center,fig_count,net_summed_choices,CO,RO,gotofig] = summed_choices_mult_conts(cps,odor_crossing,x_y_time_color,fig_count,protocol_100_0,reward,ceil(conts),gotofig,0,0,baiting)
                    pre_sumM = summed_M_choices_ends(end) ;
                    pre_sumO = summed_O_choices_ends(end);
                    pre_sum = summed_choices_ends(end);
                end

                choice_order(1:length(CO),ceil(conts)) = CO;
                reward_order(1:length(RO),ceil(conts)) = RO;


                inst_choice_ratio =[];
                if conts > 1
                    [inst_choice_ratio(cond_n-2,:),inst_income_ratio,ave_choice_ratios(expt_n,cond_n-2,ceil(conts)),ave_choice_ratios_sec_half(expt_n,cond_n-2,ceil(conts)),fig_count,ave_reward_ratios(expt_n,cond_n-2,ceil(conts)),ave_reward_ratios_sec_half(expt_n,cond_n-2,ceil(conts)),gotofig2] = inst_CR_mult_conts(fig_count,protocol_100_0,choice_order(1:length(CO),ceil(conts)),reward_order(1:length(RO),ceil(conts)),lookback,ceil(conts),pre_sum,baiting,reward,gotofig2)
                    pre_sumM = summed_M_choices_ends(end) ;
                    pre_sumO = summed_O_choices_ends(end);
                    pre_sum = summed_choices_ends(end);
                else
                    [inst_choice_ratio(cond_n-2,:),inst_income_ratio,ave_choice_ratios(expt_n,cond_n-2,ceil(conts)),ave_choice_ratios_sec_half(expt_n,cond_n-2,ceil(conts)),fig_count,ave_reward_ratios(expt_n,cond_n-2,ceil(conts)),ave_reward_ratios_sec_half(expt_n,cond_n-2,ceil(conts)),gotofig2] = inst_CR_mult_conts(fig_count,protocol_100_0,choice_order(1:length(CO),ceil(conts)),reward_order(1:length(RO),ceil(conts)),lookback,ceil(conts),0,baiting,reward,gotofig2)
                end

                % Defining which odor is more rewarded

               % UNCOMMENT FOR 100:0 EXPTS
                % The number associated with O and M may need to be
                % changed according to the length of the expt name.
%                     if expt_n == 1
%                         if cond(140) == 'O'
%                             rewarded_odor = 2;
%                         elseif cond(140) == 'M'
%                             rewarded_odor = 1;
%                         end    
%                     elseif expt_n == 2
%                         if cond(121) == 'M'
%                             rewarded_odor = 1;
%                         elseif cond(121) == 'O'
%                             rewarded_odor = 2;
%                         end    

                % UNCOMMENT FOR 3 BLOCK MATCHING EXPTS  OR EXPTS WITH MULTIPLE REWARDS  
                if expt_n == 1  
                    if ave_reward_ratios(expt_n,cond_n-2,ceil(conts)) > 45
                        rewarded_odor = 1;
                    elseif ave_reward_ratios(expt_n,cond_n-2,ceil(conts)) < 45
                        rewarded_odor = 2;
                    else
                        rewarded_odor = 0;
                    end
                elseif expt_n == 2
                    if ave_reward_ratios(expt_n,cond_n-2,ceil(conts)) > 45 
                        rewarded_odor = 1;
                    elseif ave_reward_ratios(expt_n,cond_n-2,ceil(conts)) < 45
                        rewarded_odor = 2;
                    else
                        rewarded_odor = 0;
                    end
                end    


                figure(fig_count+1)
                fig_count = fig_count+1
                hold on

                % Identifying transitions between odors and air as well
                % as turns away from odors useful for analysis in Fig.
                % 1F-H

                for b = 1:length(odor_crossing)
                    if isequal(odor_crossing(b).type,{'AtoM'})
                        scatter(odor_crossing(b).time,1,150,'s','filled','MarkerFaceColor',M_A_Color,'MarkerEdgeColor',M_A_Color)
                    elseif isequal(odor_crossing(b).type,{'AtoO'})
                        scatter(odor_crossing(b).time,2,150,'s','filled','MarkerFaceColor',O_A_Color,'MarkerEdgeColor',O_A_Color)
                    elseif isequal(odor_crossing(b).type,{'OtoM'})
                        scatter(odor_crossing(b).time,3,150,'s','filled','MarkerFaceColor',M_O_Color,'MarkerEdgeColor',M_O_Color)  
                        if rewarded_odor == 1
                            num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        elseif rewarded_odor == 2
                            num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        end     
                    elseif isequal(odor_crossing(b).type,{'MtoO'})
                        scatter(odor_crossing(b).time,4,150,'s','filled','MarkerFaceColor',O_M_Color,'MarkerEdgeColor',O_M_Color) 
                        if rewarded_odor == 2
                            num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        elseif rewarded_odor == 1
                            num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        end 
                    elseif isequal(odor_crossing(b).type,{'MtoA'})
                        scatter(odor_crossing(b).time,5,150,'s','filled','MarkerFaceColor',Air_Color,'MarkerEdgeColor',Air_Color)
                        if rewarded_odor == 2
                            num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        elseif rewarded_odor == 1
                            num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        end 
                    elseif isequal(odor_crossing(b).type,{'OtoA'})
                        scatter(odor_crossing(b).time,6,150,'s','filled','MarkerFaceColor',Air_Color,'MarkerEdgeColor',Air_Color)
                        if rewarded_odor == 1
                            num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_rewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_rewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        elseif rewarded_odor == 2
                            num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts)) = num_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts))+1;
                            time_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) = odor_crossing(b).time_pt_in_vector;
                            dist_turns_away_unrewarded(expt_n,cond_n-2,ceil(conts),b) =  x_y_time_color.distance_up_arm(odor_crossing(b).time_pt_in_vector);
                        end 
                    end
                end

                xlabel('time (sec)')
                ylabel('choice ID')
                yticks([1,2,3,4,5,6])
                yticklabels({'A to M','A to O','O to M','M to O','M to A','O to A'})


                hold off
                
                % Calculating probability of staying/switching given 
                % reward/no-reward useful for WinStayLoseSwitch Analysis
                % p(staying|Reward)
                n_staying_g_reward = 0;
                t_num_trials = 0;
                for i = 1:length(choice_order)-1
                    t_num_trials = t_num_trials + 1;
                    if choice_order(i,ceil(conts)) == 1
                        if reward_order(i,ceil(conts)) == 1
                            if choice_order(i+1,ceil(conts)) == 1
                                n_staying_g_reward = n_staying_g_reward + 1;
                            end
                        end
                    elseif choice_order(i,ceil(conts)) == 2  
                        if reward_order(i,ceil(conts)) == 2
                            if choice_order(i+1,ceil(conts)) == 2
                                n_staying_g_reward = n_staying_g_reward + 1;
                            end
                        end
                    end    
                end    

                p_staying_g_reward(length(p_staying_g_reward)+1) = n_staying_g_reward/t_num_trials;


                % p(staying|NReward)
                n_staying_g_Nreward = 0;
                t_num_trials = 0;
                for i = 1:length(choice_order)-1
                    t_num_trials = t_num_trials + 1;
                    if choice_order(i,ceil(conts)) == 1
                        if reward_order(i,ceil(conts)) ~= 1
                            if choice_order(i+1,ceil(conts)) == 1
                                n_staying_g_Nreward = n_staying_g_Nreward + 1;
                            end
                        end
                    elseif choice_order(i,ceil(conts)) == 2  
                        if reward_order(i,ceil(conts)) ~= 2
                            if choice_order(i+1,ceil(conts)) == 2
                                n_staying_g_Nreward = n_staying_g_Nreward + 1;
                            end
                        end
                    end   
                end    

                p_staying_g_Nreward(length(p_staying_g_reward)) = n_staying_g_Nreward/t_num_trials;


                % p(switching|NoReward)
                n_switching_g_Nreward = 0;
                t_num_trials = 0;
                for i = 1:length(choice_order)-1
                    t_num_trials = t_num_trials + 1;
                    if choice_order(i,ceil(conts)) == 1
                        if reward_order(i,ceil(conts)) ~= 1
                            if choice_order(i+1,ceil(conts)) == 2
                                n_switching_g_Nreward = n_switching_g_Nreward + 1;
                            end
                        end
                    elseif choice_order(i,ceil(conts)) == 2  
                        if reward_order(i,ceil(conts)) ~= 2
                            if choice_order(i+1,ceil(conts)) == 1
                                n_switching_g_Nreward = n_switching_g_Nreward + 1;
                            end
                        end
                    end    
                end

                p_switching_g_Nreward(length(p_staying_g_reward)) = n_switching_g_Nreward/t_num_trials;



                % p(switching|Reward)
                n_switching_g_reward = 0;
                t_num_trials = 0;
                for i = 1:length(choice_order)-1
                    t_num_trials = t_num_trials + 1;
                    if choice_order(i,ceil(conts)) == 1
                        if reward_order(i,ceil(conts)) == 1
                            if choice_order(i+1,ceil(conts)) == 2
                                n_switching_g_reward = n_switching_g_reward + 1;
                            end
                        end
                    elseif choice_order(i,ceil(conts)) == 2  
                        if reward_order(i,ceil(conts)) == 2
                            if choice_order(i+1,ceil(conts)) == 1
                                n_switching_g_reward = n_switching_g_reward + 1;
                            end
                        end
                    end    
                end

                p_switching_g_reward(length(p_staying_g_reward)) = n_switching_g_reward/t_num_trials;


                odor_crossing_filename = sprintf('odor_crossing_%d.mat',conts)        
                save(odor_crossing_filename,'odor_crossing')  
                cps_filename = sprintf('cps_%d.mat',conts)
                save(cps_filename,'cps')
          end 
            
            % Saving analyzed variables
            
            % Only save figures if save_fig input is 1
            if save_fig == 1 

                for fc = 1:fig_count
                    if fc == gotofig
                        saveas(figure(gotofig),'summed_choices_ends.fig')
                    elseif fc == gotofig2
                        saveas(figure(gotofig2),'inst_CR_lb10.fig')
                    else
                        saveas(figure(fc),sprintf('figure%d.fig',fc))
                    end    
                end
                pause(60)
  
            end
            
            save('choice_order.mat','choice_order')
            save('reward_order.mat','reward_order')
            save('inst_CR.mat','inst_choice_ratio')
            save('O_choice.mat','summed_O_choices_ends')
            save('M_choice.mat','summed_M_choices_ends')
            
%                        
            fig_count = 0;
            close all
        end

    end
    

  
    cd(expt_name)
    keyboard
    save('ave_CR_100_0.mat','ave_choice_ratios')
    save('ave_IR_100_0.mat','ave_reward_ratios')
    save('ave_CR_100_0_sec_half.mat','ave_choice_ratios_sec_half')
    save('ave_IR_100_0_sec_half.mat','ave_reward_ratios_sec_half')
    save('num_turns_rewarded.mat','num_turns_away_rewarded')
    save('num_turns_unrewarded.mat','num_turns_away_unrewarded')
    
    % 
    % figure(101)
    % scattered_dot_plot(transpose(cpms(1,list)),101,1,4,8,marker_colors(1,:),1,[],[0.75,0.75,0.75],[{'choices per minute'}],1,[0.35,0.35,0.35]);
end