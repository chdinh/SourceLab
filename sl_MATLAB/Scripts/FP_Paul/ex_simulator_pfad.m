%%
% PROBLEM: Cannot open file : Toolbox_SourceLab/sl_Matlab/Data/EEG/Sample/sample_audvis-ave-oct-6-fwd.fif
% changed path to : sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif

% Includes
addpath ('../../../sl_Matlab');
sl_include_core;

%%
% Clear & close old stuff
% clear all;
% close all;
% clc;

%%
% Source
t_ForwardSolution = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif');
%t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield.txt');
%t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield-sim2.txt');
plot(t_ForwardSolution);
%% Simulator
t_SamplingFrequency = 1000;
t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

T = 1/t_SamplingFrequency;
duration = 2; % when measurement is too long - localization fails

f1 = 9;
t1 = 0:T:duration-T;
s1 = sin(2*pi*t1*f1);
t_Simulator.SourceActivation.addActivation([234 3814], s1);%, [1 0 0; 0 1 0]);

f2 = 16;
t2 = 0:T:duration-T;
s2 = sin(2*pi*t2*f2);
t_Simulator.SourceActivation.addActivation([147 879], s2);%, [1 0 0; 0 1 0]);

%%
t_Simulator.simulate('mode',2,'snr',10);

plot(t_Simulator);

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);
