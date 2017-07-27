%> @page ex_rapmusic RAP-MUSIC Example
%> This is the description for the RAP-MUSIC example


%%
% Includes
sl_include_mne;

%%
% Clear & close old stuff
clear all;
close all;
clc;

%%
% Source
% t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield.txt');
% %t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield-sim2.txt');
% matGrid = sl_CUtility.readSLMat('./Data/MEG/ernie/debug/grid.txt', 'Grid');
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif');

%%
plot(t_ForwardSolution);

%%
%t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement.txt');
%t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement-sim2.txt');

t_Measurement = sl_CMeasurement('./Data/MEG/ernie/sef.fif');

%%
t_Measurement.applyTrialDefinition();
t_Measurement.applyJumpArtifactRejection({'MEG*'});
%t_Measurement.applyMuscleArtifactRejection({'MEG*'});
%%
t_Measurement.applyFilter();
%%
t_Measurement.update()
%%
plot(t_Measurement);

%% MNE
t_matNoise = zeros(96,200);
t_MNE = sl_CMNE(t_ForwardSolution, t_matNoise')

%%
t_MNE.calculate(t_Measurement, 2);

X_MNE = t_MNE.m_matResult(1:3:end,:);
Y_MNE = t_MNE.m_matResult(2:3:end,:);
Z_MNE = t_MNE.m_matResult(3:3:end,:);


Amplitude = sqrt(X_MNE.^2 + Y_MNE.^2 + Z_MNE.^2);


[Amplitudes_sorted,IX] = sort(Amplitude);


% % Energy within the areas
% 
% EnergyX = var(X_MNE,0,2);
% EnergyY = var(Y_MNE,0,2);
% EnergyZ = var(Z_MNE,0,2);


% Amplitude = sqrt(X_MNE.^2 + Y_MNE.^2 + Z_MNE.^2);
% NormFaktor = max(Amplitude,[],1);
% NormAmplitude = (Amplitude/diag(NormFaktor)).^0.1;
% min_Norm = min(NormAmplitude,[],1);
% max_Norm = max(NormAmplitude,[],1);
% diff_Norm = max_Norm-min_Norm;
% minMat = ones(size(Amplitude,1),1)*min_Norm;
% diffMat = ones(size(Amplitude,1),1)*diff_Norm;
% NormAmplitude=(NormAmplitude-minMat)./diffMat;



y_max = 20;%1e-2;
x_max = 1024;

close all;
figure;
subplot(3,1,1);
plot(X_MNE);
axis([0 x_max -y_max y_max])

subplot(3,1,2);
plot(Y_MNE);
axis([0 x_max -y_max y_max])

subplot(3,1,3);
plot(Z_MNE);
axis([0 x_max -y_max y_max])


figure('Name','Amplitude');
plot(Amplitude);



% figure;
% subplot(3,1,1);
% plot(EnergyX)
% subplot(3,1,2);
% plot(EnergyY)
% subplot(3,1,3);
% plot(EnergyZ)

%%
close all;

numberOfPoints = 500;

S = ones(numberOfPoints,1)*10;
Color = zeros(numberOfPoints,3);
%Color(:,3) = ones(size(NormAmplitude,1),1);

for i = 1:10
    %Color(:,1) = NormAmplitude(:,i);

    figure;
    scatter3(matGrid(IX(1:numberOfPoints,i),1),matGrid(IX(1:numberOfPoints,i),2),matGrid(IX(1:numberOfPoints,i),3),S(:,1),Color,'filled');
end

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);