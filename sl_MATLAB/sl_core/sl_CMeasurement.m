%> @file    sl_CMeasurement.m
%> @author  Christoph Dinh <christoph.dinh@live.de> & Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh & Peter Hoemmen. All rights reserved.
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
classdef sl_CMeasurement < sl_IValue
    %SL_CMEASUREMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties %(Access = private)
        %> ToDo
        m_cFile;
        
        %> ToDo
        m_data;
        
        %> ToDo
        m_aveData;
        
        %> ToDo
        m_cDataFlag;
        
        %> ToDo
        m_arrayDataChannelSet;
        
        %> ToDo
        m_bHDRAvailable;
        
        %> ToDo
        m_configFilter;
        
        %> ToDo
        m_configTrial;
        %> ToDo
        m_configJump;
        %> ToDo
        m_configMuscle;
        
%         m_matMeasurement
%         m_MeasurementHDR
%         m_vecTimes
    end % properties (Access = protected)
    
    properties (Dependent)
        %> ToDo
        data
        %> ToDo
        time
        
        %> ToDo
        grad
        %> ToDo
        mag
        %> ToDo
        eeg
        
        %> ToDo
        projectors
        
%         label
%         sensors
%         
        %> ToDo
        data_flag
        %> ToDo
        average
% 
        %> ToDo
        numChannels
        %> ToDo
        numSamples
        %> ToDo
        fSamplingFrequency % Hz
        
%        all
    end
    
    
    methods
        %% sl_CMeasurement Constructor
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param p_sFilename ToDo
        %>
        %> @return instance of the sl_CMeasurements class.
        % =================================================================
        function obj = sl_CMeasurement(p_sFilename)%, p_GPUDevice)
%             if nargin < 2
%                 obj.m_GPUDevice = 0;
%             else
%                 if isa(p_GPUDevice, 'sl_CGPUDevice')
%                     obj.m_GPUDevice = p_GPUDevice;
%                 else
%                     error('p_GPUDevice is not an object of the class sl_CGPUDevice.');
%                 end
%             end
            
            obj.m_data.trial = [];


            obj.m_configFilter = [];

            obj.m_configTrial = [];
            obj.m_configJump = [];
            obj.m_configMuscle = [];


            % Read continuous data
            if p_sFilename
                [~, ~, ext] = fileparts(p_sFilename);
                obj.m_cFile = p_sFilename;
                if strcmp(ext, '.txt')
                    obj.data = obj.read(p_sFilename);
                    obj.m_data.fsample = 600;
                    obj.m_bHDRAvailable = false;
                else
                    cfg.dataset = p_sFilename;
                    obj.m_data = ft_preprocessing(cfg);
                    obj.m_bHDRAvailable = true;
                    obj.data_flag = 'all';
                end
            else
                obj.m_bHDRAvailable = false;
            end

            %ToDo this has to be solved with varargin
