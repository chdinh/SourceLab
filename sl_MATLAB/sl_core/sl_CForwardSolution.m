%> @file    sl_CForwardSolution.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	February, 2012
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
classdef sl_CForwardSolution < sl_CROISpace
    %% sl_CForwardSolution
    properties %(Access = private)
        %> ToDo
        m_ForwardSolution
        
        %> ToDo
        m_vecSelectedChannels
        %> ToDo
        m_selectedSources
        
        %> ToDo
        m_ROIDistanceMap
        
        %> ToDo
        m_bDebug
    end % properties (Access = private)
    
    properties (Dependent)%, Access = protected)
        %> ToDo
        sizeForwardSolution
    end % properties (Dependent)

    properties (Dependent, SetAccess = private)
        %> ToDo
        ForwardSolutionAvailable
        %> Lead Field data
        data;
        %> ToDo
        src;

        %> ToDo
        AvailableChannels
        %> ToDo
        SelectedChannels
        %> ToDo
        numChannels;
        
        %> ToDo
        AvailableSources
        %> ToDo
        SelectedSources
        %> ToDo
        numSources
        
        %> ToDo
        ROIDistanceMap
        
        %> ToDo
        defaultSolutionSourceSpace % containing original data
        
        %> ToDo Judith
        % ToDO combine eeg_loc, eeg_src_norm, eeg_loc_norm to one eeg_sensor struct!!!
        eeg_loc
        eeg_src_norm
        eeg_loc_norm
        
    end % properties
    
    methods
        %% sl_CForwardSolution Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CForwardSolution class.
        % =================================================================
        function obj = sl_CForwardSolution(varargin) %, p_GPUDevice)
            p = inputParser;
            p.addOptional('p_sLeadFieldSource', [], @(x)ischar(x) || isempty(x) || isa(x,'sl_CForwardSolution'))
            p.addOptional('p_sLhFilename', [], @(x)ischar(x) || isempty(x))
            p.addOptional('p_sRhFilename', [], @(x)ischar(x) || isempty(x))
            p.addParamValue('debugGrid', [], @ischar)
            p.addParamValue('debugLF', [], @ischar);
            p.parse(varargin{:});
            
            obj = obj@sl_CROISpace(p.Results.p_sLeadFieldSource,...
                p.Results.p_sLhFilename,...
                p.Results.p_sRhFilename);
            
            obj.m_bDebug = false;
            if nargin == 1 && isa(p.Results.p_sLeadFieldSource, 'sl_CForwardSolution') % Copy Constructor
                obj.m_ForwardSolution = p.Results.p_sLeadFieldSource.m_ForwardSolution;
                obj.m_vecSelectedChannels = p.Results.p_sLeadFieldSource.m_vecSelectedChannels;
                obj.m_selectedSources = p.Results.p_sLeadFieldSource.m_selectedSources;
                obj.m_ROIDistanceMap = p.Results.p_sLeadFieldSource.m_ROIDistanceMap;
            else
                if ~isempty(p.Results.debugLF)
                    obj.m_ForwardSolution.sol.data = sl_CUtility.readSLMat(p.Results.debugLF,'LeadField');
                    [obj.m_ForwardSolution.sol.nrow, obj.m_ForwardSolution.sol.ncol] = size(obj.m_ForwardSolution.sol.data);
                    obj.m_ForwardSolution.nchan = obj.m_ForwardSolution.sol.nrow;
                    obj.m_ForwardSolution.nsource = obj.m_ForwardSolution.sol.ncol/3;
                    obj.m_bDebug = true;

                    if ~isempty(p.Results.debugGrid)
                        if exist(p.Results.debugGrid, 'file')
                            obj.m_ForwardSolution.source_rr = sl_CUtility.readSLMat(p.Results.debugGrid, 'Grid');
                        end
                    end

                elseif ~isempty(p.Results.p_sLeadFieldSource)
                    obj.m_ForwardSolution = sl_CForwardSolution.read(p.Results.p_sLeadFieldSource);
                else
                    obj.m_ForwardSolution = [];
                end
                
                obj.m_ROIDistanceMap = [];

                obj.resetChannelSelection();
                obj.resetSourceSelection();
            end
        end % sl_CForwardSolution

%##########################################################################
%# get/set (Dependent, Access = protected)
%##########################################################################
        %% get.sizeForwardSolution
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.sizeForwardSolution(obj)
            if obj.SourceSpaceAvailable || obj.ROISpaceAvailable
                value = obj.sizeROISpace;
            elseif obj.ForwardSolutionAvailable && isfield(obj.m_ForwardSolution, 'src')
                value = length(obj.m_ForwardSolution.src);
            else
                value = [];
            end
        end % get.sizeForwardSolution

