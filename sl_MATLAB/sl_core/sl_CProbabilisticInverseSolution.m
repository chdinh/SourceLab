%> @file    sl_CProbabilisticInverseSolution.m
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
%> ToDo detailed description
% =========================================================================
classdef sl_CProbabilisticInverseSolution < sl_CROISpace
    %% sl_CProbabilisticInverseSolution    
    properties
        %> ToDo
        m_connectedForwardSolution
        %> ToDo
        m_ProbabilisticActivationMap
        
%        m_nearestIdcs
    end
    
    methods
        %% sl_CProbabilisticInverseSolution Constructor 
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
        function obj = sl_CProbabilisticInverseSolution(p_Solution, varargin)
            p = inputParser;
            p.addRequired('p_Solution', @(x)isa(x, 'sl_CForwardSolution') || isa(x, 'sl_CProbabilisticInverseSolution'))
            p.addOptional('fs', 1000, @(x)isscalar(x) && x > 0)
            p.parse(p_Solution, varargin{:});
            
            obj = obj@sl_CROISpace(p.Results.p_Solution);

            if nargin >= 1 && isa(p_Solution, 'sl_CProbabilisticInverseSolution')%Copy constructor
                obj.m_connectedForwardSolution = p_Solution.m_connectedForwardSolution;
            else
                obj.m_connectedForwardSolution = p.Results.p_Solution;
                
                obj.init();
            end
        end % sl_CProbabilisticInverseSolution

        %% init
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function init(obj)
            obj.m_ProbabilisticActivationMap.map = [];
%            obj.m_nearestIdcs.map = [];
            for h = 1: obj.m_connectedForwardSolution.m_ForwardSolution.source_ori              
                obj.m_ProbabilisticActivationMap(1,h).map = ones(1,obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nuse);

%                 % Build Colormap based on activation
%                 fprintf('Calculating index map %d...\n',h);    
%                 obj.m_nearestIdcs(1,h).map = zeros(obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nuse,1);
%                 for i = 1:obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nuse
%                     sel_vert = obj.m_connectedForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(i);
%                     selection = find(obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nearest == sel_vert);
%                     if length(selection) > 0
%                         obj.m_nearestIdcs(1,h).map(selection) = repmat(i, length(selection), 1);
%                     end
%                 end
%                                 
%                 %%fill not set vertices ToDo
%                 selection = find(obj.m_nearestIdcs(1,h).map == 0);
%                 if length(selection) > 0
%                     fprintf('Repair not set vertices... \n');
%                     obj.m_nearestIdcs(1,h).map(selection) = repmat(1, length(selection), 1);
%                 end
                
                
            end
            obj.normalize();
        end % init
        
        
        %% normalize
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function normalize(obj)
            t_fNormalizer = 0;
            for i = 1: obj.m_connectedForwardSolution.m_ForwardSolution.source_ori
                t_fNormalizer = t_fNormalizer + sum(obj.m_ProbabilisticActivationMap(1,i).map);
            end
            for i = 1: obj.m_connectedForwardSolution.m_ForwardSolution.source_ori
                obj.m_ProbabilisticActivationMap(1,i).map = obj.m_ProbabilisticActivationMap(1,i).map / t_fNormalizer;
            end
        end % normalize
        
        %% plot
        % =================================================================
        %> @brief ToDo
        %> 
        %> ToDo
        %> Do mne_add_patch_info first to have neighboured vertices
        %> calculate patch info (cortical patch statistics) within step 
        %> mne_setup_source_space --cps
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDO
        % =================================================================
        function plot(obj, varargin)
            if obj.ROISpaceAvailable && obj.SourceSpaceAvailable
                
                t_valMax = 0;
                while 1
                    map = [];
                    for h = 1:obj.sizeSourceSpace
                        map = [map obj.m_ProbabilisticActivationMap(1,h).map];
                    end
                    t_valMax = max(map);
                    if t_valMax > 1
                        obj.normalize();
                    else
                        break;
                    end
                end

                t_offset = 0;
                for h = 1:obj.sizeSourceSpace %%LH and RH
                     % LH && RH

