%> @file    sl_CSourceSpace.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	July, 2012
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
%> ToDo Detailed explanation
% =========================================================================

classdef sl_C3DOrientation < sl_C3DVector
    %SL_C3DORIENTATIONMATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  (Access = private)
        %> A matrix which contains x,y,z orientations
    end
    
    properties (Dependent = true)
        %> ToDo
        Magnitudes;
        %> ToDo
        Norm;
    end % properties (Dependent)
    
   
    methods
        %% sl_C3DOrientation Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_C3DOrientation class.
        % =================================================================
        function obj = sl_C3DOrientation(varargin)
            obj = obj@sl_C3DVector(varargin{:}); % call superclass constructor
            %obj.xyz = aaa;         % assign a property value
        end
        
        %% get.Magnitudes
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function matMagnitudes = get.Magnitudes(obj)
            matMagnitudes = zeros(size(obj.m_matSeriesData,1),1);
            for i = 1:size(obj.m_matSeriesData,1)
                matMagnitudes(i) = norm(obj.m_matSeriesData(i,:));
            end
        end
        
        %% get.Norm
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function matNormalizedOrientations = get.Norm(obj)
            matNormalizedOrientations = zeros(size(obj.m_matSeriesData));
            for i = 1:size(obj.m_matSeriesData,1)
                matNormalizedOrientations(i,:) = obj.m_matSeriesData(i,:)/norm(obj.m_matSeriesData(i,:));
            end
            
        end        
    end
    
    methods (Static)
        
        %% sl_Type 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param ToDo
        %>
        %> @return instance of the Type class.
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Vector;
        end % getType
        
        %% get.Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param ToDo
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            %% getName
            name = '3D Orientation';
        end % getName
                 
        %Methods in a separate file

    end % static methods
    
end

