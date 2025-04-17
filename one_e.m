% Ques. 1(e)
clc; clear;

x_b = [-1.8878; 0.5924];         % final x from part (b) 
x_c = [0.9982; 0.9959];          % final x from part (c)
x_d = [1.2996; 0.6075];          % final x from part (d) 
lambda_d = [0.9928; 4.4400];     % final lambda from part (d)

tol = 1e-3;  % tolerance for checking "close to zero"

%% === Part (b): Unconstrained ===
grad_b = df0(x_b(1), x_b(2))';
fprintf('--- Part (b): Unconstrained ---\n');
fprintf('Gradient norm at final x: %.4e\n', norm(grad_b));

if norm(grad_b) < tol
    fprintf('✅ Conclusion: Part (b) solution is optimal.\n\n');
else
    fprintf('❌ Conclusion: Part (b) solution is NOT optimal.\n\n');
end

%% === Part (c): Gradient Projection ===
fprintf('--- Part (c): Constrained (Projection) ---\n');
g1_c = 2*x_c(1) + x_c(2);
g2_c = x_c(1) + 2*x_c(2);

% Check all 4 constraints
feasible = g1_c >= 3 - tol && g2_c >= 3 - tol && x_c(1) >= 0 - tol && x_c(2) >= 0 - tol;

fprintf('2x1 + x2 = %.4f (>= 3?)\n', g1_c);
fprintf('x1 + 2x2 = %.4f (>= 3?)\n', g2_c);
fprintf('x1 = %.4f (>= 0?)\n', x_c(1));
fprintf('x2 = %.4f (>= 0?)\n', x_c(2));

if feasible
    fprintf('✅ Conclusion: Part (c) solution is feasible and satisfies constraints. Likely optimal.\n\n');
else
    fprintf('❌ Conclusion: Part (c) solution violates constraints. NOT optimal.\n\n');
end

%% === Part (d): Dual Gradient Method ===
fprintf('--- Part (d): Dual Gradient ---\n');
g1 = 3 - 2*x_d(1) - x_d(2);
g2 = 3 - x_d(1) - 2*x_d(2);
grad_f = df0(x_d(1), x_d(2))';

% Stationarity condition
stationarity = grad_f + lambda_d(1)*[-2; -1] + lambda_d(2)*[-1; -2];

% Complementary slackness
cs1 = lambda_d(1) * g1;
cs2 = lambda_d(2) * g2;

fprintf('Stationarity norm: %.4e\n', norm(stationarity));
fprintf('λ1 * g1 = %.4e\n', cs1);
fprintf('λ2 * g2 = %.4e\n', cs2);

if norm(stationarity) < tol && abs(cs1) < tol && abs(cs2) < tol && all(lambda_d >= -tol)
    fprintf('✅ Conclusion: Part (d) solution satisfies KKT. Optimal.\n');
else
    fprintf('❌ Conclusion: Part (d) solution does NOT satisfy KKT. Not optimal.\n');
end
