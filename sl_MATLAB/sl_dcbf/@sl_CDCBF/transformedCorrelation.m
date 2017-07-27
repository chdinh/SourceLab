%> @file    transformedCorrelation.m
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
%> @brief   File holds function for correlation reconstruction in the
%> frequency domain

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
function [ result_transformed ] = transformedCorrelation( bt, Rb, Qbest, Wbest, trigger, Fs)
 %% transformed correlation reconstruction
    if strcmp (trigger,'no')
        result_transformed = 'empty';
    elseif strcmp (trigger,'yes')
        %> singular value decomposition
        [U S V] = svd(Qbest); % eigenvalue decomposition
        %> optimal source orientation
        Oopt = U(:,end);   %Umin

        %> Vector of source orientations
        Psi = zeros(6,2);
        Psi(1:3,1) = Oopt(1:3);
        Psi(4:6,2) = Oopt(4:6);

        %> Time Steps
        nTimeSteps = size(bt,2);
        %> Next power of 2 from length of y
        NFFT = 2^nextpow2(nTimeSteps); % Next power of 2 from length of y
        %> fast fourier transformed measurement data
        tbt = fft(bt,NFFT)/nTimeSteps;
        
        
        %> transformed time course
        tPtbest = Wbest' * tbt;
        %> transformed signal covariance matrix
        tRb = fft(Rb);
        %> transformed source covariance matrix
        tRs = Wbest' * tRb * Wbest;
        %> reduced transformed source covariance matrix
        tRs_reduced = Psi' * tRs * Psi;  % reduces estimated Rs to a 2x2 matrix
        %> transformed dual_power_correlation
        t_estimated_dual_power_correlation = (tRs_reduced(1,2))^2/(tRs_reduced(1,1)*tRs_reduced(2,2));
        %> transformed dual_amplitude_correlation
        t_estimated_dual_amplitude_correlation = sqrt(t_estimated_dual_power_correlation);

        result_transformed.tPtbest = tPtbest;
        result_transformed.tDualPowerCorr = t_estimated_dual_power_correlation;
        result_transformed.tDualAmplitudeCorr = t_estimated_dual_amplitude_correlation;
        
    end;
end

