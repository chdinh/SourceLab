function [X, Z, idx, pobj, options] = calculate(obj, M)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ltfatstart;
G = obj.m_ForwardSolution.data;
M = M.data;
norient = obj.m_norient;
maxit = obj.m_maxit;
tol = obj.m_tol;
lambda_l1 = obj.m_lambdal1;
lambda_l21 = obj.m_lambdal21;

assert(maxit > 1)

ntimes = size(M,2);
npoints = size(G,2)/norient;

options = [];

if ~isfield(options,'params')
    LW1 = ntimes/8;
    params{1}.a = 4; % Time shift.
    params{1}.M = ntimes; % Number of modulations.
    params{1}.L = ntimes;
    params{1}.g = gabtight(pgauss(ntimes,'width',LW1),params{1}.a,params{1}.M,params{1}.L);
    options.params = params;
end
params = options.params;

PhiT = obj.sparse_dgts(eye(ntimes),params,options);
Phi = PhiT';
ncoef = size(Phi,2);

if ~isfield(options,'L')
    iv = ones(npoints*norient,ntimes);
    v = iv*Phi;
    L = 0;
    it = 0;
    while it < 100
        it = it+1;
        disp(['Lipschitz estimation: iteration = ',num2str(it)])
        iv = real(v*PhiT);
        clear v;
        Gv = G*iv;
        clear iv;
        GtGv = G'*Gv;
        clear Gv;
        w = GtGv*Phi;
        clear GtGv;
        L = norm(w(:),'inf');
        v = w/L;
        clear w w2;
    end
    options.L = L;
    clear it v;
end
l = 1/options.L;

Z = zeros(npoints*norient, ncoef);

idx = 1:npoints*norient;
Y = Z;
t = 1;

for it=1:maxit
    Z0 = Z;
    idx0 = idx;
    Z = Y + G'*((M - G(:,idx)*real(Z*PhiT))*Phi*l);
    
    if norient == 1
        shrink = 1 - l*lambda_l1 ./ abs(Z);
        shrink = max(shrink, 0);
        idx = find(any(shrink,2));
        Z = Z(idx,:).*shrink(idx,:);
        clear shrink;

        l21 = sqrt(sum(abs(Z).^2,2));
        shrink = 1 - l*lambda_l21 ./ l21;
        shrink = max(shrink, 0);
        idx_l21 = find(shrink);
        idx = idx(idx_l21);
        Z = bsxfun(@times,Z(idx_l21,:),shrink(idx_l21));
    else
        l21 = reshape(sqrt(sum(reshape(abs(Z).^2,norient,[]),1))',[],ncoef);
        shrink = 1 - l*lambda_l1 ./ l21;
        shrink = kron(max(shrink, 0),ones(norient,1));
        idx = find(any(shrink,2));
        Z = bsxfun(@times,Z(idx,:,:),shrink(idx,:));

        l21 = sqrt(sum(reshape(sum(abs(Z).^2,2),norient,[]),1))';
        shrink = 1 - l*lambda_l21 ./ l21;
        shrink = kron(max(shrink, 0),ones(norient,1));
        idx_l21 = find(shrink);
        idx = idx(idx_l21);
        Z = bsxfun(@times,Z(idx_l21,:,:),shrink(idx_l21));
    end;

    clear shrink l21;
    
    Z_diff = zeros(npoints*norient, ncoef);
    Z_diff(idx,:) = Z;
    Z_diff(idx0,:) = Z_diff(idx0,:) - Z0;
    clear X0;
    
    tol_act = sqrt(sum(sum(abs(Z_diff).^2))) / sqrt(sum(sum(abs(Z).^2)));
    if  tol_act < tol
        disp('---------- Converged !!!')
        break
    end

    if mod(it,20)==0
        if norient == 1
            pobj = 0.5 * norm(M - G(:,idx)*real(Z*PhiT), 'fro')^2 + lambda_l21 * sum(sqrt(sum(abs(Z).^2,2))) + lambda_l1 * sum(sum(abs(Z)));
        else
            Ztemp = reshape(sum(reshape(abs(Z).^2,norient,[])),[],ncoef);
            pobj = 0.5 * norm(M - G(:,idx)*real(Z*PhiT), 'fro')^2 + lambda_l21 * sum(sqrt(sum(Ztemp,2))) + lambda_l1 * sum(sum(sqrt(Ztemp)));
            clear Ztemp
        end
        disp(['  in fista : iteration = ',num2str(it)]);
        disp(['           : pobj = ',num2str(pobj)]);
        disp(['           : tol_act = ',num2str(tol_act)]);
        disp(['           : size_AS = ',num2str(numel(idx))]);
    end

    t0 = t;
    t = (1.0 + sqrt(1 + 4*t^2)) * 0.5;
    Y = ((t0 - 1.0) / t) * Z_diff;
    Y(idx,:) = Y(idx,:) + Z;
    clear X_diff;
end

X = real(Z * PhiT);

if norient == 1
    pobj = 0.5 * norm(M - G(:,idx)*real(Z*PhiT), 'fro')^2 + lambda_l21 * sum(sqrt(sum(abs(Z).^2,2))) + lambda_l1 * sum(sum(abs(Z)));
else
    Ztemp = reshape(sum(reshape(abs(Z).^2,norient,[])),[],ncoef);
    pobj = 0.5 * norm(M - G(:,idx)*real(Z*PhiT), 'fro')^2 + lambda_l21 * sum(sqrt(sum(Ztemp,2))) + lambda_l1 * sum(sum(sqrt(Ztemp)));
    clear Ztemp
end
disp(['Final Energy : ',num2str(pobj)]);
obj.results.X = X;
obj.results.Z = Z;
obj.results.idx = idx;
end