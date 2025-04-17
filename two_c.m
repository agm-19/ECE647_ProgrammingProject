% part2c.m — Verify optimality of flow rates from part 2b

% Load final values from previous run:
x_final = x_hist(:, end);
lambda_final = lambda_hist(:, end);

% Rebuild A matrix
topology;
A = zeros(Num_Links, Num_Flows);
for i = 1:Num_Flows
    for j = 1:Max_Links_On_Path
        link = Flow_Path(i,j);
        if link ~= -1
            A(link, i) = 1;
        end
    end
end

% === 1. Primal feasibility: A x ≤ C ===
Ax = A * x_final;
feasible = all(Ax <= Link_Capacity(:) + 1e-3);  % small tolerance

% === 2. Dual feasibility: lambda ≥ 0 ===
dual_feasible = all(lambda_final >= -1e-6);

% === 3. Stationarity: w_i / x_i = sum over lambda on path ===
stationarity_ok = true;
for i = 1:Num_Flows
    links = Flow_Path(i, Flow_Path(i,:) > 0);
    dual_sum = sum(lambda_final(links));
    lhs = Flow_Weight(i) / x_final(i);
    if abs(lhs - dual_sum) > 1e-3
        fprintf('❌ Flow %d: Stationarity mismatch. LHS=%.4f, RHS=%.4f\n', i, lhs, dual_sum);
        stationarity_ok = false;
    end
end

% === 4. Complementary slackness: λ_l * (A x - C)_l = 0 ===
slack = lambda_final .* (Ax - Link_Capacity(:));
comp_slack_ok = all(abs(slack) < 1e-3);

% === Final Result ===
fprintf('\n--- Verification Results ---\n');
fprintf('Primal Feasibility: %s\n', tern(feasible));
fprintf('Dual Feasibility:   %s\n', tern(dual_feasible));
fprintf('Stationarity:       %s\n', tern(stationarity_ok));
fprintf('Comp. Slackness:    %s\n', tern(comp_slack_ok));

if feasible && dual_feasible && stationarity_ok && comp_slack_ok
    fprintf('✅ All KKT conditions satisfied. Final flow is optimal.\n');
else
    fprintf('❌ Some conditions failed. Final flow may not be optimal.\n');
end

% Helper: ternary formatter
function out = tern(flag)
    out = '✅ YES';
    if ~flag, out = '❌ NO'; end
end
