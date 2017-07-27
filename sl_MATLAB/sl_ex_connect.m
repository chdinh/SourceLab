%> @page sl_ex_connect Connectivity Example
%> This is the description for the Connectivity example

%%
% Includes
sl_include_core;
sl_include_connect;

%%
% Clear & close old stuff
clear all;
close all;
clc;

%%
%sl_CUtility.initSLEnv();

%%
t_ForwardSolution2 = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif', './Data/subjects/ernie/label/lh.aparc.annot','./Data/subjects/ernie/label/rh.aparc.annot');
%%
%t_ForwardSolution3 = sl_CForwardSolution('./Data/MEG/tikunz/tk_auditory_stimulus-oct-6-fwd_more.fif', './Data/subjects/tikunz/label/lh.aparc.a2009s.annot','./Data/subjects/tikunz/label/rh.aparc.a2009s.annot');
%%
active = sl_CProbabilisticInverseSolution(t_ForwardSolution2);
%%
% figure
% active.m_ProbabilisticActivationMap(1,2).map(3000:4000) = 100;
% %%
%     active.normalize()
% 
% %%
%     plot(active)
%%
n = 4; % anzahl der steps
abschnitt = floor(length(active.m_ProbabilisticActivationMap(1,1).map)/n);

for j=0:(n-1)
    
    active.m_ProbabilisticActivationMap(1,1).map(j*abschnitt+1:(j+1)*abschnitt) = 1;
    active.normalize()
    figure
    plot(active)
% plot(j, sin(j),'*r')
%M(j+1) = getframe;
   
end
% %%
% figure
%  N = [ 3 2 3 4 5 6 7 8];   
% movie(M,4,1)

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);
