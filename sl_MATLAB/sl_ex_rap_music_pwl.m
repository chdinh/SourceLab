%> @page ex_rap_music_pwl RAP-MUSIC Accelerated with Powell Search Example
%> This is the description for the RAP-MUSIC Accelerated with Powell Search example


%%
% Includes
sl_include_rap_music;

%%
% Clear & close old stuff
clear all;
close all;
clc;

%%
sl_CUtility.initSLEnv(); %If you don't have the parallel toolbox installed, comment this out

%%
% Source
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%% Select ROIs
names_in = t_ForwardSolution.ROIAtlas(1,1).struct_names(3:2:7);
labels = t_ForwardSolution.atlasName2Label(names_in);
t_ForwardSolution.selectROIs('lh',labels(1,1).label,'rh',[])

figure('Name','Forward Solution')
plot(t_ForwardSolution);

%% Simulator
t_SamplingFrequency = 1000;
t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

T = 1/t_SamplingFrequency;
duration = 0.1; % when measurement is too long - localization fails

f1 = 9;
t1 = 0:T:duration-T;
s1 = sin(2*pi*t1*f1);
t_Simulator.SourceActivation.addActivation([234 3814], s1, 'nn', [1 0 0; 0 1 0]);

f2 = 16;
t2 = 0:T:duration-T;
s2 = sin(2*pi*t2*f2);
t_Simulator.SourceActivation.addActivation([147 879], s2, 'nn', [1 0 0; 0 1 0]);
% t_Simulator.SourceActivation.addActivation([234 3814], s1, 'nn', [1 1 1; 1 1 1]);

%
t_Simulator.simulate('mode',1,'snr',10);

figure('Name','Simulated Measurement')
plot(t_Simulator);
% %% Real Measurement
% t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement.txt');
% plot(t_Measurement);

%%
t_RapMusicPwl = sl_CRapMusicPwl(t_ForwardSolution, 3, 0);


%% Calculation
[t_InverseSolution, t_resDipoles, t_resCorrelations ] = t_RapMusicPwl.calculate(t_Simulator);%t_Measurement);

%% Plot Results
figure('Name','Inverse Solution')
plot(t_InverseSolution);

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);

%%
% Close pool of MATLAB sessions for parallel computation
matlabpool close;