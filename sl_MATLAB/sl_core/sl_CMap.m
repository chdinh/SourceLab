%> @file    sl_CMap.m
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

classdef sl_CMap < sl_IValue
    %% sl_CMap
    properties (Access = protected)
        %> Holds the key list.
        m_listKeys;
        %> Holds the value list.
        m_listValues;
    end % properties (Access = private)
    
    properties (Dependent = true)
        %> Data base of the key list.
        keys;
        %> Data base of the key list.
        values;
        %> Number of items in the list.
        size;
    end % properties (Dependent = true)
    
    methods
        % =================================================================
        %> @brief sl_CMap class constructor
        %>
        %> The sl_CMap class constructor takes different input arguments.
        %> Option 1: sl_CMap ();
        %> Option 2: sl_CMap ( sl_CMap other ) -> copy constructor;
        %>
        %> @param varargin different options (see descritpion)
        %>
        %> @return instance of the sl_CMap class.
        % =================================================================
        function obj = sl_CMap(varargin)
            %% sl_CMap   
            if nargin == 1 && isa(varargin{1}, 'sl_CMap') %Copy Constructor
                obj.m_listKeys = varargin{1}.m_listKeys;
                obj.m_listValues = varargin{1}.m_listValues;
            else
                obj.m_listKeys = sl_CList();
                obj.m_listValues = sl_CList();
            end
        end % sl_CMap
        
        % =================================================================
        %> @brief Represents length of the map.
        %>
        %> Returns the number of items in the map.
        %>
        %> @return value the number of items in the map.
        % =================================================================
        function value = get.size(obj)
            value = obj.m_listKeys.size;
        end % get.size
        
        % =================================================================
        %> @brief The key data list.
        %>
        %> Returns the a list which holds the keys of the map.
        %>
        %> @return the key list.
        % =================================================================
        function list = get.keys(obj)
            list = obj.m_listKeys;
        end % get.keys

        % =================================================================
        %> @brief The value data list.
        %>
        %> Returns the a list which holds the values of the map.
        %>
        %> @return value the number of items in the list.
        % =================================================================
        function list = get.values(obj)
            list = obj.m_listValues;
        end % get.values
        
        % =================================================================
        %> @brief Checks whether map is empty.
        %>
        %> Returns true if the map contains no items; 
        %> otherwise returns false.
        %>
        %> @return bool true if the map contains no items; otherwise false.
        % =================================================================
        function bool = isEmpty(obj)
            bool = obj.m_listValues.isEmpty();
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
        function val = value(obj, key)
            [bool, idx] = obj.m_listKeys.contains(key);
            val = [];
            if bool
                val = obj.m_listValues(idx);
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
        function k = key(obj, value)
            [bool, idx] = obj.m_listValues.contains(value);
            k = [];
            if bool
                k = obj.m_listKeys(idx);
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
        function obj = insert(obj, key, value)
            if ~obj.m_listKeys.isEmpty()
                if strcmp(class(obj.m_listKeys.first()), class(key)) || (ischar(key) && iscell(obj.m_listKeys.first()))
                    if strcmp(class(obj.m_listValues.first()), class(value))
                        [b idx] = obj.m_listKeys.contains(key);
                        if b
                            obj.m_listValues.replace(idx(end),value);
                        else
                            obj.m_listKeys.append(key);
                            obj.m_listValues.append(value);
                        end
                    else
                        error(['Value (' class(value) ') and values of the map containing types (' class(obj.m_listValues.first()) ') are not identically.']);
                    end
                else
                    error(['Key (' class(key) ') and keys of the map containing types (' class(obj.m_listKeys.first()) ') are not identically.']);
                end
            else
                obj.m_listKeys.append(key);
                obj.m_listValues.append(value);
            end
        end % insert
        
        % =================================================================
        %> @brief Access by Index
        %>
        %> Use this to iterate over list.
        %>
        %> @return the key and the value
        % =================================================================
        function [key, value] = at(obj, idx)
            key = obj.m_listKeys.at(idx);
            value = obj.m_listValues.at(idx);
        end % at
        
        % =================================================================
        %> @brief Clears the map.
        %>
        %> Removes all items from the map.
        % =================================================================
        function obj = clear(obj)
                obj.m_listKeys = sl_CList();
                obj.m_listValues = sl_CList();
        end % clear
    end % methods

    methods (Static)
        % =================================================================
        %> @brief Returns the type of the class.
        %>
        %> @return The type of the class.
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
        function name = Name()
            %% getName
            name = 'sl_CMap';
        end % getName
    end % static methods
    
end

