clc; clear;

gammas = [0.01, 0.2, 0.05];
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
function x_proj = project_to_constraints(z)
    % Enforce non-negativity
    z = max(z, 0);

    % Check constraints
    if 2*z(1) + z(2) >= 3 && z(1) + 2*z(2) >= 3
        x_proj = z;
    else
        x_feas = [1;1];
        alpha = 0.9;
        for j = 1:50
            z = alpha * z + (1 - alpha) * x_feas;
            z = max(z, 0);  % ensure non-negativity
            if 2*z(1) + z(2) >= 3 && z(1) + 2*z(2) >= 3
                break;
            end
        end
        x_proj = z;
    end
end
