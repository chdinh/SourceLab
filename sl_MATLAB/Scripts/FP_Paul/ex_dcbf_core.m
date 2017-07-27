
%%
% Includes
% sl_include_roi durch sl_include_core ersetzt. Pfade für Dateien angepasst

addpath ('../../../sl_Matlab');
sl_include_dcbf;
sl_include_core;
%%
clear all;
close all;
clc;


%%
%sl_CUtility.initSLEnv();

%% ########################################################################
%  # Simulator


% names_in = t_ForwardSolution.ROIAtlas(1,1).struct_names(2:2:6);
% labels = t_ForwardSolution.atlasName2Label(names_in);
% t_ForwardSolution.selectROIs('lh',labels(1,1).label, 'rh',labels(1,2).label); % select region by label ID
% t_ForwardSolution.selectHemispheres([1 2]);   
%t_ForwardSolution.selectSources_new('lh',[1:100],'rh',[]);
%names_out = t_ForwardSolution.label2AtlasName(labels(1,1).label);
%
%t_ForwardSolution = sl_CForwardSolution([],[],[],'debugLF', './Data/MEG/ernie/debug/leadfield.txt', 'debugGrid', './Data/MEG/ernie/debug/grid.txt');
%t_ForwardSolutionSimulation = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
%Changed link + name t_ForwardSolution to t_ForwardSolutionSimulation

t_ForwardSolutionSimulation = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');
% added line:
t_ForwardSolution = t_ForwardSolutionSimulation;

t_SamplingFrequency = 1000;
SelectionAll = [t_ForwardSolutionSimulation.AvailableSources(1,1).idx t_ForwardSolutionSimulation.AvailableSources(1,2).idx];
SelectionSimulation = SelectionAll(1:4:end);
t_ForwardSolutionSimulation.selectSources(SelectionSimulation);
%% Calculation Loop
SNR = [-10];
for i = 1: length(SNR)
%%t_SamplingFrequency = 1000;
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

%%
% Localization

t_ForwardSolutionLocalization = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');

SelectionAll = [t_ForwardSolutionLocalization.AvailableSources(1,1).idx t_ForwardSolutionLocalization.AvailableSources(1,2).idx];
SelectionLocalization = SelectionAll(2:4:end);
t_ForwardSolutionLocalization.selectSources(SelectionLocalization);

%figure('Name', 'Dipole Distribution');
%plot(t_ForwardSolutionLocalization);

%%
Offset = sl_CDCBF_Tools.getOffset(t_ForwardSolutionLocalization , p_Dipole);

%%
t_DCBF = sl_CDCBF(t_ForwardSolutionLocalization);


%%
t_DCBF.estimateNoise(t_Simulator);

%%
res = t_DCBF.calculate(t_Simulator, p_Dipole);

%% find dipol coordinates
[dipol_coord, Z_coord, distance] = sl_CDCBF_Tools.getDistance( t_ForwardSolutionLocalization, res.bestPseudoZ, p_Dipole );
res.dipol_coord = dipol_coord;
res.Z_coord = Z_coord;
res.bestDistance = distance;
%%
res.SNR = SNR(i);
res.offset = Offset;
result{1,i}= res;
end;
save 1dipole result
%%
% Close pool of MATLAB sessions for parallel computation
%matlabpool close;