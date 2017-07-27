%> @page ex_TF_MxNE Example
%> This is the description for the TF_MxNE example

%%
% Includes
sl_include_TF_MxNE;

%%
% Clear & close old stuff
clear all;
close all;
clc;

%%
% Source
t_ForwardSolution = sl_CForwardSolution([],[],[],'debugLF','./Data/MEG/ernie/debug/leadfield.txt');

%%
t_Measurement = sl_CMeasurement('./Data/MEG/ernie/debug/measurement.txt');
plot(t_Measurement);

%%
t_Measurement.data = [t_Measurement.data zeros(t_Measurement.numChannels, 2 ^ ceil(log2(t_Measurement.numSamples))- t_Measurement.numSamples)];
t_Measurement.data = t_Measurement.data(:,1:128); 
figure, plot(t_Measurement);

%%
clear TF;
TF = sl_CTF_MxNE(t_ForwardSolution,'norient',3,'maxit',100,'tol',0.000001,'lambdal1',0.1,'lambdal21',10);

% add options
options = [];

TF.calculate(t_Measurement)

plot(TF)