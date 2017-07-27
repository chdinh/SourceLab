
%%
% Includes
sl_include_dcbf;
sl_include_roi;
sl_include_core
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
t_ForwardSolutionSimulation = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
t_SamplingFrequency = 1000;
SelectionAll = [t_ForwardSolutionSimulation.AvailableSources(1,1).idx t_ForwardSolutionSimulation.AvailableSources(1,2).idx];
SelectionSimulation = SelectionAll(1:4:end);
t_ForwardSolutionSimulation.selectSources(SelectionSimulation);
%% Calculation Loop
SNR = [-10];
for i = 1: length(SNR)
%%
t_Simulator = sl_CSimulator(t_ForwardSolutionSimulation, t_SamplingFrequency);

%
%t_ForwardSolutionSimulation.selectSources([600 881]);

T = 1/t_SamplingFrequency;
duration = 2;

f1 = 9;
t1 = 0:T:duration-T;
s1 = sin(2*pi*t1*f1);

f2 = 16;
t2 = 0:T:duration-T;
s2 = sin(2*pi*t2*f2);

p_Dipole.Idx = [501 2201];
%
t_Simulator.SourceActivation.addActivation([p_Dipole.Idx(1,1) p_Dipole.Idx(1,2)], s1);
%t_Simulator.SourceActivation.addActivation([234 881], s2);%, 'nn', [1 0 0; 0 1 0]);

%
t_Simulator.simulate('mode',1,'snr',SNR(i));

plot(t_Simulator);

%%
% Localization

t_ForwardSolutionLocalization = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

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