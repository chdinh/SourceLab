%%

% Calculating the Correlation Coefficient (Pearson/Spearman)for the dipols
% of the Leadfield Matrix
% Calculation of the correlation of the different orientations of the
% Leadfield Dipoles
% Graphical representation of the correlation 
% 
% !!!! IMPORTANT: Use Spearman XOR Pearson, 
% (dim: covariance matrices (8195 x 8195)

% Includes

addpath ('../../../sl_Matlab');
sl_include_dcbf;
sl_include_core
%%
clear all;
close all;
clc;



%% FowardSolution
t_ForwardSolution = sl_CForwardSolution('../../../sl_Matlab/Data/MEG/ernie/sef-oct-6p-src-fwd.fif', '../../../sl_Matlab/Data/subjects/ernie/label/lh.aparc.a2009s.annot','../../../sl_Matlab/Data/subjects/ernie/label/rh.aparc.a2009s.annot');


%% Matrix for X,Y,Z Orientation of dipoles in Leadfield Matrix

Lead_x=t_ForwardSolution.data(:,1:3:end);
Lead_y=t_ForwardSolution.data(:,2:3:end);
Lead_z=t_ForwardSolution.data(:,3:3:end);

%% Correlation Coefficient of dipoles in respect of their orientation
% !!! Use only one Calculation (Pearson XOR Spearman) to save RAM
%% Pearson
corr_x = corrcoef(Lead_x); 
corr_y = corrcoef(Lead_y);
corr_z = corrcoef(Lead_z);

%% Spearman
% Spearmankorrelation
spear_x =corr(Lead_x ,'type','Spearman') ;
spear_y =corr(Lead_y ,'type','Spearman') ;
spear_z =corr(Lead_z ,'type','Spearman') ;


%% Use according to your choice Pearson or Spearman
%% Plot Pearson

 figure('name','Pearson Correlation');

subplot(221);
imagesc(corr_x);
title('Correlation x-orientation')

subplot(222);
imagesc(corr_y);
title('Correlation y-orientation')

subplot(223);
imagesc(corr_z);
title('Correlation z-orientation')
 
%% Plot Spearman

 figure('name','Spearman Correlation');

subplot(221);
imagesc(spear_x);
title('Correlation x-orientation')

subplot(222);
imagesc(spear_y);
title('Correlation y-orientation')

subplot(223);
imagesc(spear_z);
title('Correlation z-orientation')
 
%% Connectiong corr_x, corr_y, corr_z
% change corr for spear to calculate for spearman-matrices
% Different attempts, mathematecaly not verified

% simple addition
corr_add = (corr_x + corr_y + corr_z)./3;

% simple multiplication
% corr_mult = (corr_x .* corr_y .* corr_z).^(1/3); % complex values
%%
% mean square
corr_mean = ((((corr_x).^2 + (corr_y).^2 + (corr_z).^2)./3).^(1/2));

%%
figure('name','Combined Correlation: Pearson');
subplot(121);
imagesc(corr_add);
title('simple addition')
subplot(122);
imagesc(corr_mean);
title('mean square')