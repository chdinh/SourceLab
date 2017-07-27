function T = hermitianinvunfold(M,S)
% HERMITIANINVUNFOLD    Compute inverse "Hermitian unfolding" of Hermitian matrix M
%
% |----------------------------------------------------------------
% | (C) 2006 TU Ilmenau, Communications Research Laboratory
% |
% |     Florian Römer
% |     
% |     Advisors:
% |        Dipl.-Ing. Giovanni Del Galdo
% |        Univ. Prof. Dr.-Ing. Martin Haardt
% |
% |     Last modifications: 08.25.2006
% |----------------------------------------------------------------
%
%  T = HERMITIANINVUNFOLD(M,S) computes the inverse of the Hermitian unfolding
%  operation given by HERMITIANUNFOLD. Consequently, M must be a square matrix.
%  The vector S contains the size of the final tensor T along the first R modes.
%  After the unfolding, T will therefore be of size [S,S].
%  The size of M must be PROD(S) x PROD(S).
%

SM = size(M);
R = length(S);

if (prod(S) ~= SM(1)) | (prod(S) ~= SM(2))
    error('M should be of size PROD(S) x PROD(S).');
end

% First reshape columns of matrix M into blocks and append them
% This will generate the R-unfolding of the tensor
ColsPerBlock = prod(S(1:R-1));
T_R = zeros(S(R),ColsPerBlock*prod(S));
for n = 1:SM(2)
    % Reshape n-th vector
    block = reshape(M(:,n), [S(R), ColsPerBlock]);
    % Fill into matrix. This is the same as (but faster than) T_R = [T_R,block];
    T_R(:,(n-1)*ColsPerBlock+1 : n*ColsPerBlock) = block;
end

% Then undo the R-unfolding
T = iunfolding(T_R, R, [S, S]);