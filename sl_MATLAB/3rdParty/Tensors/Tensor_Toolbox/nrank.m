function out = nrank(T, n, tol)
% Computes the n - rank of a tensor.
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
% out = nrank(T, n, tol)
%
% calculates the dimension of the vectorspace spanned by the n - mode
% vectors of T. Thereby only singular values greater than tol are taken 
% into account.
%
% out = nrank(T, n) chooses tol near eps
%
% Inputs: T   - tensor
%         n   - dimension
%         tol - tolerance (optional)
%
% Output: out - nrank of tensor T

% compute n'th nrank of tensor
if nargin == 3
    % with tol
    out = rank(unfolding(T, n), tol);
else
    % without tol
    out = rank(unfolding(T, n));
end
