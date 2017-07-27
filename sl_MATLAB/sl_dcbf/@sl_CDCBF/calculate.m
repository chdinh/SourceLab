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
%> @brief   File holdes calculate function
%
% =========================================================================
% =================================================================
%> @brief runs Algorithm
%>
%> The calculate function holds the complete algorithm of the DCBF
%> containing the estimation of the Pseudo-Z-Score of all combinations and the time course
%> reconstruction of the best dipole combination
%> 
%> @param obj The object itself.
%> @param p_Measurement The MEG/EEG Measurement of the type sl_CMeasurement.
%> @param p_Dipole information about the activated dipole pair.
%>
%> @retval result Information about localized dipole pair such as
%> index, index of activated pair, z-sore, time course, correlation
%> and calculation time
% =================================================================
function [result] = calculate(obj, p_Measurement, p_Dipole)
    %> Measurement data
    bt = p_Measurement.data;
    % Signal covariance matrix
    obj.m_matRb = cov(p_Measurement.data');   
    %> Signal covariance matrix
    Rb = obj.m_matRb;
    %> Noise Covariance Matrix
    Rn = obj.m_matRn;
    %> Number of dipole combinations
    numberOfCombinations = obj.m_iNumLeadFieldCombinations;
    
    %> Lead Field from forward solution
    t_matLeadField = obj.m_ForwardSolution.data;
    %> Inverse of signal covariance matrix
    iRb = pinv(Rb);	
    %> Inverse of signal covariance matrix multiplied with Lead Field
    iRb_L = iRb * t_matLeadField;
    
    %> Pseudo-Z-Score of each dipole combination
    Z = zeros(numberOfCombinations,1);
    %> Indeces of dipole combinations
    Idcs = zeros(numberOfCombinations,2);
    
    %> Output/result of DCBF ( holds information about localized dipole pair such as
    %> index, index of activated pair, z-sore, time course, correlation
    %> and calculation time
    result = {};
    result.dipoles = p_Dipole;
    
    %> Computation time
    starttime = tic;           
        %% Calculate Neural Activation
    for i=1:numberOfCombinations
        [p_iIdx1, p_iIdx2] = sl_CeDCBF.getPointPair(obj.m_iNumSources, i);
        Idcs(i, :) = [p_iIdx1 p_iIdx2];
   
        %> Dipole gain matrix of specific combination
        Ldual = obj.getLeadFieldPair(t_matLeadField, p_iIdx1, p_iIdx2);
        %> inverse dipole gain matrix of specific combination
        iRb_Ldual = obj.getLeadFieldPair(iRb_L, p_iIdx1, p_iIdx2);
        
        %> Q-matrix
        Q = Ldual'*iRb_Ldual;
        
        %> K-matrix
        K = pinv(Q) * (Ldual'* (iRb*Rn*iRb) * Ldual);    % "pinv" = Moore-Penrose pseudoinverse of matrix
        
        %> Pseudo-Z-Score of specific combination 
        Z(i) = 1/(min(eig(K)));

    end;
    result.t(1,1) = toc(starttime);
    %% order and find Index
    %> sorted Pseudo-Z-Scores of all combinations
    [Z_sorted, Z_Idcs] = sort(Z);   

    %> dipole indeces ordered by Pseudo-Z-Score
    ordered_Idcs = Idcs(Z_Idcs,:);  
  
    %> 50 combinations with best Pseudo-Z-Score
    bestPseudoZ = sl_CDCBF.getBestZ_Scores( 50, obj.m_iNumSources , Z_Idcs, ordered_Idcs, obj.m_ForwardSolution); % find the best pseudo Z-scores
    
    result.ordered_Idcs = ordered_Idcs;
    result.bestPseudoZ = bestPseudoZ;
    result.t(1,2)=toc(starttime);
    %%
    %> Dipole gain matrix of best combination
    Ldual_best = sl_CeDCBF.getLeadFieldPair(t_matLeadField, bestPseudoZ(1,4), bestPseudoZ(1,5));
    %> Q-matrix of best combination
    Qbest = Ldual_best' * iRb * Ldual_best;
    %> Strength of best combination
    Popt = 1/(min(eig(Qbest)));
    %> Singular value decomposition of Qbest
    [U S V] = svd(Qbest); 
    %> Optimum orientation of best combination (Umin)
    Oopt = U(:,end);   
    %> Time course of best combination
    Ptbest = Oopt*(Popt*iRb*Ldual_best*Oopt)'*bt;
    
    result.Ptbest = Ptbest;
    
    %> Correlation coefficient of Ptbest
    [corr,p] = corrcoef(Ptbest');  
    [i,j] = find(p==min(min(p)));
    %> correlation of Ptbest'
    correlation = corr(i,j);
    
    result.correlation = correlation;
    %%
    result.t(1,3)=toc(starttime);
end

