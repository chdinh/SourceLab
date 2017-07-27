%> @file    sl_C3DPoint.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh. All rights reserved.
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
classdef sl_C3DPoint < sl_C3DVector
    
    properties (Access = private)
        %> A vector which contains x,y,z coordinate and time steps
        %m_matSeriesData = [0, 0, 0];
    end
    
    properties (Dependent = true)

    end
    
    methods
        %% sl_C3DPoint Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_C3DPoint class.
        % =================================================================
        
        function obj = sl_C3DPoint(varargin)
            obj = obj@sl_C3DVector(varargin{:}); % call superclass constructor
            %obj.xyz = aaa;         % assign a property value
        end
        
        % %% plot 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        %> 
        %> @return ToDo
        % =================================================================
        function plot(obj, varargin)
            %% plot
            if ~isempty(obj.m_fSamplingFrequency)
                T = obj.iNumSamples/obj.m_fSamplingFrequency;
                t = linspace(0,T,obj.iNumSamples);

                subplot(3,1,1);
                plot(t, obj.m_matSeriesData(:,1)');
                title('X coordinate Time Series');
                xlabel('Time [s]')
                ylabel('Value');
                
                subplot(3,1,2);
                plot(t, obj.m_matSeriesData(:,2)');
                title('Y coordinate Time Series');
                xlabel('Time [s]')
                ylabel('Value');
                
                subplot(3,1,3);
                plot(t, obj.m_matSeriesData(:,3)');
                title('Z coordinate Time Series');
                xlabel('Time [s]')
                ylabel('Value');
            else
                subplot(3,1,1);
                plot(obj.m_matSeriesData(:,1)');
                title('X coordinate Time Series');
                xlabel('Samples')
                ylabel('Value');
                
                subplot(3,1,2);
                plot(obj.m_matSeriesData(:,2)');
                title('Y coordinate Time Series');
                xlabel('Samples')
                ylabel('Value');
                
                subplot(3,1,3);
                plot(obj.m_matSeriesData(:,3)');
                title('Z Coordinate Time Series');
                
                xlabel('Samples')
                ylabel('Value');
            end
        end

        %% %% plot3
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        %> 
        %> @return ToDo
        % =================================================================
        % 
        function plot3(obj, varargin)
            %% scatter
            if ~isempty(obj.m_fSamplingFrequency)
                T = obj.iNumSamples/obj.m_fSamplingFrequency;
                
                plot3(obj.m_matSeriesData(:,1)',obj.m_matSeriesData(:,2)',obj.m_matSeriesData(:,3)')
                
                text(obj.m_matSeriesData(1,1),obj.m_matSeriesData(1,2),obj.m_matSeriesData(1,3),['Start (T = ' num2str(0) 's)'],'fontsize',8); 
                text(obj.m_matSeriesData(obj.iNumSamples,1),obj.m_matSeriesData(obj.iNumSamples,2),obj.m_matSeriesData(obj.iNumSamples,3),['End (T = ' num2str(T) 's)'],'fontsize',8); 

                
                title('Coordinate Time Series');
                
                xlabel('x Value');
                ylabel('y Value');
                zlabel('z Value');
            else
                plot3(obj.m_matSeriesData(:,1)',obj.m_matSeriesData(:,2)',obj.m_matSeriesData(:,3)')
                
                text(obj.m_matSeriesData(1,1),obj.m_matSeriesData(1,2),obj.m_matSeriesData(1,3),'Start','fontsize',8); 
                text(obj.m_matSeriesData(obj.iNumSamples,1),obj.m_matSeriesData(obj.iNumSamples,2),obj.m_matSeriesData(obj.iNumSamples,3),'End','fontsize',8); 

                title('Coordinate Time Series');
                
                xlabel('x Value');
                ylabel('y Value');
                zlabel('z Value');
            end
        end
    end %methods
    
    methods (Static)
        
        % %% valType
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Vector;
        end % getType
        
        % %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            %% getName
            name = '3D Point';
        end % getName
                 
        %Methods in a separate file

    end % static methods
    
end

