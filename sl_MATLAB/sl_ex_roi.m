%> @page ex_rapmusic RAP-MUSIC Example
%> This is the description for the RAP-MUSIC example


%%
% Includes
sl_include_core;
sl_include_rap_music;


%
% Clear & close old stuff
clear all;
close all;
clc;

%%
%sl_CUtility.initSLEnv();
% matlabpool close force;
% matlabpool(8);

%%
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif', './Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%t_ForwardSolution = sl_CForwardSolution('C:\Users\Christoph\Desktop\sample_audvis-eeg-oct-6-fwd.fif');

%t_ForwardSolution = sl_CForwardSolution('C:\Users\Christoph\Documents\Thesis\Implementation\SourceLab\bin\MNE-sample-data\MEG\sample\sample_audvis-meg-eeg-oct-6-fwd.fif');

%%
t_ForwardSolution.calculateROIDistanceMap();

%%
t_ForwardSolution.plotBioMag();

%% ############## Clustering ##############
 t_ForwardSolutionClustered = t_ForwardSolution.clusterForwardSolution(40);%,[306]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
figure;
plot(t_ForwardSolutionClustered);
 
%% Plot sensor 1 change
% Sensor Data

%for sens = 1:306
sens = 5;%306;
label = t_ForwardSolution.idx2Label(1:t_ForwardSolution.numSources);
sourceCount = 0;
color = zeros(size(label,1),3);
for i = 1:t_ForwardSolution.sizeForwardSolution
    hemSize = size(t_ForwardSolution.src(1,i).rr,1);
    currLabel = label(1+sourceCount:hemSize+sourceCount);
    for j = 1:length(currLabel)
        if i == 1
            color(j+sourceCount,:) = t_ForwardSolution.label2Color('lh',currLabel(j));
        else
            [~ , color(j+sourceCount,:)] = t_ForwardSolution.label2Color('rh',currLabel(j));
        end;
    end;
    sourceCount = sourceCount + hemSize;
end
LF_orig = t_ForwardSolution.data;
tmp = reshape(LF_orig(sens,:),3,[])';

% Clustered Sensor Data
label = t_ForwardSolutionClustered.idx2Label(1:t_ForwardSolutionClustered.numSources);
sourceCount = 0;
colorClustered = zeros(size(label,1),3);
for i = 1:t_ForwardSolutionClustered.sizeForwardSolution
    hemSize = size(t_ForwardSolutionClustered.src(1,i).rr,1);
    currLabel = label(1+sourceCount:hemSize+sourceCount);
    for j = 1:length(currLabel)
        if i == 1
            colorClustered(j+sourceCount,:) = t_ForwardSolutionClustered.label2Color('lh',currLabel(j));
        else
            [~ , colorClustered(j+sourceCount,:)] = t_ForwardSolutionClustered.label2Color('rh',currLabel(j));
        end;
    end;
    sourceCount = sourceCount + hemSize;
end
LF = t_ForwardSolutionClustered.data;
tmp2 = reshape(LF(sens,:),3,[])';


%% Video %%
%% Full Source Space - without color
[m,n] = size(color);
bwColor = ones(m,n)*70;
%%
f = figure('Color',[1 1 1]);clf;
set(gca,'FontSize',18)
set(f, 'Position', [300, 150, 1024, 768]); 
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),2,bwColor./255,'filled');
xlabel('g_x [\muT/Am^2]'); ylabel('g_y [\muT/Am^2]'); zlabel('g_z [\muT/Am^2]');
axis equal; axis([-0.00025 0.00025 -0.00025 0.00025 -0.0004 0.0001 0 1]);
OptionZ.FrameRate=30;OptionZ.Duration=10;OptionZ.Periodic=true; 
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], 'FullSourceSpaceBW',OptionZ)

%% Full Source Space - with color
f = figure('Color',[1 1 1]);clf;
set(gca,'FontSize',18)
set(f, 'Position', [300, 150, 1024, 768]); 
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),3,color./255,'filled');
xlabel('g_x [\muT/Am^2]'); ylabel('g_y [\muT/Am^2]'); zlabel('g_z [\muT/Am^2]');
axis equal; axis([-0.00025 0.00025 -0.00025 0.00025 -0.0004 0.0001 0 1]);
OptionZ.FrameRate=30;OptionZ.Duration=10;OptionZ.Periodic=true; 
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], 'FullSourceSpace',OptionZ)

%% Clustered Source Space - with color
f = figure('Color',[1 1 1]);clf;
set(gca,'FontSize',18)
set(f, 'Position', [300, 150, 1024, 768]); 
scatter3(tmp2(:,1),tmp2(:,2),tmp2(:,3),3,colorClustered./255,'filled');
xlabel('g_x [\muT/Am^2]'); ylabel('g_y [\muT/Am^2]'); zlabel('g_z [\muT/Am^2]');
axis equal; axis([-0.00025 0.00025 -0.00025 0.00025 -0.0004 0.0001 0 1]);
OptionZ.FrameRate=30;OptionZ.Duration=10;OptionZ.Periodic=true; 
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], 'ClusteredSourceSpace',OptionZ)


%% Static %%
figure('Name',['Original Sensor ', num2str(sens)]);
scatter3(tmp(:,1),tmp(:,2),tmp(:,3),5,color./255,'filled');
xlabel('\muT/Am^2'); ylabel('\muT/Am^2'); zlabel('\muT/Am^2');
axis equal;
axis([-0.0002 0.0002 -0.0002 0.0002 -0.0002 0.0002 0 1])

