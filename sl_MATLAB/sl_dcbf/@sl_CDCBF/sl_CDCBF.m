%> @file    sl_CDCBF.m
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
%> @brief   File used to show an example of class description
% =========================================================================
%> @brief   This class holds the functions of the DCBF
%
% =========================================================================
classdef sl_CDCBF < sl_CScanningInverseAlgorithm
    
    properties
        %> Number of Lead Field Sources
        m_iNumSources;
        %> Number of channels/sensors used in the measurement
        m_iNumChannels;
        
        %> Number of dipole combinations (= nchoosek(m_iNumSources,2))
        m_iNumLeadFieldCombinations;
        
        %> Noise Covariance Matrix    
        m_matRn;
        %> Signal Covariance Matrix
        m_matRb;  
        
        
        %> Stores subcorrelation results for plot
        m_matCorrelationMap;
        

    end
    
    methods
        % =================================================================
        %> @brief Class constructor
        %>
        %> More detailed description of what the constructor does.
        %>
        %> @param p_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
        %>
        %> @return instance of the class sl_CDCBF.
        % =================================================================
        function obj = sl_CDCBF(p_ForwardSolution)
            obj.m_ForwardSolution = p_ForwardSolution;
            
            obj.m_iNumSources = double(obj.m_ForwardSolution.numSources);
            obj.m_iNumChannels = double(obj.m_ForwardSolution.numChannels);
            
            obj.m_iNumLeadFieldCombinations = nchoosek(obj.m_iNumSources+1,2);
        end
        
        % =================================================================
        %> @brief estimation of noise-only part
        %>
        %> This part estimates an unbiased noise measurement needed for the
        %> by the DCBF to perform source localization and time course
        %> reconstruction
        %>
        %> @param obj The object itself.
        %> @param p_Measurement The MEG/EEG Measurement of the type sl_CMeasurement.
        % =================================================================
        function estimateNoise(obj, p_Measurement)
             if isa(p_Measurement, 'sl_CSimulator')
                 obj.m_matRn = cov(p_Measurement.data_noise');
             else
                 %% ToDo
                 obj.m_matRn = cov(p_Measurement.data');
             end
        end
        
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
        [result] = calculate(obj, p_Measurement, p_Dipole)
        
        
    end % methods
    
    methods (Static)
         
        % =================================================================
        [LeadField] = getLeadField(raw_LF,sensor)
         
        % =================================================================
        [Signal, Noise] = getSig(raw, start, stop, sensor)
        
        % =================================================================
        %> @brief gives Combination with best Z-Score
        %>
        %> Compares z-scores of all combinations and lists the numScores best
        %> combinations.
        %> 
        %> @param numScores Number of wanted output combinations
        %> @param numberOfDipoles Number of dipole sources
        %> @param z_Idcs Indices of combinations that were sorted by
        %> z-score
        %> @param ordered_Idcs Combinations that were sorted by z-score 
        %> @param t_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
        %>
        %> @retval bestPseudoZ Lists the numScores best combinations with the best pseudo-zscore
        %> first column = Index of ordered z-Score, second and thrird
        %> columns = dipolepair, fourth and fifth columns = Index of dipole pair 
        % =================================================================
        [ bestPseudoZ ] = getBestZ_Scores( numScores, numberOfDipoles , Z_Idcs, ordered_Idcs, t_ForwardSolution )
        
        % =================================================================
        %> @brief estimates correlation
        %>
        %> Calculates estimated correlation and estimated time course.
        %> 
        %> @param bt Measurement data.
        %> @param Q In calculate function calculated Q matrix.
        %> @param Rs In calculate function estimated source covariance matrix 
        %> @param W  In calculate function calculated weighting matrix
        %>
        %> @retval result_estimated Structure that holds estimated time
        %> course, estimated dual power correlatiion and estimated dual
        %> amplitude correlation
        % =================================================================
        [result_estimated] = estimatedCorrelation(bt, Q , Rs , W);
        
        % =================================================================
        %> @brief calculates regularized correlation
        %>
        %> Calculates regularized correlation and regularized time courses.
        %> 
        %> @param bt Measurement data.
        %> @param Ldual Dual gain matrix of the dipole combination.
        %> @param Q In calculate function calculated Q matrix.
        %> @param Rb Sensor covariance matrix from bt.
        %> @param regParam  Regularization Parameter. 
        %>
        %> @retval result_regularized Structure that holds regularized time
        %> course, regularized dual power correlatiion, regularized dual
        %> amplitude correlation and regularization parameter
        % =================================================================
        [result_regularized] = regularizedCorrelation(bt, Ldual, Q , Rb , regParam);
        % =================================================================
        %> @brief calculates correlation in frequency domain
        %>
        %> Transforms measurement into frequency domain and calculates correlation
        %> 
        %> @param bt Measurement data.
        %> @param Rb Sensor covariance matrix from bt.
        %> @param Q In calculate function calculated Q matrix.
        %> @param W  In calculate function calculated weighting matrix
        %> @param trigger States if transformed correlation reconstruction
        %> should be performed, or not
        
        %> @retval result_transformed Structure that holds transformed time
        %> course, transformed dual power correlatiion and transformed dual
        %> amplitude correlation
        % =================================================================
        [result_transformed] = transformedCorrelation(bt, Rb, Q, W, trigger);
        
        % =================================================================
        %> @brief estimats noise-corrected correlation
        %>
        %> Gives a noise-corrected estimation of the correlation
        %> 
        %> @param Rb Sensor covariance matrix from bt.
        %> @param Rn Noise covariance matrix from noise only signal
        %> @param Q In calculate function calculated Q matrix.
        %> @param W  In calculate function calculated weighting matrix
        
        %> @retval result_noise_corrected Structure that holds noise corrected time
        %> course, noise corrected dual power correlatiion and noise corrected dual
        %> amplitude correlation
        % =================================================================
        [result_noise_corrected] = noise_correctedCorrelation(Rb, Rn, Q, W);
        
        % =================================================================
        %> @brief constructs dipole gain matrix
        %>
        %> Constructs dipole gain matrix of a special combination from the
        %> lead field
        %> 
        %> @param p_matLeadField Lead Field from forward solution.
        %> @param p_iIdx1 Index of dipole one.
        %> @param p_iIdx2 Index of dipole two.
        %>
        %> @return instance of the class sl_CDCBF.
        % =================================================================
        function p_matLeadField_Pair = getLeadFieldPair(p_matLeadField, p_iIdx1, p_iIdx2)
            p_matLeadField_Pair = zeros(size(p_matLeadField,1),6);
            t_iOffset1 = (p_iIdx1 - 1)*3 +1; %MATLAB Issue 1 based Indexing
            p_matLeadField_Pair(:,1:3) = p_matLeadField(:, t_iOffset1:t_iOffset1+2);
            t_iOffset2 = (p_iIdx2 - 1)*3 +1; %MATLAB Issue 1 based Indexing
            p_matLeadField_Pair(:,4:6) = p_matLeadField(:, t_iOffset2:t_iOffset2+2);
        end
        
         % =================================================================
        %> @brief calculates all possible combinations
        %>
        %> Calculates all possible combinations a given number of dipole
        %> sources
        %> 
        %> @param p_matLeadField Lead Field from forward solution.
        %> @param p_iPoints Number of dipole sources.
        %> @param p_iCurIdx Variable Index from 1 to p_iPoints.
        %>
        %> @retval Indices of the dipoles in the combination
        % =================================================================
        function [p_iIdx1, p_iIdx2] = getPointPair(p_iPoints, p_iCurIdx)
            p_iCurIdx = p_iCurIdx - 1; %MATLAB Issue 1 based Indexing
            
            
            ii = p_iPoints*(p_iPoints+1)/2-1-p_iCurIdx;
            K = floor((sqrt(8*ii+1)-1)/2);

            p_iIdx1 = p_iPoints-1-K;
            p_iIdx2 = (p_iCurIdx-p_iPoints*(p_iPoints+1)/2 + (K+1)*(K+2)/2)+p_iIdx1;
            
            p_iIdx1 = p_iIdx1 + 1; %MATLAB Issue 1 based Indexing
            p_iIdx2 = p_iIdx2 + 1; %MATLAB Issue 1 based Indexing
        end
    end % methods (Static)
    
end