% Ques. 1(d)
clc; clear;
gammas = [0.01, 0.2, 0.05];  % Too small, too large, just right
gamma_labels = {'Too Small', 'Too Large', 'Just Right'};
max_iters = 100;

% Create mesh for contour plot
[x1g, x2g] = meshgrid(0:0.05:3, 0:0.05:3);
f_vals = f0(x1g, x2g);

for gidx = 1:length(gammas)
    gamma = gammas(gidx);
    x = [1; 1];              % Initial feasible point
    lambda = [0; 0];         % Dual variables
    traj_x = x';
    traj_lambda = lambda';

    for k = 1:max_iters
        % Compute gradient at current x and lambda
        g = df0(x(1), x(2))';
        g(1) = g(1) - 2 * lambda(1) - lambda(2);
        g(2) = g(2) - lambda(1) - 2 * lambda(2);

        % Gradient descent on primal with projection
        x = max(x - 0.01 * g, 0);

        % Constraint violations
        g_lambda = [3 - 2*x(1) - x(2);
                    3 - x(1) - 2*x(2)];

        % Gradient ascent on dual with projection
        lambda = max(lambda + gamma * g_lambda, 0);

        % Store trajectories
        traj_x = [traj_x; x'];
        traj_lambda = [traj_lambda; lambda'];
    end

    % Plot contour with primal trajectory
    figure;
    contour(x1g, x2g, f_vals, 50); hold on;
    plot(traj_x(:,1), traj_x(:,2), 'k.-', 'DisplayName', 'Trajectory');
    plot(traj_x(1,1), traj_x(1,2), 'go', 'DisplayName','Start');
    plot(traj_x(end,1), traj_x(end,2), 'mo', 'DisplayName','End');
    title(['Primal Trajectory - ', gamma_labels{gidx}]);
    xlabel('x_1'); ylabel('x_2');
    legend; axis equal; grid on;

    % Plot x1, x2 evolution
    figure;
    subplot(2,1,1);
    plot(traj_x); title(['x_1, x_2 over Iterations - ', gamma_labels{gidx}]);
    legend('x_1','x_2'); grid on;

    % Plot lambda1, lambda2 evolution
    subplot(2,1,2);
    plot(traj_lambda); title(['\lambda_1, \lambda_2 over Iterations - ', gamma_labels{gidx}]);
    legend('\lambda_1','\lambda_2'); grid on;
end
