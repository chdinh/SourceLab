%> @file    noise_regularizedCorrelation.m
%> @author  Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	Februar, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Peter Hoemmen. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File holds function for regularized correlation reconstruction

% =================================================================
%> @brief calculates regularized correlation
%>
%> Calculates regularized correlation and regularized time courses for each of predefined regularization parameter p_Lambda.
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
function [ result_regularized ] = regularizedCorrelation(bt, Ldual_best,Qbest, Rb, p_Lambda )
%% regularized correlation reconstruction
    %> check if regularization parameter was set
    TF = isempty(p_Lambda);
    if TF == 1
        result_regularized = 'empty';
    else
        %> ptimal source power
        Popt = 1/(min(eig(Qbest))); % optimal source power
        %> singular value decomposition
        [U S V] = svd(Qbest); 
        %> optimal source orientation
        Oopt = U(:,end);  
        
        %> Vector of source orientations
        Psi = zeros(6,2);   % Vector of source orientations
        Psi(1:3,1) = Oopt(1:3);
        Psi(4:6,2) = Oopt(4:6);

        for i = 1 : length(p_Lambda)
            %> inverse of regularized covariance matrix
            iregRb = pinv(Rb + p_Lambda(i)*eye(length(Rb)));
            %> regularized weighting matrix
            rWbest = iregRb * Ldual_best * pinv(Ldual_best'*iregRb*Ldual_best);
            %> regularized time course
            rPtbest = rWbest' * bt;
            %> regularized source covariance matrix
            rRs = rWbest' * Rb * rWbest;
            %> reduced regularized source covariance matrix
            rRs_reduced = Psi' * rRs * Psi;  % reduces estimated Rs to a 2x2 matrix
            %> regularized dual_power_correlation
            r_estimated_dual_power_correlation = (rRs_reduced(1,2))^2/(rRs_reduced(1,1)*rRs_reduced(2,2));
            %> regularized dual_amplitude_correlation
            r_estimated_dual_amplitude_correlation = sqrt(r_estimated_dual_power_correlation);

            result_regularized{1,i}.rPtbest = rPtbest;
            result_regularized{1,i}.rDualPowerCorr = r_estimated_dual_power_correlation;
            result_regularized{1,i}.rDualAmplitudeCorr = r_estimated_dual_amplitude_correlation;
            result_regularized{1,i}.p_Lambda = p_Lambda(i);
            result_regularized{2,i} = p_Lambda(i);
        end;
    end;
end