figure('Name',['Clustered Sensor ', num2str(sens)]);
scatter3(tmp2(:,1),tmp2(:,2),tmp2(:,3),5,colorClustered./255,'filled');
xlabel('\muT/Am^2'); ylabel('\muT/Am^2'); zlabel('\muT/Am^2');
axis equal;
axis([-0.0002 0.0002 -0.0002 0.0002 -0.0002 0.0002 0 1])
% pause
% close all;

% end;

% Plot End
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ############## Simulator ##############
t_srcIdx = [t_ForwardSolution.AvailableSources(1,1).idx t_ForwardSolution.AvailableSources(1,2).idx];

t_Labels = [t_ForwardSolution.AvailableROIs(1,1).label; t_ForwardSolution.AvailableROIs(1,2).label];


t_numIdx = length(t_srcIdx);

t_iNumSimulationTrials = 10000;

t_SamplingFrequency = 1000;
%%

t_RapMusic = sl_CRapMusic(t_ForwardSolutionClustered, 1, 0);

result.distance = [];
result.SimulatedPairIdx = [];
result.SimulatedROIs = [];
result.ClusteredLocalizedPairIdx = [];
result.ClusteredLocalizedROIs = [];

distance = [999999, 999999];

for i = 1:t_iNumSimulationTrials
	t_SourceSimulationPairIdx = [random('unid',t_numIdx) random('unid',t_numIdx)]
    
    t_selROIs = t_ForwardSolution.idx2Label(t_SourceSimulationPairIdx);
     
    
	clear t_Simulator;
    
	t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

    T = 1/t_SamplingFrequency;
    duration = 0.1; % when measurement is too long - localization fails

    f1 = 9;
    t1 = 0:T:duration-T;
    s1 = sin(2*pi*t1*f1);
    t_Simulator.SourceActivation.addActivation(t_SourceSimulationPairIdx, s1);%, 'nn', [1 0 0; 0 1 0]);

    
    t_Simulator.simulate('mode',1,'snr',0);
    
    
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
    
    
    result(i,1).distance = distance;
    result(i,1).SimulatedPairIdx = t_SourceSimulationPairIdx;
    result(i,1).SimulatedROIs = t_selROIs;
    result(i,1).ClusteredLocalizedPairIdx = t_InverseSolution.SelectedActivatedSources;
    result(i,1).ClusteredLocalizedROIs = t_localizedROIs;
end

save('../resultROI.mat', 'result');

% %%  Single Simulation
% clear t_Simulator;
% t_SamplingFrequency = 1000;
% t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);
% 
% T = 1/t_SamplingFrequency;
% duration = 0.1; % when measurement is too long - localization fails
% 
% f1 = 9;
% t1 = 0:T:duration-T;
% s1 = sin(2*pi*t1*f1);
% t_Simulator.SourceActivation.addActivation([80 2400], s1);%, 'nn', [1 0 0; 0 1 0]);
% 
% % f2 = 16;
% % t2 = 0:T:duration-T;
% % s2 = sin(2*pi*t2*f2);
% % t_Simulator.SourceActivation.addActivation([147 879], s2, 'nn', [1 0 0; 0 1 0]);
% 
% %
% t_Simulator.simulate('mode',1,'snr',-20);
% %
% figure;
% plot(t_Simulator);
% figure;plot(t_Simulator.m_InverseSolution);
% 
% % ############## RAP-MUSIC ##############
% clear t_RapMusic t_InverseSolution;
% t_RapMusic = sl_CRapMusic(t_ForwardSolutionClustered, 1, 0);
% 
% % Calculation
% [t_InverseSolution, t_resCorrDipoleMap, t_resCorrelations ] = t_RapMusic.calculate(t_Simulator);%t_Measurement);
% 
% % Plot Results
% figure;
% plot(t_InverseSolution);
% 
% 
% 
% %% Arrange Figures
% sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);




























%% Some Selection Examples
% roiName = t_ForwardSolution.ROIAtlas(1,1).struct_names(4:2:8);
% disp(['Selecting following areas: ' roiName']);
% labels = t_ForwardSolution.atlasName2Label(roiName);
% 
% %% Select ROIs
% t_ForwardSolution.selectROIs('lh',labels(1,1).label,'rh',[])
% %% More Selection Examples
% 
% [radialList, degrees] = t_ForwardSolution.getRadialSources(20);
% 
% %%
% t_ForwardSolution.selectSources(radialList);
% 
% %%
% figure('Name', 'Radial');
% plot(t_ForwardSolution);
% 
% %%
% t_ForwardSolution.resetSourceSelection();
% 
% %%
% [tangentialList, degrees] = t_ForwardSolution.getTangentialSources(5);
% 
% %%
% t_ForwardSolution.selectSources(tangentialList);
% 
% %%
% figure('Name', 'Tangential');
% plot(t_ForwardSolution);
% 
% %%
% % t_ForwardSolution.selectSources([2 4098 4100 8195]);
% 
% t_ForwardSolution.selectChannels([1 2 3]);
% 
% %%
% t_ForwardSolution.resetSourceSelection();
% 
% %%
% plot(t_ForwardSolution);