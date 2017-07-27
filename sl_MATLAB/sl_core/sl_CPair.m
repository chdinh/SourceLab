%> @file    sl_CPair.m
%> @author  Christoph Dinh <christoph.dinh@live.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Christoph Dinh. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File contains the declaration of the sl_CPair class.
% =========================================================================
%> @brief   Stores a pair of items.
%
%> The sl_CPair class is a template class that stores a pair of items.
% =========================================================================
classdef sl_CPair < sl_IValue
    %% sl_CPair    
    properties (Access = private)
        %> Holds the first item.
        m_datFirst;
        %> Holds the second item.
        m_datSecond;
    end % properties (Access = private)
    
    properties (Dependent = true)
        %> Access property for the first item.
        first;
        %> Access property for the second item.
        second;
    end % properties (Dependent = true)
    
    methods
        
        % =================================================================
        %> @brief sl_CPair class constructor
        %>
        %> The sl_CPair class constructor takes different input arguments.
        %> Option 1: sl_CPair ();
        %> Option 2: sl_CPair ( sl_CPair other ) -> copy constructor;
        %> Option 3: sl_CPair( value1, value2 )
        %>
        %> @param varargin different options (see descritpion)
        %>
        %> @return instance of the sl_CPair class.
        % =================================================================
        function obj = sl_CPair(varargin)
            %% sl_CPair    
            p = inputParser;

            if nargin == 1 && isa(varargin{1}, 'sl_CPair') %Copy Constructor
                obj.m_datFirst = varargin{1}.m_datFirst;
                obj.m_datSecond = varargin{1}.m_datSecond;
            elseif nargin == 2
                p.addOptional('p_datFirst', []);
                p.addOptional('p_datSecond', []);
                
                p.parse(varargin{:});
                
                obj.m_datFirst = p.Results.p_datFirst;
                obj.m_datSecond = p.Results.p_datSecond;
            end
        end % sl_CPair    
        
        % =================================================================
        %> @brief Returns first component
        %>
        %> Returns the first component of the pair.
        %>
        %> @return value Returns the first component.
        % =================================================================
        function value = get.first(obj)
            %% get.first  
            value = obj.m_datFirst;
        end % get.first 
        
        % =================================================================
        %> @brief Returns second component
        %>
        %> Returns the second component of the pair.
        %>
        %> @return value Returns the second component.
        % =================================================================
        function value = get.second(obj)
            %% get.second 
            value = obj.m_datSecond;
        end % get.second 
        
        % =================================================================
        %> @brief Sets first component
        %>
        %> Sets the first component of the pair.
        %>
        %> @param p_value The value which will be assigned to the first
        %>                component.
        % =================================================================
        function set.first(obj,p_value)
            %% set.first 
            obj.m_datFirst = p_value;
        end % set.first 

        % =================================================================
        %> @brief Sets second component
        %>
        %> Sets the second component of the pair.
        %>
        %> @param p_value The value which will be assigned to the second
        %>                component.
        % =================================================================
        function set.second(obj,p_value)
            %% set.second 
            obj.m_datSecond = p_value;
        end % set.second 
        
        % =================================================================
        %> @brief Overloads operator ~= (!=)
        %>
        %> Returns true if p1 is not equal to p2; otherwise returns false.
        %> Two pairs compare as not equal if their first data members are 
        %> not equal or if their second data members are not equal.
        %>
        %> This function requires the T1 and T2 types to have an implementation of operator==().
        %>
        %> @param p1 pair one to compare
        %> @param p2 pair two to compare
        %>
        %> @return bool Returns true if p1 is not equal to p2.
        % =================================================================
        function bool = ne(p1, p2)
            %% ne
            if isa(p1, 'sl_CPair') && isa(p2, 'sl_CPair')
                if (p1.first == p2.first) && (p1.second == p2.second)
                    bool = false;
                else
                    bool = true;
                end
            else
                error('p1 & p2 are not both of the type sl_CPair.');
            end
        end % ne

        % =================================================================
        %> @brief Overloads operator <
        %>
        %> Returns true if p1 is less than p2; otherwise returns false.
        %> The comparison is done on the first members of p1 and p2;
        %> if they compare equal, the second members are compared to break
        %> the tie.
        %>
        %> This function requires the T1 and T2 types to have an implementation of operator<().
        %>
        %> @param p1 pair one to compare
        %> @param p2 pair two to compare
        %>
        %> @return bool Returns true if p1 is less than p2.
        % =================================================================
        function bool = lt(p1, p2)
            %% lt
            if isa(p1, 'sl_CPair') && isa(p2, 'sl_CPair')
                if (p1.first <= p2.first) && (p1.second < p2.second)
                    bool = true;
                else
                    bool = false;
                end
            else
                error('p1 & p2 are not both of the type sl_CPair.');
            end
        end % lt
        
        % =================================================================
        %> @brief Plots both items of the pair.
        %>
        % =================================================================
        function plot(obj, varargin)
            figure('Name', 'First Item');
            plot(obj.first, varargin);
            figure('Name', 'Second Item');
            plot(obj.second, varargin);
        end;
        
    end % methods
    
    
    methods (Static)
        % =================================================================
        %> @brief Returns the type of the class.
        %>
        %> @return The type of the class.
        % =================================================================
        function valType = Type()
            %% getType
            valType = sl_valType.Pair;
        end % getType
        
        % =================================================================
        %> @brief Returns the name of the class.
        %>
        %> @return the name of the class.
        % =================================================================
        function name = Name()
            %% getName
            name = 'sl_CPair';
        end % getName
    end % static methods
end

