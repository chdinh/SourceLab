%% open fieldtrip
clc;
clear all;
addpath(genpath('./3rdParty'));
ft_defaults;

%% Read continouse data
cfg = [];
cfg.dataset     = './Data/MEG/ernie/sef.fif';
data_org        = ft_preprocessing(cfg);

%%
[sens] = ft_read_sens('./Data/MEG/ernie/sef.fif')

%%
cfg = [];
cfg.channel                      = {'MEG*' 'STI*'};
data_ref                 = ft_preprocessing(cfg, data_org);



%% Read in Trials
%% define trials
cfg = [];                                               % create an empty variable called cfg
cfg.dataset                 = './Data/MEG/ernie/sef.fif';   % filename
cfg.trialdef.eventtype      = 'STI101';                 % use '?' to get a list of the available types (see above)
cfg.trialdef.eventvalue = 2048;                       % define trial
cfg.trialdef.prestim = .75;                            % in seconds
cfg.trialdef.poststim = .75;                           % in seconds
cfg.trialfun = 'trialfun_general';
cfg = ft_definetrial(cfg);


%% reject jump artifacts (squid jumps)
fprintf('\nsearching for jump artifacts ...\n');
cfg.channel                      = {'MEG*'};
cfg.continuous                   = 'yes';
cfg.padding                      = 1;
cfg.artfctdef.jump.medianfilter  = 'yes';
cfg.artfctdef.jump.medianfiltord = 9;
cfg.artfctdef.jump.absdiff       = 'yes';
cfg.artfctdef.jump.channel       = cfg.channel;
cfg.artfctdef.jump.cutoff        = 20;                                 % z-value at which to threshold
cfg                              = ft_artifact_jump(cfg);
cfg                              = ft_rejectartifact(cfg);


% %% reject muscle artifacts (see fieldtrip homepage for more information)
% fprintf('\nsearching for muscle artifacts ...\n');
% cfg.channel                      = {'MEG*'};
% cfg.continuous                   = 'yes';
% cfg.padding                      = 1;
% cfg.artfctdef.muscle.bpfilter    = 'yes';
% cfg.artfctdef.muscle.bpfreq      = [110 140];
% cfg.artfctdef.muscle.bpfiltord   = 8;
% cfg.artfctdef.muscle.bpfilttype  = 'but';
% cfg.artfctdef.muscle.hilbert     = 'yes';
% cfg.artfctdef.muscle.boxcar      = 0.2;
% cfg.artfctdef.muscle.channel       = cfg.channel;
% cfg.artfctdef.muscle.cutoff        = 4; 
% cfg                                = ft_artifact_muscle(cfg);
% cfg                                = ft_rejectartifact(cfg);


%% filter data
fprintf('\npreprocessing data ...\n');
cfg.channel                      = 'MEG*';          % all channels
cfg.bpfilter                     = 'yes';
cfg.bpfreq                       = [1 40];          % cut off frequencies at 1Hz and 40Hz
cfg.bpfiltord                    = 3;
cfg.dftfilter                    = 'yes';
cfg.demean                       = 'yes';           % do baseline correction
cfg.baselinewindow               = [-0.08,-0.005];
cfg.padding                      = 6;


%% preprocess 
preprocessed_data = ft_preprocessing(cfg);



%% do timelock analysis and average data
cfg                = [];
averaged = ft_timelockanalysis(cfg, preprocessed_data);
