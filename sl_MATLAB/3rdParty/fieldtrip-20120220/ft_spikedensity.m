function [sdf, sdfdata] = ft_spikedensity(cfg,data)

% FT_SPIKEDENSITY computes the spike density function of the spike trains by
% convolving the data with a window.
%
% Use as
%   [sdf]          = ft_spike_density(cfg, data)
%   [sdf, sdfdata] = ft_spike_density(cfg, data)
% 
% If you specify one output argument, only the average and variance of
% spikedensityfunction across trials will be computed and individual trials are
% not kept. See cfg.winfunc below for more information on the specific use.
%
% Inputs:
%   DATA should be organised in a structure as obtained from the
%   FT_APPENDSPIKE or FT_SPIKESTATION_SPIKE2DATA or T_PREPROCESSING
%   function.
%
% Configurations:
%   cfg.timwin         = [begin end], time of the smoothing kernel (default = [-0.1 0.1])
%                        If cfg.winfunc = @alphawin, cfg.timwin(1) will be set to 0.
%   cfg.outputunit     = 'rate' (default) or 'spikecount'. This determines the physical unit
%                        of our spikedensityfunction, either in firing rate or in
%                        spikecount.
%   cfg.winfunc        = (a) string or function handle, type of window to convolve with (def = @gauss).
%                            Options should be set with cfg.winfuncopt
%                        - @gauss (default)
%                        - @alphawin, given by win = x*exp(-x/timeconstant)
%                        - For standard window functions in the signal processing toolbox see
%                          WINDOW.
%                        (b) vector of length nSamples, used directly as window
%   cfg.winfuncopt     = options that go with cfg.winfunc
%                        For cfg.winfunc = @alpha: the timeconstant in seconds (default = 0.005s)
%                        For cfg.winfunc = @gauss: the standard devision in seconds (default =
%                                         1/4 of window duration in seconds)
%                        For cfg.winfunc = @wname with @wname any standard window function
%                                         see window opts in that function and add as cell array
%   cfg.latency        = [begin end] in seconds, 'maxperiod' (default), 'minperiod',
%                        'prestim'(t>=0), or 'poststim' (t>=0).
%   cfg.vartriallen    = 'yes' (default) or 'no'.
%                        'yes' - accept variable trial lengths and use all available trials
%                         and the samples in every trial. Missing values will be ignored in
%                         the computation of the average and the variance.
%                        'no'  - only select those trials that fully cover the window as
%                         specified by cfg.latency.
%   cfg.trials         =  numeric or logical selection of trials (default = 'all')
%   cfg.keeptrials     = 'yes' or 'no' (default). If 'yes', we store the trials in a matrix
%                         in output SDF as well.
%   cfg.fsample        = additional user input that can be used when input
%                        is a SPIKE structure, in that case a continuous
%                        representation is created using cfg.fsample
%                        (default = 1000);
% Outputs:
%   - SDF is a structure similar to TIMELOCK (output from FT_TIMELOCKANALYSIS) and can be used
%     in FT_TIMELOCKSTATISTICS for example.
%   - SDFDATA is a raw DATA type structure that can be used itself in all
%   functions that support
%     raw data input (such as FT_TIMELOCKANALYSIS, FT_FREQANALYSIS).

% TODO: check that SDFDATA is indeed completely compatible!

% Copyright (C) 2010, Martin Vinck
%
% $Id: ft_spikedensity.m 5157 2012-01-22 14:49:34Z roboos $

revision = '$Id: ft_spikedensity.m 5157 2012-01-22 14:49:34Z roboos $';

% do the general setup of the function
ft_defaults
ft_preamble help
ft_preamble callinfo
ft_preamble trackconfig

% get the default options
cfg.outputunit   = ft_getopt(cfg, 'outputunit','rate');
cfg.timwin       = ft_getopt(cfg, 'timwin',[-0.05 0.05]);
cfg.trials       = ft_getopt(cfg, 'trials', 'all');
cfg.latency      = ft_getopt(cfg,'latency','maxperiod');
cfg.spikechannel = ft_getopt(cfg, 'spikechannel', 'all');
cfg.vartriallen  = ft_getopt(cfg,'vartriallen', 'yes');
cfg.keeptrials   = ft_getopt(cfg,'keeptrials', 'yes');
cfg.winfunc      = ft_getopt(cfg,'winfunc', 'gauss');
cfg.winfuncopt   = ft_getopt(cfg,'winfuncopt', []);
cfg.fsample      = ft_getopt(cfg,'fsample', 1000);

