function [amplitudes, CP_Factors_n, X_hat] = normalize_parafac(X, CP_Factors, sort_opt)

% NORMALIZE_PARAFAC estimates PARAFAC amplitudes jointly in a LMS sense.
%
%   [amplitudes, CP_Factors_n, X_hat] = normalize_parafac(X, CP_Factors)
%   estimates the PARAFAC amplitudes for the given PARAFAC decomposition
%   in CP_Factors. CP_Factors is a length-R cell array containing the 
%   estimates for each of the R factors. X is the original data tensor.
%   The function normalizes all CP_Factors to unit norm, estimates the
%   PARAFAC amplitudes and provides the estimate of the original data
%   tensor. The normailzed PARAFAC components are sorted in descending
%   order according to abs(amplitudes).
%
%   INPUTS: X          - original data tensor
%           CP_Factors - PARAFAC estimate of tensor X
%
%   Optional Inputs
%           sort_opt - sorts components with descending amplitudes (default is 1)
%
%   OUTPUTS: amplitudes   - estimated PARAFAC amplitudes 
%            CP_Factors_n - sorted and normalized PARAFAC components
%            X_hat        - reconstructed tensor
%
%   See also: solve_parafac
%
% Author(s):
%    Martin Weis, Communications Resarch Lab, TU Ilmenau
%
% Date:
%    March 25, 2009

% Inits
if nargin < 3
    sort_opt = 1;
end

% Extract Order, Rank and Dimensions
Order = length(CP_Factors);
R = size(CP_Factors{1}, 2);
dimensions = zeros(1, Order);
for n = 1:Order % for every dimension
    dimensions(n) = size(CP_Factors{n}, 1); % get size of n-th dimension
end

% Inits
vectors = cell(1, Order);
component_matrix = zeros(prod(dimensions), R);
CP_Factors_n = CP_Factors;

% normalize components and get matrix of vec( components )
for r = 1:R % for every component
    
    % get component vectors and normalize them
    for n = 1:Order % for every dimension
        vectors{n} = CP_Factors{n}(:, r) ./ norm(CP_Factors{n}(:, r), 'fro');
        CP_Factors_n{n}(:, r) = vectors{n};
    end

    % construct component (note that this will have unit norm!)
    r_component = outer_product(vectors);
    
    % save components in matrix
    component_matrix(:, r) = r_component(:);
    
end

% Get Least Squares Estimate of PARAFAC amplitudes
amplitudes = pinv(component_matrix) * X(:);

% sort components with descending amplitudes (in absolute value)
if sort_opt == 1
    
    [temp, sort_i] = sort(abs(amplitudes), 1, 'descend'); % sort amplitudes
    amplitudes = amplitudes(sort_i);
    
    % sort normalized components
    for n = 1:Order % for every dimension
        
        CP_Factors_n{n} = CP_Factors_n{n}(:, sort_i); % sort r-th component vectors
        
    end
    
    % reconstruct data tensor
    X_hat = reshape(sum(component_matrix(:, sort_i.') * amplitudes, 2), dimensions);
    
else
    
    % reconstruct data tensor
    X_hat = reshape(sum(component_matrix * amplitudes, 2), dimensions);
    
end
