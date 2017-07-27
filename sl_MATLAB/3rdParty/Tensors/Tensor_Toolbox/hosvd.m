function [S, U_Cell, SD_Cell] = hosvd(T)
% Computes the higher order singular value decomposition of a tensor.
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
% [S, U_Cell, SD_Cell] = hosvd(T)
%
% computes the higher order singular value decomposition of T, such
% that T = S x1 U_Cell{1} x2 U_Cell{2} x3 ... xN U_Cell{N}; 
% Thereby N is the dimension of tensor T, and xn denotes the 
% n - mode product (type 'help nmode_product' for further informations). 
% All matrices U_Cell{n} are orthogonal.
% The core tensor S is of same size as T, and has the property of
% all - orthogonality. This means that the scalar product of two arbitrary
% subtensors of S is zero. SD_Cell is a cell array of n vectors containing
% the singular values of T.
%
% Input:   T       - tensor
% 
% Outputs: S       - core tensor
%          U_Cell  - cell array with matrices of eigenvectors
%          SD_Cell - cell array with vectors of singular values

% get dimensions
sizes = size(T);
dimension = length(sizes);

% get unfoldings
A_Cell = unfoldings(T);

% compute svd's of unfoldings
for n = 1:dimension
    [temp, SD_Cell{n}, U_Cell{n}] = svd(A_Cell{n}', 0);
end

% diagonalize SD_Cell
for n = 1:dimension
    SD_Cell{n} = diag(SD_Cell{n});
end

% compute core tensor
S = nmode_product(T, U_Cell{1}', 1); 
for n = 2:dimension
    S = nmode_product(S, U_Cell{n}', n); 
end
