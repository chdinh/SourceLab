function [T_red, error] = fast_dimred(T, R_new)
% Computes a fast (suboptimal) lower n - rank approximation of a tensor.
%
% |----------------------------------------------------------------
% | (C) 2006 TU Ilmenau, Communications Research Laboratory
% |
% |     Martin Weis
% |     
% |     Advisors:
% |        Dipl.-Ing. Giovanni Del Galdo
% |        Univ. Prof. Dr.-Ing. Martin Haardt
% |
% |     Last modifications: 06.20.2006
% |----------------------------------------------------------------
%
% [T_red, error] = fast_dimred(T, R_new)
%
% calculates the R_new n - rank approximation of T by setting the
% eigenvectors corresponding to the size(T) - R_New smallest
% singular values to zero. Note that this is not the best approximation
% in a least mean square sense, but it holds if the distance between
% the dominant singular values and the smaller ones is large enough.
% If R_new is only scalar, then all dimensions of T are reduced to the 
% same rank R_new.
%
% Inputs:  T     - tensor
%          R_new - vector of new n-ranks
%
% Outputs: T_red - rank R_new approximation of T
%          error - distance between T and T_red

% get dimensions
sizes = size(T);
dimension = length(sizes);

% expand R_new to a vector (if necessary)
if length(R_new) == 1
    R_new = R_new .* ones(1, dimension);
end

% get unfoldings
A_Cell = unfoldings(T);

% compute svd's of unfoldings
for n = 1:dimension
    [temp_1, temp_2, U_Cell{n}] = svd(A_Cell{n}', 0);
end

% delete vectors in U_Cell corresponding to the samlles singular values
R_new = R_new + 1;
for n = 1:dimension
    temp = U_Cell{n};
    temp(:, R_new(n):end) = 0;
    U_Cell{n} = temp;
end

% compute core tensor
S = nmode_product(T, U_Cell{1}', 1);
for n = 2:dimension
    S = nmode_product(S, U_Cell{n}', n);
end

% compute R_new n - rank approximation
T_red = reconstruct(S, U_Cell);

% compute error
error = ho_norm(T-T_red);
