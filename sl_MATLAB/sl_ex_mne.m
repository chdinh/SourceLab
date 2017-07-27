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
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
%t_ForwardSolution.addChannelInfo('./Data/MEG/ernie/sef.fif');

%t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield.txt');
%t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/debug/leadfield-sim2.txt');

%% Simulator
t_SamplingFrequency = 1000;
t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

T = 1/t_SamplingFrequency;
duration = 0.1; % when measurement is too long - localization fails

f1 = 9;
t1 = 0:T:duration-T;
s1 = sin(2*pi*t1*f1);
t_Simulator.SourceActivation.addActivation([234 3814], s1, 'nn', [1 0 0; 0 1 0]);

% f2 = 16;
% t2 = 0:T:duration-T;
% s2 = sin(2*pi*t2*f2);
% t_Simulator.SourceActivation.addActivation([147 879], s2, 'nn', [1 0 0; 0 1 0]);
% 
% %
t_Simulator.simulate('mode',1,'snr',10);
t_Simulator.addChannelInfo('./Data/MEG/ernie/sef.fif');

plot(t_Simulator);

%% Real Measurement
% t_Measurement = sl_CMeasurement('./Data/MEG/ernie/sef.fif');
% t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement.txt');
% t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement-sim2.txt');
% plot(t_Measurement);

% %% SVD
% t_TSVD = sl_CTSVD(t_ForwardSolution);
% 
% %%
% % t_TSVD.calculate(t_Measurement, 48);
% t_TSVD.calculate(t_Simulator, 48);
% 
% 
% X = t_TSVD.m_matResult(1:3:end,:);
% Y = t_TSVD.m_matResult(2:3:end,:);
% Z = t_TSVD.m_matResult(3:3:end,:);
% 
% y_max = 1e-2;
% x_max = 1024;
% 
% figure;
% subplot(3,1,1);
% plot(X);
% axis([0 x_max -y_max y_max])
% 
% subplot(3,1,2);
% plot(Y);
% axis([0 x_max -y_max y_max])
% 
% subplot(3,1,3);
% plot(Z);
% axis([0 x_max -y_max y_max])


%% MNE
% t_matNoise = zeros(96,200);
t_MNE = sl_CMNE(t_ForwardSolution, t_Simulator');

%%
%t_MNE.compute_raw_data_covariance(t_Simulator);

%%
t_MNE.calculate(t_Simulator, 2);

X_MNE = t_MNE.m_matResult(1:3:end,:);
Y_MNE = t_MNE.m_matResult(2:3:end,:);
Z_MNE = t_MNE.m_matResult(3:3:end,:);

y_max = 10;%1e-1;
x_max = 1024;

figure('Name','MNE');
subplot(3,1,1);
plot(X_MNE);
axis([0 x_max -y_max y_max])

subplot(3,1,2);
plot(Y_MNE);
axis([0 x_max -y_max y_max])

subplot(3,1,3);
plot(Z_MNE);
axis([0 x_max -y_max y_max])

figure;
plot(Y_MNE(576,:))

%% Arrange Figures
sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);
