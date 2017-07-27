%> @file    sl_CROISpace.m
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
%> @brief   File used to show an example of class description
% =========================================================================
%> @brief   Summary of this class goes here
%
%> Detailed explanation goes here
% =========================================================================
classdef sl_CROISpace < sl_CSourceSpace
    %SL_CROISOURCESPACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties %(Access = protected)
        %> ToDo
        m_BrainAtlas
        %> ToDo
        m_vecSelectedROIs
    end % properties (Access = protected)
    
    properties (Dependent, Access = protected)
        %> ToDo
        sizeROISpace
        %> ToDo
        ROILabel
    end % properties (Dependent)
    
    properties (Dependent)
        %> ToDo
        ROISpaceAvailable
        %> ToDo
        ROIAtlas
        %> ToDo
        AvailableROIs
        %> ToDo
        SelectedROIs
    end % properties (Dependent)
    
    methods
        %% sl_CCROISpace Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CROISpace class.
        % =================================================================
        function obj = sl_CROISpace(varargin)
            p = inputParser;
            p.addOptional('p_sSource', [], @(x)ischar(x) || isempty(x) || isa(x, 'sl_CROISpace'))
            p.addOptional('p_sLhFilename', [], @(x)ischar(x) || isempty(x));
            p.addOptional('p_sRhFilename', [], @(x)ischar(x) || isempty(x));
            
            p.parse(varargin{:});
            
            obj = obj@sl_CSourceSpace(p.Results.p_sSource);
            
            if nargin >= 1 && isa(varargin{1}, 'sl_CROISpace') % Copy Constructor
                obj.m_BrainAtlas = p.Results.p_sSource.m_BrainAtlas;
                obj.m_vecSelectedROIs = p.Results.p_sSource.m_vecSelectedROIs;
            else
                if ~isempty(p.Results.p_sLhFilename) && ~isempty(p.Results.p_sRhFilename)
                    obj.loadROISpace(p.Results.p_sLhFilename, p.Results.p_sRhFilename);
                else
                    obj.m_BrainAtlas = [];
                end
                obj.resetROISelection();
            end
        end
        
        %% get.sizeROISpace
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.sizeROISpace(obj)
            if obj.SourceSpaceAvailable
                value = obj.sizeSourceSpace;
            elseif obj.ROISpaceAvailable
                value = length(obj.m_BrainAtlas);
            else
                 value = [];
            
            end
        end
        
        %% get.ROILabel
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.ROILabel(obj)
            if obj.ROISpaceAvailable
                for i = 1:obj.sizeROISpace
                    value(1,i).label = obj.m_BrainAtlas(1,i).label;%(obj.defaultSolutionSourceSpace.src(1,i).vertno,:);
                end
            else
                value = [];
            end
        end % get.ROILabel
      
        %% get.ROISpaceAvailable
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function bool = get.ROISpaceAvailable(obj)
            if isempty(obj.m_BrainAtlas)
                bool = false;
            else
                bool = true;
            end
        end % get.ROISpaceAvailable
        
        %% get.ROIAtlas
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.ROIAtlas(obj)
            if obj.ROISpaceAvailable
                for i = 1:obj.sizeROISpace
                    value(1,i) = obj.m_BrainAtlas(1,i).colortable;
                end
            else
                value = [];
            end
        end % get.ROIAtlas
        
        %% get.AvailableROIs
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.AvailableROIs(obj)
            if obj.ROISpaceAvailable
                for i = 1:obj.sizeROISpace
                    value(1,i).label = ...
                        obj.m_BrainAtlas(1,i).colortable.table(:,5);
                end
            else
                value = [];
            end
        end
        
        %% get.SelectedROIs
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SelectedROIs(obj)
                if obj.SourceSpaceAvailable
                    for i = 1:obj.sizeROISpace
                        if isempty(find(ismember(obj.SelectedHemispheres, i),1))...
                                || ~obj.ROISpaceAvailable
                            value(1,i).label = [];
                        else
                            value(1,i).label = obj.m_vecSelectedROIs(1,i).label;
                        end
                    end
                elseif obj.ROISpaceAvailable
                    for i = 1:obj.sizeROISpace
                        value(1,i).label = obj.m_vecSelectedROIs(1,i).label;
                    end
                else
                    value.label = obj.m_vecSelectedROIs;
                end
        end
        
        
        %% selectROIs
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
        function selectROIs(obj, varargin)
            if obj.ROISpaceAvailable
                p = inputParser;
                p.addParamValue('lh', NaN, @(x)isnumeric(x) || isempty(x))
                p.addParamValue('rh', NaN, @(x)isnumeric(x) || isempty(x));
                p.parse(varargin{:});

                if ~isnan(p.Results.lh)
                    bIdx = ismember(obj.ROIAtlas(1,1).table(:,5), p.Results.lh);
                    if isempty(find(bIdx,1))
                        obj.m_vecSelectedROIs(1,1).label = [];                    
                    else
                        obj.m_vecSelectedROIs(1,1).label = obj.ROIAtlas(1,1).table(bIdx, 5);
                    end
                elseif isempty(p.Results.lh)
                    obj.m_vecSelectedROIs(1,1).label = [];
                end
                if ~isnan(p.Results.rh)
                    bIdx = ismember(obj.ROIAtlas(1,2).table(:,5), p.Results.rh);
                    if isempty(find(bIdx,1))
                        obj.m_vecSelectedROIs(1,2).label = [];
                    else
                        obj.m_vecSelectedROIs(1,2).label = obj.ROIAtlas(1,2).table(bIdx, 5);
                    end
                elseif isempty(p.Results.rh)
                    obj.m_vecSelectedROIs(1,2).label = [];
                end
            else
                error('ROI Space not available. Load a ROI Space first');
            end
        end
        
        %% atlasName2Label
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_vecName ToDo
        %>
        %> @return ToDo
        % =================================================================
        function labelValues = atlasName2Label(obj, p_vecName)
            p = inputParser;
            p.addRequired('p_vecName', @iscellstr)
            p.parse(p_vecName);
            
            labelValues = [];
            
            if obj.ROISpaceAvailable
                for i = 1:obj.sizeROISpace
                    labelValues(1,i).label = obj.ROIAtlas(1,i).table(ismember(obj.ROIAtlas(1,i).struct_names, p.Results.p_vecName), 5);
                end
            end
        end % atlasName2Label
        
        %% label2AtlasName
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_vecLabel ToDo
        %>
        %> @return ToDo 
        % =================================================================
        function nameValues = label2AtlasName(obj, p_vecLabel)
            
            p = inputParser;
            p.addRequired('p_vecLabel', @isnumeric)
            p.parse(p_vecLabel);
            
            nameValues = [];
            
            if obj.ROISpaceAvailable
                for i = 1:obj.sizeROISpace
                    nameValues(1,i).names = obj.ROIAtlas(1,i).struct_names(ismember(obj.ROIAtlas(1,i).table(:,5),p.Results.p_vecLabel));
                end
            end
        end % label2AtlasName
        
        %% label2Color
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo  
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        %>
        %> @retval LH_colors
        %> @retval RH_coloe
        %>
        %> @return ToDo
        % =================================================================
        function [LH_colors, RH_colors] = label2Color(obj, varargin)%Use only one input
            p = inputParser;
            p.addParamValue('lh', [], @isnumeric)
            p.addParamValue('rh', [], @isnumeric);
            p.parse(varargin{:});
            
            LH_colors = [];
            RH_colors = [];
            
            if ~isempty(p.Results.lh)
                %idx = find(ismember(obj.ROIAtlas(1,1).table(:,5),p.Results.lh));
                LH_colors = obj.ROIAtlas(1,1).table(ismember(obj.ROIAtlas(1,1).table(:,5),p.Results.lh), 1:3);
            end
            if ~isempty(p.Results.rh)
                %idx = find(ismember(obj.ROIAtlas(1,2).table(:,5),p.Results.rh));
                RH_colors = obj.ROIAtlas(1,2).table(ismember(obj.ROIAtlas(1,2).table(:,5),p.Results.rh), 1:3);
            end
        end % label2Color

        %% loadROISpace
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_sLhFilename ToDo
        %> @param p_sRhFilename ToDo
        %>
        %> @return ToDo 
        % =================================================================

        function loadROISpace(obj, p_sLhFilename, p_sRhFilename)
            
            [t_lh_BrainAtlas.vertices,...
                t_lh_BrainAtlas.label,t_lh_BrainAtlas.colortable] = ...
                read_annotation(p_sLhFilename);
            
            [t_rh_BrainAtlas.vertices,...
                t_rh_BrainAtlas.label,t_rh_BrainAtlas.colortable] = ...
                read_annotation(p_sRhFilename);
            
            obj.m_BrainAtlas = [t_lh_BrainAtlas t_rh_BrainAtlas];
        end
        
        %% resetROISelection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo 
        % =================================================================

        function resetROISelection(obj)
            if obj.ROISpaceAvailable
                obj.m_vecSelectedROIs = obj.AvailableROIs();
            else
                obj.m_vecSelectedROIs = [];
            end
        end
        
        
        %% clear
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo 
        % =================================================================

        function clear(obj)
            obj.clear@sl_CSourceSpace();
            obj.m_BrainAtlas = [];
            obj.m_vecSelectedROIs = [];
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
            if obj.ROISpaceAvailable && obj.SourceSpaceAvailable
                for h = 1:obj.sizeSourceSpace %%LH and RH
                    %% LH && RH
                    color = zeros(length(obj.m_BrainAtlas(1,h).vertices),3);
                    for i = 1:obj.m_BrainAtlas(1,h).colortable.numEntries
                        idx = find(obj.m_BrainAtlas(1,h).label == obj.m_BrainAtlas(1,h).colortable.table(i,5));
                        color(idx,:) = repmat(obj.m_BrainAtlas(1,h).colortable.table(i,1:3), length(idx), 1);
                    end
                    p = patch('Vertices',obj.m_SourceSpace(1,h).rr,...
                        'Faces',obj.m_SourceSpace(1,h).tris,...
                        'FaceVertexCData',color./255,...
                        'FaceColor','interp',...
                        'EdgeColor','none',...
                        'FaceLighting','gouraud');
                    
                    if isempty(find(ismember(obj.SelectedHemispheres, h),1)) ||...
                            isempty(find(ismember(obj.ROILabel(1,h).label,obj.m_vecSelectedROIs(1,h).label),1))
                        set(p,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
                    else
                        alpha = ones(length(obj.ROILabel(1,h).label),1)*0.1;
                        alpha(ismember(obj.ROILabel(1,h).label,obj.m_vecSelectedROIs(1,h).label)) = 1;
                        set(p,'FaceVertexAlphaData',alpha,'FaceAlpha','interp');
                    end
                    
                    set(gca,'Alim',[0 1]);

                    % LH && RH  end
                    hold on;
                end
                title('Forward Solution');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

                %shading interp
    %            set(gcf,'Renderer','zbuffer')
                set(findobj(gca,'type','surface'),...
                    'AmbientStrength',.3,'DiffuseStrength',.8,...
                    'SpecularStrength',.9,'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
            elseif obj.SourceSpaceAvailable
                obj.plot@sl_CSourceSpace(varargin);
            end
            axis equal;
            hold off
        end
   
 %% Judith -----------------
 
        %% plot_DSPos
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

 
  function plot_DSPos(obj, varargin)
      
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            p.addParamValue('dim', [], @(x)isscalar(x));
            p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
      
            fig_h = p.Results.axesHandle;
            dim = p.Results.dim;
      
           
            if obj.SourceSpaceAvailable
               obj.plot_DSPos@sl_CSourceSpace(varargin{:});
            end
            axis equal;
            hold off
  end
        %% plot_3D_SourceSpace
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

        function plot_3D_SourceSpace(obj, varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
            
            fig_h = p.Results.axesHandle;
            
            obj.plot_3D_SourceSpace@sl_CSourceSpace(varargin{:});
        end
        
        %% plot_3D_ROISpace
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

        function plot_3D_ROISpace(obj,varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
            
            fig_h = p.Results.axesHandle;
             % plot
            if obj.ROISpaceAvailable && obj.SourceSpaceAvailable
                for h = 1:obj.sizeSourceSpace %%LH and RH
                    %% LH && RH
                    color = zeros(length(obj.m_BrainAtlas(1,h).vertices),3);
                    for i = 1:obj.m_BrainAtlas(1,h).colortable.numEntries
                        idx = find(obj.m_BrainAtlas(1,h).label == obj.m_BrainAtlas(1,h).colortable.table(i,5));
                        color(idx,:) = repmat(obj.m_BrainAtlas(1,h).colortable.table(i,1:3), length(idx), 1);
                    end
                    p = patch('Vertices',obj.m_SourceSpace(1,h).rr,...
                        'Faces',obj.m_SourceSpace(1,h).tris,...
                        'FaceVertexCData',color./255,...
                        'FaceColor','interp',...
                        'EdgeColor','none',...
                        'FaceLighting','gouraud',...
                        'Parent',fig_h);
                    
                    if isempty(find(ismember(obj.SelectedHemispheres, h),1)) ||...
                            isempty(find(ismember(obj.ROILabel(1,h).label,obj.m_vecSelectedROIs(1,h).label),1))
                        set(p,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
                    else
                        alpha = ones(length(obj.ROILabel(1,h).label),1)*0.1;
                        alpha(ismember(obj.ROILabel(1,h).label,obj.m_vecSelectedROIs(1,h).label)) = 1;
                        set(p,'FaceVertexAlphaData',alpha,'FaceAlpha','interp');
                    end
                    
                    %set(gca,'Alim',[0 1]);

                    % LH && RH  end
                    hold on;
                end
                %title('Forward Solution');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

                %shading interp
    %            set(gcf,'Renderer','zbuffer')
    
                if isempty(fig_h)
                    set(findobj(gca,'type','surface'),...
                        'AmbientStrength',.3,'DiffuseStrength',.8,...
                        'SpecularStrength',.9,'SpecularExponent',25,...
                        'BackFaceLighting','unlit')
                else
                    set(findobj(fig_h,'type','surface'),...
                        'AmbientStrength',.3,'DiffuseStrength',.8,...
                        'SpecularStrength',.9,'SpecularExponent',25,...
                        'BackFaceLighting','unlit')
                end
        end
        end
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
            type = sl_Type.ROISpace;
        end % getType
        
        %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @return ToDo 
        % =================================================================

        function name = Name()
            name = 'ROI Space';
        end % getName
        
        %% read
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param p_sFilename
        %>
        %> @return ToDo 
        % =================================================================

        function roiSpace = read(p_sFilename)
            p = inputParser;
            p.addRequired('p_sFilename', @ischar)
            p.parse(p_sFilename);
            [roiSpace.vertices,roiSpace.label,roiSpace.colortable] = ...
                read_annotation(p.Results.p_sFilename);
        end %read
    end % methods (Static)
    
    
end

