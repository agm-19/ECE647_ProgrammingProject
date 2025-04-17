% Ques. 2(b) Network Rate Control Problem 
clc; clear all;
% Reads configuration from topology.m file
run('topology.m');  
% Create routing matrix from Flow_Path
R = zeros(Num_Links, Num_Flows);
for flow = 1:Num_Flows
    for link_idx = 1:Max_Links_On_Path
        link = Flow_Path(flow, link_idx);
        if link > 0  % -1 indicates no link
            R(link, flow) = 1;
        end
    end
end

c = Link_Capacity';
w = Flow_Weight';

% Dual Gradient Algorithm parameters
num_iterations = 1000;
step_size = 0.1;  % fast convergence
    
% Initialize dual variables (Lagrange multipliers) and flow rates
lambda = ones(Num_Links, 1);  % Initial dual variables
x_history = zeros(Num_Flows, num_iterations);  % To store flow rates
lambda_history = zeros(Num_Links, num_iterations);  % To store dual variables

% Dual Gradient Algorithm
for k = 1:num_iterations
    % Store current lambda
    lambda_history(:, k) = lambda;
    % Calculate flow rates based on current lambda
    x = zeros(Num_Flows, 1);
    for i = 1:Num_Flows
        % Find which links flow i uses
        links_used = find(R(:, i));
        % Calculate sum of lambdas for these links
        sum_lambda = sum(lambda(links_used));
        % Update flow rate using formula: x_i = w_i / sum_lambda
        if sum_lambda > 0
            x(i) = w(i) / sum_lambda;
        else
            x(i) = 10;  % Some large value if sum_lambda is zero
        end
    end
    
    % Store current flow rates
    x_history(:, k) = x;
    % Update dual variables
    link_loads = R * x;  % Calculate load on each link
    lambda = max(0, lambda + step_size * (link_loads - c));  % Projection to non-negative values
end

% Plot flow rates convergence
figure;
plot(1:num_iterations, x_history, 'LineWidth', 1.5);
title('Flow Rates Convergence');
xlabel('Iteration');
ylabel('Flow Rate');
legend_flow = cell(1, Num_Flows);
for i = 1:Num_Flows
    legend_flow{i} = sprintf('Flow %d', i);
end
legend(legend_flow);
grid on;

% Plot dual variables' convergence
figure;
plot(1:num_iterations, lambda_history, 'LineWidth', 1.5);
title('Dual Variables Convergence');
xlabel('Iteration');
ylabel('Dual Variable Value');
legend_links = cell(1, Num_Links);
for i = 1:Num_Links
    legend_links{i} = sprintf('Link %d', i);
end
legend(legend_links);
grid on;

% Display final flow rates and dual variables
fprintf('Final flow rates:\n');
for i = 1:Num_Flows
    fprintf('x%d = %.4f\n', i, x_history(i, end));
end

fprintf('\nFinal dual variables:\n');
for i = 1:Num_Links
    fprintf('lambda%d = %.4f\n', i, lambda_history(i, end));
end

% Calculate final link loads
final_link_loads = R * x_history(:, end);
fprintf('\nFinal link loads vs capacities:\n');
for i = 1:Num_Links
    fprintf('Link %d: Load = %.4f, Capacity = %.4f\n', i, final_link_loads(i), c(i));
end

% Verify optimality of the solution
fprintf('\nVerifying optimality of solution:\n');

% 1. Check primal feasibility
link_loads = R * x_history(:, end);
primal_feasible = all(link_loads <= c + 1e-6);  % Adding small tolerance
fprintf('1. Primal feasibility (Rx <= c): %s\n', string(primal_feasible));

% 2. Check dual feasibility
dual_feasible = all(lambda_history(:, end) >= 0);
fprintf('2. Dual feasibility (lambda >= 0): %s\n', string(dual_feasible));

% 3. Check complementary slackness
comp_slack = true;
fprintf('3. Complementary slackness:\n');
for i = 1:Num_Links
    slack = abs(lambda_history(i, end) * (link_loads(i) - c(i)));
    if slack > 1e-6
        comp_slack = false;
        fprintf('   Failed for link %d: lambda = %.6f, (Rx-c) = %.6f, product = %.6f\n', ...
                i, lambda_history(i, end), link_loads(i) - c(i), slack);
    end
end
fprintf('Overall complementary slackness satisfied: %s\n', string(comp_slack));

% 4. Check stationarity
stationarity = true;
fprintf('4. Stationarity condition (x_i = w_i / sum_j(lambda_j * R_ji)):\n');
for i = 1:Num_Flows
    links_used = find(R(:, i));
    sum_lambda = sum(lambda_history(links_used, end));
    expected_x = w(i) / sum_lambda;
    diff = abs(x_history(i, end) - expected_x);
    
    if diff > 1e-6
        stationarity = false;
        fprintf('   Failed for flow %d: Actual x = %.6f, Expected x = %.6f, Diff = %.6f\n', ...
                i, x_history(i, end), expected_x, diff);
    end
end
fprintf('   Overall stationarity condition satisfied: %s\n', string(stationarity));

% Overall optimality
fprintf('\nOverall optimality conditions satisfied: %s\n', ...
        string(primal_feasible && dual_feasible && comp_slack && stationarity));

% Calculate utility value
utility = sum(w .* log(x_history(:, end)));
fprintf('\nFinal utility value: %.6f\n', utility);
