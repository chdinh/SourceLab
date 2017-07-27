function [Factors, X_hat, amps] = cfp(X, d, sjd, odr, bm)
% [Factors, X_hat, amps] = cfp(X, d)
%
% R-D closed form PARAFAC according to [1, 2]. The normalization is done 
% according to [3] i.e. the component vectors are normalized to unit norm,
% and the amplitudes are found in amps. The PARAFAC components are sorted 
% with descending amplitudes (in absolute value).
%
% Inputs:  X   - tensor
%          d   - number of sources
%
% Optional Inputs:         
%          sjd - switch for using JD performance as selection criterion 
%                (dafault is 0 --> minimum reconstruction error)
%          odr - switch for using HOOI for dimensionality reduction (default is 0)
%          bm  - switch for best match option (default is 0)
%                (Attention --> this is only applicable for small number of 
%                dimensions --> with bm = 1 the option sjd is automatically 0!)
% 
% Outputs: Factors - PARAFAC Factors
%          X_hat   - The PARAFAC fit for tensor X
%          amps    - PARAFAC amplitudes
%
% Requirements:
%     Toolboxes: Tensor_Toolbox, PARAFAC Toolbox
%     Functions: pick, normalize_parafac 
% 
% Author(s):
%     Martin Weis, Communications Resarch Lab, TU Ilmenau
%
% References:
%   [1] F. Roemer and M. Haardt, "A closed-form solution for parallel
%   factor (PARAFAC) analysis," in Proc. IEEE Int. Conf. Acoust., 
%   Speech, and Signal Processing (ICASSP), (Las Vegas, NV), pp. 2365-2368, 
%   Apr. 2008.
%
%   [2] F. Roemer and M. Haardt, "A closed-form solution for multilinear
%   PARAFAC decompositions," in Proc. 5-th IEEE Sensor Array and 
%   Multichannel Signal Processing Workshop (SAM 2008), 
%   (Darmstadt, Germany), pp. 487 - 491, July 2008.
%
%   [3] M.Weis and F.Roemer and M. Haardt and D.Jannek and P.Husar, "Multi-
%   dimensional Space-Time_Frequency Component Analysis of Event Related Data
%   Using Closed-Form PARAFAC," in Proc. IEEE Int. Conf. Acoust., 
%   Speech, and Signal Processing (ICASSP), (Taipei, Taiwan), To be
%   Published.
%
%   Date:
%      March 25, 2009
%
% $Revision: 1.01$  $Date: 2009/08/06$

%-----------------------------Inits----------------------------------------
X_sizes = size(X);
R = length(X_sizes);
N_est = 0;
if nargin < 3
    sjd = 0;
    odr = 0;
    bm = 0;
elseif nargin < 4
    odr = 0;
    bm = 0;
elseif nargin < 5
    bm = 0;
end

%% make HOSVD and cut it
if odr == 1 
    [U_Cell, T_red] = opt_dimred(X, d);
    S = core_tensor(T_red, U_Cell);
else
    [S, U_Cell] = hosvd(X);
    [S, U_Cell] = cuthosvd(S, U_Cell, d);
end

%% determine all possible JD Problems 
kl_perms = nchoosek(1:R, 2);   % all posible combinations for k and l --> R*(R-1)/2
under_det = find(X_sizes < d); % find underdetermined dimensions
for n = 1:length(under_det)    % remove unsolvable JD problems
     [row_indis, col_indis] = find(kl_perms == under_det(n));
     kl_perms(row_indis, :) = [];
end

