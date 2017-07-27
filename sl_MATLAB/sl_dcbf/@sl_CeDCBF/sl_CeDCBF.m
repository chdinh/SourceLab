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
%> @brief   This class holds the functions of the eDCBF
%
% =========================================================================

classdef sl_CeDCBF < sl_CDCBF

    
    properties
        
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
        function obj = sl_CeDCBF(p_ForwardSolution)
            obj = obj@sl_CDCBF(p_ForwardSolution);
        end

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
        [t_InverseSolution, result] = calculate(obj, p_Measurement, p_Dipole, p_Lambda, trigger)
    end % methods
   
    methods (Static)

        
    end % methods (Static)
    
end
