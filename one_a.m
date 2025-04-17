% Ques. 1 (a)
clc; clear;

%% 3D picture of the function. Uses the shared f0.m configuration file.
[x1, x2] = meshgrid(-5:0.1:5, -5:0.1:5); 
f_vals = f0(x1, x2); 

figure;
mesh(x1, x2, f_vals);
xlabel('x_1'); ylabel('x_2'); zlabel('f(x_1,x_2)');
title('3D Surface plot of f(x_1,x_2)');
grid on;

%% Plotting the function along 3 random directions from [0, 0]
origin = [0; 0];
dirs = randn(2, 3);           % 3 random directions
dirs = dirs ./ vecnorm(dirs); % normalizing them to unit vectors
t = linspace(-5, 5, 100);     % line parameter t

figure;
hold on;
colors = ['r', 'g', 'b'];
for i = 1:3
    d = dirs(:, i);                   % i'th direction
    x_t = origin(1) + t * d(1);       % x1(t)
    y_t = origin(2) + t * d(2);       % x2(t)
    f_t = f0(x_t, y_t);               % f(x(t))
    
    plot(t, f_t, colors(i), 'DisplayName', sprintf('Direction %d', i));
end
xlabel('t'); ylabel('f(x(t))');
title('Function along 3 random directions from [0,0]');
legend show;
grid on;
