function [time_per_choice]  = time_per_choice_fn(x_y_time_color,cps)
    time_per_choice = [];
    ct = 0;
    color_vec = cbrewer('qual','Dark2',10,'cubic')
    Air_Color = 0*color_vec(6,:);
    O_A_Color = color_vec(1,:);
    O_M_Color = 0.6*color_vec(1,:);
    M_A_Color = color_vec(7,:);
    M_O_Color = 0.3*color_vec(7,:);
        
    for i = 2:length(cps)
        i
        ct = ct+1;
        start_pt = [];
        end_pt = [];
        no_match = 1;
        kk = 0;
        jj = 0;
        while no_match == 1
            kk = kk+1;
            if sum(x_y_time_color.color(cps(i)-kk,:) == M_A_Color)==3
                no_match = 2;
                start_pt = x_y_time_color.time(cps(i)-kk);
                jj = kk;
                while no_match == 2
                    jj = jj+1;
                    if sum(x_y_time_color.color(cps(i)-kk,:) == M_A_Color)~=3
                        no_match = 0;
                        end_pt = x_y_time_color.time(cps(i)-jj);
                    end
                end
            elseif sum(x_y_time_color.color(cps(i)-kk,:) == O_A_Color)==3 
                no_match = 2;
                start_pt = x_y_time_color.time(cps(i)-kk);
                jj = kk;
                while no_match == 2
                    jj = jj+1;
                    if sum(x_y_time_color.color(cps(i)-kk,:) == O_A_Color)~=3
                        no_match = 0;
                        end_pt = x_y_time_color.time(cps(i)-jj);
                    end
                end
            elseif sum(x_y_time_color.color(cps(i)-kk,:) == O_M_Color)==3 
                no_match = 2;
                start_pt = x_y_time_color.time(cps(i)-kk);
                jj = kk;
                while no_match == 2
                    jj = jj+1;
                    if sum(x_y_time_color.color(cps(i)-kk,:) == O_M_Color)~=3
                        no_match = 0;
                        end_pt = x_y_time_color.time(cps(i)-jj);
                    end
                end
            elseif sum(x_y_time_color.color(cps(i)-kk,:) == M_O_Color)==3 
                no_match = 2;
                start_pt = x_y_time_color.time(cps(i)-kk);
                jj = kk;
                while no_match == 2
                    jj = jj+1;
                    if sum(x_y_time_color.color(cps(i)-kk,:) == M_O_Color)~=3
                        no_match = 0;
                        end_pt = x_y_time_color.time(cps(i)-jj);
                    end
                end
            end
        end
        time_per_choice(ct) = start_pt-end_pt;
    end
end    