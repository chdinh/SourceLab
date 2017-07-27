%> @file    sl_ITimeSeriese.m
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

classdef sl_ITimeSeries < sl_IValue
    %SL_ITIMESERIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties   (Access = protected)
        %for sake of speed no list for a time series: m_listSeries;
        %but put series data here
        %> ToDo
        m_matSeriesData;
        
        %> ToDo
        m_fSamplingFrequency;
    end
    
    properties (Dependent = true)
        %> ToDo
        data;
        %> ToDo
        fSamplingFrequency;
        %> ToDo
        iNumSamples;
    end
    
    methods
        
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
        function matData = get.data(obj)
            matData = obj.m_matSeriesData;
        end
        
        %% set.data
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_matCoordinate
        %>
        %> @return ToDo
        % =================================================================
        function set.data(obj,p_matCoordinate)
            p = inputParser;

            p.addRequired('p_matCoordinate', @(x)ismatrix(x) && (size(x,1) == 3 || size(x,2) == 3));
            p.parse(p_matCoordinate);

            if size(p.Results.p_matCoordinate,1) == 3 && size(p.Results.p_matCoordinate,2) ~= 3
                obj.m_matSeriesData = p.Results.p_matCoordinate';
            else
                obj.m_matSeriesData = p.Results.p_matCoordinate;
            end
        end
        
        
        %% get.SamplingFrequency
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function p_fSamplingFrequency = get.fSamplingFrequency(obj)
            p_fSamplingFrequency = obj.m_fSamplingFrequency;
        end
        
        %% set.fSamplingFrequency
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_fSamplingFrequency
        %>
        %> @return ToDo
        % =================================================================
        function set.fSamplingFrequency(obj, p_fSamplingFrequency)
            p = inputParser;
            
            p.addRequired('p_fSamplingFrequency', [], @(x)isscalar(x));
            p.parse(p_fSamplingFrequency);
            
            obj.m_fSamplingFrequency = p.Results.p_fSamplingFrequency;
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
            p_numSamples = size(obj.m_matSeriesData,1);
        end
        
    end
    
end

