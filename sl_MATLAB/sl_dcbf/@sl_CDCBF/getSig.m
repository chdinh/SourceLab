%> @file    getSig.m
%> @author  Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	April, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2012 Peter Hoemmen. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File holds function to seperate Signal and Noise from Average

% =================================================================
%> @brief Seperates Signal and Noise
%>
%> Decomposes singular values from average data and seperates signal modes
%> and noise modes
%> 
%> @param raw  averaged signal from trigger till end
%> @param start First sample of desired signal window
%> @param stop Last sample of desired signal window
%> @param sensor Defines if only magnetometer, gradiometer or all sensors
%> should be taken into account (choose: 'mag', 'grad' or 'all')
%>
%> @retval Signal Calculated Signal containing signal only part and white
%> gaussian noise from the same power as noise only part
%> @retval Noise White gaussian noise from the same power as noise only
%> part
% =================================================================

function [Signal, Noise] = getSig(raw, start, stop, sensor)
    
    % choose set of sensors
    if strcmp(sensor,'mag') == 1
        raw = raw(3:3:end,:);
    elseif strcmp(sensor,'grad') == 1
        raw(3:3:end,:) = [];
    end;
        
    %> Sigular value decomposition of raw signal
    [U,S,V]=svd(raw(:,start:stop));
    %> Signal part
    s1 = U*S(:,1:8)*V(:,1:8)';
    %> Noise Only part
    n1 = U*S(:,9:end)*V(:,9:end)';
    %> Signal
    Signal = s1;
    
    for i = 1:size(s1,1);
        %> Signal-to-Noise Ratio
        SNR = 10*log10(var(s1(i,:))/var(n1(i,:)));
        % Substitude noise with white gaussian noise 
        Signal(i,:) = awgn(Signal(i,:), SNR,'measured');
    end;
    
    %> White Gaussian Noise Only
    Noise = Signal - s1;