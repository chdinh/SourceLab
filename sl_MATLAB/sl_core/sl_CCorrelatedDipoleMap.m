%> @file    sl_CCorrelatedDipoleMap.m
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
classdef sl_CCorrelatedDipoleMap < sl_IValue
    %SL_CCORRELATEDDIPOLEMAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %> ToDo
        m_dipoleMapOne;
        %> ToDo
        m_dipoleMapTwo;
        
        %m_pForwardSolution;
    end
    
    properties (Dependent = true)
        %> ToDo
        first;
        %> ToDo
        second;
        %> ToDo
        NumOfDipolePairs;
    end % properties (Dependent=true)
    
    methods
        %% sl_CCorrelateddipoleMap Constructor 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param varargin ToDo
        %>
        %> @return instance of the sl_CCorrelatedDipoleMap class.
        % =================================================================
        function obj = sl_CCorrelatedDipoleMap(varargin)
            if nargin == 1 && isa(varargin{1}, 'sl_CCorrelatedDipoleMap') %Copy Constructor
                obj.m_dipoleMapOne = varargin{1}.m_mapOne;
                obj.m_dipoleMapTwo = varargin{1}.m_mapTwo;
                
                %obj.m_pForwardSolution = varargin{1}.m_pForwardSolution;
            else
                obj.m_dipoleMapOne = sl_CDipoleMap();
                obj.m_dipoleMapTwo = sl_CDipoleMap();
                
                %obj.m_pForwardSolution = sl_CForwardSolution();
            end
        end % sl_CCorrelatedDipoleMap
        
        
        % =================================================================
        %> @brief Returns first component
        %>
        %> Returns the first component of the pair.
        %>
        %> @return value Returns the first component.
        % =================================================================
        
        %% get.first 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return instance of the get.first class.
        % =================================================================
        function value = get.first(obj)
            %% get.first  
            value = obj.m_dipoleMapOne;
        end % get.first 
        
        
        % =================================================================
        %> @brief Returns second component
        %>
        %> Returns the second component of the pair.
        %>
        %> @return value Returns the second component.
        % =================================================================
        
        %% get.first 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return instance of the get.first class.
        % =================================================================
        function value = get.second(obj)
            %% get.second 
            value = obj.m_dipoleMapTwo;
        end % get.second 
        
        
        % =================================================================
        %> @brief Sets first component
        %>
        %> Sets the first component of the pair.
        %>
        %> @param p_value The value which will be assigned to the first
        %>                component.
        % =================================================================
        
        %% set.first 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @param obj Instance of the class object
        %> @param p_value ToDo
        %>
        %> @return instance of the set.first class.
        % =================================================================
        function set.first(obj,p_value)
            %% set.first
            if isa(p_value, 'sl_CDipoleMap')
                obj.m_dipoleMapOne = p_value;
            else
                error('p_value is not of the type sl_CDipoleMap.');
            end
        end % set.first 

        % =================================================================
        %> @brief Sets second component
        %>
        %> Sets the second component of the pair.
        %>
        %> @param p_value The value which will be assigned to the second
        %>                component.
        % =================================================================
        
        %% set.second
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param p_value ToDo
        %>
        %> @return instance of the set.second class.
        % =================================================================
        function set.second(obj,p_value)
            %% set.second 
            if isa(p_value, 'sl_CDipoleMap')
                obj.m_dipoleMapTwo = p_value;
            else
                error('p_value is not of the type sl_CDipoleMap.');
            end
        end % set.second 
        
        
        %% get.NumOfDipolePairs 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return instance of the get.NumOfDipolePairs class.
        % =================================================================
        function numDipoles = get.NumOfDipolePairs(obj)
            numDipoles = obj.m_dipoleMapOne.size();
        end
        
        
        % =================================================================
        %> @brief The key data list.
        %>
        %> Returns the a list which holds the keys of the map.
        %>
        %> @return the key list.
        % =================================================================
        
        %% keys 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @retval keyListOne ToDo
        %> @retval keyListTwo ToDo
        %>
        %> @return instance of the keys class.
        % =================================================================
        function [keyListOne, keyListTwo]  = keys(obj)
            keyListOne = obj.m_dipoleMapOne.keys;
            keyListTwo = obj.m_dipoleMapTwo.keys;
        end % get.keys

        % =================================================================
        %> @brief The value data list.
        %>
        %> Returns the a list which holds the values of the map.
        %>
        %> @return value the number of items in the list.
        % =================================================================
        
        %% values
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @retval valueListOne ToDo
        %> @retval valueListTwo ToDo
        %>
        %> @return instance of the values class.
        % =================================================================
        function [valueListOne, valueListTwo] = values(obj)
            valueListOne = obj.m_dipoleMapOne.values;
            valueListTwo = obj.m_dipoleMapTwo.values;
        end % get.values
        
        % =================================================================
        %> @brief Checks whether map is empty.
        %>
        %> Returns true if the map contains no items; 
        %> otherwise returns false.
        %>
        %> @return bool true if the map contains no items; otherwise false.
        % =================================================================
        
        %% isEmpty 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return instance of the isEmptyclass.
        % =================================================================
        function bool = isEmpty(obj)
            bool = obj.m_dipoleMapOne.isEmpty();
        end % isEmpty
        
        % =================================================================
        %> @brief Returns the value associated with the key key.
        %>
        %> If the map contains no item with key key, the function returns
        %> an empty array. If there are multiple items for key
        %> in the map, all values are returned in an array.
        %>
        %> @param key The key for which associated values are requested
        %>
        %> @retval val Values which are associated with the key.
        % =================================================================
        
        %% value 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param key ToDo
        %> @param mapNum ToDo
        %>
        %> @retval valOne ToDo
        %> @retval valTwo ToDo
        %>
        %> @return instance of the value class.
        % =================================================================
        function [valOne, valTwo] = value(obj, key, mapNum)
            
            if mapNum == 1
                [bool, idx] = obj.m_dipoleMapOne.keys.contains(key);
            else
                [bool, idx] = obj.m_dipoleMapTwo.keys.contains(key);
            end
            valOne = [];
            valTwo = [];
            if bool
                valOne = obj.m_dipoleMapOne.values(idx);
                valTwo = obj.m_dipoleMapTwo.values(idx);
            end
        end % value
        
        % =================================================================
        %> @brief Returns the keys with value value.
        %>
        %> If the map contains no item with value value, the function
        %> returns an empty array.
        %>
        %> @param value The value for which associated keys are requested
        %>
        %> @retval k Keys which are associated with the value.
        % =================================================================
        
        %% key 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param value ToDo
        %> @param mapNum ToDo
        %>
        %> @retval keyOne ToDo
        %> @retval keyTwo ToDo
        %>
        %> @return instance of the key class.
        % =================================================================
        function [keyOne, keyTwo] = key(obj, value, mapNum)
            
            if mapNum == 1
                [bool, idx] = obj.m_dipoleMapOne.values.contains(value);
            else
                [bool, idx] = obj.m_dipoleMapTwo.values.contains(value);
            end
            keyOne = [];
            keyTwo = [];
            if bool
                keyOne = obj.m_dipoleMapOne.keys(idx);
                keyTwo = obj.m_dipoleMapTwo.keys(idx);
            end
        end % key
        
        % =================================================================
        %> @brief Inserts item(s);
        %>
        %> Inserts a new item with the key key and a value of value.
        %> If there is already an item with the key key, that item's value
        %> is replaced with value.
        %> 
        %> If there are multiple items with the key key, the most recently
        %> inserted item's value is replaced with value.
        %>
        %> @param key the key of the inserted item.
        %> @param value the value of the item
        % =================================================================
        
        %% insert 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param keyOne ToDo
        %> @param dipoleOne ToDo
        %> @param keyTwo ToDo
        %> @param dipoleTwo ToDo
        %>
        %> @return instance of the insert class.
        % =================================================================
        function obj = insert(obj, keyOne, dipoleOne, keyTwo, dipoleTwo)
            if obj.m_dipoleMapOne.keys.isEmpty() || obj.m_dipoleMapTwo.keys.isEmpty()
                obj.m_dipoleMapOne.clear();
                obj.m_dipoleMapTwo.clear();%good point to make sure both maps are synchronized
            end
            obj.m_dipoleMapOne.insert(keyOne,dipoleOne);
            obj.m_dipoleMapTwo.insert(keyTwo,dipoleTwo);
        end % insert
        
        
        % =================================================================
        %> @brief Access by Index
        %>
        %> Use this to iterate over list.
        %>
        %> @return the key and the value
        % =================================================================
        
        %% at 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %> @param idx ToDo
        %>
        %> @retval keyOne ToDo
        %> @retval valueOne ToDo
        %> @retval keyTwo ToDo
        %> @retval valueTwo ToDo
        %>
        %> @return instance of the at class.
        % =================================================================
        function [keyOne, valueOne, keyTwo, valueTwo] = at(obj, idx)
            [keyOne, valueOne] = obj.m_dipoleMapOne.at(idx);
            [keyTwo, valueTwo] = obj.m_dipoleMapTwo.at(idx);
        end % at
        
        % =================================================================
        %> @brief Clears the map.
        %>
        %> Removes all items from the map.
        % =================================================================
        
        %% clear 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo More detailed description of what the constructor does.
        %>
        %> @param obj Instance of the class object
        %>
        %> @return instance of the clear class.
        % =================================================================
        function obj = clear(obj)
            obj.m_dipoleMapOne.clear();
            obj.m_dipoleMapTwo.clear();
        end % clear
        
    end % methods
    
    methods (Static)
        % =================================================================
        %> @brief Returns the type of the class.
        %>
        %> @return The type of the class.
        % =================================================================
        
        %% Type 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo 
        %>
        %> @return instance of the Type class.
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Map;
        end % getType
        
        % =================================================================
        %> @brief Returns the name of the class.
        %>
        %> @return the name of the class.
        % =================================================================
        
        %% Name 
        % =================================================================
        %> @brief ToDo
        %>
        %> ToDo
        %>
        %> @return instance of the Name class.
        % =================================================================
        function name = Name()
            %% getName
            name = 'sl_CCorrelatedDipoleMap';
        end % getName
    end % static methods
end