% ensure that the options are valid
cfg = ft_checkopt(cfg,'outputunit','char', {'rate', 'spikecount'});
cfg = ft_checkopt(cfg,'spikechannel',{'cell', 'char', 'double'});
cfg = ft_checkopt(cfg,'latency', {'char', 'doublevector'});
cfg = ft_checkopt(cfg,'trials', {'char', 'doublevector', 'logical'}); 
cfg = ft_checkopt(cfg,'vartriallen', 'char', {'yes', 'no'});
cfg = ft_checkopt(cfg,'keeptrials', 'char', {'yes', 'no'});
cfg = ft_checkopt(cfg,'timwin', 'doublevector');
cfg = ft_checkopt(cfg,'winfunc', {'char', 'function_handle', 'doublevector'});
cfg = ft_checkopt(cfg,'winfuncopt', {'cell', 'double', 'empty'});
cfg = ft_checkopt(cfg,'fsample', 'double');

% check input data structure
data = ft_checkdata(data,'datatype', 'raw', 'feedback', 'yes', 'fsample', cfg.fsample);

% select the units
cfg.channel = ft_channelselection(cfg.spikechannel, data.label);
spikesel    = match_str(data.label, cfg.channel);
nUnits      = length(spikesel); % number of spike channels
if nUnits==0, error('MATLAB:spike:density:cfg:spikechannel:noSpikeChanSelected',...
    'No spikechannel selected by means of cfg.spikechannel');
end

% get the number of trials or change DATA according to cfg.trials
if  strcmp(cfg.trials,'all')
  cfg.trials = 1:length(data.trial);
elseif islogical(cfg.trials)
  cfg.trials = find(cfg.trials);
end
cfg.trials = sort(cfg.trials(:));
if max(cfg.trials)>length(data.trial),error('MATLAB:spike:density:cfg:trials:maxExceeded',...
    'maximum trial number in cfg.trials should not exceed length of DATA.trial')
end
if isempty(cfg.trials),
  errors('MATLAB:spike:density:cfg:trials','No trials were selected in cfg.trials');
end

% determine the duration of each trial
begTrialLatency = cellfun(@min,data.time(cfg.trials));
endTrialLatency = cellfun(@max,data.time(cfg.trials));

% select the latencies
if strcmp(cfg.latency,'minperiod')
  cfg.latency = [max(begTrialLatency) min(endTrialLatency)];
elseif strcmp(cfg.latency,'maxperiod')
  cfg.latency = [min(begTrialLatency) max(endTrialLatency)];
elseif strcmp(cfg.latency,'prestim')
  cfg.latency = [min(begTrialLatency) 0];
elseif strcmp(cfg.latency,'poststim')
  cfg.latency = [0 max(endTrialLatency)];
elseif ~isrealvec(cfg.latency)||length(cfg.latency)~=2
  error('MATLAB:spike:density:cfg:latency',...
    'cfg.latency should be "max", "min", "prestim", "poststim" or 1-by-2 numerical vector');
end
if ~isrealvec(cfg.timwin)||length(cfg.timwin)~=2
  error('MATLAB:spike:density:cfg:timwin',...
    'cfg.latency should be 1-by-2 numerical vector');
end
if cfg.latency(1)>=cfg.latency(2),
  error('MATLAB:spike:density:cfg:latency:wrongOrder',...
    'cfg.latency should be a vector in ascending order, i.e., cfg.latency(2)>cfg.latency(1)');
end
if (cfg.latency(1) < min(begTrialLatency)), cfg.latency(1) = min(begTrialLatency);
  warning('MATLAB:spike:density:begLatencyTooEarly',...
    'Correcting begin latency of averaging window');
end
if (cfg.latency(2) > max(endTrialLatency)), cfg.latency(2) = max(endTrialLatency);
  warning('MATLAB:spike:density:endLatencyTooLate',...
    'Correcting end latency of averaging window');
end

% start processing the window information
if strcmp(cfg.winfunc,'alphawin') % now force start of window to be positive.
  warning('MATLAB:spike:density:cfg:timwin:alphawin:timwinNeg',...
    'cfg.timwin(1) should be a non-negative number if cfg.winfunc = @alphawin')
  cfg.timwin(1) = 0;
