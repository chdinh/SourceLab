%> @file    getLeadField.m
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
%> @brief   File holds function to seperate Lead Field in chosen Sensors

% =================================================================
%> @brief Seperates Lead Field in chosen Sensors
%>
%> Seperates the full Lead Field in only magnetometers, gradiometers or all
%> sensors
%> 
%> @param raw_LF Unprepared Lead Field
%> @param sensor Defines if only magnetometer, gradiometer or all sensors
%> should be taken into account (choose: 'mag', 'grad' or 'all')
%>
%> @retval LeadField Seperated Lead Field
% =================================================================

function [LeadField] = getLeadField(raw_LF,sensor)

    % choose set of sensors
    if strcmp(sensor,'mag') == 1
        LeadField = raw_LF(3:3:end,:);
    elseif strcmp(sensor,'grad') == 1
        LeadField = raw_LF;
        LeadField(3:3:end,:) = [];
    elseif strcmp(sensor,'all') == 1
        LeadField = raw_LF;
    end;