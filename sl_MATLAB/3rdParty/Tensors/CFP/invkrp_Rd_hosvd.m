function Factors = invkrp_Rd_hosvd(X,M,doba, corramp)

if prod(M) ~= size(X,1)
    error('X should be of size [PROD(M),N]!');
end
if nargin < 3
    doba = 0;
end
if nargin < 4
    corramp = 1;
end

N = size(X,2);

R = length(M);
Factors = cell(1,R);
for r = 1:R
    Factors{r} = zeros(M(r),N);
end

for n = 1:N
    Xn = X(:,n);
    Xn_t = reshape(Xn,M(end:-1:1));
    [S,U,SD] = hosvd(Xn_t);
    if doba && (R>2)
        [Uc,Xn_t] = opt_dimred(Xn_t,1);
        Sc = core_tensor(Xn_t,Uc);
    else
        [Sc,Uc] = cuthosvd(S,U,1);
    end
    Uc = Uc(end:-1:1);
    for r = 1:R
        Factors{r}(:,n) = Uc{r};
    end
    Factors{1}(:,n) = Factors{1}(:,n) * Sc;
end

if corramp
    rec = krp_Rd(Factors);
    ampl = mean(X ./ rec,1);
    Factors{1} = Factors{1}*diag(ampl);
end