%             if p_sFilename
%                 [obj.m_matMeasurement, obj.m_vecTimes, obj.m_MeasurementHDR] = obj.read(p_sFilename);
%             end
        end;
        
        %% update 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function update(obj)
            cfg = [];
            
            cfg.dataset = obj.m_cFile;
            
            if ~isempty(obj.m_configMuscle)
                cfg = sl_CUtility.catstruct(cfg, obj.m_configMuscle);
            elseif ~isempty(obj.m_configJump)
                cfg = sl_CUtility.catstruct(cfg, obj.m_configJump);
            elseif ~isempty(obj.m_configTrial)
                cfg = sl_CUtility.catstruct(cfg, obj.m_configTrial);
            end

            if ~isempty(obj.m_configFilter)
                cfg = sl_CUtility.catstruct(cfg, obj.m_configFilter);
            end
            
            obj.m_data = ft_preprocessing(cfg);
            
            %% do timelock analysis and average data
            if ~isempty(obj.m_configTrial)
                cfg = [];
                cfg.channel = {'MEG*' 'EEG*' 'EOG*'};
                obj.m_aveData = ft_timelockanalysis(cfg, obj.m_data);
            end
        end;
                
        %% get.grad
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.grad(obj)
            if obj.m_bHDRAvailable
                value = cellfun(@(x) strcmp(x, 'megplanar'), obj.m_data.hdr.chantype);
            else
                value = [];
            end
        end
        
        %% get.mag
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.mag(obj)
            if obj.m_bHDRAvailable
                value = cellfun(@(x) strcmp(x, 'megmag'), obj.m_data.hdr.chantype);
            else
                value = [];
            end
        end
        
        %% get.eeg 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.eeg(obj)
            if obj.m_bHDRAvailable
                value = cellfun(@(x) strcmp(x, 'eeg'), obj.m_data.hdr.chantype);
            else
                value = [];
            end
        end
        
        %% get.projectors
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.projectors(obj)
            if obj.m_bHDRAvailable
                value = obj.m_data.hdr.orig.projs;
            else
                value = [];
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
        function data = get.data(obj)
            if ~isempty(obj.m_data.trial)
                if length(obj.m_data.trial) > 1
                    data = obj.m_data.trial{1,1};
                    for i = 2:length(obj.m_data.trial)
                        data = [data obj.m_data.trial{1,i}];
                    end
                else
                    data = obj.m_data.trial{1,1};
                end
            else
                data = [];
            end
            
            %obj.m_matMeasurement;
        end
        
        %% get.time 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function time = get.time(obj)
            if ~isfield(obj.m_data, 'time')
                T = 1/obj.fSamplingFrequency;
                time = (1:length(obj.m_data.trial{1,1}))*T;
            elseif length(obj.m_data.trial) > 1
                size = 0;
                
                for i = 1:length(obj.m_data.trial)
                    size = size + length(obj.m_data.time{1,i});
                end
                
                T = 1/obj.fSamplingFrequency;
                
                time = (1:size)*T;
            else
                time = obj.m_data.time{1,1};
            end
        end
        
        %% set.time 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param time_vec ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.time(obj, time_vec)
            if size(time_vec,1) > 1
                obj.m_data.time{1,1} = time_vec';
            else
                obj.m_data.time{1,1} = time_vec;
            end
        end
        
        %% set.data 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_matData ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.data(obj,p_matData)
            obj.m_data.trial{1,1} = p_matData;
            
            obj.m_data.hdr.nChans = size(p_matData , 1);
            
            obj.m_data.sampleinfo(2) = size(p_matData , 2);
            
%             obj.m_MeasurementHDR.info.nchan = size(data, 1);
%             iTimeSteps = size(data, 2);
%             T = iTimeSteps/obj.m_MeasurementHDR.info.sfreq;
% 
%             obj.m_vecTimes = linspace(0,T,iTimeSteps);
        end
        
        %% get.data_flag
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function flag = get.data_flag(obj)
            flag = obj.m_cDataFlag;
            %obj.m_matMeasurement;
        end
        
        %% set.data_flag
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_cFlag
        %>
        %> @return ToDo
        % =================================================================
        function set.data_flag(obj, p_cFlag)
            %Magnetometer {'MEG*1'}
            %Gradiometer {'MEG*2' 'MEG*3'} 
            if strcmp(p_cFlag, 'all')
                obj.m_cDataFlag = 'all';
                obj.m_arrayDataChannelSet = {'MEG*' 'EEG*' 'EOG*'};
            elseif strcmp(p_cFlag, 'meg')
                obj.m_cDataFlag = 'meg';
                obj.m_arrayDataChannelSet = {'MEG*'};
            elseif strcmp(p_cFlag, 'eeg')
                obj.m_cDataFlag = 'eeg';
                obj.m_arrayDataChannelSet = {'EEG*'};
            elseif strcmp(p_cFlag, 'eog')
                obj.m_cDataFlag = 'eog';
                obj.m_arrayDataChannelSet = {'EOG*'};
            end
        end

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
            %value = obj.m_data.hdr.nChans;%
            value = size(obj.data,1);
