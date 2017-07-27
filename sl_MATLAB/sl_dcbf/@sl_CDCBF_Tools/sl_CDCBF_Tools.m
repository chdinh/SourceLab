%> @file    sl_CDCBF_Tools.m
%> @author  Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	March, 2012
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
%> @brief   This class holds analysis functions for the performance
%> evaluation of source localization methods.
%
% =========================================================================
classdef sl_CDCBF_Tools
    
    properties
    end
    
    methods
        % =================================================================
        %> @brief Class constructor
        %>
        %> More detailed description of what the constructor does.
        %>
        %> @return instance of the class sl_CDCBF_Tools.
        % =================================================================
        function obj = sl_CDCBF_Tools()
        end
    end
    
    methods (Static)
        % =================================================================
        %> @brief Calculates distance between activated dipoles and
        %> localized dipoles
        %>
        %> getDistance finds the distance between simulated and calculated
        %> dipoles. It lists the calculated Dipoles in the first two columns 
        %> ordered by best pseudo-Z-score from top to bottom (see function 
        %> bestPseudoZ)
        %> The last two columns of bestDistance list the distance between the
        %> calculated dipole and the simulated ones
        %> column three lists the distance of dipole in column one,
        %> column four lists the distance of dipole in column two
        %> 
        %> @param t_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
        %> @param bestPseudoZ Holds the 50 dipoles with best pseudo-Z-score
        %> @param p_Dipole Holds information about the activated dipole pair.
        %>
        %> @retval dipol_coord Lists coordinates of activated dipoles
        %> @retval Z_coord Lists coordinates of localized dipoles with best
        %> pseudo-Z-score
        %> @retval distance lists distances between best localized and
        %> activated dipole pair
        % =================================================================
        [dipol_coord, Z_coord, distance] = getDistance( t_ForwardSolution, bestPseudoZ, p_Dipole )

        % =================================================================
        %> @brief Calculates distance offset
        %>
        %> getOffset finds the distance between activated dipole in simulation 
        %> leadfeald and the closest dipole in the localization lead field.
        %> It is required that both lead fields are from the same forward
        %> solution as they have to be set in the same coordinate system
        %>
        %> @param t_ForwardSolutionLocalization This holds the Lead Field Matrix used for localization; of the type sl_CForwardSolution.
        %> @param p_Dipole Holds information about the activated dipole pair.
        %>
        %> @retval Offset Holds to distance values. The first value is the
        %> offset for dipole 1 and the second value is the offset for dipole
        %> 2
        % =================================================================
        [Offset] = getOffset(t_ForwardSolutionLocalization , p_Dipole)
    end % methods (Static)
end

