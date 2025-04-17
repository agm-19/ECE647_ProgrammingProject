% Ques 1. (c)
clc; clear;

gammas = [0.01, 0.11, 0.05];
gamma_labels = {'Too Small', 'Too Large', 'Just Right'};

[x1_grid, x2_grid] = meshgrid(-1:0.05:3, -1:0.05:3);
f_vals = f0(x1_grid, x2_grid);

for idx = 1:length(gammas)
    gamma = gammas(idx);
    x = [1; 1];  % Start in feasible region
    traj = x;

    for k = 1:100
        g = df0(x(1), x(2))';      % Gradient
        z = x - gamma * g;         % Gradient descent step

        % Project z using a helper function
        x = project_to_constraints(z);

        traj = [traj x];
    end

    %% Plot x1 and x2 evolution
    figure;
    plot(0:size(traj,2)-1, traj(1,:), 'r', 'DisplayName','x_1');
    hold on;
    plot(0:size(traj,2)-1, traj(2,:), 'b', 'DisplayName','x_2');
    title(sprintf('x_1 and x_2 vs Iterations (%s Step)', gamma_labels{idx}));
    xlabel('Iteration'); ylabel('Value');
    legend show; grid on;

    %% Trajectory on contour plot
    figure;
    [~, h_contour] = contour(x1_grid, x2_grid, f_vals, 50); hold on;
    set(h_contour, 'DisplayName', 'Contour lines');
    plot(traj(1,:), traj(2,:), 'k.-', 'DisplayName','Trajectory');
    plot(traj(1,1), traj(2,1), 'go', 'MarkerFaceColor','g', 'DisplayName','Start');
    plot(traj(1,end), traj(2,end), 'mo', 'MarkerFaceColor','m', 'DisplayName','End');

    x_min = traj(:, end);
    f_min = f0(x_min(1), x_min(2));
    plot(x_min(1), x_min(2), 'kp', 'MarkerFaceColor','y', 'MarkerSize', 10, 'DisplayName', 'Approx. Minimum');
    text(x_min(1)+0.2, x_min(2), sprintf('Min f ≈ %.2f', f_min), 'FontSize', 9);

    title(sprintf('Projected Gradient Trajectory (%s Step)', gamma_labels{idx}));
    xlabel('x_1'); ylabel('x_2');
    legend show; axis equal; grid on; colorbar;
end

%% Projection Subroutine
function x_proj = project_to_constraints(x)
    x = max(x, 0);  % Project to non-negative orthant
    % Iterate toward feasible region if constraints violated
    while (2*x(1) + x(2) < 3) || (x(1) + 2*x(2) < 3)
        % Move slightly in feasible direction
        grad = [2*x(1) + x(2) - 3; x(1) + 2*x(2) - 3];
        x = x + 0.01 * [1; 1] .* (grad < 0); 
        x = max(x, 0);  % Enforce non-negativity again
    end
    x_proj = x;
end
