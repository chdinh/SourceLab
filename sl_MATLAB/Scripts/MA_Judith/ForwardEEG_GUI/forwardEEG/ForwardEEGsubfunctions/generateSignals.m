 function [EEGsig,fs,N]=generateSignals(signal)

% function that generates the signals for the dipoles in the ForwardEEG GUI

addpath('DipoleSignals');
% set signal parameters
fs = 1000; % sampling frequency in sps
l= 0.5; % signal length in s
N=fs*l; % no. of samples
dt=1/fs; % time step
t=0:dt:(N-1)*dt; % time axis
t_d=0:dt:(100-1)*dt;

%for i=1:length(signal,1)
switch signal
    case 1 % none
    case 2 % alpha-band sinus wave
        amp=1;
        f=12;
        EEGsig=zeros(1,N);
        EEGsig(1,1:N)=amp.*sin(2*pi*f*t);
    case 3 % beta-band sinus wave
        amp=1;
        f=20;
        EEGsig=zeros(1,N);
        EEGsig(1,:)=amp.*sin(2*pi*f*t);
    case 4 % ts-alpha-band sinus wave
        amp=1;
        f=12;
        EEGsig=zeros(1,N);
        EEGsig(1,151:250)=amp.*sin(2*pi*f*t_d);
    case 5 % ts-beta-band sinus wave
        amp=1;
        f=20;
        EEGsig=zeros(1,N);
        EEGsig(1,151:250)=amp.*sin(2*pi*f*t_d);
        EEGsig=Y(:,2);
    case 6 % gamma-band sinus wave
        amp=1;
        f=50;
        EEGsig=amp.*sin(2*pi*f*t);
    case 7 % evoked potential
        EEGsig=zeros(length(t),1); % initialize the signal
        load syntransvep
        EEGsig(1:length(tra))=tra;
    case 8 % sleep spindles
        ampSleep=1;
        f=20;
        fmod=3;
        EEGsig= ampSleep.*sin(2*pi*f*t).*sin(2*pi*fmod*t);
    case 9 % wave
        signal_name='wave';
        t_K=t(:,1:300);
        fSin = 1.6;
        amp=1;
        EEGsig=zeros(1,N);
        x=(sin(2*pi*fSin*t_K).*exp(-3*t_K))/max(sin(2*pi*fSin*t_K).*exp(-3*t_K));
        EEGsig(1,1:size(t_K,2)) = (sin(2*pi*fSin*t_K).*exp(-25*t_K))/max(sin(2*pi*fSin*t_K).*exp(-25*t_K));
    case 10 % spikes
        t_tri=(t(:,1:fs/4))-0.05;
        EEGsig=zeros(1,N);
        EEGsig(1,1:250)=repmat(tripuls(t_tri,0.03),1,1); % occurrence one per second with a duration of 60 ms
    case 11 % spike wave complex
        t_tri=t(:,1:80)-0.04;
        tri=(tripuls(t_tri)./0.92-1)/max(tripuls(t_tri)./0.92-1);
        t_par=t(:,1:300)-0.15;
        par=-45.*(t_par.^2)+1.0125;
        par=par./max(par); %normalization
        SW=repmat([tri par],1,1);
        EEGsig=zeros(length(t),1);
        EEGsig(length(EEGsig)/8:length(EEGsig)/8+length(SW)-1,:)=SW;
    case 12 % eye blink
        t_eye=t(:,1:400);
        fSin = 2.5;
        amp=1;
        EEGsig=zeros(1,N);
        EEGsig(1:length(t_eye))=(sin(2*pi*fSin*t_eye).*exp(-3*t_eye))/max(sin(2*pi*fSin*t_eye).*exp(-3*t_eye))+1;
    case 13 % polyspikes
        t_tri=t(:,1:73)-0.035;
        t_tri=linspace(-1,1,83);
        tri=tripuls(t_tri,2);
        poly_tri=repmat(tri,1,8);
        EEGsig=poly_tri(22:length(t)+21)-0.5;
    case 14 %shortTestSignal
        EEGsig=zeros(1,N);
        EEGsig(1:400)=ones(1,400);
    case 15 % paraboloid
        t_par=t(:,1:100);
        par=-1/0.05^2.*((t_par-0.05).^2)+1;
        par=par./max(par); %normalization
        EEGsig=zeros(length(t),1);
        EEGsig(1:100,:)=par;
    case 16 % triangle
        t_tri=t(:,1:81)-0.04;
        tri=(tripuls(t_tri)./0.92-1)/max(tripuls(t_tri)./0.92-1);
        EEGsig=zeros(length(t),1);
        EEGsig(length(EEGsig)/8:length(EEGsig)/8+length(tri)-1,:)=tri;
    case 17 % sinus period
        nsamp=250;
        EEGsig=zeros(length(t),1);
        t_sin=t(:,1:nsamp);
        t_g=linspace(1,250,250);
        f=10;
        amp=0.5;
        off=0;
        gauss=pdf('norm',t_g,125,70);
        %gauss=1;
        sinsig=amp.*sin(2*pi*f*t_sin);
        EEGsig(1:nsamp)=gauss.*amp.*sin(2*pi*f*t_sin)+off;
    case 18 % gauss with rect
        t_g1=linspace(1,50,50);
        t_g2=linspace(1,150,150);
        %t_rect=linspace(51,250,200);
        g_1=pdf('norm',t_g1,50,10);
        g_2=pdf('norm',t_g2,150,50);
        g_1=g_1./max(g_1);
        g_2=g_2./max(g_2);
        EEGsig=zeros(length(t),1);
        EEGsig(1:300,1)=[g_1'; ones(100,1); flipud(g_2')];
        % only gauss
         signal_name='gauss';
        t_g=linspace(1,100,100);
        g=pdf('norm',t_g,50,15);
        EEGsig=zeros(length(t),1);
        EEGsig(1:100,1)=g';
        EEGsig=EEGsig';
     case 19 % time-shifted spike
        t_tri=(t(:,1:fs/4))-0.05;
        EEGsig=zeros(1,N);
        EEGsig(1,101:350)=repmat(tripuls(t_tri,0.03),1,1);   
end

% normalize EEG signal
EEGsig=EEGsig./max(abs(EEGsig));

%  figure;
%  plot(t_sin,sinsig);
%  figure;
%  t_plot=linspace(1,length(t),length(t));
%  plotSig=plot(t_plot,EEGsig);
%  ylabel('normalized amplitude','FontSize',14);
%  xlabel('t/ms','FontSize',14);
%  set(gca,'fontsize',14);