%##########################################################################
%# get/set (Dependent, SetAccess = private)
%##########################################################################
        %% get.ForwardSolutionAvailable
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.ForwardSolutionAvailable(obj)
            if isempty(obj.m_ForwardSolution)
                value = false;
            else
                value = true;
            end
        end % get.ForwardSolutionAvailable

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
        function value = get.data(obj)
            if obj.m_bDebug
                value = obj.m_ForwardSolution.sol.data;
            elseif obj.ForwardSolutionAvailable
                idx = obj.SelectedSources(1,1).idx;
                for h = 2:obj.sizeForwardSolution
                    idx = [idx, obj.SelectedSources(1,h).idx];
                end
                tripletIdx = sl_CForwardSolution.tripletSelection(idx);
                value = obj.m_ForwardSolution.sol.data(obj.m_vecSelectedChannels,tripletIdx);
            else
                value = [];
            end
        end % get.data
        
        %% get.src
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.src(obj)
            if obj.ForwardSolutionAvailable
                for i = 1:obj.sizeForwardSolution
                    if i > 1 %Continous Indexing
                        idx = obj.SelectedSources(1,i).idx - obj.AvailableSources(1,i-1).idx(end);
                    else
                        idx = obj.SelectedSources(1,i).idx;
                    end
                    value(1,i).rr = obj.defaultSolutionSourceSpace.src(1,i).rr(idx,:);
                    value(1,i).nn = obj.defaultSolutionSourceSpace.src(1,i).nn(idx,:);
                end
            else
                value = [];
            end
        end % get.src
        
        %% get.AvailableChannels
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.AvailableChannels(obj)
            if obj.ForwardSolutionAvailable
                value = 1:obj.defaultSolutionSourceSpace.numChannels;
            else
                value = [];
            end
        end % get.AvailableChannels
        
        %% get.SelectedChannels
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SelectedChannels(obj)
            value = obj.m_vecSelectedChannels;
        end % get.SelectedChannels

        %% get.numChannels
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.numChannels(obj)
            if obj.ForwardSolutionAvailable
                if isempty(obj.m_vecSelectedChannels)
                    value = obj.m_ForwardSolution.nchan;
                else
                    value = length(obj.m_vecSelectedChannels);
                end
            else
                value = [];
            end
        end % get.numChannels

        %% get.AvailableSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function values = get.AvailableSources(obj)
            if obj.ForwardSolutionAvailable
                for i = 1:obj.sizeForwardSolution
                    values(1,i).idx = 1:length(obj.defaultSolutionSourceSpace.src(1,i).vertno);
                    if i > 1 %Continous Indexing
                        values(1,i).idx = values(1,i).idx + values(1,i-1).idx(end);
                    end
                    %values(1,i).label = obj.ROILabel(1,i).label(obj.defaultSolutionSourceSpace.src(1,i).vertno)';
                end
            else
                values = [];
            end
        end
        
        %% get.SelectedSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function values = get.SelectedSources(obj)
            if obj.ForwardSolutionAvailable
                if obj.ROISpaceAvailable %ROI masking
                    for i = 1:obj.sizeForwardSolution
                        label = obj.SelectedROIs(1,i).label;
                        
                        vertno_labeled = obj.ROILabel(1,i).label(obj.defaultSolutionSourceSpace.src(1,i).vertno);
                    
                        idcs = find(ismember(vertno_labeled,obj.SelectedROIs(1,i).label));
                        
                        if i > 1 %Continous Indexing
                            idcs = idcs + obj.AvailableSources(1,i-1).idx(end);
                        end
                        
                        values(1,i).idx = idcs(ismember(idcs,obj.m_selectedSources(1,i).idx))';
                    end
                elseif obj.SourceSpaceAvailable %Hemisphere masking
                    for i = 1:obj.sizeForwardSolution
                        if isempty(find(ismember(obj.SelectedHemispheres, i),1))
                            values(1,i).idx = [];
                        else
                            values(1,i).idx = obj.m_selectedSources(1,i).idx;
                        end
                    end
                else %No Masking
                    values = obj.m_selectedSources;
                end
            else
                values = [];
            end
        end % get.SelectedSources
        
        %% get.numSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.numSources(obj)
            if isempty(obj.m_ForwardSolution)
                value = [];
            else
                value = size(obj.data,2)/3;
            end
        end % get.numSources
        
        %% get.ROIDistanceMap
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.ROIDistanceMap(obj)
            if isempty(obj.m_ROIDistanceMap)
                value = [];
            else
                value = obj.m_ROIDistanceMap;
            end
        end % get.ROIDistanceMap

        %% get.defaultSolutionSourceSpace
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function dSSS = get.defaultSolutionSourceSpace(obj)
            if obj.SourceSpaceAvailable && isfield(obj.m_ForwardSolution, 'src')
                dSSS.data = obj.m_ForwardSolution.sol.data;
                dSSS.numChannels = obj.m_ForwardSolution.nchan;
                dSSS.numSources = obj.m_ForwardSolution.nsource;

                for i = 1:obj.sizeForwardSolution
                    dSSS.src(1,i).rr = obj.m_ForwardSolution.src(1,i).rr(obj.m_ForwardSolution.src(1,i).vertno,:);
                    dSSS.src(1,i).nn = obj.m_ForwardSolution.src(1,i).nn(obj.m_ForwardSolution.src(1,i).vertno,:);
                    dSSS.src(1,i).vertno = obj.m_ForwardSolution.src(1,i).vertno';
                    if obj.ROISpaceAvailable
                        dSSS.src(1,i).label = obj.ROILabel(1,i).label(dSSS.src(1,i).vertno);
                    else
                        dSSS.src(1,i).label = [];
                    end
                end
            else
                dSSS.data = [];
                dSSS.numChannels = [];
                dSSS.numSources = [];
                dSSS.src.rr = [];
                dSSS.src.nn = [];
                dSSS.src.vertno = [];
            end
        end % get.defaultSolutionSourceSpace

        %% get.eeg_loc Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo Judith
        % =================================================================
        function value = get.eeg_loc(obj)
            if ~isempty(obj.src) && isfield(obj.m_ForwardSolution, 'chs')
                value.eeg_loc = [];
                for i=1:obj.m_ForwardSolution.nchan
                    value(1,i).eeg_loc = obj.m_ForwardSolution.chs(1,i).eeg_loc;
                end
            else
                value = [];
            end
        end % get.eeg_loc
                
        %% get.eeg_src_norm Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo Judith
        % =================================================================
        function value = get.eeg_src_norm(obj)
                if ~isempty(obj.src) && ~isempty(obj.eeg_loc)
                    elecCoord=[];
                    tmp_eeg_loc = obj.eeg_loc;
                    for j= 1:obj.m_ForwardSolution.nchan
                        if obj.m_ForwardSolution.chs(1,j).kind == 2
                            elecCoord=[elecCoord tmp_eeg_loc(1,j).eeg_loc(:,1)];
                        end
                    end
                    if ~isempty(elecCoord)
                       % substact mean of elecCoord for normalization
                        elecCoord_ms=zeros(3,size(elecCoord,2));
                        for i=1:3
                            elecCoord_ms(i,:)=elecCoord(i,:)-mean([obj.src(1,1).rr(:,i)' obj.src(1,2).rr(:,i)' elecCoord(i,:)]);
                        end




                        for i=1:obj.sizeForwardSolution
                            for j=1:3 % coordinates
                                value(1,i).rr(:,j)=obj.src(1,i).rr(:,j)-mean(mean([obj.src(1,1).rr(:,j)' obj.src(1,2).rr(:,j)' elecCoord(j,:)]));
                            end
                        end


                        norm_val=max(max(abs([value(1,1).rr' value(1,2).rr' elecCoord_ms])));
                        for i=1:obj.sizeForwardSolution
                            value(1,i).rr=value(1,i).rr./norm_val;
                        end
                    else
                        value = [];
                    end
                else
                    value = [];
                end
        end % get.eeg_src_norm
        
        %% get.eeg_loc_norm Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo Judith
        % =================================================================
        function value = get.eeg_loc_norm(obj)
            if ~isempty(obj.src) && ~isempty(obj.eeg_loc)
                elecCoord=[];
                tmp_eeg_loc = obj.eeg_loc;
                for j = 1:obj.m_ForwardSolution.nchan
                    if obj.m_ForwardSolution.chs(1,j).kind == 2
                        elecCoord=[elecCoord tmp_eeg_loc(1,j).eeg_loc(:,1)];
                    end
                end
                if ~isempty(elecCoord)
                    for i=1:3
                        elecCoord(i,:)=elecCoord(i,:)-mean([ obj.src(1,1).rr(:,i)' obj.src(1,2).rr(:,i)' elecCoord(i,:)]);
                    end

                    % substract mean of source space data

                        for i=1:obj.sizeForwardSolution
                            for j=1:3 % coordinates
                            src_ms(1,i).rr(:,j)=obj.src(1,i).rr(:,j)-mean(mean([obj.src(1,1).rr(:,j)' obj.src(1,2).rr(:,j)' elecCoord(j,:)]));
                            end
                        end

                    elecCoord=elecCoord./(max(max(abs([src_ms(1,1).rr' src_ms(1,2).rr' elecCoord]))));
                end
                value = elecCoord;
%                 for i=1:size(obj.SelectedChannels,2)
%                  value(1,+size(obj.AvailableChannels,2)-size(obj.SelectedChannels,2)).eeg_loc(:,1)=obj.eeg_loc(1,i+size(obj.AvailableChannels,2)-size(obj.SelectedChannels,2)).eeg_loc(:,1)-mean(mean([elecCoord]));
%                 end
%                 for i=1:306
%                  value(1,i).eeg_loc(:,1)=[];
%                 end   
%                 norm_val=max(max(abs([value(1,1).rr' value(1,2).rr' eeg_loc_mat])));
%                for i=1:size(eeg_loc,2)
%                    value(:,i).eeg_loc=value(:,i).eeg_loc./norm_val;
%                end
            else
                value = [];
            end
        end % get.eeg_loc_norm
       
