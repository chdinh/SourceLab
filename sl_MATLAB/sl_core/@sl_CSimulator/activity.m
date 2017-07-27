%> @file    activity.m
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
function p_matActivity = activity(obj, fs, dur)



%Function alhu_Activity generates all needed activity variables
%
%Input
%fs - sample rate
%dur - duration of one simulation periode

%generate background activity
[bckgrnd_akt, asymmetric_ratio] = bckgrnd_activity(fs, dur, ss_mesh, bd, bt, ba, bb, bg)

bckgrnd_act_mV = bckgrnd_akt*2*10^4;        %factor to recieve physiological values in responses

%generate spike signal
%[spike, t] = alhu_spike(fs,dur);
load(strcat(datapath,'/model_data/SpikeSignal.mat'),'spike');
spike_mV = spike*4*10^5;                    %factor to recieve physiological values in responses
spike_in_bckgrnd_mV = spike_mV+bckgrnd_act_mV(:,1)';

% %load precalculated signals
% load(strcat(datapath,'/model_data/Activity_Spike_mV.mat'),'bckgrnd_act_mV','spike_mV','spike_in_bckgrnd_mV');

%Signal components
p_matActivity.BG_Activity=bckgrnd_act_mV;
p_matActivity.Spike=spike_mV';
p_matActivity.Spike_in_Activity=spike_in_bckgrnd_mV';
p_matActivity.Silence=zeros(size(p_matActivity.BG_Activity));

%background sources
p_matActivity.BG_Sources.crd=ss_mesh.p(1:10:end,:);
inds=1:10:length(ss_mesh.p);
p_matActivity.BG_Sources.inds=inds'; 
p_matActivity.BG_Sources.ories=ss_mesh.orientations(p_matActivity.BG_Sources.inds,:);

%constants
t=0:1/fs:dur-1/fs;
p_matActivity.t=t'; 
p_matActivity.fs=fs;
p_matActivity.dur=dur;

save(strcat(datapath,'/model_data/Activity.mat'),'p_matActivity','-v7.3');