function T_out = nmode_product(T_in, A, n)
% Computes the n - mode Product of a Tensor and a Matrix.
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
% T_out = nmode_product(T_in, A, n)
%
% computes the n - mode product of the tensor T_in and the matrix A.
% This means that all n - mode vectors of T are multiplied from the left
% with A.
%
% Inputs: T_in  - tensor
%         A     - matrix
%         n     - dimension
%
% Output: T_out - T_out = ( T_in  xn  A )

% compute new dimensions of T_out
new_size = size(T_in);
new_size(n) = size(A, 1);

% compute n - mode product
T_out = iunfolding( A * unfolding(T_in, n), n, new_size );

