%> @file    calculate.m
%> @author  Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	Februar, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2012 Peter Hoemmen. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File holdes calculate function for enhanced Dual-Core
%> Beamformer
%
% =========================================================================
%> @brief runs Algorithm
%>
%> The calculate function holds the complete algorithm of the DCBF
%> containing the estimation of the Pseudo-Z-Score of all combinations and the time course
%> reconstruction of the best dipole combination, as well as the
%> correlation quantification methods
%> 
%> @param obj The object itself.
%> @param p_Measurement Struct with Information about the MEG/EEG Measurement of the type sl_CMeasurement.
%> @param p_Dipole Information about the activated dipole pair.
%> @param p_Lambda Regularization Parameter
%> @param transcorr Trigger for transformed correlation reconstruction
%> (yes/no)
%>
%> @retval p_InverseSolution Inverse Solution for Activation Plot
%> @retval result Information about localized dipole pair such as
%> index, index of activated pair, z-sore, time course, estimated
%> correlation, transformed correlation, regularized correlation,
%> noise-corrected correlation and calculation time
% =================================================================
function [p_InverseSolution, result] = calculate(obj, p_Measurement, p_Dipole, p_Lambda, transCorr)
    %Init Results
    p_InverseSolution = sl_CInverseSolution(obj.m_ForwardSolution);
    %Init Results End

    %% For Simulator Data
    %     bt = p_Measurement.data;
    %     obj.m_matRb = cov(p_Measurement.data');   % covariant matrix from ssim (', because ssim = <Channel x time>)
    %     Rb = obj.m_matRb;
    %     Rn = obj.m_matRn;
    %     numberOfCombinations = obj.m_iNumLeadFieldCombinations;
    %     %Lead Field from forward solution
    %     t_matLeadField = p_Measurement.LeadField;

    %% for Real Data
    %> Measurement data
    bt = p_Measurement.Signal;
    %> Noise Only Estimate
    n = p_Measurement.Noise;
    % Signal covariance matrix
    obj.m_matRb = cov(bt');
    %> Signal covariance matrix
    Rb = obj.m_matRb;
    %> Noise Covariance Matrix
    Rn = cov(n');
    %> Number of dipole combinations
    numberOfCombinations = obj.m_iNumLeadFieldCombinations;
    %> Lead Field from forward solution
    t_matLeadField = p_Measurement.LeadField;
    
    %%    
    %> Inverse of signal covariance matrix
    iRb = pinv(Rb);	% inverse of covariant matrix
    %> Inverse of noise covariance matrix
    iRn = pinv(Rn);
    %> Inverse of signal covariance matrix multiplied with Lead Field
    iRb_L = iRb * t_matLeadField;
    %> Inverse of noise covariance matrix multiplied with Lead Field
    iRn_L = iRn * t_matLeadField;
    %> Pseudo-Z-Score of each dipole combination (Neural Activation)
    Z = zeros(numberOfCombinations,1);
    %> Indeces of dipole combinations
    Idcs = zeros(numberOfCombinations,2);
    %> Output/result of DCBF ( holds information about localized dipole pair such as
    %> index, index of activated pair, z-sore, time course, correlation
    %> and calculation time
    result = {};
   
    %> Computation time
    starttime = tic;            % start measuring computation time
   
    %% Calculate Neural Activation
    % For K-related Pseudo-Z-score
    parfor i=1:numberOfCombinations
        [p_iIdx1, p_iIdx2] = sl_CeDCBF.getPointPair(obj.m_iNumSources, i);
        Idcs(i, :) = [p_iIdx1 p_iIdx2];
        
        %> Dipole gain matrix of specific combination
        Ldual = obj.getLeadFieldPair(t_matLeadField, p_iIdx1, p_iIdx2);
        %> inverse dipole gain matrix of specific combination
        iRb_Ldual = obj.getLeadFieldPair(iRb_L, p_iIdx1, p_iIdx2);
        %> Inverse of Q-Matrix (proportional to source-power)
        Rs = pinv(Ldual'*iRb_Ldual); 
        %> Beamformer weighting matrix
        W = iRb_Ldual*Rs;   % weighting matrix
        %> K-Matrix (Represents SNR in source space)
        K = W'*Rn*W*pinv(W'*Rb*W);    %     K = DSC * (Ldual'* (iRb*Rn*iRb) * Ldual); 
        Z(i) = 1/(min(eig(K)));
    end;
    
%     % For Power pseudo-Z-Score
%     parfor i=1:numberOfCombinations
%         [p_iIdx1, p_iIdx2] = sl_CeDCBF.getPointPair(obj.m_iNumSources, i);
%         Idcs(i, :) = [p_iIdx1 p_iIdx2];
%         
%         %> Dipole gain matrix of specific combination
%         Ldual = obj.getLeadFieldPair(t_matLeadField, p_iIdx1, p_iIdx2);
%         %> inverse dipole gain matrix of specific combination
%         iRb_Ldual = obj.getLeadFieldPair(iRb_L, p_iIdx1, p_iIdx2);
%         %> inverse noise related dipole gain matrix of specific combination
%         iRn_Ldual = obj.getLeadFieldPair(iRn_L, p_iIdx1, p_iIdx2);
%         %> Inverse of Q-Matrix (proportional to source-power)
%         Rs = pinv(Ldual'*iRb_Ldual); 
%         
%         Rsn = pinv(Ldual'*iRn_Ldual);
%         Z(i) = trace(Rs)/trace(Rsn);
%     end;
    result.t(1,1) = toc(starttime);
    %% order and find Index with best Pseudo-Z
    %> Ordered Z-scores, Ideces of ordered Z-scores
    [Z_sorted, Z_Idcs] = sort(Z);   %   Sort and keep old indeces
    %> Ordered Indeces
    ordered_Idcs = Idcs(Z_Idcs,:);  %  Index Combinations ordered by size
    
    bestPseudoZ = sl_CDCBF.getBestZ_Scores( 50, obj.m_iNumSources , Z_Idcs, ordered_Idcs, obj.m_ForwardSolution); % find the best pseudo Z-scores

    result.ordered_Idcs = ordered_Idcs;
    result.bestPseudoZ = bestPseudoZ;
    result.Zscore = Z;
    
    
    %%
    %> Dipole gain matrix of combination with best pseudo-Z-score
    Ldual_best = sl_CeDCBF.getLeadFieldPair(t_matLeadField, bestPseudoZ(1,4), bestPseudoZ(1,5));
    %> Q-matrix of combination with best pseudo-Z-score
    Qbest = Ldual_best' * iRb * Ldual_best;
    %> Inverse of Qbest
    Rsbest = pinv(Qbest);
    %> Beamformer weight of combination with best pseudo-Z-score
    Wbest = iRb * Ldual_best * Rsbest;
    %> Time Course of combination with best pseudo-Z-score
    Ptbest = Wbest'*bt;
    
    %p_InverseSolution.addActivation([bestPseudoZ(1,2) bestPseudoZ(1,3)], Ptbest, 'activation', Z(bestPseudoZ(1,1)));

    result.InverseSolution = p_InverseSolution;
    
    result.Ptbest = Ptbest; 
    %> Correlation Coefficients
    [corr,p] = corrcoef(Ptbest');   % correlation coefficient of Ptbest'
    [i,j] = find(p==min(min(p)));
    correlation = corr(i,j);
    
    result.correlation.coeff = corr;
    result.correlation.corr = correlation;
    
    result.correlation.eCorr = sl_CeDCBF.estimatedCorrelation(bt,Qbest,Rsbest,Wbest);
    result.correlation.rCorr = sl_CeDCBF.regularizedCorrelation(bt, Ldual_best,Qbest, Rb, p_Lambda);
    result.correlation.tCorr = sl_CeDCBF.transformedCorrelation(bt, Rb, Qbest, Wbest, transCorr);
    result.correlation.ncCorr = sl_CeDCBF.noise_correctedCorrelation(Rb, Rn, Qbest, Wbest);
    %%
    result.t(1,2)=toc(starttime);
end

