function [result] = calculate(obj, p_Measurement, p_Dipole, p_Lambda)
%CALCULATE Summary of this function goes here
%   Detailed explanation goes here
    bt = p_Measurement.data;
    obj.m_matRb = cov(p_Measurement.data');   % covariant matrix from ssim (', because ssim = <Channel x time>)
    Rb = obj.m_matRb;
    
    result.Lambda = p_Lambda;
    result.Dipole = p_Dipole;
    

    iregRb = pinv(Rb + p_Lambda*eye(length(Rb))); 

    epsilon = obj.m_matRn;
    numberOfCombinations = obj.m_iNumLeadFieldCombinations;

    tic;            % start measuring computation time

    Z = zeros(numberOfCombinations,1);
    Idcs = zeros(numberOfCombinations,2);

    %% Seperate lead field matrix into lead field vectors L
    for i=1:numberOfCombinations
        [p_iIdx1, p_iIdx2] = sl_CeDCBF_regularized.getPointPair(obj.m_iNumSources, i);


        Idcs(i, :) = [p_iIdx1 p_iIdx2];


        %fprintf('Kombination %d: %d - %d \n', i, p_iIdx1, p_iIdx2);

        Ldual = sl_CeDCBF_regularized.getLeadFieldPair(obj.m_ForwardSolution.data, p_iIdx1, p_iIdx2);         % Leadfield Vectors (+1, da Lgesamt mit 1 beginnt)


        W = iregRb * Ldual * pinv(Ldual' * iregRb * Ldual);   % weighting matrix

        K = W'*epsilon*W*pinv(W'*Rb*W);    %     K = DSC * (Ldual'* (iC*epsilon*iC) * Ldual); 

        Z(i) = 1/(min(eig(K)));

        %warning off last;
    end;

 %% order and find Index
    [Z_sorted, Z_Idcs] = sort(Z);   %   Sortieren und alte Indeces beibehalten

    ordered_Idcs = Idcs(Z_Idcs,:);  %   der groesse nach geordnete Index-Kombinationen

    bestPseudoZ = sl_CDCBF.getBestZ_Scores( 50, obj.m_iNumSources , Z_Idcs, ordered_Idcs); % find the best pseudo Z-scores

    result.Zscore=Z_sorted;
    result.Idcs=ordered_Idcs;
    result.bestPseudoZ = bestPseudoZ;
    %% find dipol coordinates
     [dipol_coord, Z_coord, distance] = sl_CDCBF.getDistance( obj.m_ForwardSolution, bestPseudoZ, p_Dipole );
     result.dipol_coord = dipol_coord;
     result.Z_coord = Z_coord;
     result.bestDistance = distance;
     
    %%
    Ldual_best = sl_CeDCBF_regularized.getLeadFieldPair(obj.m_ForwardSolution.data, bestPseudoZ(1,2), bestPseudoZ(1,3));
    Wbest = iregRb * Ldual_best * pinv(Ldual_best' * iregRb * Ldual_best);
    result.Ptbest = Wbest'*bt;

    %%
    t  = toc;
    result.time = t;

end


