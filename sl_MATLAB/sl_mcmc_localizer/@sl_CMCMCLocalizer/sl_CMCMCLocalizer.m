%> @file    sl_CMCMCLocalizer.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	June, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2012 Christoph Dinh. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   ToDo File description
% =========================================================================
%> @brief   ToDo Summary of this class
%
%> ToDo detailed explanation
% =========================================================================
classdef sl_CMCMCLocalizer
    %SL_CMCMCLOCALIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %> ToDo
        m_currentProbabilisticInverseSolution
        %> ToDo
        m_connectedForwardSolution
        %> ToDo
        m_ListInverseAlgorithms
    end
    
    methods
        %% sl_CMCMCLocalizer Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param p_Solution ToDo
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CProbabilisticInverseSolution class.
        % =================================================================
        function obj = sl_CMCMCLocalizer(p_Solution, varargin)
            p = inputParser;
            p.addRequired('p_Solution', @(x)isa(x, 'sl_CForwardSolution') || isa(x, 'sl_CProbabilisticInverseSolution'))
            p.addOptional('fs', 1000, @(x)isscalar(x) && x > 0)
            p.parse(p_Solution, varargin{:});

            if nargin >= 1 && isa(p_Solution, 'sl_CMCMCLocalizer')%Copy constructor
                obj.m_connectedForwardSolution = p_Solution.m_connectedForwardSolution;
            else
                obj.m_connectedForwardSolution = p.Results.p_Solution;
                
                obj.m_currentProbabilisticInverseSolution = sl_CProbabilisticInverseSolution(obj.m_connectedForwardSolution);
                
                obj.init();
            end
        end % sl_CMCMCLocalizer
        
        %% init
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function init(obj)
            
        end % init
        
        %% sense
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function sense(obj)

        end % sense
        
        %% predict
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function predict(obj)
            obj.m_currentProbabilisticInverseSolution;
            
            
            newProbabilisticInverseSolution =  sl_CProbabilisticInverseSolution(obj.m_connectedForwardSolution);
            
            obj.m_currentProbabilisticInverseSolution = newProbabilisticInverseSolution;
        end % predict
        
        
    end
    
end

