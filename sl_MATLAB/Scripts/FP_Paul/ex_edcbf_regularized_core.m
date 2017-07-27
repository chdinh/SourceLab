%%
% Test: changing sl_include_roi for sl_include_core.  
% Error in line 65

% Includes

addpath ('../../../sl_Matlab');
sl_include_dcbf;
sl_include_core;

%%
%sl_CUtility.initSLEnv();

%%
clear all;
close all;
clc;

%%
% sl_CUtility.initSLEnv();

%t_ForwardSolution = sl_CForwardSolution([],[],[],'debugLF', './Data/MEG/ernie/debug/leadfield.txt', 'debugGrid', './Data/MEG/ernie/debug/grid.txt');

%t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif', './Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
t_ForwardSolution = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');


%
names_in = t_ForwardSolution.ROIAtlas(1,1).struct_names(2:3);
labels = t_ForwardSolution.atlasName2Label(names_in);
t_ForwardSolution.selectROIs('lh',labels(1,1).label);%('rh',labels(1,2).label); % select region by label ID
t_ForwardSolution.selectHemispheres([1]);   
%t_ForwardSolution.selectSources_new('lh',[1:100],'rh',[]);


%names_out = t_ForwardSolution.label2AtlasName(labels(1,1).label);

%%
%plot(t_ForwardSolution);
%%
% Correlated Dipole Map
corrDipoleMap = sl_CCorrelatedDipoleMap();

p_Dipole.Idx = [32 32]; 
p_Dipole.direction{1} = [0 0 1];
p_Dipole.direction{2} = [1 0 0];
p_Dipole.direction{3} = [0 1 0];
p_Dipole.direction{4} = [0 0 1];
p_Dipole.direction{5} = [1 0 1];
p_Dipole.direction{6} = [0 1 1];

if length(p_Dipole.Idx)==2
corrDipoleMap.insert(p_Dipole.Idx(1), sl_CDipole(p_Dipole.direction{1}), p_Dipole.Idx(2), sl_CDipole(p_Dipole.direction{2}));
elseif length(p_Dipole.Idx)==4
corrDipoleMap.insert(p_Dipole.Idx(1), sl_CDipole(p_Dipole.direction{1}), p_Dipole.Idx(2), sl_CDipole(p_Dipole.direction{2}));
corrDipoleMap.insert(p_Dipole.Idx(3), sl_CDipole(p_Dipole.direction{3}), p_Dipole.Idx(4), sl_CDipole(p_Dipole.direction{4}));
elseif length(p_Dipole.Idx)==2
corrDipoleMap.insert(p_Dipole.Idx(1), sl_CDipole(p_Dipole.direction{1}), p_Dipole.Idx(2), sl_CDipole(p_Dipole.direction{2}));
corrDipoleMap.insert(p_Dipole.Idx(3), sl_CDipole(p_Dipole.direction{3}), p_Dipole.Idx(4), sl_CDipole(p_Dipole.direction{4}));
corrDipoleMap.insert(p_Dipole.Idx(5), sl_CDipole(p_Dipole.direction{5}), p_Dipole.Idx(6), sl_CDipole(p_Dipole.direction{6}));
end;

t_Simulator = sl_CSimulator(t_ForwardSolution, 1000);
%%
t_Simulator.simulate(corrDipoleMap, 0.199, 'harmonic', [9 16], 'sf', 1000, 'snr', 10);

plot(t_Simulator)

%%
t_eDCBF_regularized = sl_CeDCBF_regularized(t_ForwardSolution);


%%
t_eDCBF_regularized.estimateNoise(t_Simulator);


%%
t_lambda = [0.00001];

sizeLambda = length(t_lambda);

for l = 1:sizeLambda
    res{1,l} = t_eDCBF_regularized.calculate(t_Simulator, p_Dipole, t_lambda(l));
end


%%
% Close pool of MATLAB sessions for parallel computation
%matlabpool close;