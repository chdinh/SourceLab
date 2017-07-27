%> @file    sl_IInverseAlgorithm.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	Dezember, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh, Tim Kunze. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   ToDo File description
% =========================================================================
%> @brief   ToDo Summary of this class
%
%> ToDo detailed description
% =========================================================================
classdef sl_IInverseAlgorithm < sl_IAlgorithm
    %% sl_IInverseAlgorithm
    properties
        %> ToDo
        m_ForwardSolution;
    end
    
    methods (Abstract)
        %% calculate
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        result = calculate(obj);
        
        %% calcluateProbabilisticInverseSolution
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
%        result = calcluateProbabilisticInverseSolution(obj);
    end
    
    methods (Static)
        %% Type
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function type = Type()
            type = sl_Type.Inverse;
        end % Type
        
        %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            name = 'Inverse Algorithm';
        end % Name
    end % static methods
end % classdef