%             if obj.m_matMeasurement == 0
%                 error('Data matrix is not set.');
%             else
%                 value = obj.m_MeasurementHDR.info.nchan;
%             end
        end
        
        %% get.numSamples
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.numSamples(obj)
            value = obj.m_data.sampleinfo(2);
%             if obj.m_matMeasurement == 0
%                 error('Data matrix is not set.');
%             else
%                 value = length(obj.m_vecTimes);
%             end;
        end
        
        %% get.fSamplingFrequency
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.fSamplingFrequency(obj)
            value = obj.m_data.fsample;
%             if obj.m_matMeasurement == 0
%                 error('Data are not loaded.');
%             else
%                 value = obj.m_MeasurementHDR.info.sfreq;
%             end;
        end
        
        %% set.fSamplingFrequency 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param value ToDo
        %>
        %> @return ToDo
        % =================================================================
        function set.fSamplingFrequency(obj, value)
            obj.m_data.fsample = value;
%             if obj.m_matMeasurement == 0
%                 error('Data are not loaded.');
%             else
%                 value = obj.m_MeasurementHDR.info.sfreq;
%             end;
        end
        
        
        %% applyTrialDefinition
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function applyTrialDefinition(obj)
            obj.m_configTrial.dataset = obj.m_cFile;
            
            obj.m_configTrial.trialdef.eventtype      = 'STI101';	% use '?' to get a list of the available types (see above)
            obj.m_configTrial.trialdef.eventvalue = 2048;           % define trial
            obj.m_configTrial.trialdef.prestim = .75;               % in seconds
            obj.m_configTrial.trialdef.poststim = .75;              % in seconds
            obj.m_configTrial.trialfun = 'trialfun_general';
            obj.m_configTrial = ft_definetrial(obj.m_configTrial);
        end
        
        %% applyJumpArtifactRejection 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_channelSet
        %>
        %> @return ToDo
        % =================================================================
        function applyJumpArtifactRejection(obj, p_channelSet)
            
            if ~isempty(obj.m_configTrial)
                obj.m_configJump = obj.m_configTrial;

                obj.m_configJump.continuous = 'yes';
                obj.m_configJump.padding = 1;
                obj.m_configJump.artfctdef.jump.medianfilter  = 'yes';
                obj.m_configJump.artfctdef.jump.medianfiltord = 9;
                obj.m_configJump.artfctdef.jump.absdiff = 'yes';
                obj.m_configJump.artfctdef.jump.channel = p_channelSet;
                obj.m_configJump.artfctdef.jump.cutoff = 20; % z-value at which to threshold
                obj.m_configJump = ft_artifact_jump(obj.m_configJump);
                obj.m_configJump = ft_rejectartifact(obj.m_configJump);
            else
                fprintf('Error! Trials are not defined...\n');
            end
        end
        
        %% applyMuscleArtifactRejection
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_channelSet
        %>
        %> @return ToDo
        % =================================================================
        function applyMuscleArtifactRejection(obj, p_channelSet)
            
            if ~isempty(obj.m_configJump)
                obj.m_configMuscle = obj.m_configJump;

                obj.m_configMuscle.continuous                   = 'yes';
                obj.m_configMuscle.padding                      = 1;
                obj.m_configMuscle.artfctdef.muscle.bpfilter    = 'yes';
                obj.m_configMuscle.artfctdef.muscle.bpfreq      = [110 140];
                obj.m_configMuscle.artfctdef.muscle.bpfiltord   = 8;
                obj.m_configMuscle.artfctdef.muscle.bpfilttype  = 'but';
                obj.m_configMuscle.artfctdef.muscle.hilbert     = 'yes';
                obj.m_configMuscle.artfctdef.muscle.boxcar      = 0.2;
                obj.m_configMuscle.artfctdef.muscle.channel     = p_channelSet;
                obj.m_configMuscle.artfctdef.muscle.cutoff      = 4; 
                obj.m_configMuscle	= ft_artifact_muscle(obj.m_configMuscle);
                obj.m_configMuscle	= ft_rejectartifact(obj.m_configMuscle);
            else
                fprintf('Error! Jump artifacts are not defined...\n');
            end
        end
        
        %% applyFilter
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function applyFilter(obj)
            obj.m_configFilter.bpfilter                     = 'yes';
            obj.m_configFilter.bpfreq                       = [1 40];          % cut off frequencies at 1Hz and 40Hz
            obj.m_configFilter.bpfiltord                    = 3;
            obj.m_configFilter.dftfilter                    = 'yes';
            obj.m_configFilter.demean                       = 'yes';           % do baseline correction
            obj.m_configFilter.baselinewindow               = [-0.08,-0.005];
            obj.m_configFilter.padding                      = 6;
        end
            

        %% read 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_sFilename
        %>
        %> @retval p_Measurement ToDo
        %>
        %> @return ToDo
        % =================================================================
        function [p_Measurement] = read(obj, p_sFilename)
            
            [~, ~, ext] = fileparts(p_sFilename);
            
            if strcmp(ext, '.txt')
                p_Measurement = sl_CUtility.readSLMat(p_sFilename, 'Measurement');
                
