%%
% Includes
sl_include_dcbf;
sl_include_core
%%
clear all;
close all;
clc;

%%
%matlabpool localconfig1 4 ;

%% ########################################################################
% t_ForwardSolution = sl_CForwardSolution('C:\Users\Peter Hömmen\Desktop\Neuer Ordner\BAbiomad data\sl_data\MEG\pehoem\SEF/Medianus2_PE_15_970_raw-oct-6-fwd.fif','C:/Users/Peter Hömmen/Desktop/Neuer Ordner\BAbiomad data/sl_data/subjects/pehoem/label/lh.aparc.a2009s.annot','C:/Users/Peter Hömmen/Desktop/Neuer Ordner\BAbiomad data/sl_data/subjects/pehoem/label/rh.aparc.a2009s.annot');
% names_in = t_ForwardSolution.ROIAtlas(1,1).struct_names(i);
% labels = t_ForwardSolution.atlasName2Label(names_in);
% t_ForwardSolution.selectROIs('lh',labels(1,1).label, 'rh',labels(1,2).label); % select region by label ID
% t_ForwardSolution.selectHemispheres([1 2]);   
% %t_ForwardSolution.selectSources_new('lh',[1:100],'rh',[]);
% names_out = t_ForwardSolution.label2AtlasName(labels(1,1).label);
%
% t_ForwardSolution = sl_CForwardSolution([],[],[],'debugLF', './Data/MEG/ernie/debug/leadfield.txt', 'debugGrid', './Data/MEG/ernie/debug/grid.txt');
t_ForwardSolution = sl_CForwardSolution('C:\Users\Peter Hömmen\Desktop\Neuer Ordner\BAbiomad data\sl_data\MEG\pehoem\SEF/Medianus2_PE_15_970_raw-oct-6-fwd.fif','C:/Users/Peter Hömmen/Desktop/Neuer Ordner\BAbiomad data/sl_data/subjects/pehoem/label/lh.aparc.a2009s.annot','C:/Users/Peter Hömmen/Desktop/Neuer Ordner\BAbiomad data/sl_data/subjects/pehoem/label/rh.aparc.a2009s.annot');
t_SamplingFrequency = 1000;
SelectionAll = [t_ForwardSolution.AvailableSources(1,1).idx t_ForwardSolution.AvailableSources(1,2).idx];
Selection = SelectionAll(1:3:end);
t_ForwardSolution.selectSources(Selection);
t_ForwardSolution.selectSources([401 4051]);
plot(t_ForwardSolution);
%%
t_eDCBF = sl_CeDCBF(t_ForwardSolution);
%% Signal
load('C:\Users\Peter Hömmen\Desktop\Neuer Ordner\BAbiomad data\Medianus_stim\Medianus2/TLdata.mat');

Raw = data_TLs15_970.avg(:,751:end);
Sample = [130 250];
Sensor = 'all';

for i = 1: length(Sample)/2
    %%
    [MEG.Signal, MEG.Noise] = sl_CDCBF.getSig(Raw, Sample(i), Sample(i+length(Sample)/2), Sensor);
    [MEG.LeadField] = sl_CDCBF.getLeadField(t_ForwardSolution.data, Sensor);


    %%
    MEG.counter = i;
    
    p_Lambda = [1e-24 1e-17 1e-16 1e-15 1e-14 1e-13 1e-12 1e-11 1e-10 1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 0.1 1 10 1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9 1e10]; % Parameter for regularized correlation reconstruction --> if empty, no regularized reconstruction is performed
    transCorr = 'no';  %Trigger for transformed correlation reconstruction --> Choose 'yes' for transformed correlation or 'no' for no transformed correlation

    [p_InverseSolution,res] = t_eDCBF.calculate(MEG, [] , p_Lambda, transCorr);


    %%
    res.samples = Sample;
    res.wave = i;
    result{1,i}= res;
    result{2,i}= p_InverseSolution;
end;
save som_powerZw3_3 result
        
%%
% Close pool of MATLAB sessions for parallel computation
%matlabpool close;