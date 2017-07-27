% clear all;

A  = crand(4, 3); B = crand(8, 3); C = crand(7, 3);
% A  = rand(5, 4); B = rand(8, 4); C = rand(7, 4);

X = outer_product({A(:, 1), B(:, 1), C(:, 1), D(:, 1)}) + ...
    outer_product({A(:, 2), B(:, 2), C(:, 2), D(:, 2)}) + ...
    outer_product({A(:, 3), B(:, 3), C(:, 3), D(:, 3)});

[Factors_1, X_hat_1, amplitudes_1] = cfp(X, 3, 0);
[Factors_2, X_hat_2, amplitudes_2] = cfp(X, 3, 0, 0, 1);

err_1 = ho_norm( X_hat_1 - X ) / ho_norm( X );
err_2 = ho_norm( X_hat_2 - X ) / ho_norm( X );

% disp
mse = [err_1 err_2]