end

% construct the time-axis for the window
if cfg.timwin(1)>0 || cfg.timwin(2)<0 || cfg.timwin(1)>=cfg.timwin(2)
  error('MATLAB:spike:density:cfg:timwin:noInclusionTimeZero',...
    'Please specify cfg.timwin(1)<=0 and cfg.timwin(2)>=0 and cfg.timwin(2)>cfg.timwin(1)')
end
fsample       = data.fsample; % PLEASE DO NOT MESS WITH THIS LINE!
sampleTime    = 1/fsample;
winTime       = [fliplr(0:-sampleTime:cfg.timwin(1)) (sampleTime):sampleTime:cfg.timwin(2)];
nLeftSamples  = length(find(winTime<0));
nRightSamples = length(find(winTime>0));
nSamplesWin   = length(winTime);
if nSamplesWin==1, warning('MATLAB:spike:density:cfg:timwin:winLengthOne',...
    'Number of samples in selected window is exactly one, so no smoothing applied')
end

% construct the window
% construct the window
if strcmp(cfg.winfunc,'gauss')
  if  isempty(cfg.winfuncopt), cfg.winfuncopt{1} = 0.25*diff(cfg.timwin); end
  win = exp(-(winTime.^2)/(2*cfg.winfuncopt{1}^2));
elseif strcmp(cfg.winfunc,'alphawin')
  if isempty(cfg.winfuncopt),  cfg.winfuncopt{1} = 0.005; end
  win = winTime.*exp(-winTime/cfg.winfuncopt{1});
elseif ischar(cfg.winfunc) || strcmp(class(cfg.winfunc),'function_handle')
  if isempty(cfg.winfuncopt)
    win = feval(cfg.winfunc,nSamplesWin);
  else
    win = feval(cfg.winfunc,nSamplesWin, cfg.winfuncopt{:});
  end
elseif isnumeric(cfg.winfunc) % only do error check here
  if  ~isrealvec(cfg.winfunc) || length(cfg.winfunc)~=nSamplesWin
    error('MATLAB:spike:density:cfg:window:wrongSize', '%s\n%s%d',...
      'cfg.winfunc should be 1-by-N vector, with N equal to the number', ...
      'of samples as determined by cfg.timwin, namely',length(cfg.winfunc))
  end
else   error('MATLAB:spike:density:cfg:window:unknownOption','%s\n%s',...
    'cfg.winfunc should be "gausswin_private", "alphawin", window function (string or handle)',...
    'or 1-by-N vector');
end
win    = win(:).'./sum(win);    % normalize the window to 1
winDur = max(winTime) - min(winTime); % duration of the window

% check which trials will be used based on the latency
% at this point cfg.trials has selected trials and begTrialLatency is accordingly
overlaps      = endTrialLatency>=(cfg.latency(1)+winDur) & begTrialLatency<=(cfg.latency(2)-winDur);
if strcmp(cfg.vartriallen,'no') % only select trials that fully cover our latency window
  startsLater    = single(begTrialLatency>single(cfg.latency(1)));
  endsEarlier    = single(endTrialLatency<single(cfg.latency(2)));
  hasWindow      = ~(startsLater | endsEarlier); % it should not start later or end earlier
else
  hasWindow      = true(length(cfg.trials),1); % in case vartriallen = "yes"
end
trialSel          = overlaps(:) & hasWindow(:); % trials from cfg.trials we select further
cfg.trials        = cfg.trials(trialSel);       % cut down further on cfg.trials
begTrialLatency   = begTrialLatency(trialSel);  % on this variable as well
nTrials           = length(cfg.trials);         % the actual number of trials we will use
if isempty(cfg.trials),warning('MATLAB:ft_spikedensity:cfg:trials:noneSelected',...
    'no trials were selected, please check cfg.trials')
end

% calculates the samples we are shifted wrt latency(1)
samplesShift      = zeros(1,nTrials);
sel               = (begTrialLatency-cfg.latency(1))>0; % otherwise 0 samples to be padded
samplesShift(sel) = round(fsample*(begTrialLatency(sel)-cfg.latency(1)));

