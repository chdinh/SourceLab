%> @file    sl_CSimulator.m
%> @author  Christoph Dinh <christoph.dinh@live.de>; 
%>          Alexander Hunold <alexander.hunold@tu-ilmenau.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh, Alexander Hunold. All rights reserved.
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
classdef sl_CSimulator < sl_CMeasurement
    %% sl_CSimulator
    properties %(Access = private)
        %> ToDo
        m_InverseSolution;
        
        %> ToDo
        m_matNoise;
        %> ToDo
        m_fNoiseScaling;
    end

    properties (Dependent)
        %> ToDo
        data_noise
        
        %> ToDo
        data_signal
        
        %> ToDo
        SourceActivation
    end
    
    methods
        %% sl_CSimulator Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param p_ForwardSolution ToDo
        %> @param p_fSamplingFrequency ToDo
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CSimulator class.
        % =================================================================
        function obj = sl_CSimulator(p_ForwardSolution, p_fSamplingFrequency, varargin)
	    % Copy Constructor - nargin == 0;
        
            p = inputParser;
            p.addRequired('p_ForwardSolution', @(x)isa(x, 'sl_CForwardSolution'));
            p.addOptional('p_fSamplingFrequency', 1000, @(x)isnumeric(x) && x > 0);
            
            p.parse(p_ForwardSolution, p_fSamplingFrequency, varargin{:});
            super_args{1} = 0;
            obj = obj@sl_CMeasurement(super_args{:});
            
            %ToDo this has to be done in super class
            obj.m_InverseSolution = sl_CInverseSolution(p.Results.p_ForwardSolution);

            obj.fSamplingFrequency = p.Results.p_fSamplingFrequency;
            
            obj.m_fNoiseScaling = 1;
        end % sl_CSimulator
        
        %% get.data_noise
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.data_noise(obj)
            value = obj.m_matNoise*obj.m_fNoiseScaling;
        end % get.data_noise
        
        %% get.data_signal
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.data_signal(obj)
            value = obj.m_InverseSolution.data_sensors;
        end % get.data_signal
        
        %% get.SourceActivation
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function value = get.SourceActivation(obj)
            value = obj.m_InverseSolution;
        end % get.SourceActivation
        
        %% simulate
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param varargin ToDo
        % =================================================================
        function simulate(obj, varargin)
            % simulate Signals
            p = inputParser;
            p.addParamValue('mode', 1, @isscalar);
 
            p.addParamValue('snr', 20, @(x)isnumeric(x));
            p.addParamValue('sf', 1000, @(x)isnumeric(x) && x > 0);
            p.parse(varargin{:});

            if ~isempty(p.Results.sf)
                obj.fSamplingFrequency = p.Results.sf;
            end
           
            if p.Results.mode == 1
                obj.simHarmonic(obj.m_InverseSolution, p.Results.snr);
            elseif p.Results.mode == 2
                obj.simRealistic(obj.m_InverseSolution, p.Results.snr);
            end
        end % simulate

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
            % plot
            T = obj.numSamples/obj.fSamplingFrequency;
            t = linspace(0,T,obj.numSamples);
            
            subplot(3,1,1)
            plot(t, obj.data');
            title('Simulated Measurement');
            %ToDo if EEG -> mV || if MEG -> mT
            ylabel('Magnitude');
            
            subplot(3,1,2)
            plot(t, obj.data_noise');
            title('Simulated Noise');
            %ToDo if EEG -> mV || if MEG -> mT
            ylabel('Magnitude');
            
            subplot(3,1,3)
            plot(t, obj.data_signal');
            title('Simulated Signal');
            xlabel('Time [s]')
            %ToDo if EEG -> mV || if MEG -> mT
            ylabel('Magnitude');
        end % plot
    end % methods
    
    methods (Access = private)
        %% simHarmonic
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_InverseSolution ToDo
        %> @param p_dSNR ToDo
        % =================================================================
        function simHarmonic(obj, p_InverseSolution, p_dSNR)
            %% simHarmonic Simulate EEG data

            %Add white gaussian noise -> awgn(X,Noise in dB,'measured');
            obj.data = awgn(p_InverseSolution.data_sensors,p_dSNR,'measured');
            obj.m_fNoiseScaling = 1;
            
            obj.m_matNoise = obj.data - p_InverseSolution.data_sensors;

            iTimeSteps = size(obj.data, 2);
            T = iTimeSteps/obj.fSamplingFrequency;
            obj.time = linspace(0,T,iTimeSteps);
        end % simHarmonic
        
        %% simRealistic
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param p_InverseSolution ToDo
        %> @param p_dSNR ToDo
        % =================================================================
        function simRealistic(obj, p_InverseSolution, p_dSNR)
            % simRealistic Simulate MEG/EEG data
            
            if p_InverseSolution.numSamples < 2000
                p_fDuration = 2000;
            else
                p_fDuration = p_InverseSolution.numSamples;
            end
            
            p_iDownSampling = 10;
            
            [p_matBckgrnd_activity, asymmetric_ratio] = bckgrnd_activity(obj, p_InverseSolution, p_fDuration, p_iDownSampling);
            
            p_matBckgrnd_activity=p_matBckgrnd_activity(1:p_InverseSolution.numSamples,:);
            
            nn = p_InverseSolution.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,1).nn;
            for h = 2:p_InverseSolution.m_corrForwardSolution.sizeForwardSolution
                nn = [nn; p_InverseSolution.m_corrForwardSolution.defaultSolutionSourceSpace.src(1,h).nn];
            end
            
            p_matBckgrnd_activity_cartesian = zeros(size(p_matBckgrnd_activity,1),size(nn,1)*3);
            
            for k = 1 : 3 %Cartesian
                for i = 1 : size(p_matBckgrnd_activity,1)
                    tmp = p_matBckgrnd_activity(i,:);
                    tmp2 = nn(1:p_iDownSampling:end,k);
                    tmp3 = tmp'.*tmp2;
                    p_matBckgrnd_activity_cartesian(i, k:3*p_iDownSampling:end) = tmp3;
                end
            end

            obj.m_matNoise = p_InverseSolution.m_corrForwardSolution.data * p_matBckgrnd_activity_cartesian';

            %SNR factor
            coeff = 10^(p_dSNR/10);
            var_noise = sum(var(obj.m_matNoise'));
            var_signal = sum(var(p_InverseSolution.data_sensors'));
            var_noise_wanted = var_signal/coeff;
            obj.m_fNoiseScaling = sqrt(var_noise_wanted/var_noise);
%             var_noise_new = sum(var(obj.m_matNoise'*obj.m_fNoiseScaling));
%             coeff_new = var_signal/var_noise_new;
            
            
            obj.data = obj.m_matNoise*obj.m_fNoiseScaling + p_InverseSolution.data_sensors;
            
            iTimeSteps = size(obj.data, 2);
            T = iTimeSteps/obj.fSamplingFrequency;
            obj.time = linspace(0,T,iTimeSteps);
        end % simRealistic
        
        %% bckgrnd_activity
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param invSol ToDo
        %> @param dur ToDo
        %> @param ds ToDo
        %>
        %> @retval p_matBckgrnd_activity ToDo
        %> @retval asymmetric_ratio ToDo
        % =================================================================
        [p_matBckgrnd_activity, asymmetric_ratio] = bckgrnd_activity(obj, invSol, dur, ds)%, varargin)

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
            % Type
            type = sl_Type.Simulator;
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
            % Name
            name = 'Simulator';
        end % Name
    end % static methods
end

