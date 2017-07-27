%> @file    sl_CInverseSolution.m
%> @author  Christoph Dinh <christoph.dinh@live.de>; 
%>          Alexander Hunold <alexander.hunold@tu-ilmenau.de>
%> @version	1.0
%> @date	July, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh, Alexander Hunold. All rights reserved.
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
classdef sl_CInverseSolution < sl_CROISpace
    %SL_CINVERSESOLUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties %(Access = private)
        %> ToDo
        m_corrForwardSolution
        
        %> ToDo
        m_fSamplingFrequency
        
        %> ToDo
        m_Activation
        %> ToDo
        m_dipoleMapActivation
        
        %> ToDo
        m_bUseForwardSolutionSelection
        %> ToDo
        m_selectedActivatedSources
    end
    
    properties (Dependent)
        %> ToDo
        ActivationAvailable
        
        %> ToDo
        data
        %> ToDo
        data_sensors
        
        %> ToDo
        SamplingFrequency
        
        %> ToDo
        AvailableActivatedSources
        %> ToDo
        SelectedActivatedSources
        %> ToDo
        numActivatedSources
        
        %> ToDo
        numSamples
        
        %> ToDo
        UseForwardSolutionSelection
    end  %properties (Dependent)
    
    methods
        
        %% sl_CInverseSolution Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param p_Solution ToDo
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CInverseSolution class.
        % =================================================================
        function obj = sl_CInverseSolution(p_Solution, varargin)
            p = inputParser;
            p.addRequired('p_Solution', @(x)isa(x, 'sl_CForwardSolution') || isa(x, 'sl_CInverseSolution'))
            p.addOptional('fs', 1000, @(x)isscalar(x) && x > 0)
            p.parse(p_Solution, varargin{:});
            
            obj = obj@sl_CROISpace(p.Results.p_Solution);%Copy constructor

            if nargin >= 1 && isa(p_Solution, 'sl_CInverseSolution')%Copy constructor
                obj.m_corrForwardSolution = p_Solution.m_corrForwardSolution;
                obj.m_Activation.dipoleMap = sl_CDipoleMap(p_Solution.m_Activation.dipoleMap);
                obj.m_Activation.numIndependentSources = p_Solution.m_Activation.numIndependentSources;
                obj.m_Activation.source.act_label = p_Solution.m_Activation.source.act_label;
                obj.m_Activation.source.activation = p_Solution.m_Activation.source.activation;
                obj.m_bUseForwardSolutionSelection = p_Solution.m_bUseForwardSolutionSelection;
            else
                obj.m_corrForwardSolution = p.Results.p_Solution;
                obj.m_Activation.dipoleMap = sl_CDipoleMap();
                obj.m_Activation.numIndependentSources = 0;
                obj.m_Activation.source.act_label = [];
                obj.m_Activation.source.activation = [];
                obj.m_bUseForwardSolutionSelection = true;
            end
            
            obj.m_fSamplingFrequency = p.Results.fs;
        end % sl_CInverseSolution
        
        %% get.ActivationAvailable Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.ActivationAvailable(obj)
            if obj.m_Activation.dipoleMap.size > 0
                value = true;
            else
                value = false;
            end
        end
        
        %% get.Data Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function srcActivity = get.data(obj)
            if obj.ActivationAvailable
                srcActivity = zeros(obj.numActivatedSources*3,obj.numSamples);
                for i = 1:obj.numActivatedSources
                    sel = obj.SelectedActivatedSources(i);
                    idx = (i-1)*3+1;
                    srcActivity(idx:idx+2,:) = obj.m_Activation.dipoleMap.Dipole(sel).data';
                end
            else
                srcActivity = [];
            end
        end
        
        %% get.data_sensors Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.data_sensors(obj)
            if obj.ActivationAvailable
                triSelect = repmat((obj.SelectedActivatedSources - 1) * 3 + 1, 3, 1);
                triSelect = [triSelect(1,:); triSelect(2,:)+1; triSelect(3,:)+2];
                triSelect = triSelect(:);

                %value = obj.m_corrForwardSolution.data(:,triSelect)*obj.data;%obj.m_corrForwardSolution.defaultSolutionSourceSpace.data(:,triSelect)*obj.data;
                %value=obj.m_corrForwardSolution.defaultSolutionSourceSpace.data(:,triSelect)*obj.data;
                value=obj.m_corrForwardSolution.defaultSolutionSourceSpace.data(obj.m_corrForwardSolution.SelectedChannels,triSelect)*obj.data;
            
            else
                value = [];
            end
        end
        
        %% get.SamplingFrequency Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SamplingFrequency(obj)
            value = obj.m_fSamplingFrequency;
        end
        
        %% set.SamplingFrequency Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param p_fSamplingFrequency
        %>
        %> @return ToDo
        % =================================================================
        function set.SamplingFrequency(obj, p_fSamplingFrequency)
            p = inputParser;
            p.addRequired('p_fSamplingFrequency', @isscalar)
            p.parse(p_fSamplingFrequency);
            obj.m_fSamplingFrequency = p.Results.p_fSamplingFrequency;
        end

        
        %% set.AvailableActivatedSources Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.AvailableActivatedSources(obj)
            if obj.ActivationAvailable
                value = obj.m_Activation.dipoleMap.keys.data;
            else
                value = [];
            end
        end

        %% get.SelectedActivatedSources Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SelectedActivatedSources(obj)
            if obj.ActivationAvailable
                if obj.m_bUseForwardSolutionSelection
                    value = obj.AvailableActivatedSources;
                    bIdx = ismember(obj.AvailableActivatedSources, []);
                    for i = 1:obj.sizeROISpace
                        bIdx = bIdx | ismember(obj.AvailableActivatedSources, obj.m_corrForwardSolution.SelectedSources(1,i).idx);
                    end
                    value = value(bIdx);
                else
                    value = obj.m_selectedActivatedSources;
                end
            else
                value = [];
            end
        end

        %% get.numActivatedSources Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.numActivatedSources(obj)
            if obj.ActivationAvailable
                value = length(obj.SelectedActivatedSources);
            else
                value = [];
            end
        end
        
        %% get.numSamples Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.numSamples(obj)
            if obj.ActivationAvailable
                value = obj.m_Activation.dipoleMap.values.data(1,1).iNumSamples;
            else
                value = [];
            end
        end
        
        
        %% get.UseForwardSolutionSelection Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.UseForwardSolutionSelection(obj)
            value = obj.m_bUseForwardSolutionSelection;
        end
        
        %% set.UseForwardSolutionSelection Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param bool ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.UseForwardSolutionSelection(obj, bool)
            obj.m_bUseForwardSolutionSelection = bool;
            obj.resetActivatedSourceSelection();
        end
        

