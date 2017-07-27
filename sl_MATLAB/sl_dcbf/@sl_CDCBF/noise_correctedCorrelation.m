%> @file    noise_correctedCorrelation.m
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
%> @brief   File holds function noise_correctedCorrelation

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
function [ result_noise_corrected ] = noise_correctedCorrelation( Rb, Rn, Qbest, Wbest )
%NOISE_CORRECTEDCORRELATION Summary of this function goes here
%   Detailed explanation goes here
%% noise corrected correlation reconstruction
    %> singular value decomposition
    [U S V] = svd(Qbest); % eigenvalue decomposition
    %> optimal source orientation
    Oopt = U(:,end);   %Umin

    %> Vector of source orientations
    Psi = zeros(6,2);
    Psi(1:3,1) = Oopt(1:3);
    Psi(4:6,2) = Oopt(4:6); 
    

    %> estimated source covariance matrix
    nRs = Wbest' * Rb * Wbest; 
    %> K-matrix
    K = Wbest' * Rn * Wbest * pinv(Wbest' * Rb * Wbest);
    %> The noisefree or the 4×4 true dual-source vectorcovariance matrix Rs
    trueRs = (eye(size(K)) - K) * nRs;  
    %> The reduced 2x2 true dual-source vectorcovariance matrix Rs
    trueRs_reduced = Psi' * trueRs * Psi;
    %> noise-corrected dual_power_correlation
    nc_dual_power_correlation = (trueRs_reduced(1,2))^2/(trueRs_reduced(1,1)*trueRs_reduced(2,2)); % noise corrected correlation
    %> noise-corrected dual_amplitude_correlation
    nc_dual_amplitude_correlation = sqrt(nc_dual_power_correlation);    

    
    result_noise_corrected.ncDualPowerCorr = nc_dual_power_correlation;
    result_noise_corrected.ncDualAmplitudeCorr = nc_dual_amplitude_correlation;
    
end

