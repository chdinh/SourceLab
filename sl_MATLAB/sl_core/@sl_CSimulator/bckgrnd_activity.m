%> @file    bckgrnd_activity.m
%> @author  Alexander Hunold <alexander.hunold@tu-ilmenau.de>
%> @version	1.0
%> @date	December, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Alexander Hunold. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.


% =================================================================
%> @brief Brief description of the exampleStaticPrivateMethod method
%>
%> This method is static and private
%>
%> @param obj object itself
%> @param dur Duration of the generated measurement.
%>
%> @retval p_matBckgrnd_activity ToDo
%> @retval asymmetric_ratio ToDo
% =================================================================
function [p_matBckgrnd_activity, asymmetric_ratio] = bckgrnd_activity(obj, invSol, dur, ds)%, varargin)% bd, bt, ba, bb, bg)
%generate a background signal for each source
% first draft: fs=1000; dur=5;

% p = inputParser;
% p.addOptional('bd', [], @isvector);
% p.addOptional('bt', [], @isvector);
% p.addOptional('ba', [], @isvector);
% p.addOptional('bb', [], @isvector);
% p.addOptional('bg', [], @isvector);
% 
% p.parse(varargin{:});
% 
% bd = p.Results.bd;
% bt = p.Results.bt;
% ba = p.Results.ba;
% bb = p.Results.bb;
% bg = p.Results.bg;

%Alex LF Format
iNumOfSources = invSol.m_corrForwardSolution.defaultSolutionSourceSpace.numSources;

p_matBckgrnd_activity=zeros(dur, iNumOfSources/ds);
asymmetric_ratio=zeros(1,iNumOfSources/ds);

m=1;
%Calculate Background activity for every 10th source
for i = 1:ds:iNumOfSources 
    [bckgrnd_sgnl, asym_ratio] = obj.noise2bckgrnd(dur/obj.fSamplingFrequency);%bd, bt, ba, bb, bg);
    p_matBckgrnd_activity(:,m) = bckgrnd_sgnl;
    asymmetric_ratio(1,m) = asym_ratio;
    m=m+1;
end

%save('/home/msi/AlHu/Data/BEM/alhu/model_data/BackgroundActivity.mat', 'p_matBckgrnd_activity', 'asymmetric_ratio', '-v7.3');