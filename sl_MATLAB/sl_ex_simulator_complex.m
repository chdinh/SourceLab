clc;
clear all;
close all;

sl_include_core;

%% Inits
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%%
t_InverseSolution = sl_CInverseSolution(t_ForwardSolution);

f = 9;
t = 0:0.1:600-0.1;
s = sin(2*pi*t*f);
t_InverseSolution.addActivation([10 12], s);

%test = t_InverseSolution.data_signal();

%%


%ToDo remove t_ForwardSolution within constructor
Simulator = sl_CSimulator(t_ForwardSolution, 600);

Simulator.simulate_new(t_InverseSolution);

%% plot
plot(Simulator)

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);