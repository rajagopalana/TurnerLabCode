load_filename = input('.mat file to load')
H_vec_max = input('enter max number of trials back to use in model')

load(load_filename);

% converting choice matrix to a choice vector for ease of referencing
choice_order = [];
reward_order = [];
reward_order_2 = [];
for a = 1:2100
    choice_order = cat(2,choice_order,C1_list(a,:));
    reward_order = cat(2,reward_order,I1_list(a,:));
end

z_list = find(choice_order == 0);
choice_order(z_list) = 2;

for a = 1:2100
    reward_order_2 = cat(2,reward_order_2,I2_list(a,:));
end

for b = 1:length(reward_order)
    if reward_order(b) == 0 && reward_order_2(b) == 1
        reward_order(b) = 2;
    end
end  

CO = choice_order;
RO = reward_order;
wi_mat = {};
Pc_mat = {};
P2_mat = {};
LossLOU_mat = {};

for simnum = 1:2100
    simnum
    choice_order = CO(((simnum-1)*240)+1 : simnum*240);
    reward_order = RO(((simnum-1)*240)+1 : simnum*240);
    
    % n0=length(cps_pre);
    n0=1;

    %
    H_vec=1:H_vec_max;
    N = length(choice_order);
    lenH=length(H_vec);
    indH=0;
    LossLOU=zeros(lenH,1);
    Pc = NaN(length(H_vec),N-1);
    P2 = NaN(length(H_vec),N-1);
    
    for H=H_vec
        tic;
%         indH=indH+1
        % H=1;


        n=N-H;  % num of obs
        p=3*H; % num of parameters
        X=zeros(n,p);

    %     c = -1+2*eq(choice_order,2);
        r = -1+2*ne(reward_order,0);
        c=choice_order;
    %     r = reward_order;
        Y = choice_order((H+1):end)';
        for i = (H+1):N
            X(i-H,1:H) = c(i-(1:H));
            X(i-H,(H+1):(2*H)) = r(i-(1:H));
            X(i-H,(2*H+1):(3*H)) = c(i-(1:H)).*r(i-(1:H));
        end
        % Leave one out
        %             i
            Xi = X;
            %Xi(i,:) = [];
            Yi = Y;
            %Yi(i) = [];
            i;
            wi = mnrfit(Xi,Yi);
            %store the regresseros for sd 

            % ADITHYA - 07.12.20:
            % wi_mat is 5 element char with each element corresponding to
            % different windows of trials (H_vec long). Each element contains
            % the weights ( regressors) of different predictors of present
            % choice. Three types of predictors are used above. past choice
            % (for the past H choices), past reward (for the past H choices)
            % and a product of past choices and past rewards (for the past H
            % choices). so each element will contain a n X 3*H long vector
            % (where n = N-H, where N is the number of choices made in the
            % session).

            wi_mat{(simnum),H}=wi;
        
        for i = 1:n
%

            % hi is the predicted Y values based on the given Xs and calculated
            % wis
            hi = [1 X(i,:)]*wi;

            if eq(Y(i),1)
                prob_i = exp(hi)/(1+exp(hi));
            else
                prob_i = 1/(1+exp(hi));
            end
            % Probability of model choosing action 2
            P2(H,i)=1/(1+exp(hi));
            % probability of model choosing action chosen by fly
            Pc(H,i)=(prob_i);
        end

        LossLOU(H)=mean(Pc(H,1:end - H+1));
        toc;
        
        Pc_mat{simnum} = Pc;
        P2_mat{simnum} = P2;
        LossLOU_mat{simnum} = LossLOU;
        


    end
end    
    
<<<<<<< HEAD
%     figure(11)
%     subplot (2,3,H)
%     plot(Pc(H,:),'g')
%     hold on
%     plot(P2(H,:),'k')
%     plot(Y-1,'or')
=======
    figure(11)
    subplot (2,3,H)
    plot(Pc(H,:),'g')
    hold on
    plot(P2(H,:),'k')
    plot(Y-1,'or')
>>>>>>> 9d2760640073c206b4c5a280cc37700186926f0c