%                 p_MeasurementHDR.info.nchan = size(p_Measurement, 1);
%                 iTimeSteps = size(p_Measurement, 2);
%                 p_MeasurementHDR.info.sfreq = 400;
%                 T = iTimeSteps/p_MeasurementHDR.info.sfreq;
%                 
%                 p_Times = linspace(0,T,iTimeSteps);
%             elseif strcmp(ext, '.fif')
%                 [p_Measurement, p_Times, p_MeasurementHDR] = sl_CMeasurement.read_fif_raw(p_sFilename, true, false, false);
            end
        end %read
        
        %% addChannelInfo
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_fiffMeasurementFile ToDo
        % =================================================================
        function addChannelInfo(obj, p_fiffMeasurementFile)
            p = inputParser;
            p.addRequired('p_fiffMeasurementFile', @ischar)
            p.parse(p_fiffMeasurementFile);
            
            hdr = ft_read_header(p.Results.p_fiffMeasurementFile);
            
            if hdr.nChans > obj.numChannels
                kind = [hdr.orig.chs(1,:).kind];
                idx = find(kind == 1 | kind == 2); % MEG == 1; EEG == 2
                if obj.numChannels == length(idx)
                    hdr_new.label = {hdr.label{idx}}';
                    hdr_new.nChans = length(idx);
                    hdr_new.Fs = hdr.Fs;
                    if isfield(hdr,'grad')
                        hdr_new.grad = hdr.grad;
                    end
                    if isfield(hdr,'elec')
                        hdr_new.grad = hdr.elec;
                    end
                    hdr_new.unit = {hdr.unit{idx}};
                    hdr_new.chantype = {hdr.chantype{idx}}';
                    hdr_new.chanunit = {hdr.chanunit{idx}}';
                    hdr_new.orig = hdr.orig;
                    
                    hdr = hdr_new;
                end
            end
            hdr.nSamples = obj.numSamples;
            hdr.nSamplesPre = 0;
            hdr.nTrials = 1;
            obj.m_data.hdr = [];
            obj.m_data.hdr = hdr;
            obj.m_bHDRAvailable = true;
        end % addChannelInfo
        
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
            plot(obj.time, obj.data);
            
            title('Measurement');
            
            xlabel('Time [s]')
            %ToDo if EEG -> mV || if MEG -> mT
            ylabel('Magnitude');
            
            %%
            if ~isempty(obj.m_aveData)
                figure('Name','Average');
                plot(obj.m_aveData.time, obj.m_aveData.avg(1:306,:)');

                title('Measurement');

                xlabel('Time [s]')
                %ToDo if EEG -> mV || if MEG -> mT
                ylabel('Magnitude');
            end
        end
   end %methods

   %======================================================================
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
            type = sl_Type.Measurement;
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
            name = 'Measurement';
        end % getName
        
%         % =================================================================
%         function [p_Measurement, p_Times, p_MeasurementHDR] = read_fif_raw(p_sFilename, want_meg, want_eeg, want_stim)
%             me='SourceLab:read_fif_raw';
%             %%
%             p_MeasurementHDR = fiff_setup_read_raw(p_sFilename);
% 
%             %[data, time] = mne_ex_read_raw('Ch_int_000_46_raw.fif', raw_data.first_samp, raw_data.last_samp, true);
% 
%             keep_comp = true;
% 
%             in_samples = true;
% 
%             from = p_MeasurementHDR.first_samp;
%             to   = p_MeasurementHDR.last_samp;
% 
%             %
%             %   Set up pick list: MEG + STI 014 - bad channels
%             %
%             include = {};
%             %
%             picks = fiff_pick_types(p_MeasurementHDR.info,want_meg,want_eeg,want_stim,include,p_MeasurementHDR.info.bads);
%             %
%             %   Set up projection
%             %
%             if isempty(p_MeasurementHDR.info.projs)
%                 fprintf(1,'No projector specified for these data\n');
%                 p_MeasurementHDR.proj = [];
%             else
%                 %
%                 %   Activate the projection items
%                 %
%                 for k = 1:length(p_MeasurementHDR.info.projs)
%                     p_MeasurementHDR.info.projs(k).active = true;
%                 end
%                 fprintf(1,'%d projection items activated\n',length(p_MeasurementHDR.info.projs)); 
%                 %
%                 %   Create the projector
%                 %
%                 [proj,nproj] = mne_make_projector_info(p_MeasurementHDR.info);
%                 if nproj == 0
%                     fprintf(1,'The projection vectors do not apply to these channels\n');
%                     p_MeasurementHDR.proj = [];
%                 else
%                     fprintf(1,'Created an SSP operator (subspace dimension = %d)\n',nproj);
%                     p_MeasurementHDR.proj = proj;
%                 end
%             end
%             %
%             %   Set up the CTF compensator
%             %
%             current_comp = mne_get_current_comp(p_MeasurementHDR.info);
%             if current_comp > 0
%                 fprintf(1,'Current compensation grade : %d\n',current_comp);
%             end
%             if keep_comp
%                 dest_comp = current_comp;
%             end
%             if current_comp ~= dest_comp
%                 try
%                     p_MeasurementHDR.comp = mne_make_compensator(p_MeasurementHDR.info,current_comp,dest_comp);
%                     p_MeasurementHDR.info.chs  = mne_set_current_comp(p_MeasurementHDR.info.chs,dest_comp);
%                     fprintf(1,'Appropriate compensator added to change to grade %d.\n',dest_comp);
%                 catch
%                     error(me,'%s',mne_omit_first_line(lasterr));
%                 end
%             end
%             %
%             %   Read a data segment
%             %   times output argument is optional
%             %
%             try
%                 if in_samples
%                     [ p_Measurement, p_Times ] = fiff_read_raw_segment(p_MeasurementHDR,from,to,picks);
%                 else    
%                     [ p_Measurement, p_Times ] = fiff_read_raw_segment_times(p_MeasurementHDR,from,to,picks);
%                 end
%             catch
%                 fclose(p_MeasurementHDR.fid);
%                 error(me,'%s',mne_omit_first_line(lasterr));
%             end
%             fprintf(1,'Read %d samples.\n',size(p_Measurement,2));
%             %
%             %   Remember to close the file descriptor
%             %
%             fclose(p_MeasurementHDR.fid);
%             fprintf(1,'File closed.\n');
%         end %read_fif_raw
        %Methods in a separate file
    end % static methods 
end

