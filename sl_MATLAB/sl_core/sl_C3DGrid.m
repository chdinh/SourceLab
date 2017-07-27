%> @file    sl_C3DGrid.m
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
classdef sl_C3DGrid < sl_ITimeSeries
    %% sl_C3DGrid    
    properties  (Access = private)
        %> A matrix which contains x1,y1,z1,x2,y2,z2... coordinates
        m_matCoordinates;
    end
    
    properties (Dependent = true)
        %> ToDo
        data;
        %> ToDo
        matX;
        %> ToDo
        matY;
        %> ToDo
        matZ;
        %> ToDo
        iNumCoordinates;
        %> ToDo
        iNumSamples;
    end
    
    methods
        %% sl_C3DGrid Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_C3DGrid class.
        % =================================================================
        function obj = sl_C3DGrid(varargin)
            p = inputParser;
            
            if nargin == 1 && isa(varargin{1}, 'sl_C3DPointMatrix') %Copy Constructor
                obj.m_matCoordinates = varargin{1}.m_matCoordinates;
                obj.m_fSamplingFrequency = varargin{1}.m_fSamplingFrequency;
            else
                p.addOptional('p_matCoordinates', [], @(x)ismatrix(x) && (~mod(size(x,1),3) || ~mod(size(x,2),3)));
                p.addOptional('p_fSamplingFrequency', [], @(x)isscalar(x));
                
                p.parse(varargin{:});

                if isfield(p.Results, 'p_matCoordinates')
                    if ~mod(size(p.Results.p_matCoordinates,1),3) && mod(size(p.Results.p_matCoordinates,2),3)
                        obj.m_matCoordinates = p.Results.p_matCoordinates';
                    else
                        obj.m_matCoordinates = p.Results.p_matCoordinates;
                    end                    
                end
                
                if isfield(p.Results, 'p_fSamplingFrequency')
                    obj.m_fSamplingFrequency = p.Results.p_fSamplingFrequency;                                        
                end
            end
        end
        
        %% setCoordinates
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_matCoordinates ToDo
        %>
        %> @return ToDo
        % =================================================================
        function obj = setCoordinates(obj,p_matCoordinates)
            if size(p_matCoordinates,1) == 3
                obj.m_matCoordinates = p_matCoordinates';
            elseif size(p_matCoordinates,2) == 3
                obj.m_matCoordinates = p_matCoordinates;
            else
                error('parameter Coordinates does not have the right format (Nx3)');
            end
        end
        
        %% get.data
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function matCoordinates = get.data(obj)
            matCoordinates = obj.m_matCoordinates;
        end
        
        %% get.matX
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.matX(obj)
            value = obj.m_matCoordinates(:,1:3:size(obj.m_matCoordinates,2));
        end
        
        %% get.matY
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.matY(obj)
            value = obj.m_matCoordinates(:,2:3:size(obj.m_matCoordinates,2));
        end
        
        %% get.matZ
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.matZ(obj)
            value = obj.m_matCoordinates(:,3:3:size(obj.m_matCoordinates,2));
        end
        
        %% get.iNumSamples
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================

        function p_numSamples = get.iNumSamples(obj)
            p_numSamples = size(obj.m_matCoordinates,1);
        end
        
        %% get.iNumCoordinates
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function p_numPoints = get.iNumCoordinates(obj)
            p_numPoints = size(obj.m_matCoordinates,2)/3;
        end
 
    end
    
    methods (Static)
        
        %% valType
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param ToDo
        %>
        %> @return ToDo
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Matrix;
        end % getType
        
        %% Name()
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
            name = '3D Grid';
        end % getName
                 
        %Methods in a separate file

    end % static methods
    
end

