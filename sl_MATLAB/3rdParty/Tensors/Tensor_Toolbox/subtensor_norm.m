function SDn = subtensor_norm(T, n)
% Computes from a tensor the Frobenius norms of all subtensors along dimension n.
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
% SDn = subtensor_norm(T, n)
%
% computes a vector with the frobenius norms of all possible
% subtensors of T along the dimension n. If T is an N - dimensional
% Tensor with the elements T(I1, I2, ..., IN) then a subtensors along 
% dimension n are build by keeping the In'th index of T fixed.
%
% Inputs: T - tensor
%         n - dimension
%         
% Output: SDn - Vector with norms of the n'th Subtensors of T

% get elements of subtensors
A = unfolding(T, n);

% compute Frobenius norms
for n = 1:size(A, 1)
    SDn(n) = sqrt(A(n, :)*A(n, :)');
end
