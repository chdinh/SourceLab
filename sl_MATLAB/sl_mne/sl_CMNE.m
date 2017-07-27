classdef sl_CMNE < sl_CImagingInverseAlgorithm
    %SL_CTSVD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        m_matR;
        m_matC;
               
        m_matResult;
    end
    
    methods
        %% sl_CMNE Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param p_ForwardSolution ToDo
        %> @param p_rawMeasurement ToDo
        %>
        %> @return instance of the sl_CSimulator class.
        % =================================================================
        function obj = sl_CMNE(p_ForwardSolution, p_rawMeasurement)
            obj.m_ForwardSolution = p_ForwardSolution;
            
            obj.init(p_rawMeasurement);
        end
        
        %% init
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_rawMeasurement ToDo
        %>
        %> @return ToDo
        % =================================================================
        function bool = init(obj, p_rawMeasurement)
            if ~isempty(obj.m_ForwardSolution.data)
%                obj.m_matR = cov(obj.m_ForwardSolution.data);
%                obj.m_matC = cov(obj.m_matNoise);
                obj.m_matC = sl_CMNE.make_inverse_operator(p_rawMeasurement);

                bool = true;
            else
                bool = false;
            end
        
        end
        
        %% calculate
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_Measurement ToDo
        %> @param p_fLambda ToDo
        % =================================================================
        function calculate(obj, p_Measurement, p_fLambda)
            % ˆq = RG^T (GRG^T + \lambda^2C)^?1 y
            tmp = obj.m_matR*obj.m_ForwardSolution.data';
            tmp2 = obj.m_ForwardSolution.data*obj.m_matR*obj.m_ForwardSolution.data' + p_fLambda^2*obj.m_matC;
            tmp3 = tmp2^-1;

            obj.m_matResult = tmp*tmp3*p_Measurement.data;
        end
    end
    
        
        
        
        
    methods (Static)
        %% make_inverse_operator
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_rawMeasurement ToDo
        %>
        %> @return ToDo
        % =================================================================
        function data = make_inverse_operator(p_rawMeasurement)
            data = sl_CMNE.compute_raw_data_covariance(p_rawMeasurement);

            cov = sl_CMNE.regularize(data, p_rawMeasurement, 'mag', 0.05, 'grad', 0.05, 'eeg', 0.1);
        end
        
        %% compute_raw_data_covariance
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_rawMeasurement ToDo
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % =================================================================
        function data = compute_raw_data_covariance(p_rawMeasurement, varargin)

            p = inputParser;
            p.addRequired('p_rawMeasurement', @(x)isa(x,'sl_CMeasurement'))
            p.addParamValue('tmin', 0, @isscalar)
            p.addParamValue('tmax', [], @isscalar)
            p.addParamValue('tstep', 0.2, @isscalar)
            p.addParamValue('reject', [], @isscalar)
            p.addParamValue('flat', [], @isscalar)
            p.parse(p_rawMeasurement, varargin{:});

            fprintf('Estimate covariance matrix from a raw FIF file')

            sfreq = p.Results.p_rawMeasurement.fSamplingFrequency;
            tmin = p.Results.tmin;
            tmax = p.Results.tmax;
            tstep = p.Results.tstep;
            reject = p.Results.reject;
            flat = p.Results.flat;

            start = int32(floor(tmin * sfreq)) + 1;

            if isempty(tmax)
                stop = p_rawMeasurement.numSamples;
            else
                stop = int32(floor(tmax * sfreq)) + 1;
            end

            step = int32(ceil(tstep * sfreq));

            data = zeros(p_rawMeasurement.numChannels,p_rawMeasurement.numChannels);
            n_samples = 0;
            mu = zeros(p_rawMeasurement.numChannels,1);

            % Read data in chuncks
            for first = start:step:stop
                last = first + step;
                if last >= stop
                    last = stop;
                end
                raw_segment = p_rawMeasurement.data(:,first:last);%(picks, first:last)
                %% ToDo Artefact Rejection
                %if _is_good(raw_segment, info['ch_names'], idx_by_type, reject, flat)
                    mu = mu + sum(raw_segment,2);
                    data = data + raw_segment * transpose(raw_segment);
                    n_samples = n_samples + step;
                %else
                %    fprintf('Artefact detected in [%d, %d]', first, last);
                %end
            end

            mu = mu / double(n_samples);
            data = data - double(n_samples) * mu * transpose(mu);
            data = data / (double(n_samples) - 1.0);
            fprintf('Number of samples used : %d', n_samples);
            fprintf('[done]');
        end
        
        %     """Regularize noise covariance matrix
        % 
        %     This method works by adding a constant to the diagonal for each
        %     channel type separatly. Special care is taken to keep the
        %     rank of the data constant.
        % 
        %     Parameters
        %     ----------
        %     cov: Covariance
        %         The noise covariance matrix.
        %     info: dict
        %         The measurement info (used to get channel types and bad channels)
        %     mag: float
        %         Regularization factor for MEG magnetometers
        %     grad: float
        %         Regularization factor for MEG gradiometers
        %     eeg: float
        %         Regularization factor for EEG
        %     exclude: list
        %         List of channels to mark as bad. If None, bads channels
        %         are extracted from info and cov['bads'].
        %     proj: bool
        %         Apply or not projections to keep rank of data.
        % 
        %     Return
        %     ------
        %     reg_cov : Covariance
        %         The regularized covariance matrix.
        %% regularize
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param p_rawMeasurement ToDo
        %> @param varargin ToDo
        %>
        %> @return ToDo
        % =================================================================
        function cov = regularize(cov, p_rawMeasurement, varargin)

            p = inputParser;
            p.addRequired('cov', @isnumeric)
            p.addRequired('p_rawMeasurement', @(x)isa(x,'sl_CMeasurement'))
            p.addParamValue('mag', 0.1, @isscalar)
            p.addParamValue('grad', 0.1, @isscalar)
            p.addParamValue('eeg', 0.1, @isscalar)
            p.addParamValue('exclude', [], @isvector)
            p.addParamValue('proj', true, @islogical)
            p.parse(cov, p_rawMeasurement, varargin{:});

            mag = p.Results.mag;
            grad = p.Results.grad;
            eeg = p.Results.eeg;
            exclude = p.Results.exclude;
            proj = p.Results.proj;

            sel_mag = p_rawMeasurement.eeg;
            sel_mag = p_rawMeasurement.mag;
            sel_grad = p_rawMeasurement.grad;
            
            idx_eeg = find(p_rawMeasurement.eeg);
            idx_mag = find(p_rawMeasurement.mag);
            idx_grad = find(p_rawMeasurement.grad);

            %ToDo pick channels
            C = cov;
            %assert len(C) == (len(idx_eeg) + len(idx_mag) + len(idx_grad))

%             if proj:
%                 projs = info['projs'] + cov['projs']
%                 projs = activate_proj(projs)
%             end
% 
%     for desc, idx, reg in [('EEG', idx_eeg, eeg), ('MAG', idx_mag, mag),
%                            ('GRAD', idx_grad, grad)]:
%         if len(idx) == 0 or reg == 0.0:
%             print "    %s regularization : None" % desc
%             continue
% 
%         print "    %s regularization : %s" % (desc, reg)
% 
%         this_C = C[idx][:, idx]
%         if proj:
%             this_ch_names = [ch_names[k] for k in idx]
%             P, ncomp, _ = make_projector(projs, this_ch_names)
%             U = linalg.svd(P)[0][:, :-ncomp]
%             if ncomp > 0:
%                 print '    Created an SSP operator for %s (dimension = %d)' % \
%                                                                   (desc, ncomp)
%                 this_C = np.dot(U.T, np.dot(this_C, U))
% 
%         sigma = np.mean(np.diag(this_C))
%         this_C.flat[::len(this_C) + 1] += reg * sigma  # modify diag inplace
%         if proj and ncomp > 0:
%             this_C = np.dot(U, np.dot(this_C, U.T))
% 
%         C[np.ix_(idx, idx)] = this_C
% 
%     cov['data'] = C
        end
    end
end

