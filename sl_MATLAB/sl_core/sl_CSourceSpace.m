%> @file    sl_CSourceSpace.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	March, 2012
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
classdef sl_CSourceSpace < sl_IValue
    %% sl_CSourceSpace
    properties %(Access = protected)
        %> ToDo
        m_SourceSpace
        %> ToDo
        m_vecSelectedHemispheres
    end % properties (Access = protected)
    
    properties (Dependent, Access = protected)
        %> ToDo
        sizeSourceSpace
%        vertices
%        faces
    end % properties (Dependent)
    
    properties (Dependent)
        %> ToDo
        SourceSpaceAvailable
        %> ToDo
        AvailableHemispheres
        %> ToDo
        SelectedHemispheres
        %> ToDo
        SourceSpace_norm
    end % properties (Dependent)
    
    methods
        %% sl_CSourceSpace Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CSourceSpace class.
        % =================================================================
        function obj = sl_CSourceSpace(varargin)
            if nargin == 1 && isa(varargin{1},'sl_CSourceSpace') %%Copy Constructor
                obj.m_SourceSpace = varargin{1}.m_SourceSpace;
                obj.m_vecSelectedHemispheres = varargin{1}.m_vecSelectedHemispheres;
            else
                p = inputParser;
                p.addOptional('p_sFilename', [], @(x)ischar(x) || isempty(x))
                p.parse(varargin{:});
                
                if ~isempty(p.Results.p_sFilename)
                    obj.loadSourceSpace(p.Results.p_sFilename);
                else
                    obj.m_SourceSpace = [];
                end
                obj.resetHemisphereSelection();
            end
        end % sl_CSourceSpace
        
        %% get.sizeSourceSpace
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.sizeSourceSpace(obj)
            if obj.SourceSpaceAvailable
                value = length(obj.m_SourceSpace);
            else
                value = [];
            end
        end % get.sizeSourceSpace
        
        %% get.SourceSpaceAvailable
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function bool = get.SourceSpaceAvailable(obj)
            if isempty(obj.m_SourceSpace)
                bool = false;
            else
                bool = true;
            end
        end % get.SourceSpaceAvailable
        
        %% get.AvailableHemispheres
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.AvailableHemispheres(obj)
            if obj.SourceSpaceAvailable
                value = 1:obj.sizeSourceSpace;
            else
                value = [];
            end
        end % get.AvailableHemispheres
        
        %% get.SelectedHemispheres
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SelectedHemispheres(obj)
            value = obj.m_vecSelectedHemispheres;
        end % get.SelectedHemispheres
        
        %% get.SourceSpace_norm Judith
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SourceSpace_norm(obj)
            value = [];%obj.m_SourceSpace;
            if ~isempty(obj.m_SourceSpace)
                for i=1:obj.sizeSourceSpace
                    for j=1:3 % coordinates
                        value(1,i).rr(:,j)=obj.m_SourceSpace(1,i).rr(:,j)-mean(mean([obj.m_SourceSpace(1,1).rr(:,j)' obj.m_SourceSpace(1,2).rr(:,j)']));
                    end
                end
                %%ToDo value(1,1).rr' value(1,2) for one or less
                %%hemispheres
                tmp = value(1,1).rr';
                for i=2:obj.sizeSourceSpace
                    tmp = [tmp value(1,i).rr'];
                end
                norm_val=max(max(abs(tmp)));
                for i=1:obj.sizeSourceSpace
                    value(1,i).rr = value(1,i).rr./norm_val;
                end   
            end
        end % get.SourceSpace_norm Judith
        
        %% selectHemispheres
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_vecHemisphereSelection ToDo
        %>
        %> @return ToDo
        % =================================================================
        function selectHemispheres(obj, p_vecHemisphereSelection)
            if obj.SourceSpaceAvailable
                p = inputParser;
                p.addRequired('p_vecHemisphereSelection', @(x)isvector(x) &&...
                    min(x) >= 1 &&...
                    max(x) <= 2 ||...
                    isempty(x))
                p.parse(p_vecHemisphereSelection);

                obj.m_vecSelectedHemispheres = p.Results.p_vecHemisphereSelection;
                obj.m_vecSelectedHemispheres = sort(obj.m_vecSelectedHemispheres);
            else
                error('Source Space not available. Load a Source Space first');
            end
        end % selectHemispheres
        
        
%         % =================================================================
%         function vert = get.vertices(obj)
%             if ~obj.SourceSpaceAvailable || isempty(obj.m_vecSelectedHemispheres)
%                 vert = [];
%             else
%                 for i=1:length(obj.m_vecSelectedHemispheres)
%                     k = obj.m_vecSelectedHemispheres(i);
%                     vert(1,k).rr = obj.m_SourceSpace(1,k).rr;
%                     vert(1,k).nn = obj.m_SourceSpace(1,k).nn;
%                 end
%             end
%         end
%         
%         % =================================================================
%         function face = get.faces(obj)
%             if ~obj.SourceSpaceAvailable || isempty(obj.m_vecSelectedHemispheres)
%                 face = [];
%             else
%                 for i=1:length(obj.m_vecSelectedHemispheres)
%                     k = obj.m_vecSelectedHemispheres(i);
%                     face(1,k).tris = obj.m_SourceSpace(1,k).tris;
%                 end
%             end
%         end
  
        %% loadSourceSpace
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_sFilename ToDo
        % =================================================================
        function loadSourceSpace(obj, p_sFilename)
            obj.m_SourceSpace = sl_CSourceSpace.read(p_sFilename);
        end % loadSourceSpace
        
        %% resetHemisphereSelection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function resetHemisphereSelection(obj)
            if isempty(obj.m_SourceSpace)
                obj.m_vecSelectedHemispheres = [];
            else
                obj.m_vecSelectedHemispheres = obj.AvailableHemispheres();
            end
        end % resetHemisphereSelection

        %% clear
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function clear(obj)
            obj.m_SourceSpace = [];
            obj.m_vecSelectedHemispheres = [];
        end
        
        %% plot
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        % =================================================================
        function plot(obj, varargin)
            color_map = [0 0 255; 0 255 000];
            if obj.SourceSpaceAvailable
                for h = 1:length(obj.m_SourceSpace) %LH & RH
                    color = color_map(h, :)./255;%h;%zeros(size(obj.m_SourceSpace(1,1).rr,1),3);
                    p = patch('Vertices',obj.m_SourceSpace(1,h).rr,...
                        'Faces',obj.m_SourceSpace(1,h).tris,...
                        'FaceColor',color,...
                        'EdgeColor','none',...
                        'FaceLighting','gouraud');
                    
                    if isempty(find(ismember(obj.m_vecSelectedHemispheres, h),1))
                        set(p,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
                    end

                    hold on;
                end % LH & RH
%                inspect(p)
                title('SourceSpace');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

%               shading interp
%               set(gcf,'Renderer','zbuffer')
                set(findobj(gca,'type','surface'),...
                    'AmbientStrength',.3,...
                    'DiffuseStrength',.8,...
                    'SpecularStrength',.9,...
                    'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
                axis equal;
                hold off;
            end
        end % plot
        
        %% plot_3D_SourceSpace Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        % =================================================================
        function plot_3D_SourceSpace(obj, varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
      
            fig_h = p.Results.axesHandle;
            %dim = p.Results.dim;
            %cla(fig_h);
            % plot
            color_map = [150 150 150; 211 211 211];
            if obj.SourceSpaceAvailable
                for h = 1:length(obj.m_SourceSpace) %LH & RH
                    color = color_map(h, :)./255;%h;%zeros(size(obj.m_SourceSpace(1,1).rr,1),3);
                    
                    p = patch('Vertices',obj.SourceSpace_norm(1,h).rr,...
                        'Faces',obj.m_SourceSpace(1,h).tris,...
                        'FaceColor',color,...
                        'EdgeColor','none',...
                        'FaceLighting','gouraud',...
                        'Parent', fig_h,...
                        'FaceVertexAlphaData',0.1,...
                        'FaceAlpha','flat');
                   %reducepatch(p,0.1);
                                       
                    if isempty(find(ismember(obj.m_vecSelectedHemispheres, h),1))
                        set(p,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
                    end

                    hold on;
                end % LH & RH
%                inspect(p)
                %title('SourceSpace');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

%               shading interp
%               set(gcf,'Renderer','zbuffer')

                set(findobj(fig_h,'type','patch'),...
                    'AmbientStrength',.3,...
                    'DiffuseStrength',.8,...
                    'SpecularStrength',.9,...
                    'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
                axis equal;
                hold off;
            end
        end % plot_3D_SourceSpace
        
        %% plot_DSPos Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        % =================================================================
        function plot_DSPos(obj, varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.addParamValue('dim', [], @(x)isscalar(x));
           
            p.parse(varargin{:});
      
            fig_h = p.Results.axesHandle;
            dim = p.Results.dim;
            
            % plot
            color_map = [150 150 150; 211 211 211];
            if obj.SourceSpaceAvailable
                for h = 1:length(obj.m_SourceSpace) %LH & RH
                    color = color_map(h, :)./255;%h;%zeros(size(obj.m_SourceSpace(1,1).rr,1),3);
                    if dim ==1
                        p_vertices = [obj.SourceSpace_norm(1,h).rr(:,1) obj.SourceSpace_norm(1,h).rr(:,3) obj.SourceSpace_norm(1,h).rr(:,2)];
                        p_faces = [obj.m_SourceSpace(1,h).tris(:,3) obj.m_SourceSpace(1,h).tris(:,1) obj.m_SourceSpace(1,h).tris(:,2)];
                    elseif dim ==2
                        p_vertices = [obj.SourceSpace_norm(1,h).rr(:,2) obj.SourceSpace_norm(1,h).rr(:,1) obj.SourceSpace_norm(1,h).rr(:,3)];
                        p_faces = [obj.m_SourceSpace(1,h).tris(:,1) obj.m_SourceSpace(1,h).tris(:,2) obj.m_SourceSpace(1,h).tris(:,3)];
                    elseif dim == 3
                        p_vertices = [obj.SourceSpace_norm(1,h).rr(:,2) obj.SourceSpace_norm(1,h).rr(:,3) obj.SourceSpace_norm(1,h).rr(:,1)];
                        p_faces = [obj.m_SourceSpace(1,h).tris(:,2) obj.m_SourceSpace(1,h).tris(:,3) obj.m_SourceSpace(1,h).tris(:,1)];
                    end
                   
                    h_patch = patch('Vertices',p_vertices,...
                        'Faces',p_faces,...
                        'FaceColor',color,...
                        'EdgeColor','none',...
                        'FaceLighting','none',...
                        'Parent', fig_h,...
                        'FaceVertexAlphaData',0.05,...
                        'FaceAlpha','flat');
                    %reducepatch(h_patch,0.1);
                       
                    if isempty(find(ismember(obj.m_vecSelectedHemispheres, h),1))
                        set(h_patch,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
                    end

                    hold on;
                end % LH & RH
%                inspect(p)
                %title('SourceSpace');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

%               shading interp
%               set(gcf,'Renderer','zbuffer')
                h=findobj(fig_h,'type','surface');
                set(findobj(fig_h,'type','surface'),...
                    'AmbientStrength',.3,...
                    'DiffuseStrength',.8,...
                    'SpecularStrength',.9,...
                    'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
                axis equal;
                hold off;
            end
        end % plot_DSPos
    end % methods
    
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
            type = sl_Type.SourceSpace;
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
            name = 'Source Space';
        end % Name
        
        %% read
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_sFilename ToDo
        %>
        %> @return ToDo
        % =================================================================
        function sourceSpace = read(p_sFilename)
            p = inputParser;
            p.addRequired('p_sFilename', @ischar)
            p.parse(p_sFilename);
            
            [~, ~, ext] = fileparts(p.Results.p_sFilename);
            if strcmp(ext, '.fif')
                sourceSpace =  mne_read_forward_solution(p.Results.p_sFilename);
                %mne_read_source_spaces(p.Results.p_sFilename);  --> without trafo, this does not fit to forward solution
                sourceSpace = sourceSpace.src;
            else
                sourceSpace = [];
            end
        end % read
    end % methods (Static)
    
end

