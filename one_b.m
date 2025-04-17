% Ques. 1 (b)
clc; clear;

% Step sizes 
gammas = [0.01, 0.115, 0.05];  % small, large, just right
gamma_labels = {'Small', 'Large', 'Just Right'};

% Contour
[x1_grid, x2_grid] = meshgrid(-5:0.1:5, -5:0.1:5);
f_vals = f0(x1_grid, x2_grid);

for idx = 1:length(gammas)
    gamma = gammas(idx);
    x = [0; 0];            % Start at origin
    traj = x;              
    max_iter = 100;

    for k = 1:max_iter
        g = df0(x(1), x(2));    % Gradient using the configuration file
        x = x - gamma * g(:);   % Gradient descent
        traj = [traj x];        
    end

    %% Plot x1(k) and x2(k) vs iteration
    figure;
    plot(0:max_iter, traj(1,:), 'r-', 'DisplayName', 'x_1(k)');
    hold on;
    plot(0:max_iter, traj(2,:), 'b-', 'DisplayName', 'x_2(k)');
    title(sprintf('Evolution of x_1 and x_2 (%s Step Size)', gamma_labels{idx}));
    xlabel('Iteration'); ylabel('Value');
    legend show;
    grid on;

    %% Plot trajectory on contour plot
    figure;
    % --- Plot contour and trajectory ---
    [~, h_contour] = contour(x1_grid, x2_grid, f_vals, 50); hold on;
    set(h_contour, 'DisplayName', 'Contour lines');
    plot(traj(1,:), traj(2,:), 'k.-', 'DisplayName','Trajectory');
    plot(traj(1,1), traj(2,1), 'go', 'MarkerFaceColor','g', 'DisplayName','Start');
    plot(traj(1,end), traj(2,end), 'mo', 'MarkerFaceColor','m', 'DisplayName','End');
    x_min = traj(:, end);
    f_min = f0(x_min(1), x_min(2));
    plot(x_min(1), x_min(2), 'kp', 'MarkerFaceColor','y', 'MarkerSize', 10, 'DisplayName', 'Approx. Minimum');
    text(x_min(1)+0.3, x_min(2), sprintf('Min f ≈ %.2f', f_min), 'FontSize', 9, 'Color', 'k');
    title(sprintf('Contour Plot and Trajectory (%s Step Size)', gamma_labels{idx}));
    xlabel('x_1'); ylabel('x_2');
    legend show;
    axis equal; grid on;
    colorbar;
end
