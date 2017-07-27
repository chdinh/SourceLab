function M = hermitianunfold(T)
% HERMITIANUNFOLD   Compute "Hermitian unfolding" of a Hermitian tensor.
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
%   M = HERMITIANUNFOLD(T) is the so-called Hermitian unfolding of
%   the Hermitian tensor T which is computed in such a way that 
%   the matrix M becomes Hermitian itself.
%   T must be of length 2*R and exhibit a conjugate symmetry between the
%   first R and the last R indices. When S = SIZE(T), M will be of
%   size PROD(S(1:R)) x PROD(S(1:R)).
%   If T features the conjugate symmetry, M will be a Hermitian matrix.
%

twoR = ndims(T);
if mod(twoR,2) ~= 0
    error('Number of dimensions in T should be even.');
end
R = twoR / 2;

S = size(T);
if any(S(1:R) ~= S(R+1:2*R))
    error('T should be a Hermitian tensor.');
end


% First, compute R-unfolding of tensor.
T_R = unfolding(T,R);

% Then form blocks in which the last R indices are constant.
% Reshape these blocks to vectors and put them into the final matrix.
ColsPerBlock = prod(S(1:R-1));
M = zeros(prod(S(1:R)));
for n = 1:size(T_R,2) / ColsPerBlock
    block = T_R(:,(n-1)*ColsPerBlock+1:n*ColsPerBlock);
    M(:,n) = block(:);
end