%##########################################################################
%#  methods
%##########################################################################
        %% selectChannels
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_vecChannelSelection ToDo
        % =================================================================
        function selectChannels(obj, p_vecChannelSelection)
            p = inputParser;
            p.addRequired('p_vecChannelSelection', @(x)isvector(x) &&...
                min(x) >= 1 &&...
                max(x) <= obj.defaultSolutionSourceSpace.numChannels ||...
                isempty(x))
            p.parse(p_vecChannelSelection);
            
            obj.m_vecSelectedChannels = p.Results.p_vecChannelSelection;
            obj.m_vecSelectedChannels = sort(obj.m_vecSelectedChannels);            
        end % selectChannels

        %% resetChannelSelection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function resetChannelSelection(obj)
            if obj.ForwardSolutionAvailable
                obj.m_vecSelectedChannels = obj.AvailableChannels();
            else
                obj.m_vecSelectedChannels = [];
            end
        end % resetChannelSelection

        %% selectSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_vecIdxSelection ToDo
        % =================================================================
        function selectSources(obj, p_vecIdxSelection)
            p = inputParser;
            p.addRequired('p_vecIdxSelection', @(x)isnumeric(x) || isempty(x))
            p.parse(p_vecIdxSelection);
            
            
            for i = 1:obj.sizeForwardSolution
                if isempty(p.Results.p_vecIdxSelection)
                    obj.m_selectedSources(1,i).idx = [];
                else
                    bIdx = ismember(obj.AvailableSources(1,i).idx, p.Results.p_vecIdxSelection);
                    obj.m_selectedSources(1,i).idx = obj.AvailableSources(1,i).idx(bIdx);
                end
            end
        end % selectSources

        %% resetSourceSelection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function resetSourceSelection(obj)
            if obj.ForwardSolutionAvailable && ~obj.m_bDebug;
                obj.m_selectedSources = obj.AvailableSources;
            else
                obj.m_selectedSources = [];
            end
        end % resetSourceSelection
               
        %% idx2Label
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_vecIdx ToDo
        % =================================================================
        function labelValues = idx2Label(obj, p_vecIdx)
            p = inputParser;
            p.addRequired('p_vecIdx', @isvector)
            p.parse(p_vecIdx);
            
            labelValues = [];
            
            if obj.ROISpaceAvailable && obj.ForwardSolutionAvailable
                for i = 1:obj.sizeForwardSolution
                    bIdx = ismember(obj.AvailableSources(1,i).idx, p.Results.p_vecIdx);
                    labelValues = [labelValues; obj.defaultSolutionSourceSpace.src(1,i).label(bIdx)];
                end
            end
        end % idx2label

        %% getRadialSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param angel ToDo
        %>
        %> @retval radialSel ToDo
        %> @retval degrees ToDo
        % =================================================================
        function [radialSel , degrees] = getRadialSources(obj, angel)
            rr = [];
            nn = [];
            for i = 1:obj.sizeForwardSolution
                rr = [rr; obj.defaultSolutionSourceSpace.src(1,i).rr];
                nn = [nn; obj.defaultSolutionSourceSpace.src(1,i).nn];
            end

            degrees = acosd(dot(rr, nn, 2)./(sqrt(sum(rr.^2,2)).*sqrt(sum(nn.^2,2))));
            
            radialSel = find(degrees <= angel | degrees >= 180-angel);
            degrees = degrees(radialSel);
        end % getRadialSources

        %% getTangentialSources
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param angel ToDo
        %>
        %> @retval tangentialSel ToDo
        %> @retval degrees ToDo
        % =================================================================
        function [tangentialSel, degrees] = getTangentialSources(obj, angel)
            rr = [];
            nn = [];
            for i = 1:obj.sizeForwardSolution
                rr = [rr; obj.defaultSolutionSourceSpace.src(1,i).rr];
                nn = [nn; obj.defaultSolutionSourceSpace.src(1,i).nn];
            end

            degrees = acosd(dot(rr, nn, 2)./(sqrt(sum(rr.^2,2)).*sqrt(sum(nn.^2,2))));
            
            tangentialSel = find(degrees >= 90-angel & degrees <= 90+angel);
            degrees = degrees(tangentialSel);
        end % getTangentialSources
        
        %% getROISources
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
        function roiSel = getROISources(obj, varargin)
            if obj.ROISpaceAvailable && obj.ForwardSolutionAvailable
                p = inputParser;
                p.addParamValue('lh', [], @(x)isnumeric(x) || iscellstr(x))
                p.addParamValue('rh', [], @(x)isnumeric(x) || iscellstr(x));
                p.parse(varargin{:});

                lh = p.Results.lh;
                rh = p.Results.rh;

                roiSel(1,1).idx = [];
                roiSel(1,2).idx = [];
                %LH
                if ~isempty(lh)
                    if iscellstr(lh)
                        LH_Ids = obj.atlasName2Label(lh);
                        LH_Ids = LH_Ids(1,1).label; 
                    else
                        LH_Ids = lh;
                    end
                    for i = 1:length(LH_Ids)
                        roiSel(1,1).idx = [roiSel(1,1).idx; find(obj.defaultSolutionSourceSpace.src(1,1).label == LH_Ids(i))];
                    end
                end
                roiSel(1,1).idx = sort(roiSel(1,1).idx);

                if ~isempty(rh)
                    if iscellstr(rh)
                        RH_Ids = obj.atlasName2Id(rh);
                        RH_Ids = RH_Ids(1,2).label;
                    else
                        RH_Ids = rh;
                    end
                    for i = 1:length(RH_Ids)
                        roiSel(1,2).idx = [roiSel(1,2).idx; find(obj.defaultSolutionSourceSpace.src(1,2).label == RH_Ids(i))];
                    end
                end
                roiSel(1,2).idx = sort(roiSel(1,2).idx);
            end
        end % get.getROISources
        
        
%         % =================================================================
%         function setLeadField(obj, p_matLeadField)
%             % ToDo check Lead Field Format
%             
%             
%             obj.clearSourceSelection();
%             
%             obj.m_ForwardSolution.sol.data = p_matLeadField;
%             
%             [obj.m_ForwardSolution.sol.nrow, obj.m_ForwardSolution.sol.ncol] = size(p_matLeadField);
%             obj.m_ForwardSolution.nchan = obj.m_ForwardSolution.sol.nrow;
%             obj.m_ForwardSolution.nsource = obj.m_ForwardSolution.sol.ncol/3;
%         end

        %% getCoordinate
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param vecLeadFieldIdx ToDo
        %>
        %> @return ToDo
        % =================================================================
        function coord = getCoordinate(obj, vecLeadFieldIdx)
            % ToDo change to absolut index
            coord = obj.m_ForwardSolution.source_rr(vecLeadFieldIdx,:);
        end % getCoordinate
        
        
        
