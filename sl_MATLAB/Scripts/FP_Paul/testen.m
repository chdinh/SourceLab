%%
% Includes

addpath ('../../../sl_Matlab');
sl_include_dcbf;
sl_include_core;
%%
clear all;
close all;
clc;

%%
%matlabpool localconfig1 4 ;

%% ########################################################################
%  # Simulator

% t_ForwardSolutionSimulation = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
% names_in = t_ForwardSolutionSimulation.ROIAtlas(1,1).struct_names(55);
% labels = t_ForwardSolutionSimulation.atlasName2Label(names_in);
% t_ForwardSolutionSimulation.selectROIs('lh',labels(1,1).label, 'rh',labels(1,2).label); % select region by label ID
% t_ForwardSolutionSimulation.selectHemispheres([1 2]);   
% %t_ForwardSolutionSimulation.selectSources_new('lh',[1:100],'rh',[]);
% names_out = t_ForwardSolutionSimulation.label2AtlasName(labels(1,1).label);
%
%t_ForwardSolution = sl_CForwardSolution([],[],[],'debugLF', './Data/MEG/ernie/debug/leadfield.txt', 'debugGrid', './Data/MEG/ernie/debug/grid.txt');
%t_ForwardSolutionSimulation = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
t_ForwardSolutionSimulation = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');


t_SamplingFrequency = 1000;
SelectionAll = [t_ForwardSolutionSimulation.AvailableSources(1,1).idx t_ForwardSolutionSimulation.AvailableSources(1,2).idx];
SelectionSimulation = SelectionAll(1:4:end);
%t_ForwardSolutionSimulation.selectSources([1957 8077]);
t_ForwardSolutionSimulation.selectSources(SelectionSimulation);
%t_ForwardSolutionSimulation.selectSources([1597 1997]);
%plot(t_ForwardSolutionSimulation);
%% Calculation Loop
%for k = 1:2
k = 1;
for j = 1:2

    SNR = [5];
    Dur = [0.01 0.02 0.03 0.04 0.05];
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
t_Simulator.simulate('mode',k,'snr',SNR);

        %%
        % Localization

        %t_ForwardSolutionLocalization = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
        t_ForwardSolutionLocalization = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');

        SelectionAll = [t_ForwardSolutionLocalization.AvailableSources(1,1).idx t_ForwardSolutionLocalization.AvailableSources(1,2).idx];
        SelectionLocalization = SelectionAll(2:4:end);
        t_ForwardSolutionLocalization.selectSources(SelectionLocalization);

        %figure('Name', 'Dipole Distribution');
        %plot(t_ForwardSolutionLocalization);

        %%
        Offset = sl_CDCBF_Tools.getOffset(t_ForwardSolutionLocalization , p_Dipole);

        %%
        t_eDCBF = sl_CeDCBF(t_ForwardSolutionLocalization);


        %%
        t_eDCBF.estimateNoise(t_Simulator);

        %%
        p_Lambda = [1e-18 1e-17 1e-16 1e-15 1e-14 1e-13 1e-12 1e-11 1e-10 1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 0.1 1 10 1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9 1e10]; % Parameter for regularized correlation reconstruction --> if empty, no regularized reconstruction is performed
        transCorr = 'no';  %Trigger for transformed correlation reconstruction --> Choose 'yes' for transformed correlation or 'no' for no transformed correlation

        [t_InverseSolution, res] = t_eDCBF.calculate(t_Simulator, p_Dipole, p_Lambda, transCorr);

        %% find dipol coordinates
        [dipol_coord, Z_coord, distance] = sl_CDCBF_Tools.getDistance( t_ForwardSolutionLocalization, res.bestPseudoZ, p_Dipole );
        res.dipol_coord = dipol_coord;
        res.Z_coord = Z_coord;
        res.bestDistance = distance;
        %%
        res.Duration = duration;
        res.SNR = SNR;
        res.offset = Offset;
        result{1,i}= res;
    %end;
    if j == 1
            save durdipolepair1_correlated result
        elseif j == 2
            save durdipolepair1_uncorrelated result
    end;
% if k == 1
%     if j == 1
%         save 1dipolepair1_correlated result
%     elseif j == 2
%         save 1dipolepair1_uncorrelated result
%     end;
% elseif k == 2
%     if j == 1
%         save 1dipolepair2_correlated result
%     elseif j == 2
%         save 1dipolepair2_uncorrelated result
%     end;
% end;
end;
% end;
%%
% Close pool of MATLAB sessions for parallel computation
%matlabpool close;