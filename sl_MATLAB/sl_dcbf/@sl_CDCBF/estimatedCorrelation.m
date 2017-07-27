%> @file    estimatedCorrelation.m
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
%> @brief   File holds function for estimated correlation

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
function [ result_estimated ] = estimatedCorrelation(bt, Qbest, Rs , Wbest)
%% estimated correlation reconstruction  
    
    %> optimal source power
    Popt = 1/(min(eig(Qbest))); 
    %> singular value decomposition
    [U S V] = svd(Qbest); 
    %> optimal source orientation
    Oopt = U(:,end); 
    %> estimated source covariance matrix    
    eRs = Rs;

    %> Vector of source orientations
    Psi = zeros(6,2);   
    Psi(1:3,1) = Oopt(1:3);
    Psi(4:6,2) = Oopt(4:6);
    
    %> estimated source time course
    ePtbest = Psi' * Wbest' * bt;
    %> reduces estimated Rs to a 2x2 matrix
    eRs_reduced = Psi' * eRs * Psi;  
    %> estimated dual_power_correlation
    estimated_dual_power_correlation = (eRs_reduced(1,2))^2/(eRs_reduced(1,1)*eRs_reduced(2,2));
    %> estimated dual_amplitude_correlation
    estimated_dual_amplitude_correlation = sqrt(estimated_dual_power_correlation);
   
    
    result_estimated.ePtbest = ePtbest;
    result_estimated.eDualPowerCorr = estimated_dual_power_correlation;
    result_estimated.eDualAmplitudeCorr = estimated_dual_amplitude_correlation;
end

