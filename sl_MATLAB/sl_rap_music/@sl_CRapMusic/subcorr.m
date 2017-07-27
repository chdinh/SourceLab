function [t_dRetSigma_C, p_vec_phi_k_1] = subcorr(p_matProj_G, p_matU_B, p_bCalcDirection)
    if ~p_bCalcDirection 
        %Orthogonalisierungstest wegen performance weggelassen -> ohne is es viel schneller
        [t_matU_A, t_matSigma_A, ~] = svd(p_matProj_G);

        %lt. Mosher 1998 ToDo: Only Retain those Components of U_A and U_B that correspond to nonzero singular values
        %for U_A and U_B the number of columns corresponds to their ranks
        %reduce to rank only when directions aren't calculated, otherwise use the full t_matU_A_T
        t_matU_A_T_full = t_matU_A(:,1:rank(t_matSigma_A))';%rows and cols are changed, because of CV_SVD_U_T

        %Step 2: compute the subspace correlation
        t_matCor = t_matU_A_T_full*p_matU_B;%lt. Mosher 1998: C = U_A^T * U_B

        if (size(t_matCor,2) > size(t_matCor,1))
            t_matCor_H = t_matCor'; %for complex it has to be adjunct

            [~,t_matSigma_C,~] = svd(t_matCor_H);
        else                
            [~,t_matSigma_C,~] = svd(t_matCor);
        end

        t_dRetSigma_C = t_matSigma_C(1,1); %Take only the correlation of the first principal components
    else
        % Orthogonalisierungstest wegen performance weggelassen -> ohne is es viel schneller
        [U_A, sigma_A, V_A] = svd(p_matProj_G);

        U_A_T = U_A(:,1:6)';

        %lt. Mosher 1998 ToDo: Only Retain those Components of U_A and U_B that correspond to nonzero singular values
        %for U_A and U_B the number of columns corresponds to their ranks
        %-> reduce to rank only when directions aren't calculated, otherwise use the full U_A_T

        %Step 2: compute the subspace correlation
        t_matCor = U_A_T*p_matU_B;%lt. Mosher 1998: C = U_A^T * U_B

        %Step 4
        if (size(t_matCor,2) > size(t_matCor,1))
            Cor_H = t_matCor'; %for complex it has to be adjunct

            [~, sigma_C, V] = svd(Cor_H);

            U_C = V; %because t_matCor Hermitesch U and V are exchanged
        else
            [U_C, sigma_C, ~] = svd(t_matCor);
        end

        sigma_a_inv = zeros(6,6);
        sigma_a_inv(1:rank(sigma_A),:) = inv(sigma_A(1:rank(sigma_A),:));

        X = (V_A*sigma_a_inv)*U_C;%X = V_A*Sigma_A^-1*U_C

        %only for the maximum c - so instead of X->cols use 1
        X_max = X(:,1);
        norm_X = 1/(norm(X_max));

        %Multiply a scalar with an Array -> linear transform
        p_vec_phi_k_1 = X_max*norm_X;%u1 = x1/||x1|| this is the orientation

        %Step 3
        t_dRetSigma_C = sigma_C(1,1); %Take only the correlation of the first principal components

    end
end

