%> @file    sl_CGPUDevice.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	July, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2012 Christoph Dinh. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   ToDo File description
% =========================================================================
%> @brief   ToDo Summary of this class
%
%> ToDo Detailed explanation
% =========================================================================

classdef sl_CGPUDevice
    %SL_CGPUDEVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %> ToDo
        m_iDeviceCount; % explaination goes here
        %> ToDo
        m_selGPUDevice;    % explaination goes here
    end % properties
    
    methods
        %% sl_CGPUDevice 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @return instance of the sl_CGPUDevice class.
        % =================================================================
        function obj = sl_CGPUDevice()
        % SL_CGPUDEVICE  Default Constructor
            obj.m_iDeviceCount = gpuDeviceCount;
            if obj.m_iDeviceCount > 0
                obj.m_selGPUDevice = gpuDevice;
            end;
        end % sl_CDevice
        
        %% disp 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object@param varargin ToDo
        %>
        %> @return instance of the disp class.
        % =================================================================
        function disp(obj)
        % DISP  Display the selected gpu device
            if isa(obj, 'sl_CGPUDevice')
                if obj.m_iDeviceCount > 0
                    disp('Selected GPU Device:');
                    disp(obj.m_selGPUDevice);
                else
                    error('No suitable device available!');
                end;
            else
                error('Input is not an object of the class sl_CGPUDevice.');
            end
        end % disp
        
        
    end % methods
end % classdef