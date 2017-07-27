function Tf = factorize_tensor(T,r)
% FACTORIZE_TENSOR   Compute a square-root factor of a Hermitian tensor
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
%    Tf = FACTORIZE_TENSOR(T) computes a square-root factor of
%        the tensor R, such that INNER_PRODUCT(Tf,conj(Tf),ndims(Tf)) == T.
%        This method only works if the tensor T is Hermitian. If
%        it is not, a warning is produced and the result is likely
%        to be inaccurate. The size of Tf along its last dimension is
%        chosen to be as small as possible without introducing errors.
%    Tf = FACTORIZE_TENSOR(T,P) only consideres P vectors along the last
%        mode of T. For small values of P this leads to a low-rank
%        approximation.
%


% First, compute the Hermitian unfolding of T ...
Tm = hermitianunfold(T);
% ... and check whether T was really Hermitian ...
threshold = 1e-10; % (We do not know where T comes from, so we have to set a threshold arbitrarily.)
if max(max(abs(Tm - Tm'))) > threshold
    % ... since if it is not, the square-root thing does not work.
    warning(sprintf('T is not Hermitian at an accuracy level of %g. The result will not be a factor of T at this accuracy level.',threshold));
end

S = size(T);
R = length(S) / 2;


% Now factorize the matrix. Compute an SVD ...
[U,Sig] = svd(Tm);

% ... if the rank was not given estimate it ...
if nargin < 2
    s = diag(Sig);
    % ... (as in RANK.M) ...
    tol = max(size(Tm)') * max(s) * eps;
    r = sum(s > tol);
else
    % Just in case the given rank is too high we truncate it.
    r = min(r,size(Sig,2));
end
% ... and then compute the square root-matrix with 
% only as many columns as the rank.
Tf = U * sqrt(Sig(:,1:r));

% Now reshape it into a tensor ... eh voilà!
Tf = iunfolding(Tf.',R+1,[S(1:R), r]);