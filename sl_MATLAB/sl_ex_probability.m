
%%
% Includes
sl_include_core;
sl_include_mcmc_localizer;

%%
% Clear & close old stuff
clear all;
close all;
clc;

%%
%sl_CUtility.initSLEnv();

%%
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif', './Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%%
t_ProbabilisticInverseSolution = sl_CProbabilisticInverseSolution(t_ForwardSolution);

%%
%t_MCMCLocalizer = sl_CMCMCLocalizer(t_ForwardSolution);

plot(t_ProbabilisticInverseSolution) % equaly activated

h = 1; %Hemisphere
t_ProbabilisticInverseSolution.m_ProbabilisticActivationMap(1,h).map(1:43) = 2; %dipol 1-43 in hemisphere h=1

figure;
plot(t_ProbabilisticInverseSolution)