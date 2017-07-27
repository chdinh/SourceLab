%> @file    sl_C3DVector.m
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
%> ToDo detailed explanation
% =========================================================================
classdef sl_C3DVector  < sl_ITimeSeries
    %SL_C3DVECTORSERIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent = true)
        %> ToDo
        X;
        %> ToDo
        Y;
        %> ToDo
        Z;
    end
    
    methods
        %% s1_C3DVector Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the s1_C3DVector class.
        % =================================================================
        function obj = sl_C3DVector(varargin)
            p = inputParser;
            
            if nargin == 1 && isa(varargin{1}, 'sl_C3DVector') %Copy Constructor
                obj.m_matSeriesData = varargin{1}.m_matSeriesData;
                obj.m_fSamplingFrequency = varargin{1}.m_fSamplingFrequency;
            else
                p.addOptional('p_Data', [], @(x)(size(x,1) == 3 || size(x,2) == 3));
                p.addOptional('p_fSamplingFrequency', [], @(x)isscalar(x));
            
                p.parse(varargin{:});
            
                if isfield(p.Results, 'p_Data')
                    if size(p.Results.p_Data,1) == 3 && size(p.Results.p_Data,2) ~= 3
                        obj.m_matSeriesData = p.Results.p_Data';
                    else
                        obj.m_matSeriesData = p.Results.p_Data;
                    end                    
                end
                
                if isfield(p.Results, 'p_fSamplingFrequency')
                    obj.m_fSamplingFrequency = p.Results.p_fSamplingFrequency;                                        
                end
            end
        end
        
        %% push
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_Data ToDo
        %>
        %> @return ToDo
        % =================================================================
        function obj = push(obj,p_Data)
            
            p = inputParser;
            
            p.addRequired('p_Data', @(x)ismatrix(x) || isa(x,'sl_C3DVector'));

            p.parse(p_Data);
            
            idx = obj.iNumSamples+1;
            
            if isa(p.Results.p_Data,'sl_C3DVector')
                p_Data = p.Results.p_Data.data;
            else
                if size(p.Results.p_Data,1) == 3 && size(p.Results.p_Data,2) ~= 3
                    p_Data = p.Results.p_Data';
                else
                    p_Data = p.Results.p_Data;
                end
            end
            
            obj.m_matSeriesData(idx:idx+size(p_Data,1)-1,:) = p_Data;
        end

        %% insert
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_Data ToDo
        %> @param timeIdx ToDo
        %>
        %> @return ToDo
        % =================================================================
        function obj = insert(obj, p_Data, timeIdx)
            p = inputParser;
            
            p.addRequired('p_Data', @(x)ismatrix(x) || isa(x,'sl_C3DVector'));
            p.addRequired('timeIdx', @(x)isscalar(x) && x > 0 && x <= obj.iNumSamples );

            p.parse(p_Data, timeIdx);
            
            idx = p.Results.timeIdx;
            
            tmpCoordinate = obj.m_matSeriesData(idx:end,:);
            
            if isa(p.Results.p_Data,'sl_C3DVector')
                p_Data = p.Results.p_Data.data;
            else
                if size(p.Results.p_Data,1) == 3 && size(p.Results.p_Data,2) ~= 3
                    p_Data = p.Results.p_Data';
                else
                    p_Data = p.Results.p_Data;
                end
            end
            
            obj.m_matSeriesData(idx:idx+size(p_Data,1)-1,:) = p_Data;
            
            offIdx = idx+size(p_Data,1);
            
            obj.m_matSeriesData(offIdx:offIdx+size(tmpCoordinate,1)-1,:) = tmpCoordinate;
        end
        
        %% set
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_Data ToDo
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set(obj, p_Data, varargin)
            
            p = inputParser;
            
            p.addRequired('p_Data', @(x)ismatrix(x) || isa(x,'sl_C3DVector'));
            p.addOptional('timeIdx', [], @(x)isscalar(x) && x > 0 );
            
            p.parse(p_Data, varargin{:});
            idx = p.Results.timeIdx;
            
            if isa(p.Results.p_Data,'sl_C3DVector')
                p_Data = p.Results.p_Data.data;
            else
                if size(p.Results.p_Data,1) == 3 && size(p.Results.p_Data,2) ~= 3
                    p_Data = p.Results.p_Data';
                else
                    p_Data = p.Results.p_Data;
                end
            end
                    
            if ~isempty(idx)
                if idx <= obj.iNumSamples
                    obj.m_matSeriesData(idx:idx+size(p_Data,1)-1,:) = p_Data;
                else
                    obj.m_matSeriesData = [obj.m_matSeriesData; p_Data];
                end
            else %Set first Coordinate
                obj.m_matSeriesData(1:size(p_Data,1),:) = p_Data;
            end
        end
        
        %% get
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % ================================================================= % =================================================================
        function p_Data = get(obj,varargin)
            
            p = inputParser;
            
            p.addOptional('timeIdx', [], @(x)isscalar(x) && x > 0 && x <= obj.iNumSamples );
            p.addOptional('range', [], @(x)isscalar(x) && x > 0);
            
            p.parse(varargin{:});
            
            idx = p.Results.timeIdx;
            range = p.Results.range;
            
            if ~isempty(idx)
                if ~isempty(range)
                    if idx+range > obj.iNumSamples
                        error('timeIdx+range-1 are out of range.');
                    end
                    p_Data = obj.m_matSeriesData(idx:idx+range-1,:);
                else
                    p_Data = obj.m_matSeriesData(idx,:);
                end
            else %Default return all
                p_Data = obj.m_matSeriesData;
            end
        end
        
        %% get.X
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
       
        function p_xTimeVec = get.X(obj)
            p_xTimeVec = obj.m_matSeriesData(:,1);
        end

        %% set.X
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_xTimeVec ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.X(obj, p_xTimeVec)
            obj.m_matSeriesData(:,1) = p_xTimeVec;
        end

        %% get.Y
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function p_yTimeVec = get.Y(obj)
            p_yTimeVec = obj.m_matSeriesData(:,2);
        end

        %% set.Y
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_yTimeVec ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.Y(obj, p_yTimeVec)
            obj.m_matSeriesData(:,2) = p_yTimeVec;
        end

        %% get.Z
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function p_zTimeVec = get.Z(obj)
            p_zTimeVec = obj.m_matSeriesData(:,3);
        end

        %% get.Z
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_zTimeVec ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.Z(obj, p_zTimeVec)
            obj.m_matSeriesData(:,3) = p_zTimeVec;
        end

        %% plot
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
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

        %% plot3
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % =================================================================
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
    end % methods
    
    methods (Static)
        
        %% Type
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %>
        %> @return ToDo
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Vector;
        end % getType
        
        %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            %% getName
            name = '3D Vector';
        end % getName
                 
        %Methods in a separate file

    end % static methods
    
end

