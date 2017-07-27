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
%> @brief   File used to show an example of class description
% =========================================================================
%> @brief   Summary of this class goes here
%
%> Detailed explanation goes here
% =========================================================================
    
classdef sl_CeDCBF_regularized < sl_CDCBF
    %SL_CEDCBF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
    end
    
   methods
      % =================================================================
        function obj = sl_CeDCBF_regularized(p_ForwardSolution)
            obj = obj@sl_CDCBF(p_ForwardSolution);
        end

        % =================================================================
        [result] = calculate(obj, p_Measurement, t_ForwardSolution, p_Dipole, p_Lambda)
    end % methods
   
    methods (Static)

    end % methods (Static)
    
end

