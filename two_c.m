% Ques. 2(c)
% Verification of optimality for the network rate control problem
% This code should be run after two_b.m so that it can share the workspace
% Get the final flow rates and dual variables
x_final = x_history(:, end);
lambda_final = lambda_history(:, end);

% 1. Verify primal feasibility: Rx ≤ c
link_loads = R * x_final;
fprintf('Verifying optimality of solution:\n\n');
fprintf('1. Primal feasibility (Rx ≤ c):\n');

primal_feasible = true;
for i = 1:Num_Links
    feasible_i = link_loads(i) <= c(i) + 1e-6;  % Small tolerance
    fprintf('   Link %d: Load %.6f, Capacity %.6f, Feasible: %s\n', ...
            i, link_loads(i), c(i), string(feasible_i));
    if ~feasible_i
        primal_feasible = false;
    end
end
fprintf('Overall primal feasibility: %s\n\n', string(primal_feasible));

% 2. Verify dual feasibility: λ ≥ 0
fprintf('2. Dual feasibility (λ ≥ 0):\n');
dual_feasible = true;
for i = 1:Num_Links
    feasible_i = lambda_final(i) >= 0;
    fprintf('λ%d = %.6f, Feasible: %s\n', i, lambda_final(i), string(feasible_i));
    if ~feasible_i
        dual_feasible = false;
    end
end
fprintf('Overall dual feasibility: %s\n\n', string(dual_feasible));

% 3. Verify complementary slackness: λᵢ(Rx-c)ᵢ = 0
fprintf('3. Complementary slackness (λᵢ(Rx-c)ᵢ = 0):\n');
comp_slack = true;
for i = 1:Num_Links
    slack_product = lambda_final(i) * (link_loads(i) - c(i));
    slack_condition = abs(slack_product) < 1e-6;  % Should be close to zero
    fprintf('Link %d: λ = %.6f, (Rx-c) = %.6f, Product = %.9f, Satisfied: %s\n', i, lambda_final(i), link_loads(i) - c(i), slack_product, string(slack_condition));
    if ~slack_condition
        comp_slack = false;
    end
end
fprintf('   Overall complementary slackness: %s\n\n', string(comp_slack));

% 4. Verify stationarity: xᵢ = wᵢ/∑ⱼλⱼrⱼᵢ
fprintf('4. Stationarity condition (xᵢ = wᵢ/∑ⱼλⱼrⱼᵢ):\n');
stationarity = true;
for i = 1:Num_Flows
    links_used = find(R(:, i));
    sum_lambda = sum(lambda_final(links_used));
    expected_x = w(i) / sum_lambda;
    diff = abs(x_final(i) - expected_x);
    stationarity_i = diff < 1e-6;  % Should be very close
    
    fprintf('Flow %d: w = %.6f, sum(λ) = %.6f\n', i, w(i), sum_lambda);
    fprintf('Actual x = %.6f, Expected x = %.6f, Difference = %.9f, Satisfied: %s\n', x_final(i), expected_x, diff, string(stationarity_i));
    
    if ~stationarity_i
        stationarity = false;
    end
end
fprintf('Overall stationarity condition: %s\n\n', string(stationarity));

% 5. Overall optimality verification
fprintf('5. Overall optimality:\n');
fprintf('Primal feasibility: %s\n', string(primal_feasible));
fprintf('Dual feasibility: %s\n', string(dual_feasible));
fprintf('Complementary slackness: %s\n', string(comp_slack));
fprintf('Stationarity: %s\n', string(stationarity));
fprintf('ALL CONDITIONS SATISFIED: %s\n\n', string(primal_feasible && dual_feasible && comp_slack && stationarity));

% 6. Calculate and display the utility value
utility = sum(w .* log(x_final));
fprintf('6. Final utility value: %.6f\n', utility);

% Visualize the verification - show flows and capacities
figure;
bar_data = [link_loads, c];
bar(bar_data);
title('Link Loads vs. Capacities');
xlabel('Link');
ylabel('Rate');
legend('Link Load', 'Link Capacity');
grid on;