%% get Factor estimates from all possible JD Problems
F = cell(R, 2.*size(kl_perms, 1));
rec_error = zeros(1, 2.*size(kl_perms, 1));
jd_error = zeros(1, 2.*size(kl_perms, 1));
for JDC = 1:size(kl_perms, 1) % for each JD problem
    
    %% determine k and l and possible r values
    k = kl_perms(JDC, 1);
    l = kl_perms(JDC, 2);
    r_values = 1:R;
    r_values(r_values == k) = [];
    r_values(r_values == l) = [];
    
    %% determine S_{k, l, (n)} --> ref [2] equation 6
    S_kl = S;
    for r = r_values
        S_kl = nmode_product(S_kl, U_Cell{r}, r);
    end
    
    %% create all slices S_{k, l, (n)} --> ref[2] equation 8
    S_kln = permute(S_kl, [k, l, r_values]);
    S_kln = S_kln(:, :, :);
    
    %% determine condition numbers for all slices S_{k, l, (n)}
    N_Slices = size(S_kln, 3);
    S_kln_cond_numbers = zeros(1, N_Slices);
    for n = 1:N_Slices
        S_kln_cond_numbers(n) = cond( S_kln(:, :, n) ); % old version: S_kln_cond_numbers(k) = cond( S_kln(:, :, n) );
    end
    
    %% determine best (inverse) pivot slice --> minimum condition number
    [Value, pivot_index] = min(S_kln_cond_numbers);
    inv_pivot_slice = inv( S_kln(:, :, pivot_index) );
    
    %% determine S_{k, l, (n)}^rhs --> ref [2] equation 11
    S_kln_rhs = zeros( size(S_kln) );
    for n = 1:N_Slices
        S_kln_rhs(:, :, n) = S_kln(:, :, n) * inv_pivot_slice;
    end
    
    %% determine S_{k, l, (n)}^lhs --> ref [2] equation 12
    S_kln_lhs = zeros( size(S_kln) );
    for n = 1:N_Slices
        S_kln_lhs(:, :, n) = ( inv_pivot_slice * S_kln(:, :, n) ).';
    end
    
    %% solve JointDiag Problems
    if isreal(X)
        [D_k, T_k, rjd_err] = jointdiag(S_kln_rhs);
        [D_l, T_l, ljd_err] = jointdiag(S_kln_lhs);
    else
        [D_k, T_k, rjd_err] = jointdiag_c(S_kln_rhs);
        [D_l, T_l, ljd_err] = jointdiag_c(S_kln_lhs);
    end
    
    %% Generate estimates of all Factors F from S_kln_rhs
    N_est = N_est + 1;
    
    F{k, N_est} = U_Cell{k} * T_k;
    
    F_krp = zeros(N_Slices, d);
    for n = 1:N_Slices
        F_krp(n, :) = ( diag( D_k(:, :, n) ) .* diag( D_k(:, :, pivot_index) ) ).';
    end
    if length(r_values) > 1
        decomp_krp = fliplr( invkrp_Rd_hosvd( F_krp, fliplr(X_sizes(r_values)), odr ) );
        for n = 1:length(r_values)
            F{r_values(n), N_est} = decomp_krp{n};
        end
    else
        F{r_values, N_est} = F_krp;
    end
    
    jd_error(N_est) = rjd_err(end) ./ N_Slices;
    
    krp_order = fliplr( [fliplr(1:l-1), fliplr(l+1:R)] );
    F{l, N_est} = unfolding(X, l) * pinv( krp_Rd( { F{krp_order, N_est} } ).' );
    
    %% normalize estimate and sort components with ascending amplitudes
    [amplitudes, temp, X_hat] = normalize_parafac(X, { F{:, N_est} });
    for r = 1:R
        F{r, N_est} = temp{r};
    end
    rec_error(N_est) = ho_norm( X_hat - X ) / ho_norm( X );
    
    %% Generate estimates of all Factors F from S_kln_lhs  
    N_est = N_est + 1;
    
    F{l, N_est} = U_Cell{l} * T_l;
    
    F_krp = zeros(N_Slices, d);
    for n = 1:N_Slices
        F_krp(n, :) = ( diag( D_l(:, :, n) ) .* diag( D_l(:, :, pivot_index) ) ).';
    end
    if length(r_values) > 1
        decomp_krp = fliplr( invkrp_Rd_hosvd( F_krp, fliplr(X_sizes(r_values)), odr ) );
        for n = 1:length(r_values)
            F{r_values(n), N_est} = decomp_krp{n};
        end
    else
        F{r_values, N_est} = F_krp;
    end
    
    jd_error(N_est) = ljd_err(end) ./ N_Slices;
    
    krp_order = fliplr( [fliplr(1:k-1), fliplr(k+1:R)] );
    F{k, N_est} = unfolding(X, k) * pinv( krp_Rd( { F{krp_order, N_est} } ).' );
    
    %% normalize estimate and sort components with ascending amplitudes
    [amplitudes, temp, X_hat] = normalize_parafac(X, { F{:, N_est} });
    for r = 1:R
        F{r, N_est} = temp{r};
    end
    rec_error(N_est) = ho_norm( X_hat - X ) / ho_norm( X );
    
end

%% serch for best combination of factor matrices (if selected)
if (bm == 1) && (N_est > 0)
    
    % inits
    Factor_combis = pick(1:N_est, R, 'or');
    rec_error = size(Factor_combis, 1);
    
    % equalize permutation of component vectors
    for n = 1:size(Factor_combis, 1)
        
        % create cell array with factors
        Fac_combi = cell(1, R);
        for r = 1:R
            Fac_combi{r} = F{r, Factor_combis(n, r)};
        end
        
        % normalize and get reconstruction error
        [amplitudes, Fac, X_hat] = normalize_parafac(X, Fac_combi, 0);
        rec_error(n) = ho_norm( X_hat - X ) / ho_norm( X );
           
    end
    
    % generate output
    [temp, n_sel] = min(rec_error);
    Fac_combi = cell(1, R);
    for r = 1:R
        Fac_combi{r} = F{r, Factor_combis(n_sel, r)};
    end
    [amps, Factors, X_hat] = normalize_parafac(X, Fac_combi);
    return;
    
end

%% generate output
if isempty(kl_perms) > 0
    
    error('Too much Rank Deficiencies!!!');
    
else
    if sjd
        [temp, JDC_sel] = min(jd_error);
    else
        [temp, JDC_sel] = min(rec_error);
    end
        
    [amps, Factors, X_hat] = normalize_parafac(X, { F{:, JDC_sel} });
    
end