% create the time axis for the spike density
time           = cfg.latency(1):(1/fsample):cfg.latency(2);
cfg.latency(2) = time(end);   % this is the used latency that should be stored in cfg again
maxNumSamples  = length(time);

% preallocate the sum, squared sum and degrees of freedom
[s,ss]   = deal(NaN(nUnits, maxNumSamples)); % sum and sum of squares
dof      = zeros(nUnits, length(s));

if (strcmp(cfg.keeptrials,'yes')), singleTrials = zeros(nTrials,nUnits,size(s,2)); end

% preallocate depending on whether nargout is 1 or 2
if nargout==2, [sdfdata.trial(1:nTrials) sdfdata.time(1:nTrials)] = deal({[]}); end
for iTrial = 1:nTrials
  origTrial  = cfg.trials(iTrial);   % this is the original trial we use for DATA input
  timeAxis   = data.time{origTrial}; % get the time axis for this trial
  sampleSel  = nearest(timeAxis, cfg.latency(1)) : nearest(timeAxis, cfg.latency(2));
  nSamples   = length(sampleSel);
  trialTime  = timeAxis(sampleSel);  % select the relevant portion of time
  
  for iUnit = 1:nUnits
    unitIndx = spikesel(iUnit); % index in data.label
    dat      = data.trial{origTrial}(unitIndx,sampleSel); % get the data
    if any(dat)
      y = conv(full(dat),win);  % use convolution to get the raw spike density
    else
      y = zeros(1,nSamples + nSamplesWin - 1); % no spikes; no convolution needed
    end
    
    if strcmp(cfg.outputunit, 'rate')
      y = y*fsample;  % normalize to the sampling rate, to get it in Hz.
    else
      y = y*nSamplesWin;   % now maximum becomes N (length window)
    end
    y = y(nLeftSamples+1 : end-nRightSamples); % delete additional points we get with conv
    y([1:nLeftSamples end-nRightSamples+1:end]) = NaN; % assign NaN at borders
    
    if nargout==2
      sdfdata.trial{iTrial}(iUnit,:) = y;
      sdfdata.time{iTrial}(iUnit,:)  = trialTime; % write back original time axis
    end
    
    dofsel = ~isnan(y);%true(1,length(y));
    if strcmp(cfg.vartriallen,'yes')
      padLeft  = zeros(1, samplesShift(iTrial));
      padRight = zeros(1,(maxNumSamples - nSamples - samplesShift(iTrial)));
      ySingleTrial = [NaN(size(padLeft)) y NaN(size(padRight))];
      y        = [padLeft y padRight];
      dofsel   = logical([padLeft dofsel padRight]);
    else
      ySingleTrial = y;
    end
    s(iUnit,:)        = nansum([s(iUnit,:);y]);            % compute the sum
    ss(iUnit,:)       = nansum([ss(iUnit,:);y.^2]);         % compute the squared sum
    
    % count the number of samples that went into the sum
    dof(iUnit,dofsel) = dof(iUnit,dofsel) + 1;
    
    if strcmp(cfg.keeptrials,'yes'), singleTrials(iTrial,iUnit,:) = ySingleTrial; end
  end
  % remove the trial from data in order to avoid buildup in memory
  data.trial{origTrial} = [];
  data.time{origTrial}  = [];
end
dofMat                   = dof;

% give back a similar structure as timelockanalysis
sdf.avg                  = s ./ dofMat;
sdf.var                  = (ss - s.^2./dofMat)./(dofMat-1); % sumPsth.^2 ./ dof = dof .* (sumPsth/dof).^2
sdf.dof                  = dofMat;
sdf.time                 = time;
sdf.fsample           	 = fsample;
sdf.label(1:nUnits)      = data.label(spikesel);
if (strcmp(cfg.keeptrials,'yes'))
  sdf.trial = singleTrials;
  sdf.dimord = 'rpt_chan_time';
else
  sdf.dimord = 'chan_time';
end

% create a new structure that is a standard raw data spike structure itself
% this is returned as second output argument
sdfdata.fsample              = fsample;
sdfdata.label(1:nUnits)      = data.label(spikesel);
sdfdata.hdr                  = data.hdr;

% do the general cleanup and bookkeeping at the end of the function
ft_postamble trackconfig
ft_postamble callinfo
ft_postamble previous data
% store the configuration history in both output arguments
ft_postamble history sdf
ft_postamble history sdfdata

