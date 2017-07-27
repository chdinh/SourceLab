function [coef] = sparse_dgts(obj,f,params,options)

% use_real = getoption(options,'use_real',false);
% sparse_mat = getoption(options,'sparse_mat',true);

use_real = false;
sparse_mat = false;

posnorm = find(any(f,1)); % find columns that have non-zero entries
my_nnz = length(posnorm);

coef = cell(length(params),1);

for ii = 1:length(params)
    p = params{ii};

    if use_real
        n_rows = (p.M/2+1)*(size(f,1)/p.a);
        dat = dgtreal(f(:,posnorm),p.g,p.a,p.M);
    else
        n_rows = (p.M)*(size(f,1)/p.a);
        dat = dgt(f(:,posnorm),p.g,p.a,p.M);
    end

    c = zeros(n_rows, size(f,2));
    c(:,posnorm) = reshape(dat, n_rows, my_nnz);
    coef{ii} = c;
end

coef = vertcat(coef{:});
