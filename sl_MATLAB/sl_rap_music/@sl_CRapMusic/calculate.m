function [p_InverseSolution p_CorrDipoleResults p_CorrValues] = calculate(obj, p_Measurement)

    idxMap = [];
    for i = 1:length(obj.m_ForwardSolution.SelectedSources)
        idxMap = [idxMap, obj.m_ForwardSolution.SelectedSources(1,i).idx];
    end
    
    %Init Results
    p_InverseSolution = sl_CInverseSolution(obj.m_ForwardSolution);
    p_CorrDipoleResults = sl_CCorrelatedDipoleMap();
    p_CorrValues = [];
    %Init Results End
    
    t_matLeadField = obj.m_ForwardSolution.data; %because obj.m_ForwardSolution.data is everytime evaluated

    [t_matPhi_s, t_r] = sl_CRapMusic.calcPhi_s(p_Measurement.data);

    if obj.m_iN < t_r
        t_iMaxSearch = obj.m_iN;
    else
        t_iMaxSearch = t_r;
    end

    t_matOrthProj = eye(obj.m_iNumChannels);
    t_matA_k_1 = zeros(obj.m_iNumChannels,t_iMaxSearch);

    %Stores result for plot
    obj.m_matCorrelationMap = zeros(obj.m_iNumLeadFieldCombinations, t_iMaxSearch);

    for r = 0:t_iMaxSearch-1
        t_matProj_Phi_s = t_matOrthProj * t_matPhi_s;
        t_matProj_LeadField = t_matOrthProj * t_matLeadField;

        [U,S,~] = svd(t_matProj_Phi_s);
        t_matU_B = U(:,1:rank(S));

        t_vecRoh = zeros(obj.m_iNumLeadFieldCombinations,1);

        parfor i = 0:obj.m_iNumLeadFieldCombinations-1
            idx1 = obj.m_PairIdxCombinations(i +1,1);
            idx2 = obj.m_PairIdxCombinations(i +1,2);

            t_matProj_G = sl_CRapMusic.getLeadFieldPair(t_matProj_LeadField, idx1, idx2);

            t_vecRoh(i+1) = sl_CRapMusic.subcorr(t_matProj_G, t_matU_B, false);%t_vecRoh holds the correlations roh_k
        end


        [t_val_roh_k, t_iMaxIdx] = max(t_vecRoh);
        obj.m_matCorrelationMap(:,r+1) = t_vecRoh;

        t_iIdx1 = obj.m_PairIdxCombinations(t_iMaxIdx,1);
        t_iIdx2 = obj.m_PairIdxCombinations(t_iMaxIdx,2);

        fprintf('Iteration: %d of %d; Correlation: %d; Position (Idx+1): %d - %d \n\n', r+1, t_iMaxSearch, t_val_roh_k, idxMap(t_iIdx1+1), idxMap(t_iIdx2+1));
        p_CorrValues = [p_CorrValues t_val_roh_k];

        %Calculations with the max correlated dipole pair G_k_1
        %MatrixX6T t_matG_k_1(m_pMappedMatLeadField->rows(),6);
        t_matG_k_1 = sl_CRapMusic.getLeadFieldPair(t_matLeadField, t_iIdx1, t_iIdx2);

        %MatrixX6T t_matProj_G_k_1(t_matOrthProj.rows(), t_matG_k_1.cols());
        t_matProj_G_k_1 = t_matOrthProj * t_matG_k_1;%Subtract the found sources from the current found source
        %MatrixX6T t_matProj_G_k_1(t_matProj_LeadField.rows(), 6);
        %getLeadFieldPair(t_matProj_LeadField, t_matProj_G_k_1, t_iIdx1, t_iIdx2);


%                t_matProj_G_k_1 = sl_CRapMusic.getLeadFieldPair(t_matProj_LeadField, t_iIdx1, t_iIdx2);

        %Calculate source direction
        %source direction (p_pMatPhi) for current source r (phi_k_1)

        %Correlate the current source to calculate the direction
        [~, t_vec_phi_k_1] = sl_CRapMusic.subcorr(t_matProj_G_k_1, t_matU_B, true);
        
        %Save Results
        p_CorrDipoleResults.insert(idxMap(t_iIdx1+1), sl_CDipole(t_vec_phi_k_1(1:3)), idxMap(t_iIdx2+1), sl_CDipole(t_vec_phi_k_1(4:6)));
        
        p_InverseSolution.addActivation([idxMap(t_iIdx1+1) idxMap(t_iIdx2+1)], t_vec_phi_k_1(1:6), 'activation', t_val_roh_k);
        %Set return values
%                 p_pRapDipoles->insertSource(t_iIdx1, t_iIdx2, t_vec_phi_k_1.data(), t_val_roh_k);

        %Stop Searching when Correlation is smaller then the Threshold
        if t_val_roh_k < obj.m_dThreshold
            fprintf('Searching stopped, last correlation %f is smaller then the given threshold %f \n\n', t_val_roh_k, m_dThreshold);
            break;
        end

        % ToDo
        %Calculate A_k_1 = [a_theta_1..a_theta_k_1] matrix for subtraction of found source
        t_matA_k_1 = sl_CRapMusic.calcA_k_1(t_matG_k_1, t_vec_phi_k_1, r, t_matA_k_1);

        %Calculate new orthogonal Projector (Pi_k_1)
        t_matOrthProj = obj.calcOrthProj(t_matA_k_1);

    end
end

