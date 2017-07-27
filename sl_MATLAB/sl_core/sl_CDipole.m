%> @file    sl_CDipole.m
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
classdef sl_CDipole < sl_C3DOrientation
    %ToDo it is actually a Orientation - inherit from Orientation
    
    %SL_CDIPOLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent = true)
        
    end
    
    methods 
        
        %% sl_CDipole Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CDipole class.
        % =================================================================
        function obj = sl_CDipole(varargin)
            obj = obj@sl_C3DOrientation(varargin{:}); % call superclass constructor
            %obj.xyz = aaa;         % assign a property value
        end
    end
    
    methods (Static)
        
        %% Type
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More 
        %>
        %> @return ToDo
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.PhysicalModel;
        end % getType
        
        %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            %% getName
            name = 'Dipole';
        end % getName
                 
        %Methods in a separate file

    end % static methods

end

