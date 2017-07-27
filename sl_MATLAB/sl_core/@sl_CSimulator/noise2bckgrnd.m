%> @file    noise2bckgrnd.m
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
function [bckgrnd_sgnl, asym_ratio] = noise2bckgrnd(obj, dur)%, varargin)%bd, bt, ba, bb, bg)
% build background signal from nois

fs = obj.fSamplingFrequency;

%fs=1000; dur=10;
fny=fs/2; 
t=0:1/fs:dur-1/fs;
f=0:1/dur:fs-1/dur;
f_half=0:1/dur:fs/2-1/dur;

%nois
nois = randn(((dur+4)*fs),1); %white gaussian noise 2 parts longer to get rid of filter effects
nois = nois./max(abs(nois));
stop=(2*fs-1)+dur*fs;
%nois_plot = nois(2*fs:stop);

% p = inputParser;
% 
% p.addOptional('bd', band('delta', nois, fs, dur, stop, f_half), @(x)isvector(x));
% p.addOptional('bt', band('theta', nois, fs, dur, stop, f_half), @(x)isvector(x));
% p.addOptional('ba', band('alpha', nois, fs, dur, stop, f_half), @(x)isvector(x));
% p.addOptional('bb', band('beta', nois, fs, dur, stop, f_half), @(x)isvector(x));
% p.addOptional('bg', band('gamma', nois, fs, dur, stop, f_half), @(x)isvector(x));
% 
% p.parse(varargin{:});
% 
% bd = p.Results.bd;
% bt = p.Results.bt;
% ba = p.Results.ba;
% bb = p.Results.bb;
% bg = p.Results.bg;

%detailed frequency scale
fmax=100;
fstop=find(f==fmax);
fplot=f(1:fstop);

%get bands
delta = band('delta', nois, fs, dur, stop, f_half);%, bd);
theta = band('theta', nois, fs, dur, stop, f_half);%, bt);
alpha = band('alpha', nois, fs, dur, stop, f_half);%, ba);
beta = band('beta', nois, fs, dur, stop, f_half);%, bb);
gamma = band('gamma', nois, fs, dur, stop, f_half);%, bg);

%get signal
bckgrnd_sgnl=2/5*delta+4/5*theta+alpha+1/5*beta+1/20*gamma;

%get signal spectrum
bckgrnd_sgnl_spt = abs(fft(bckgrnd_sgnl)).^2;

% %detailed spectral visualization
% bckgrnd_sgnl_spt_plot=bckgrnd_sgnl_spt(1:size(fplot,2));

% %visualization
% figure(40); 
% subplot 512; plot(t, bckgrnd_sgnl); 
% subplot 513; plot(fplot,bckgrnd_sgnl_spt_plot); 

%calculate asymmetric ratio
du=find(f==3.5);
tl=find(f==4); tu=find(f==7.5);
al=find(f==8); au=find(f==13);
bl=find(f==14); bu=find(f==30);

asym_ratio= (sum(bckgrnd_sgnl_spt(1:du))+sum(bckgrnd_sgnl_spt(tl:tu)))/(sum(bckgrnd_sgnl_spt(al:au))+sum(bckgrnd_sgnl_spt(bl:bu)))

if asym_ratio >= 0.6 || asym_ratio <= 0.4
    [bckgrnd_sgnl, asym_ratio] = obj.noise2bckgrnd(dur);%, bd, bt, ba, bb, bg);
end
end

function band = band(name, nois, fs, dur, stop, f_half) %, b)
    switch name
        case 'delta'
        fu=0.1; fo=3.5; rank=20+1;
        case 'theta'
        fu=5.5; fo=6.5; rank=20+2;
        case 'alpha'
        fu=10; fo=11; rank=20+3;
        case 'beta'
        fu=14; fo=30; rank=20+4;
        case 'gamma'
        fu=30; fo=100; rank=20+5;
    end
    
    %filter design
    fny = fs/2;
    order=round(1/3*fs*dur);
    a = 1;
    wu = fu/fny; wo = fo/fny;
    b = fir1(order, [wu wo]);
    
    %band signal
    band = filter(b,a,nois);
    band = band(2*fs:stop);
    
    %band spectrum
    band_spkt = abs(fft(band)).^2;
    band_spkt_plot= band_spkt(1:size(f_half,2));
    
%     %visualisation
%     figure(100+rank);
%     % subplot 511; plot(t,nois_plot);
%     subplot 512; plot(t,band);
%     subplot 513; plot(f_half,band_spkt_plot);
%     % subplot 514; plot(t,delta_butter);
%     % subplot 515; plot(f_half,delta_butter_spkt_plot);
%     figure(rank+5);
%     freqz(b,a);
    
end