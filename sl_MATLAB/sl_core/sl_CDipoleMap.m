%> @file    sl_CDipoleMap.m
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

classdef sl_CDipoleMap < sl_CMap
    %SL_CINVERSESOLUTION Summary of this class goes here
    %   Detailed explanation goes here
        
    properties
        %m_pForwardSolution;
    end
    
    properties (Dependent = true)
        %> ToDo
        NumOfDipoles;
    end % properties (Dependent)
      
    methods
        %% sl_CDipoleMap Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CDipoleMap class.
        % =================================================================
        function obj = sl_CDipoleMap(varargin)
            if nargin == 1 && isa(varargin{1}, 'sl_CDipoleMap') %Copy Constructor
                obj.m_listKeys = varargin{1}.m_listKeys;
                obj.m_listValues = varargin{1}.m_listValues;
                %obj.m_pForwardSolution = varargin{1}.m_pForwardSolution;
            else
                obj.m_listKeys = sl_CList();
                obj.m_listValues = sl_CList();
                %obj.m_pForwardSolution = sl_CForwardSolution();
            end
        end % sl_CDipoleMap
        
        %% get.NumOfDipoles Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return ToDo
        % =================================================================
        function numDipoles = get.NumOfDipoles(obj)
            numDipoles = obj.size();
        end
        
        % =================================================================
        %> @brief [Overloaded]Inserts Dipole(s);
        %>
        %> Inserts a new dipole with the coresponding key key.
        %> If there is already an item with the key key, that dipole is
        %> replaced.
        %> 
        %> If there are multiple items with the key key, the most recently
        %> inserted item's value is replaced with value.
        %>
        %> @param key the key of the inserted item.
        %> @param dipole the new dipole
        % =================================================================
        
        %% insert
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param key ToDo
        %> @param dipole ToDo
        %>
        %> @return ToDo
        % =================================================================
        function obj = insert(obj, key, dipole)
            if isa(dipole, 'sl_CDipole')
                if ~obj.m_listKeys.isEmpty()
                    if strcmp(class(obj.m_listKeys.first()), class(key)) || (ischar(key) && iscell(obj.m_listKeys.first()))
                        if strcmp(class(obj.m_listValues.first()), class(dipole))
                            % ToDo allow multiple values for one dipole
%                             [b idx] = obj.m_listKeys.contains(key);
%                             if b
%                                 obj.m_listValues.replace(idx(end),dipole);
%                             else
                                obj.m_listKeys.append(key);
                                obj.m_listValues.append(dipole);
%                             end
                        else
                            error(['Value (' class(dipole) ') and values of the map containing types (' class(obj.m_listValues.first()) ') are not identically.']);
                        end
                    else
                        error(['Key (' class(key) ') and keys of the map containing types (' class(obj.m_listKeys.first()) ') are not identically.']);
                    end
                else
                    obj.m_listKeys.append(key);
                    obj.m_listValues.append(dipole);
                end
            else
                error(['Dipole (' class(dipole) ') is not of class type sl_CDipole.']);
            end
        end % insert
        
        % =================================================================
        %> @brief Same as insert();
        %>
        %> Inserts a new dipole with the coresponding key key.
        %> If there is already an item with the key key, that dipole is
        %> replaced.
        %> 
        %> If there are multiple items with the key key, the most recently
        %> inserted item's value is replaced with value.
        %>
        %> @param key the key of the inserted item.
        %> @param dipole the new dipole
        % =================================================================
        
        %% addDipole
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param key ToDo
        %> @param p_Dipole ToDo
        %>
        %> @return ToDo
        % =================================================================
        function obj = addDipole(obj, key, p_Dipole)
            if isa(p_Dipole, 'sl_CDipole')
                obj.insert(key, p_Dipole);
            else
                error('p_Dipole is not of class type sl_CDipole.');
            end
        end
        

        % =================================================================
        %> @brief Returns the dipole associated with the key key. (Same as
        %>        value())
        %>
        %> If the map contains no item with key key, the function returns
        %> an empty array. If there are multiple items for key
        %> in the map, all values are returned in an array.
        %>
        %> @param key The key for which associated values are requested
        %>
        %> @retval val Values which are associated with the key.
        % =================================================================
        
        %% Dipole
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @param obj Instance of the class object
        %> @param key ToDo
        %>
        %> @return ToDo
        % =================================================================
        
        function p_Dipole = Dipole(obj, key)
            p_Dipole = obj.value(key);
        end
        
    end % methods
    
    
    methods (Static)
        
        %% Type
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function type = Type()
            type = sl_Type.PhysicalModel;
        end % getType
        
        %% Name
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return ToDo
        % =================================================================
        function name = Name()
            name = 'Dipole Map';
        end % getName
    end % static methods
    
end

