% Ques. 1(d)
clc; clear;

gammas = [0.01, 0.2, 0.05];
gamma_labels = {'Too Small', 'Too Large', 'Just Right'};

[x1_grid, x2_grid] = meshgrid(-1:0.05:3, -1:0.05:3);
f_vals = f0(x1_grid, x2_grid);

% Solver options for inner minimization
opts = optimoptions('fmincon','Display','off','Algorithm','sqp');

for idx = 1:length(gammas)
    gamma = gammas(idx);
    lambda = [0; 0];   % Initial dual variables (lambda1, lambda2)
    traj_x = [];
    traj_lambda = lambda;

    x0 = [1; 1];  % Feasible initial x

    for k = 1:100
        % Inner minimization: Minimize Lagrangian over x1,x2 >= 0
        lagrangian = @(x) f0(x(1), x(2)) + ...
            lambda(1)*(3 - 2*x(1) - x(2)) + ...
            lambda(2)*(3 - x(1) - 2*x(2));

        % Constraints: x1 >= 0, x2 >= 0
        x = fmincon(lagrangian, x0, [], [], [], [], [0 0], [], [], opts);
        x0 = x;  % use warm-start for next iteration

        % Dual variable update
        g1 = 3 - 2*x(1) - x(2);
        g2 = 3 - x(1) - 2*x(2);
        lambda = max(lambda + gamma * [g1; g2], 0);  % projection onto lambda >= 0

        traj_x = [traj_x x];
        traj_lambda = [traj_lambda lambda];
    end

    % Plot primal x1 and x2 evolution
    figure;
    plot(0:size(traj_x,2)-1, traj_x(1,:), 'r', 'DisplayName','x_1');
    hold on;
    plot(0:size(traj_x,2)-1, traj_x(2,:), 'b', 'DisplayName','x_2');
    title(sprintf('x_1 and x_2 vs Iterations (Dual: %s Step)', gamma_labels{idx}));
    xlabel('Iteration'); ylabel('Value');
    legend show; grid on;

    % Plot dual lambda evolution
    figure;
    plot(0:size(traj_lambda,2)-1, traj_lambda(1,:), 'r--', 'DisplayName','\lambda_1');
    hold on;
    plot(0:size(traj_lambda,2)-1, traj_lambda(2,:), 'b--', 'DisplayName','\lambda_2');
    title(sprintf('Dual Variables vs Iterations (%s Step)', gamma_labels{idx}));
    xlabel('Iteration'); ylabel('Lambda value');
    legend show; grid on;

    % Plot trajectory on contour
    figure;
    [~, h_contour] = contour(x1_grid, x2_grid, f_vals, 50); hold on;
    set(h_contour, 'DisplayName', 'Contour lines');
    plot(traj_x(1,:), traj_x(2,:), 'k.-', 'DisplayName','Trajectory');
    plot(traj_x(1,1), traj_x(2,1), 'go', 'MarkerFaceColor','g', 'DisplayName','Start');
    plot(traj_x(1,end), traj_x(2,end), 'mo', 'MarkerFaceColor','m', 'DisplayName','End');
    
    x_min = traj_x(:, end);
    f_min = f0(x_min(1), x_min(2));
    plot(x_min(1), x_min(2), 'kp', 'MarkerFaceColor','y', 'MarkerSize', 10, 'DisplayName', 'Approx. Minimum');
    text(x_min(1)+0.2, x_min(2), sprintf('Min f ≈ %.2f', f_min), 'FontSize', 9);

    title(sprintf('Dual Gradient Trajectory (%s Step)', gamma_labels{idx}));
    xlabel('x_1'); ylabel('x_2');
    legend show; axis equal; grid on; colorbar;
end