%                     color = ones(length(obj.m_BrainAtlas(1,h).vertices),3)*255;
%                     
%                     % Build Colormap based on activation
%                     fprintf('Calculating color map %d...\n',h);                    
%                     for i = 1:obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nuse
%                         sel_vert = obj.m_connectedForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(i);
%                         selection = find(obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nearest == sel_vert);
%                         if length(selection) > 0
%                             fak = (1 - obj.m_ProbabilisticActivationMap(1,h).map(i)/t_valMax);
%                             current_color = [255 (255*fak) (255*fak)]; % ToDo make this map more beautiful and faster!!
%                             color(selection,:) = repmat(current_color, length(selection), 1);
%                         end
%                     end
                    
%                     lg_idx = ismember(obj.m_connectedForwardSolution.AvailableSources(1,h).idx,obj.SelectedActivatedSources);
%                     sel = obj.m_connectedForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(lg_idx);


                    p = patch('Vertices',obj.m_SourceSpace(1,h).rr,...
                        'Faces',obj.m_SourceSpace(1,h).tris,...
                        'FaceVertexCData',t_offset + obj.m_connectedForwardSolution.m_ForwardSolution.src(1,h).nearest',...
                        'FaceColor','flat',...
                        'EdgeColor','none',...
                        'FaceLighting','gouraud');%%obj.m_ProbabilisticActivationMap(1,h).map(obj.m_nearestIdcs(1,h).map),...%color./255,...
                    
                    
                    t_offset = t_offset + length(obj.m_BrainAtlas(1,h).vertices);
                    
                    
                    
                    %p = reducepatch(p, 0.15);
                    
%                     if isempty(find(ismember(obj.SelectedHemispheres, h),1)) ||...
%                             isempty(find(ismember(obj.ROILabel(1,h).label,obj.m_vecSelectedROIs(1,h).label),1))
%                         set(p,'FaceVertexAlphaData',0.1,'FaceAlpha','flat');
%                     else
%                         alpha = ones(length(obj.ROILabel(1,h).label),1)*0.1;
% %                         if obj.ActivationAvailable
% %                             sel_rois = obj.m_connectedForwardSolution.idx2Label(obj.SelectedActivatedSources);
% %                         else
%                         sel_rois = obj.m_vecSelectedROIs(1,h).label;
%                     end
%                     
%                     alpha(ismember(obj.ROILabel(1,h).label,sel_rois)) = 1;
%                     
%                     set(p,'FaceVertexAlphaData',alpha,'FaceAlpha','interp');
% %                     end
                    
                    set(gca,'Alim',[0 1]);

                    % LH && RH  end
                    hold on;
                end

                color = ones(length(map),3);
                
                map = map / t_valMax;
                
                color(:,2) = 1 - map';
                color(:,3) = 1 - map';
                colormap(color)
                
                
                
                
                title('Normalized Probabilistic Inverse Solution');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

                %shading interp
    %            set(gcf,'Renderer','zbuffer')
                set(findobj(gca,'type','surface'),...
                    'AmbientStrength',.3,'DiffuseStrength',.8,...
                    'SpecularStrength',.9,'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
            end

%             if obj.m_connectedForwardSolution.ForwardSolutionAvailable
%                 %% Plot Source Grid 
%                 hold on
% 
%                 for i = 1:obj.m_connectedForwardSolution.sizeForwardSolution
%                     plot3(obj.m_connectedForwardSolution.src(1,i).rr(:,1),obj.m_connectedForwardSolution.src(1,i).rr(:,2),obj.m_connectedForwardSolution.src(1,i).rr(:,3),'r*')
% 
%                     quiver3(obj.m_connectedForwardSolution.src(1,i).rr(:,1),obj.m_connectedForwardSolution.src(1,i).rr(:,2),obj.m_connectedForwardSolution.src(1,i).rr(:,3),...
%                         obj.m_connectedForwardSolution.src(1,i).nn(:,1),obj.m_connectedForwardSolution.src(1,i).nn(:,2),obj.m_connectedForwardSolution.src(1,i).nn(:,3),0.5)
%                 end
%             end
        end % plot       
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
            type = sl_Type.ProbabilisticInverseSolution;
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
            name = 'Probabilistic Inverse Solution';
        end % Name
    end % static methods
end % sl_CProbabilisticInverseSolution