%##########################################################################
        %% addActivation Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param p_iLFIdx ToDo
        %> @param p_matTimeCourse ToDo
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % =================================================================
        function addActivation(obj, p_iLFIdx, p_matTimeCourse, varargin)
            
            p = inputParser;
            p.addRequired('p_iLFIdx', @(x)isvector(x) &&...
                min(x) > 0 &&...
                max(x) <= obj.m_corrForwardSolution.defaultSolutionSourceSpace.numSources)
            p.addRequired('p_matTimeCourse', @(x)isnumeric(x))
            p.addParamValue('nn', [], @(x)isnumeric(x) && size(x,2) == 3)
            p.addParamValue('activation', [], @(x)isvector(x))
            p.parse(p_iLFIdx, p_matTimeCourse, varargin{:});
            
            LFIdx = p.Results.p_iLFIdx;
            TimeCourse = p.Results.p_matTimeCourse;
            normVec =  p.Results.nn;
            activation = p.Results.activation;
            
            
            if size(TimeCourse,1) == 1 && size(TimeCourse,1) < size(TimeCourse,2) % Same Timecourse for all components
                TimeCourse = TimeCourse';
            elseif length(LFIdx)*3 == size(TimeCourse,2) % Timecourse for each component
                TimeCourse = TimeCourse';
            end
            
            if length(LFIdx)*3 == size(TimeCourse,1) % Timecourse for each component
                for i = 1:length(LFIdx)
                    dipole = sl_CDipole(TimeCourse((i-1)*3+1:(i-1)*3+3,:));
                    obj.m_Activation.dipoleMap.addDipole(LFIdx(i), dipole);
                end
            elseif size(TimeCourse,2) == 1 % Same Timecourse for all components
                if isempty(normVec)
                    nn = [obj.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,1).nn; obj.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,2).nn];
                    normVec = nn(LFIdx,:);
                else
                    if size(normVec,1) == 1
                        normVec = repmat(normVec,length(LFIdx),1);
                    elseif size(normVec,1) ~= length(LFIdx)
                        error('Number of Normals does not match the Number of LF Indeces.');
                    end
                end

                for i = 1:length(LFIdx)
                    sig = TimeCourse*normVec(i,:);
                    dipole = sl_CDipole(sig);
                    obj.m_Activation.dipoleMap.addDipole(LFIdx(i), dipole);
                end
            end
            
            
            if isempty(activation)
                for i=1:length(LFIdx)
                    obj.m_Activation.numIndependentSources = obj.m_Activation.numIndependentSources + 1;
                    obj.m_Activation.source.act_label = [obj.m_Activation.source.act_label obj.m_Activation.numIndependentSources];
                    obj.m_Activation.source.activation = [obj.m_Activation.source.activation 1];
                end
            elseif length(activation) == 1
                obj.m_Activation.numIndependentSources = obj.m_Activation.numIndependentSources + 1;
                obj.m_Activation.source.activation = [obj.m_Activation.source.activation activation];
                for i=1:length(LFIdx)
                    obj.m_Activation.source.act_label = [obj.m_Activation.source.act_label obj.m_Activation.numIndependentSources];
                end
            elseif length(activation) == length(LFIdx)
                for i=1:length(LFIdx)
                    obj.m_Activation.numIndependentSources = obj.m_Activation.numIndependentSources + 1;
                    obj.m_Activation.source.act_label = [obj.m_Activation.source.act_label obj.m_Activation.numIndependentSources];
                    obj.m_Activation.source.activation = [obj.m_Activation.source.activation activation(i)];
                end
            else
                error('Parameter activation has wrong size');
            end
        end
        
        %% resetActivatedSourceSelection Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function resetActivatedSourceSelection(obj)
            if obj.ActivationAvailable
                obj.m_selectedActivatedSources = obj.AvailableActivatedSources;
            else
                obj.m_selectedActivatedSources = [];
            end
        end
        
        %% plot 
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
            if obj.ROISpaceAvailable && obj.SourceSpaceAvailable
                for h = 1:obj.sizeSourceSpace %%LH and RH
                    %% LH && RH
                    color = ones(length(obj.m_BrainAtlas(1,h).vertices),3)*255;
                    
                    lg_idx = ismember(obj.m_corrForwardSolution.AvailableSources(1,h).idx,obj.SelectedActivatedSources);
                    sel = obj.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(lg_idx);
                    if length(sel) > 0
                        color(sel,:) = repmat([255 0 0], length(sel), 1);
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
                        if obj.ActivationAvailable
                            sel_rois = obj.m_corrForwardSolution.idx2Label(obj.SelectedActivatedSources);
                        else
                            sel_rois = obj.m_vecSelectedROIs(1,h).label;
                        end
                        alpha(ismember(obj.ROILabel(1,h).label,sel_rois)) = 1;
                        set(p,'FaceVertexAlphaData',alpha,'FaceAlpha','interp');
                    end
                    
                    set(gca,'Alim',[0 1]);

                    % LH && RH  end
                    hold on;
                end
                title('Inverse Solution');

                light('Position',[1 1 0],'Style','infinite');
                light('Position',[-1 -1 0],'Style','infinite');

                %shading interp
    %            set(gcf,'Renderer','zbuffer')
                set(findobj(gca,'type','surface'),...
                    'AmbientStrength',.3,'DiffuseStrength',.8,...
                    'SpecularStrength',.9,'SpecularExponent',25,...
                    'BackFaceLighting','unlit')
            end
            
            
            if obj.ActivationAvailable
                %% Plot Source Grid 
                hold on
                
                rr = [];
                nn = [];
                
                for h = 1:obj.sizeSourceSpace %%LH and RH
                    rr = [rr; obj.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,h).rr];
                    nn = [nn; obj.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,h).nn];
                end
                
                color_map = jet(obj.m_Activation.numIndependentSources);
                
                
                selection = obj.SelectedActivatedSources;
                act_label = obj.m_Activation.source.act_label(ismember(obj.m_Activation.dipoleMap.keys.data,selection));
                
                for i = 1:obj.m_Activation.numIndependentSources
                    idcs = ismember(act_label, i);
                    sel_cur = selection(idcs);
                    act_cur = obj.m_Activation.source.activation(i);
                    
                    hold on;
                    plot3(rr(sel_cur,1),rr(sel_cur,2),rr(sel_cur,3),'gd','MarkerFaceColor',color_map(i,:),'MarkerSize',10*act_cur)
                    quiver3(rr(sel_cur,1),rr(sel_cur,2),rr(sel_cur,3),nn(sel_cur,1),nn(sel_cur,2),nn(sel_cur,3),0.5)
                end
            end
            
            axis equal;
            hold off
        end
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
            type = sl_Type.InverseSolution;
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
            name = 'Inverse Solution';
        end % Name
    end % static methods
end % classdef

