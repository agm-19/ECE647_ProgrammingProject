% part2b.m — Dual Gradient Algorithm for Network Utility Maximization
clc; clear;

% === Load topology ===
topology;  % loads Link_Capacity, Flow_Weight, Flow_Path

% === Build routing matrix A (L x F) ===
A = zeros(Num_Links, Num_Flows);
for i = 1:Num_Flows
    for j = 1:Max_Links_On_Path
        link = Flow_Path(i,j);
        if link ~= -1
            A(link, i) = 1;
        end
    end
end

% === Dual gradient method ===
gamma = 0.01;  % step size (can tune if needed)
max_iter = 500;

lambda = zeros(Num_Links, 1);         % initial dual variables
x_hist = zeros(Num_Flows, max_iter);  % flow rate history
lambda_hist = zeros(Num_Links, max_iter);  % dual variable history

for k = 1:max_iter
    x = zeros(Num_Flows, 1);  % flow rates

    % Compute flow rates for current lambda
    for i = 1:Num_Flows
        links = Flow_Path(i, Flow_Path(i,:) > 0);  % links used by flow i
        denom = sum(lambda(links));
        if denom == 0
            x(i) = 1e6;  % clip to large value
        else
            x(i) = Flow_Weight(i) / denom;
        end
    end

    % === FIXED: Proper vector shapes for dual update ===
    lambda = lambda + gamma * (A * x - Link_Capacity(:));
    lambda = max(lambda, 0);  % projection onto λ ≥ 0

    % Store history
    x_hist(:,k) = x;
    lambda_hist(:,k) = lambda;
end

% === Plot flow rates ===
figure;
plot(x_hist');
xlabel('Iteration'); ylabel('Flow Rate x_i');
title('Evolution of Flow Rates');
legend(arrayfun(@(i) sprintf('x_%d', i), 1:Num_Flows, 'UniformOutput', false));
grid on;

% === Plot dual variables ===
figure;
plot(lambda_hist');
xlabel('Iteration'); ylabel('Dual Variables \lambda_l');
title('Evolution of Dual Variables');
legend(arrayfun(@(l) sprintf('\\lambda_%d', l), 1:Num_Links, 'UniformOutput', false));
grid on;
