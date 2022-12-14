function [I1,I2,C1_1000,C2_1000] = Loewenstein_Seung_v1(p1,p2)

C1 = 0;
C2 = 0;
C1_1000 = 0;
C2_1000 = 0;
I1 = 0;
I2 = 0;
W1 = 1;
W1_vec = [1];
W2 = 1;
W2_vec = [1];
aR1 = 0;
aR2 = 0;
rR1 = [0,0,0,0,0,0,0,0,0,0];
rR2 = [0,0,0,0,0,0,0,0,0,0];
rR = [0,0,0,0,0,0,0,0,0,0];
tS1 = [0,0,0,0,0,0,0,0,0,0];
tS2 = [0,0,0,0,0,0,0,0,0,0];
% plasticity rate for cov LR
n = 0.2;
%plasticity rate for non-cov LR
% n = 0.0002;
currC = [];

for trialn = 1:2000
    cS1 = 1;%0.1.*randn(1,1) + 1;
    cS2 = 1;%0.1.*randn(1,1) + 1;
    tS1(trialn) = cS1;
    tS2(trialn) = cS2;
    
    eR1 = mean(rR1(end-9:end)); % Expected reward from choice 1
    eR2 = mean(rR2(end-9:end)); % Expected reward from choice 2
    eR = mean(rR(end-9:end));
    
    if isnan(eR1) == 1
        eR1 = 0;
    elseif isnan(eR2) == 1
        eR2 = 0;
    end    
    
    % reward for option 1
    if aR1 == 1
        aR1 = 1;
    elseif aR1 == 0
        if rand(1,1) < p1
            aR1 = 1;
        end
    end
    
    % reward for option 2
    if aR2 == 1
        aR2 = 1;
    elseif aR2 == 0
        if rand(1,1) < p2
            aR2 = 1;
        end
    end

    M1 = W1*cS1;
    M2 = W2*cS2;
    
    if mean(M1) > mean(M2)
%    if rand(1,1) < 1/(1+exp(-8*(M1-M2)))        
        currC = 1;
        if trialn > 1000
            C1_1000 = C1_1000 + 1;
        end    
        C1 = C1 + 1;
        if aR1 == 1
            rR1(length(rR1)+ 1) = aR1;
            rR(length(rR)+1) = aR1;
            I1 = I1 + 1;
            aR1 = 0;
        else
            rR1(length(rR1)+ 1) = aR1;
            rR(length(rR)+1) = aR1;
        end
    elseif mean(M2) > mean(M1)
        currC = 2;
        if trialn > 1000
            C2_1000 = C2_1000 + 1;
        end 
        C2 = C2 + 1;
        if aR2 == 1
            rR2(length(rR2)+ 1) = aR2;
            rR(length(rR)+1) = aR2;
            I2 = I2 + 1;
            aR2 = 0;
        else
            rR2(length(rR2)+ 1) = aR2;
            rR(length(rR)+1) = aR2;
        end
    elseif mean(M1) == mean(M2)
        if rand(1,1) < 0.5
            currC = 1;
            if trialn > 1000
                C1_1000 = C1_1000 + 1;
            end 
            C1 = C1 + 1;
            if aR1 == 1
                rR1(length(rR1)+ 1) = aR1;
                rR(length(rR)+1) = aR1;
                I1 = I1 + 1;
                aR1 = 0;
            else
                rR1(length(rR1)+ 1) = aR1;
                rR(length(rR)+1) = aR1;
            end
        else
            currC = 2;
            if trialn > 1000
                C2_1000 = C2_1000 + 1;
            end 
            C2 = C2 + 1;
            if aR2 == 1
                rR2(length(rR2)+ 1) = aR2;
                rR(length(rR)+1) = aR2;
                I2 = I2 + 1;
                aR2 = 0;
            else
                rR2(length(rR2)+ 1) = aR2;
                rR(length(rR)+1) = aR2;
            end
        end
    end
    
    
          
    % update rule for cov LR 1
%     if currC == 1
%         dW1 = n .* [rR1(end)] .* [cS1-mean(tS1(end-9:end))];
% %         dW1 = n .* [rR1(end)] .* [cS1-mean(tS1)];
%         W1 = W1 + transpose(dW1);
%     elseif currC == 2
%         dW2 = n .* [rR2(end)] .* [cS2-mean(tS2(end-9:end))];
% %         dW2 = n .* [rR2(end)] .* [cS2-mean(tS2)];
%         W2 = W2 + transpose(dW2);
%     end  

%     % update rule for cov LR 2
%     if currC == 1
%         dW1 = n .* [rR1(end)-eR1] .* [cS1];
%         W1 = W1 + transpose(dW1);
%     elseif currC == 2
%         dW2 = n .* [rR2(end)-eR2] .* [cS2];
%         W2 = W2 + transpose(dW2);
%     end  
%     
% update rule for cov LR 3
    if currC == 1
        cS2 = cS2-1; % to say this stimulus disappears but noise remains
        dW1 = n .* [rR(end)-eR] .* [cS1];
        W1 = W1 + transpose(dW1);
        W1_vec(trialn+1) = W1;
        dW2 = n .* [rR(end)-eR] .* [cS2];
        W2 = W2 + transpose(dW2);
        W2_vec(trialn+1) = W2;
    elseif currC == 2
        cS1 = cS1-1; %same reasoning as above
        dW1 = n .* [rR(end)-eR] .* [cS1];
        W1 = W1 + transpose(dW1);
        W1_vec(trialn+1) = W1;
        dW2 = n .* [rR(end)-eR] .* [cS2];
        W2 = W2 + transpose(dW2);
        W2_vec(trialn+1) = W2;
    end   
    
    % update rule for non-cov LR
%     if currC == 1
%         dW1 = n .* [rR1(end)] .* [cS1];
%         W1 = W1 + transpose(dW1);
%     elseif currC == 2
%         dW2 = n .* [rR2(end)] .* [cS2];
%         W2 = W2 + transpose(dW2);
%     end 
    
%     keyboard
end 
end