%% functions for EEG simulator GUI
        %% getPosIdx Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param D_Pos ToDo Judith
        %>
        %> @return ToDo Judith
        % =================================================================
        function idx_pos = getPosIdx(obj, D_Pos)
            e_activate=0.08;
            for i=1:size(D_Pos,1) % works only for one fixed dipole !!
                 available_Pos=[obj.eeg_src_norm(1,1).rr' obj.eeg_src_norm(1,2).rr'];
                 %available_Pos=available_Pos(:,obj.m_selectedSources);
                 twoNorm = sqrt(sum(abs(available_Pos-repmat(D_Pos(i,:)',1,size(available_Pos,2))).^2,1)); %# The two-norm of each column
                 %idx_pos= twoNorm==min(twoNorm);
                 idx_pos=find(twoNorm<=min(twoNorm)+e_activate);
            end
             h1=[obj.SelectedSources(1,1).idx obj.SelectedSources(1,2).idx];
             idx_pos=h1(idx_pos);
        end % getPosIdx
        
        %% getPathIdcs Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param D_Pos ToDo Judith
        %>
        %> @return ToDo Judith
        % =================================================================
        function idcs = getPathIdcs(obj, p_Path)
             e_activate=0.08; %
             idcs=cell(size(p_Path,1),1);
             available_Pos=[obj.eeg_src_norm(1,1).rr' obj.eeg_src_norm(1,2).rr'];
             for i=1:size(p_Path,1) 
                 twoNorm = sqrt(sum(abs(available_Pos-repmat(p_Path(i,:)',1,size(available_Pos,2))).^2,1)); %# The two-norm of each column
                 idx_s=find(twoNorm==min(twoNorm));
                 %idx_s=find(twoNorm<=min(twoNorm)+e_activate);
                 idcs{i,1} = idx_s;
             end
        end % getPathIdcs
        
        %% getPathIdcs_2 Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param p_Path ToDo Judith
        %>
        %> @return ToDo Judith
        % =================================================================
        function path_idcs = getPathIdcs_2(obj, p_Path)
             % determine activation of start position (1 source)
             available_Pos=[obj.eeg_src_norm(1,1).rr' obj.eeg_src_norm(1,2).rr'];
             twoNorm = sqrt(sum(abs(available_Pos-repmat(p_Path(1,:)',1,size(available_Pos,2))).^2,1)); %# The two-norm of each column
             idx_pos_start=find(twoNorm<=min(twoNorm));
             pos_start=available_Pos(:,idx_pos_start);
             % determine activation of end position (one source)
             available_Pos=[obj.eeg_src_norm(1,1).rr' obj.eeg_src_norm(1,2).rr'];
             twoNorm = sqrt(sum(abs(available_Pos-repmat(p_Path(2,:)',1,size(available_Pos,2))).^2,1)); %# The two-norm of each column
             idx_pos_end=find(twoNorm<=min(twoNorm));
             pos_end=available_Pos(:,idx_pos_end);
             % 
             e_activate=0.15; % environment for activation
             e_newpos=0.09; % environment to look for new dipole position
             path_idcs={};
             cu_act=idx_pos_start;
             while cu_act ~= idx_pos_end
                 % determine environment
                 pos_cu_act=available_Pos(:,cu_act);
                 twoNorm = sqrt(sum(abs(available_Pos-repmat(available_Pos(:,cu_act),1,size(available_Pos,2))).^2,1)); %# The two-norm of each column
                 %idx_cu_act_envi=find(twoNorm<=min(twoNorm)+e_activate);
                 idx_cu_act_envi=find(twoNorm==min(twoNorm));
                 path_idcs=[path_idcs idx_cu_act_envi]; % set the path with activated environment

                 idx_cu_act_newpos=find(twoNorm<=min(twoNorm)+e_newpos);
                 pos_envi=available_Pos(:,idx_cu_act_newpos);
                 twoNorm_envi=sqrt(sum(abs(pos_envi-repmat(pos_end,1,size(pos_envi,2))).^2,1)); %# The two-norm of each column
                 new_act=find(twoNorm_envi==min(twoNorm_envi));

                 % Abbruchkriterium
                 if norm(available_Pos(idx_cu_act_newpos(new_act))-pos_end) < e_newpos
                    break;
                 else
                     cu_act=idx_cu_act_newpos(new_act);
                 end
             end
        end % getPathIdcs_2
        
        %% plot_DSPos Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo Judith
        % =================================================================         
        function plot_DSPos(obj, varargin)
            
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            p.addParamValue('dim', [], @(x)isscalar(x));
            p.addParamValue('ac_Srcs', [], @(x)isvector(x));
            p.parse(varargin{:});
            
            fig_h = p.Results.axesHandle;
            dim = p.Results.dim;
            ac_Srcs = p.Results.ac_Srcs;
            % split indices in right and left hemispshere
            idcs_rl=cell(1,2);
            
            idcs_rl{1,1}=ac_Srcs(ac_Srcs <= size(obj.src(1,1).rr,1)); % left hemissphere
            idcs_rl{1,2}=ac_Srcs(ac_Srcs > size(obj.src(1,1).rr,1)); % right hemissphere 
            
            if obj.ForwardSolutionAvailable
                % Plot Source Grid 
                hold on

                for i = 1:obj.sizeForwardSolution
                    if dim == 1
                        obj.plot_DSPos@sl_CROISpace(varargin{:});
                    elseif dim == 2 
                        obj.plot_DSPos@sl_CROISpace(varargin{:});
                    elseif dim == 3
                       obj.plot_DSPos@sl_CROISpace(varargin{:});                       
                    elseif dim == 4 % 3-dimensional plot                      
                        if ~isempty(idcs_rl{1,i})
                            h_idc=find(ismember(obj.SelectedSources(1,i).idx,idcs_rl{1,i}));
                        else
                            h_idc = [];
                        end
                        % select and plot active elements
                        idcs_plot_s1=obj.eeg_src_norm(1,i).rr(:,1);
                        idcs_plot_s1=idcs_plot_s1(h_idc);% ??
                        idcs_plot_s2=obj.eeg_src_norm(1,i).rr(:,2);idcs_plot_s2=idcs_plot_s2(h_idc); % ??
                        idcs_plot_s3=obj.eeg_src_norm(1,i).rr(:,3);idcs_plot_s3=idcs_plot_s3(h_idc); % ??
                        plot3(fig_h,idcs_plot_s1,idcs_plot_s2,idcs_plot_s3,'r*')                 
                    end
                end
            end          
            hold off
        end % plot_DSPos
        
        %% plot_3D_SourceSpace Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo Judith
        % =================================================================     
        function plot_3D_SourceSpace(obj, varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
            
            obj.plot_3D_SourceSpace@sl_CROISpace(varargin{:});
        end % plot_3D_SourceSpace
        
        %% plot_3D_ROISpace Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo Judith
        % =================================================================  
        function plot_3D_ROISpace(obj, varargin)
            p = inputParser;
            p.addParamValue('axesHandle', [], @(x)ishandle(x));
            %p.addParamValue('dim', [], @(x)isscalar(x));
            %p.addParamValue('ac_Srcs', [], @(x)isnumeric(x));
            p.parse(varargin{:});
                       
            obj.plot_3D_ROISpace@sl_CROISpace(varargin{:});
        end % plot_3D_ROISpace
        
        %% import_ft_ForwardSolution Judith
        % =================================================================
        %> @brief ToDo Judith
        %>
        %> ToDo Judith detailed description
        %>
        %> @param obj Instance of the class object
        %> @param p_matLF ToDo Judith
        %> @param p_structElecs ToDo Judith
        %> @param p_coordDip ToDo Judith
        % =================================================================  
        function import_ft_ForwardSolution(obj, p_matLF, p_structElecs, p_coordDip)  
            obj.clear();            
            obj.m_ForwardSolution.source_ori = 1; % no of hemispheres ..
            obj.m_ForwardSolution.coord_frame = 0; % ??
            obj.m_ForwardSolution.nsource = size(p_coordDip,1); % no of sources for calculation of lf-matrix
            obj.m_ForwardSolution.nchan = size(p_matLF,1); % no of channels
            obj.m_ForwardSolution.sol.data = p_matLF; % leadfield matrix
            
            [obj.m_ForwardSolution.sol.nrow, obj.m_ForwardSolution.sol.ncol] = size(obj.m_ForwardSolution.sol.data);
            
            obj.m_ForwardSolution.sol.row_names = p_structElecs.label'; %??
            obj.m_ForwardSolution.sol.col_names = [];
            
            
            obj.m_ForwardSolution.src.vertno = 1:(obj.m_ForwardSolution.sol.ncol/3);
            obj.m_ForwardSolution.src.rr = p_coordDip;
            obj.m_ForwardSolution.src.nn = obj.m_ForwardSolution.src.rr./norm(obj.m_ForwardSolution.src.rr);
            obj.m_SourceSpace = obj.m_ForwardSolution.src;
            
            obj.m_ForwardSolution.sol_grad = []; % ??
            
            
            obj.m_ForwardSolution.source_rr = p_structElecs.pnt;  % coordinates of sources
            obj.m_ForwardSolution.source_nn = zeros(obj.m_ForwardSolution.nsource*3,3);           
            
            for i=1:size(p_matLF,1)
                %obj.m_ForwardSolution.chs(1,i).loc = p_structElecs.pnt(i,:);
                obj.m_ForwardSolution.chs(1,i).ch_name = p_structElecs.label(i,1);
                obj.m_ForwardSolution.chs(1,i).eeg_loc = p_structElecs.pnt(i,:);
            end
            
            obj.m_vecSelectedChannels = 1:size(p_matLF,1);
            obj.m_selectedSources(1,1).idx = linspace(1,ceil(size(p_structElecs.pnt,1)/2),ceil(size(p_structElecs.pnt,1)/2));
            obj.m_selectedSources(1,2).idx = linspace(ceil(size(p_structElecs.pnt,1)/2)+1,size(p_structElecs.pnt,1),floor(size(p_structElecs.pnt,1)/2));
           
            obj.m_bDebug = false;
            
            obj.resetHemisphereSelection();
            
            obj.resetChannelSelection();
            obj.resetSourceSelection();
        end % import_ft_ForwardSolution

        %% clusterForwardSolution
        % =================================================================
        %> @brief ToDo 
        %>
        %> ToDo detailed description
        %>
        %> @param obj Instance of the class object
        %> @param p_iClusterSize ToDo
        %> @param varargin ToDo 
        %>
        %> @return ToDo
        % =================================================================
        function p_ClusteredForwardSolution = clusterForwardSolution(obj, p_iClusterSize, varargin)
            p = inputParser;
            p.addRequired('p_iClusterSize', @isscalar);
            p.addOptional('p_vecPlotSensors', 0, @isvector);
            p.parse(p_iClusterSize, varargin{:});
            p_iClusterSize = p.Results.p_iClusterSize;
            p_vecPlotSensors = p.Results.p_vecPlotSensors;
            
            if obj.ForwardSolutionAvailable && obj.ROISpaceAvailable
                p_ClusteredForwardSolution = sl_CForwardSolution(obj);
                
                t_LF_new = [];
                t_src_new(1,1).rr = [];
                t_src_new(1,1).nn = [];
                t_src_new(1,1).vertno = [];
                
                t_src_new(1,2).rr = [];
                t_src_new(1,2).nn = [];
                t_src_new(1,2).vertno = [];
                
                
                for h = 1:obj.sizeForwardSolution
                    disp('#######################################################################################');
                    disp(['########################## Cluster Hemisphere ' num2str(h) ' ##########################']);
                    disp('#######################################################################################');
                    label = obj.AvailableROIs(1,h).label;
                    for i = 1:length(label)
                        if label(i) ~= 0
                            curr_name = obj.label2AtlasName(label(i));
                            if h == 1
                                curr_name = [curr_name(1,1).names{1,1} ' left hemisphere'];
                                disp(['Cluster ' num2str(i) '/' num2str(length(label)) ', ' curr_name]);
                                p_ClusteredForwardSolution.selectROIs('lh',label(i),'rh',[]);
                            else
                                curr_name = [curr_name(1,2).names{1,1} ' right hemisphere'];
                                disp(['Cluster ' num2str(i) '/' num2str(length(label)) ', ' curr_name]);
                                p_ClusteredForwardSolution.selectROIs('lh',[],'rh',label(i));
                            end

                            t_LF = p_ClusteredForwardSolution.data;
                            
                            [t_iSensors, t_iSources_p] = size(t_LF);
                            
                            if t_iSources_p > 0
                                t_iSources = t_iSources_p/3;
                                t_iClusters = ceil(t_iSources/p_iClusterSize);
                                
                                fprintf('%d Cluster(s)\n', t_iClusters);

                                t_LF_partial = zeros(t_iSensors,t_iClusters*3);

                                for j = 1:t_iSensors %parfor
                                    t_sensLF = reshape(t_LF(j,:),3,[]);
                                    t_sensLF = t_sensLF';

                                    % Kmeans Reduction
                                    opts = statset('Display','off');%'final');
%                                     %Euclidean
%                                     [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                         'Distance','sqEuclidean',...
%                                                         'Replicates',5,...
%                                                         'Options',opts);
%                                     %Correlation
%                                     [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                         'Distance','correlation',...
%                                                         'Replicates',5,...
%                                                         'Options',opts);
                                    %L1
                                    [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
                                                        'Distance','cityblock',...
                                                        'Replicates',5,...
                                                        'Options',opts);
%                                     [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                         'Distance','cosine',...
%                                                         'Replicates',5,...
%                                                         'Options',opts);
                                                    
                                                    
                                    ctrs_straight = ctrs';
                                    t_LF_partial(j,:) = ctrs_straight(:)';




                                    %Plot %% ToDo problem with ParFor
                                    if ~isempty(find(ismember(p_vecPlotSensors, j),1)) %plot the selected sensor
                                        %Before Clustering
                                        if h == 1
                                            color = obj.label2Color('lh',label(i));
                                        else
                                            color = obj.label2Color('rh',label(i));
                                        end
                                        figure('Name', 'Before Clustering');
                                        plot3(t_sensLF(:,1), t_sensLF(:,2), t_sensLF(:,3), 'o', 'MarkerSize', 6, 'MarkerFaceColor', color./255);
                                        title(['Sensor ' num2str(j) ' ' strrep(curr_name, '_', ' ')]);
                                        axis equal

                                        %After Clustring
                                        figure('Name', 'After Clustering');
                                        color_map = jet(t_iClusters);
                                        marker = ['+'; 'o';'s';'*';'.';'x';'d';'^';'v'];
                                        for k = 1:t_iClusters
                                            plot3(t_sensLF(idx==k,1),t_sensLF(idx==k,2),t_sensLF(idx==k,3),marker(k),'MarkerEdgeColor',color./255,'MarkerFaceColor',color./255,'MarkerSize',6);%'MarkerEdgeColor',color_map(k,:),'LineWidth',2,
                                            axis equal
                                            hold on
                                        end
                                        plot3(ctrs(:,1),ctrs(:,2),ctrs(:,3),'x',...
                                            'MarkerEdgeColor',color./255,'MarkerSize',12,'LineWidth',2)
                                        title(['Clustered Sensor ' num2str(j) ' ' strrep(curr_name, '_', ' ')]);
                                        sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);
                                        pause;
                                        close all;
                                    end
                                end

                                %Assign clustered data to new LeadField
                                t_LF_new = [t_LF_new t_LF_partial];

                                for k = 1:t_iClusters
                                    [~, n] = size(t_LF);
                                    nSources = n/3;
                                    idx = (k-1)*3+1;
                                    t_LF_partial_resized = repmat(t_LF_partial(:,idx:idx+2),1,nSources);
                                    t_LF_diff = sum(abs(t_LF-t_LF_partial_resized),1);

                                    t_LF_diff_dip = [];
                                    for l = 1:nSources
                                        idx = (l-1)*3+1;
                                        t_LF_diff_dip = [t_LF_diff_dip sum(t_LF_diff(idx:idx+2))];
                                    end

                                    %Take the closest coordinates
                                    sel_idx = ismember(t_LF_diff_dip, min(t_LF_diff_dip));
                                    rr = p_ClusteredForwardSolution.src(1,h).rr(sel_idx,:);
                                    nn = [0 0 0];
                                    t_src_new(1,h).rr = [t_src_new(1,h).rr; rr];
                                    t_src_new(1,h).nn = [t_src_new(1,h).nn; nn];

                                    rr_idx = ismember(p_ClusteredForwardSolution.defaultSolutionSourceSpace.src(1,h).rr, rr);
                                    vertno_idx = rr_idx(:,1) & rr_idx(:,2) & rr_idx(:,3);
                                    t_src_new(1,h).vertno = [t_src_new(1,h).vertno p_ClusteredForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(vertno_idx)];
                                end
                            end
                        end
                    end
                end
                
                
                %set new stuff;
                p_ClusteredForwardSolution.m_ForwardSolution.sol.data = t_LF_new;
                [p_ClusteredForwardSolution.m_ForwardSolution.sol.nrow,...
                    p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol] = size(t_LF_new);
                
                p_ClusteredForwardSolution.m_ForwardSolution.nsource = p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol/3;
                p_ClusteredForwardSolution.m_ForwardSolution.nchan = p_ClusteredForwardSolution.m_ForwardSolution.sol.nrow;
                
                source_rr = [];
                for h = 1:obj.sizeForwardSolution
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).vertno = t_src_new(1,h).vertno;
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).nuse = length(t_src_new(1,h).vertno);
                    source_rr = [source_rr; t_src_new(1,h).rr];
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).nuse_tri = 0;
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).use_tris = [];
                end
                p_ClusteredForwardSolution.m_ForwardSolution.source_rr = source_rr;
                p_ClusteredForwardSolution.m_ForwardSolution.source_nn = ...
                    p_ClusteredForwardSolution.m_ForwardSolution.source_nn(1:p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol,:);
                
                
                p_ClusteredForwardSolution.resetROISelection();
                p_ClusteredForwardSolution.resetSourceSelection();
                
                
            else
                p_ClusteredForwardSolution = [];
            end
        end % clusterForwardSolution
        
        
        %% clusterForwardSolutionNew
        % =================================================================
        %> @brief ToDo 
        %>
        %> ToDo detailed description
        %>
        %> @param obj Instance of the class object
        %> @param p_iClusterSize ToDo
        %> @param varargin ToDo 
        %>
        %> @return ToDo
        % =================================================================
        function p_ClusteredForwardSolution = clusterForwardSolutionNew(obj, p_iClusterSize, p_sMethod, varargin)
            p = inputParser;
            p.addRequired('p_iClusterSize', @isscalar);
            p.addRequired('p_sMethod', @ischar);
            p.addOptional('p_vecPlotSensors', [], @isvector);
            p.parse(p_iClusterSize, p_sMethod, varargin{:});
            p_iClusterSize = p.Results.p_iClusterSize;
            p_sMethod = p.Results.p_sMethod;
            p_vecPlotSensors = p.Results.p_vecPlotSensors;
            
            if obj.ForwardSolutionAvailable && obj.ROISpaceAvailable
                p_ClusteredForwardSolution = sl_CForwardSolution(obj);
                
                t_LF_new = [];
                t_src_new(1,1).rr = [];
                t_src_new(1,1).nn = [];
                t_src_new(1,1).vertno = [];
                
                t_src_new(1,2).rr = [];
                t_src_new(1,2).nn = [];
                t_src_new(1,2).vertno = [];
                
                
                for h = 1:obj.sizeForwardSolution
                    disp('#######################################################################################');
                    disp(['########################## Cluster Hemisphere ' num2str(h) ' ##########################']);
                    disp('#######################################################################################');
                    label = obj.AvailableROIs(1,h).label;
                    for i = 1:length(label)
                        if label(i) ~= 0
                            curr_name = obj.label2AtlasName(label(i));
                            if h == 1
                                curr_name = [curr_name(1,1).names{1,1} ' left hemisphere'];
                                disp(['Cluster ' num2str(i) '/' num2str(length(label)) ', ' curr_name]);
                                p_ClusteredForwardSolution.selectROIs('lh',label(i),'rh',[]);
                            else
                                curr_name = [curr_name(1,2).names{1,1} ' right hemisphere'];
                                disp(['Cluster ' num2str(i) '/' num2str(length(label)) ', ' curr_name]);
                                p_ClusteredForwardSolution.selectROIs('lh',[],'rh',label(i));
                            end

                            t_LF = p_ClusteredForwardSolution.data;
                            
                            [t_iSensors, t_iSources_p] = size(t_LF);
                            
                            if t_iSources_p > 0
                                t_iSources = t_iSources_p/3;
                                t_iClusters = ceil(t_iSources/p_iClusterSize);
                                
                                fprintf('%d Cluster(s)\n', t_iClusters);

                                t_LF_partial = zeros(t_iSensors,t_iClusters*3);

                                
                                t_sensLF = zeros(size(t_LF,2)/3, 3*t_iSensors);

                                for j = 1:t_iSensors
                                    t_sensLF_tmp = reshape(t_LF(j,:),3,[]);
                                    idx = ((j-1)*3)+1;
                                    t_sensLF(:,idx:idx+2) = t_sensLF_tmp';
                                end

                                % Kmeans Reduction
                                opts = statset('Display','off');%'final');
                                
                                [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
                                                    'Distance',p_sMethod,...
                                                    'Replicates',5,...
                                                    'Options',opts);
                                %Euclidean
%                                 [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                     'Distance','sqEuclidean',...
%                                                     'Replicates',5,...
%                                                     'Options',opts);



%                                     %Correlation
%                                     [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                         'Distance','correlation',...
%                                                         'Replicates',5,...
%                                                         'Options',opts);


%                                 %L1
%                                 [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                     'Distance','cityblock',...
%                                                     'Replicates',5,...
%                                                     'Options',opts);
                                                
                                                
                                                
%                                     [idx, ctrs] = kmeans(t_sensLF,t_iClusters,...
%                                                         'Distance','cosine',...
%                                                         'Replicates',5,...
%                                                         'Options',opts);

                                %
                                % Assign the centroid for each cluster to the partial LF
                                %
                                for c = 1:t_iClusters
                                    for j = 1:t_iSensors
                                        idxC = ((c-1)*3)+1;
                                        idxS = ((j-1)*3)+1;
                                        t_LF_partial(j,idxC:idxC+2) = ctrs(c,idxS:idxS+2);
                                    end
                                end


                                %Plot %% ToDo problem with ParFor
                                if (~isempty(p_vecPlotSensors) && (i == 30))% || i == 34))%plot the selected sensor -> 29+1 (29 = G_precentral Precentral gyrus)
                                    for j = 1:t_iSensors %parfor
                                        if ~isempty(find(ismember(p_vecPlotSensors, j),1)) %plot the selected sensor
                                            idxSens = (j-1)*3+1;
                                            t_sensLFSingle = t_sensLF(:,idxSens:idxSens+2);

                                            %Before Clustering
                                            if h == 1
                                                color = obj.label2Color('lh',label(i));
                                            else
                                                color = obj.label2Color('rh',label(i));
                                            end
                                            figure('Name', ['Sensor = ' int2str(j) ', NumClusters = ' int2str(t_iClusters) ', ' strrep(curr_name, '_', ' ')]);
                                            subplot(1,2,1);
%                                             plot3(t_sensLFSingle(:,1), t_sensLFSingle(:,2), t_sensLFSingle(:,3), 'o', 'MarkerSize', 6, 'MarkerFaceColor', color./255, 'MarkerEdgeColor', color./255);
% %                                             title(['Sensor ' num2str(j) ' ' strrep(curr_name, '_', ' ')]);
%                                             axis equal
%                                             grid on;
%                                             
%                                             if(mod(j,3) == 0) %Magnetometer
%                                                 axis([-0.00001 0.00001 -0.00001 0.00001 -0.00001 0.00001 0 1])
%                                             else
%                                                 axis([-0.0002 0.0002 -0.0002 0.0002 -0.0002 0.0002 0 1])
%                                             end;
%                                             xlabel('X')
%                                             ylabel('Y')
%                                             zlabel('Z')              
% %                                            view([0,0,1])%X-Y
% %                                            view([1,0,0])%Y-Z
%                                             view([0,-1,0])%X-Z

                                            plot(t_sensLFSingle(:,2), t_sensLFSingle(:,3), 'o', 'MarkerSize', 6, 'MarkerEdgeColor', color./255);
%                                             title(['Sensor ' num2str(j) ' ' strrep(curr_name, '_', ' ')]);
                                            axis equal
                                            grid on;
                                            
                                            if(mod(j,3) == 0) %Magnetometer
                                                axis([-0.00001 0.00001 -0.00001 0.00001])
                                            else
                                                axis([-0.0001 0.0001 -0.0001 0.0001])
                                            end;
                                            xlabel('Y')
                                            ylabel('Z')              


                                            %After Clustring
                                            subplot(1,2,2);
%                                             marker = ['+';'x';'s';'*';'.';'o';'d';'^';'v'];
%                                             for k = 1:t_iClusters
%                                                 plot3(t_sensLFSingle(idx==k,1),t_sensLFSingle(idx==k,2),t_sensLFSingle(idx==k,3),marker(k),'MarkerSize',6,'MarkerEdgeColor',color./255)%, 'MarkerEdgeColor',color_map(k,:),'LineWidth',2,
%                                                 axis equal
%                                                 hold on
%                                             end
%                                             grid on;
%                                             if(mod(j,3) == 0) %Magnetometer
%                                                 axis([-0.00001 0.00001 -0.00001 0.00001 -0.00001 0.00001 0 1])
%                                             else
%                                                 axis([-0.0002 0.0002 -0.0002 0.0002 -0.0002 0.0002 0 1])
%                                             end;
%                                                 
%                                             xlabel('X')
%                                             ylabel('Y')
%                                             zlabel('Z')              
% %                                            view([0,0,1])%X-Y
% %                                            view([1,0,0])%Y-Z
%                                             view([0,-1,0])%X-Z
%                                         
%                                             plot3(ctrs(:,idxSens),ctrs(:,idxSens+1),ctrs(:,idxSens+2),'x',...
%                                                 'MarkerEdgeColor','red','MarkerSize',12,'LineWidth',2)
% %                                             title(['Clustered Sensor ' num2str(j) ' ' strrep(curr_name, '_', ' ')]);

                                            marker = ['+';'x';'s';'*';'.';'o';'d';'^';'v'];
                                            for k = 1:t_iClusters
                                                plot(t_sensLFSingle(idx==k,2),t_sensLFSingle(idx==k,3),marker(k),'MarkerSize',8,'MarkerEdgeColor',color./255)%, 'MarkerEdgeColor',color_map(k,:),'LineWidth',2,
                                                axis equal
                                                hold on
                                            end
                                            grid on;
                                            if(mod(j,3) == 0) %Magnetometer
                                                axis([-0.00001 0.00001 -0.00001 0.00001])
                                            else
                                                axis([-0.0001 0.0001 -0.0001 0.0001])
                                            end;
                                                
                                            xlabel('Y')
                                            ylabel('Z')              

                                            plot(ctrs(:,idxSens+1),ctrs(:,idxSens+2),'x',...
                                                'MarkerEdgeColor','red','MarkerSize',14,'LineWidth',2)

                                            sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);

                                        end;
                                    end;
                                    sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);
                                    pause;
                                    close all;
                                end

                                %Assign clustered data to new LeadField
                                t_LF_new = [t_LF_new t_LF_partial];

                                for k = 1:t_iClusters
                                    [~, n] = size(t_LF);
                                    nSources = n/3;
                                    idx = (k-1)*3+1;
                                    t_LF_partial_resized = repmat(t_LF_partial(:,idx:idx+2),1,nSources);
                                    t_LF_diff = sum(abs(t_LF-t_LF_partial_resized),1);

                                    t_LF_diff_dip = [];
                                    for l = 1:nSources
                                        idx = (l-1)*3+1;
                                        t_LF_diff_dip = [t_LF_diff_dip sum(t_LF_diff(idx:idx+2))];
                                    end

                                    %Take the closest coordinates
                                    sel_idx = ismember(t_LF_diff_dip, min(t_LF_diff_dip));
                                    
                                    %if more than one is closest take the
                                    %first
                                    if(sum(sel_idx) > 1)
                                        oneIdcs = find(sel_idx);
                                        sel_idx = zeros(1, length(sel_idx));
                                        sel_idx(oneIdcs(1)) = 1;
                                        sel_idx = logical(sel_idx);
                                    end;
                                    
                                    rr = p_ClusteredForwardSolution.src(1,h).rr(sel_idx,:);
                                    nn = [0 0 0];
                                    t_src_new(1,h).rr = [t_src_new(1,h).rr; rr];
                                    t_src_new(1,h).nn = [t_src_new(1,h).nn; nn];
 
                                    rr_idx = ismember(p_ClusteredForwardSolution.defaultSolutionSourceSpace.src(1,h).rr, rr);
                                    vertno_idx = rr_idx(:,1) & rr_idx(:,2) & rr_idx(:,3);

                                    t_src_new(1,h).vertno = [t_src_new(1,h).vertno p_ClusteredForwardSolution.defaultSolutionSourceSpace.src(1,h).vertno(vertno_idx)];
                                end
                            end
                        end
                    end
                end

                %set new stuff;
                p_ClusteredForwardSolution.m_ForwardSolution.sol.data = t_LF_new;
                [p_ClusteredForwardSolution.m_ForwardSolution.sol.nrow,...
                    p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol] = size(t_LF_new);
                
                p_ClusteredForwardSolution.m_ForwardSolution.nsource = p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol/3;
                p_ClusteredForwardSolution.m_ForwardSolution.nchan = p_ClusteredForwardSolution.m_ForwardSolution.sol.nrow;
                
                source_rr = [];
                for h = 1:obj.sizeForwardSolution
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).vertno = t_src_new(1,h).vertno;
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).nuse = length(t_src_new(1,h).vertno);
                    source_rr = [source_rr; t_src_new(1,h).rr];
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).nuse_tri = 0;
                    p_ClusteredForwardSolution.m_ForwardSolution.src(1,h).use_tris = [];
                end
                p_ClusteredForwardSolution.m_ForwardSolution.source_rr = source_rr;
                p_ClusteredForwardSolution.m_ForwardSolution.source_nn = ...
                    p_ClusteredForwardSolution.m_ForwardSolution.source_nn(1:p_ClusteredForwardSolution.m_ForwardSolution.sol.ncol,:);
                
                
                p_ClusteredForwardSolution.resetROISelection();
                p_ClusteredForwardSolution.resetSourceSelection();
                
                
            else
                p_ClusteredForwardSolution = [];
            end        
        end % clusterForwardSolutionNew
        
        %% calculateROIDistanceMap
        % =================================================================
        %> @brief ToDo 
        %>
        %> ToDo detailed description
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function calculateROIDistanceMap(obj)
            t_iNumRois = length(obj.AvailableROIs(1,1).label) + length(obj.AvailableROIs(1,2).label);
            
            t_ForwardSolution = sl_CForwardSolution(obj);
            t_ROICoordinates.rr = [];
            t_count = 1;
            for i = 1:2
                for j = 1:length(obj.AvailableROIs(1,i).label)
                    if i == 1
                        t_ForwardSolution.selectROIs('lh',obj.AvailableROIs(1,1).label(j),'rh',[])
                    else
                        t_ForwardSolution.selectROIs('lh',[],'rh',obj.AvailableROIs(1,2).label(j))
                    end
                    t_ROICoordinates(1,t_count).rr = t_ForwardSolution.src(1,i).rr;
                    t_count = t_count + 1;
                end
            end
            
            obj.m_ROIDistanceMap = zeros(t_iNumRois);
            
            for i = 1:t_iNumRois-1
                t_rr = t_ROICoordinates(1,i).rr;
                for j = i+1:t_iNumRois
                    t_Distance = 999999;
                    for k = 1:size(t_rr,1)
                        t_rrRep = repmat(t_rr(k,:),size(t_ROICoordinates(1,j).rr,1),1);
                        t_rrDiff = t_rrRep - t_ROICoordinates(1,j).rr;
                        t_EuklidDistance = sum(t_rrDiff.^2,2).^0.5;
                        if min(t_EuklidDistance) < t_Distance
                            t_Distance = min(t_EuklidDistance);
                        end
                    end
                    obj.m_ROIDistanceMap(i,j) = t_Distance;
                    obj.m_ROIDistanceMap(j,i) = t_Distance;
                end
            end
        end % calculateROIDistanceMap
        
        %% clear
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        % =================================================================
        function clear(obj)
            obj.clear@sl_CROISpace();
            
            obj.m_ForwardSolution = [];
                    
            obj.m_vecSelectedChannels = [];
            obj.m_selectedSources = [];

            obj.m_ROIDistanceMap = [];

            obj.m_bDebug = [];
        end
        
        %% plot
        % =================================================================
        %> @brief ToDo 
        %>
        %> ToDo detailed description
        %>
        %> @param obj Instance of the class object
        %> @param varargin Instance of the class object
        % =================================================================
        function plot(obj, varargin)
            % plot
            % ToDo Check lead field format fuction -> Convert Function
            obj.plot@sl_CROISpace(varargin);

%             if obj.ForwardSolutionAvailable
%                 %% Plot Source Grid 
%                 hold on
% 
%                 for i = 1:obj.sizeForwardSolution
%                     plot3(obj.src(1,i).rr(:,1),obj.src(1,i).rr(:,2),obj.src(1,i).rr(:,3),'r*')
% 
%                    quiver3(obj.src(1,i).rr(:,1),obj.src(1,i).rr(:,2),obj.src(1,i).rr(:,3),...
%                        obj.src(1,i).nn(:,1),obj.src(1,i).nn(:,2),obj.src(1,i).nn(:,3),0.5)
%                 end
%             end
            
            title('Forward Solution');
            
            hold off
        end % plot
        
        %% plotBioMag
        % =================================================================
        %> @brief ToDo 
        %>
        %> ToDo detailed description
        %>
        %> @param obj Instance of the class object
        %> @param varargin Instance of the class object
        % =================================================================
        function plotBioMag(obj, varargin)
            % ToDo Check lead field format fuction -> Convert Function
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
                        'FaceColor',ones(1,3).*.5,...
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
                    'SpecularStrength',0,'SpecularExponent',0,...
                    'BackFaceLighting','unlit')
%             elseif obj.SourceSpaceAvailable
%                 %obj.plot@sl_CSourceSpace(varargin);
            end
            axis equal;
            hold off      

            if obj.ForwardSolutionAvailable
                % Plot Source Grid 
                hold on

                rr = [];

                label = obj.idx2Label(1:obj.numSources);
                
                %color = obj.label2Color(label);
                %[b,m,n] = unique(label);
                %colortable = rand(size(b,1),3);
                %colorofdipoles = colortable(n,:);
                sourceCount = 0;
                color = zeros(size(label,1),3);
                for i = 1:obj.sizeForwardSolution
                    rr = [rr; obj.src(1,i).rr];
                    
                    hemSize = size(obj.src(1,i).rr,1);
                    currLabel = label(1+sourceCount:hemSize+sourceCount);
                    for j = 1:length(currLabel)
                        if i == 1
                            color(j+sourceCount,:) = obj.label2Color('lh',currLabel(j));
                        else
                            [~ , color(j+sourceCount,:)] = obj.label2Color('rh',currLabel(j));
                        end;
                    end;
                    sourceCount = sourceCount + hemSize;
                end

                scatter3(rr(:,1),rr(:,2),rr(:,3),30,color./255,'filled');
                
            end
            
            title('Forward Solution');
            
            hold off
        end % plotBioMag

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
            type = sl_Type.ForwardSolution;
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
            name = 'Forward Solution';
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
        function fwdSolution = read(p_sFilename)
            p = inputParser;
            p.addRequired('p_sFilename', @ischar)
            p.parse(p_sFilename);
            fwdSolution = mne_read_forward_solution(p.Results.p_sFilename);
        end %read
        
        %% tripletSelection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_sFilename ToDo
        %>
        %> @return ToDo
        % =================================================================
        function triSelect = tripletSelection(p_vecIdxSelection)
            if size(p_vecIdxSelection,1) > 1
                p_vecIdxSelection = p_vecIdxSelection';
            end

            triSelect = repmat((p_vecIdxSelection - 1) * 3 + 1, 3, 1);
            triSelect = [triSelect(1,:); triSelect(2,:)+1; triSelect(3,:)+2];
            triSelect = triSelect(:);
        end % tripletSelection
    end % static methods
end % classdef

