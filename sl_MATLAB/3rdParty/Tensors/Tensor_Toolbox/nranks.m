function out = nranks(T, tol)
% Computes all n - ranks of a tensor.
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
% out = nranks(T, tol)
%
% calculates all dimensions of the vectorspaces spanned by the n - mode
% vectors of T. Thereby only singular values greater than tol are taken 
% into account.
%
% out = nrank(T) chooses tol near eps
%
% Inputs: T   - tensor
%         tol - tolerance (optional)
%
% Output: out - vector of all nranks of the tensor T

% get unfolding ( because nrank(T) = rank(Tn) )
temp = unfoldings(T);

% initialize output
out = zeros(1, length(temp));

% compute n - ranks
if nargin == 2
    % with tol
    for n = 1:length(temp)
        out(n) = rank(temp{n}, tol);
    end
else
    % without tol
    for n = 1:length(temp)
        out(n) = rank(temp{n});
    end
end
