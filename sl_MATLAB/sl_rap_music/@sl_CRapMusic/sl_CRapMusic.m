%> @file    sl_CRapMusic.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File used to show an example of class description
% =========================================================================
%> @brief   Summary of this class goes here
%
%> Detailed explanation goes here
% =========================================================================
classdef sl_CRapMusic < sl_CScanningInverseAlgorithm
    
    properties
        m_iN;
        m_dThreshold;
        
        m_iNumPoints;
        m_iNumChannels;
        
        m_iNumLeadFieldCombinations;
        m_PairIdxCombinations;
        
        %> Stores subcorrelation results for plot
        m_matCorrelationMap;
    end
    
    methods
        % =================================================================
        function obj = sl_CRapMusic(p_ForwardSolution, p_iN, p_dThr)
            %ToDo Grid has to be part of the forward solution
            
            obj.m_iN = p_iN;
            obj.m_dThreshold = p_dThr;
            obj.m_ForwardSolution = p_ForwardSolution;
            
            obj.m_iNumPoints = obj.m_ForwardSolution.numSources;
            obj.m_iNumChannels = obj.m_ForwardSolution.numChannels;
            
            obj.m_iNumLeadFieldCombinations = nchoosek(obj.m_iNumPoints+1,2);
            
            obj.m_PairIdxCombinations = sl_CRapMusic.calcPairCombinations(obj.m_iNumPoints);
        end
        
        % =================================================================
        function [p_InverseSolution p_CorrDipoleResults p_CorrValues] = calcluateProbabilisticInverseSolution(obj, p_Measurement)
            %ToDo !!!!
            [p_InverseSolution p_CorrDipoleResults p_CorrValues] = obj.calculate(obj);
        end
        
        % =================================================================
        [p_InverseSolution p_CorrDipoleResults p_CorrValues] = calculate(obj, p_Measurement)
        
        % =================================================================
        function p_matOrthProj = calcOrthProj(obj, p_matA_k_1)
            %Calculate OrthProj=I-A_k_1*(A_k_1'*A_k_1)^-1*A_k_1' //Wetterling -> A_k_1 = Gain

            t_matA_k_1_tmp = p_matA_k_1'*p_matA_k_1;%A_k_1'*A_k_1 = A_k_1_tmp -> A_k_1' has to be adjoint for complex

            t_size = size(t_matA_k_1_tmp,2);

            while ~det(t_matA_k_1_tmp(1:t_size,1:t_size))
                t_size = t_size-1;
            end

            t_matA_k_1_tmp_inv = zeros(size(t_matA_k_1_tmp));

            t_matA_k_1_tmp_inv(1:t_size,1:t_size) = inv(t_matA_k_1_tmp(1:t_size,1:t_size));%(A_k_1_tmp)^-1 = A_k_1_tmp_inv
            

            t_matA_k_1_tmp = p_matA_k_1*t_matA_k_1_tmp_inv;%(A_k_1*A_k_1_tmp_inv) = A_k_1_tmp


            t_matA_k_1_tmp2 = t_matA_k_1_tmp*p_matA_k_1';%(A_k_1_tmp)*A_k_1' -> here A_k_1' is only transposed - it has to be adjoint


            I = eye(obj.m_iNumChannels,obj.m_iNumChannels);

            p_matOrthProj = I-t_matA_k_1_tmp2; %OrthProj=I-A_k_1*(A_k_1'*A_k_1)^-1*A_k_1';
        end
        
    end
    
    methods (Static)

        % =================================================================
        function p_matA_k_1 = calcA_k_1(	p_matG_k_1, p_matPhi_k_1, p_iIdxk_1, p_matA_k_1)
            %Calculate A_k_1 = [a_theta_1..a_theta_k_1] matrix for subtraction of found source
            t_vec_a_theta_k_1 = p_matG_k_1*p_matPhi_k_1; % a_theta_k_1 = G_k_1*phi_k_1   this corresponds to the normalized signal component in subspace r

            p_matA_k_1(:,p_iIdxk_1+1) = t_vec_a_theta_k_1;
        end
        
        % =================================================================
        [t_dRetSigma_C, p_vec_phi_k_1] = subcorr(p_matProj_G, p_matU_B, p_bCalcDirection)
       
        % =================================================================
        function p_matLeadField_Pair = getLeadFieldPair(p_matLeadField, p_iIdx1, p_iIdx2)
            p_matLeadField_Pair = zeros(size(p_matLeadField,1),6);
            t_iOffset1 = p_iIdx1*3 +1;
            p_matLeadField_Pair(:,1:3) = p_matLeadField(:, t_iOffset1:t_iOffset1+2);
            t_iOffset2 = p_iIdx2*3 +1;
            p_matLeadField_Pair(:,4:6) = p_matLeadField(:, t_iOffset2:t_iOffset2+2);
        end
        
        % =================================================================
        function [t_pMatPhi_s, t_r] = calcPhi_s(p_matMeasurement)
            if (size(p_matMeasurement,2) > size(p_matMeasurement,1))
                t_matF = p_matMeasurement*p_matMeasurement';
            else
                t_matF = p_matMeasurement;
            end
            
            [U,S,~] = svd(t_matF);

            t_r = rank(S);

            t_pMatPhi_s = U(:, 1:t_r);
        end

        % =================================================================
        function matPairCombinations = calcPairCombinations(p_iNumPoints)
            %ToDo Grid has to be part of the forward solution
            
            t_iNumCombinations = nchoosek(p_iNumPoints+1,2);
            
            matPairCombinations = zeros(t_iNumCombinations,2);
            
            parfor i = 0:t_iNumCombinations-1
                [idx1, idx2] = sl_CRapMusic.getPointPair(p_iNumPoints, i);
                
                matPairCombinations(i+1,:) = [idx1, idx2];
            end
        end 
        
        % =================================================================
        function [p_iIdx1, p_iIdx2] = getPointPair(p_iPoints, p_iCurIdx)
            ii = p_iPoints*(p_iPoints+1)/2-1-p_iCurIdx;
            K = floor((sqrt(8*ii+1)-1)/2);

            p_iIdx1 = p_iPoints-1-K;
            p_iIdx2 = (p_iCurIdx-p_iPoints*(p_iPoints+1)/2 + (K+1)*(K+2)/2)+p_iIdx1;
        end
        
    end
    
end
