%> @page ex_rapmusic RAP-MUSIC Example
%> This is the description for the RAP-MUSIC example


%%
% Includes
addpath '../sl_core' '-begin';
addpath '../sl_rap_music' '-end';
addpath(genpath('../3rdParty'));

%% Clear & close old stuff
clear all;
close all;
clc;

%%
sl_CUtility.initSLEnv();
% matlabpool close force;
% matlabpool(8);

%%
t_ForwardSolution = sl_CForwardSolution('../Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../Data/subjects/ernie/label/lh.aparc.a2009s.annot','../Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%%
t_ForwardSolution.calculateROIDistanceMap();


%% ############## Clustering ##############
 t_ForwardSolutionClustered = t_ForwardSolution.clusterForwardSolution(40);%,[306]);


%% ############## Simulator ##############
t_srcIdx = [t_ForwardSolution.AvailableSources(1,1).idx t_ForwardSolution.AvailableSources(1,2).idx];

t_numIdx = length(t_srcIdx);

t_Labels = [t_ForwardSolution.AvailableROIs(1,1).label; t_ForwardSolution.AvailableROIs(1,2).label];

t_SamplingFrequency = 100;

t_iNumSimulationTrials = 1000;
t_vecSNR = [20 10 5 0 -5 -10 -20];

t_RapMusic = sl_CRapMusic(t_ForwardSolutionClustered, 1, 0);

result.snr = [];
result.err.distance = [];
result.err.SimulatedPairIdx = [];
result.err.SimulatedROIs = [];
result.err.ClusteredLocalizedPairIdx = [];
result.err.ClusteredLocalizedROIs = [];


%%
distance = [999999, 999999];

for z = 1:length(t_vecSNR)
    z
    result(z,1).snr = t_vecSNR(z);
    
    for i = 1:t_iNumSimulationTrials
        i
        search = true;
        while search
            t_SourceSimulationPairIdx = [random('unid',t_numIdx) random('unid',t_numIdx)]
            if t_SourceSimulationPairIdx(1) ~= t_SourceSimulationPairIdx(2)
                search = false;
            end
        end

        t_selROIs = t_ForwardSolution.idx2Label(t_SourceSimulationPairIdx);


        clear t_Simulator;

        t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

        T = 1/t_SamplingFrequency;
        duration = 0.1; % when measurement is too long - localization fails

        f1 = 9;
        t1 = 0:T:duration-T;
        s1 = sin(2*pi*t1*f1);
        t_Simulator.SourceActivation.addActivation(t_SourceSimulationPairIdx, s1);%, 'nn', [1 0 0; 0 1 0]);


        t_Simulator.simulate('mode',1,'snr',t_vecSNR(z));


        % ############## RAP-MUSIC ##############
    %     clear t_RapMusic t_InverseSolution;
    %     t_RapMusic = sl_CRapMusic(t_ForwardSolutionClustered, 1, 0);
        clear t_InverseSolution;

        % Calculation
        [t_InverseSolution, t_resCorrDipoleMap, t_resCorrelations ] = t_RapMusic.calculate(t_Simulator);%t_Measurement);


        t_localizedROIs = t_ForwardSolutionClustered.idx2Label(t_InverseSolution.SelectedActivatedSources);


        %% Result
        pair.src = [0 0];
        pair.target = [0 0];
        for j = 1:2
            if t_SourceSimulationPairIdx(j) <= length(t_ForwardSolution.AvailableSources(1,1).idx)
                k = find(t_Labels == t_selROIs(j), 1, 'first');
            else
                k = find(t_Labels == t_selROIs(j), 1, 'last');
            end
            pair.src(j) = k;

            if t_InverseSolution.SelectedActivatedSources(j) <= length(t_ForwardSolutionClustered.AvailableSources(1,1).idx)
                l = find(t_Labels == t_localizedROIs(j), 1, 'first');
            else
                l = find(t_Labels == t_localizedROIs(j), 1, 'last');
            end
            pair.target(j) = l;
        end

        distance = [99999 99999];
        for j = 1:2
            distance(j) = t_ForwardSolution.ROIDistanceMap(pair.src(j),pair.target(1));

            if distance(j) > t_ForwardSolution.ROIDistanceMap(pair.src(j),pair.target(2))
                distance(j) = t_ForwardSolution.ROIDistanceMap(pair.src(j),pair.target(2));
            end
        end

        %Do cross check
        result(z,1).err(i,1).distance = distance;
        result(z,1).err(i,1).SimulatedPairIdx = t_SourceSimulationPairIdx;
        result(z,1).err(i,1).SimulatedROIs = t_selROIs;
        result(z,1).err(i,1).ClusteredLocalizedPairIdx = t_InverseSolution.SelectedActivatedSources;
        result(z,1).err(i,1).ClusteredLocalizedROIs = t_localizedROIs;
    end
end

filename = strcat('resultROI_', datestr(now,'yyyymmddTHHMMSS'));
save(strcat('./output/',filename), 'result');