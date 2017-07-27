%> @file    sl_CList.m
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
%> @brief   File contains the declaration of the sl_CList class.
% =========================================================================
%> @brief   The sl_CList class provides lists.
%
%> sl_CList is one of the generic container classes. It stores a list of
%> values and provides access as well as insertions and removals.
% =========================================================================
classdef sl_CList < sl_IValue
    %% sl_CList   
    properties (Access = private)
        %> Holds the list array.
        m_datList;
    end % properties (Access = private)
    
    properties (Dependent = true)
        %> Data base of the list.
        data;
        %> Number of items in the list.
        size;
    end % properties (Dependent = true)
   
    methods
        % =================================================================
        %> @brief sl_CList class constructor
        %>
        %> The sl_CList class constructor takes different input arguments.
        %> Option 1: sl_CList ();
        %> Option 2: sl_CList ( sl_CPair other ) -> copy constructor;
        %>
        %> @param varargin different options (see descritpion)
        %>
        %> @return instance of the sl_CList class.
        % =================================================================
        function obj = sl_CList(varargin)
            %% sl_CList    
            if nargin == 1 && isa(varargin{1}, 'sl_CList') %Copy Constructor
                obj.m_datList = varargin{1}.m_datList;
            else
                obj.m_datList = [];
            end
        end % sl_CList
        
        % =================================================================
        %> @brief Represents length of the list.
        %>
        %> Returns the number of items in the list.
        %>
        %> @return value the number of items in the list.
        % =================================================================
        function value = get.size(obj)
            value = length(obj.m_datList);
        end % get.size
        
        % =================================================================
        %> @brief Data base of the list.
        %>
        %> Returns the data base of the list.
        %>
        %> @return the data base
        % =================================================================
        function data = get.data(obj)
            data = obj.m_datList;
        end % get.data
        
        % =================================================================
        %> @brief Checks whether list is empty.
        %>
        %> Returns true if the list contains no items; 
        %> otherwise returns false.
        %>
        %> @return bool true if the list contains no items; otherwise false.
        % =================================================================
        function bool = isEmpty(obj)
            bool = isempty(obj.m_datList);
        end % isEmpty
        
        % =================================================================
        %> @brief Returns (an) item(s) at a specific position(s).
        %>
        %> Returns the item(s) at index position(s) i in the list.
        %> i must be (a) valid index position(s) in the list (i.e., 0 < i <= size()).
        %>
        %> @param i the index/indeces of item(s) which should be returned.
        %>
        %> @return value the item(s) at index/indeces position(s) i in the list.
        % =================================================================
        function value = at(obj, i)
            if isscalar(i) && i - floor(i) == 0 && i <= obj.size() && i > 0
                value = obj.m_datList(i);
            elseif isvector(i) && isempty(find(i - floor(i),1)) && max(i) <= obj.size() && min(i) > 0
                value = obj.m_datList(i);
            else
                error('i is/are not (a) valid index/indeces.')
            end
        end % at
        
        % =================================================================
        %> @brief Overloads get method for operator ()
        %>
        %> Returns the item(s) at index position(s) (i) in the list.
        %> i must be (a) valid index position(s) in the list (i.e., 0 < i <= size()).
        %> It is equivalent to at(), 
        %>
        %> @param S the index/indeces of item(s) which should be returned.
        %>
        %> @reval varargout the result of the indexed expression.
        % =================================================================
        function varargout = subsref(obj, S)
            if length(S) == 1 && strcmp(S(1).type, '()')
                %function(obj(indexes))
                %varargout{1} = sl_CList;
                varargout{1} = builtin('subsref', obj.m_datList, S(1));
            elseif length(S) > 1 && strcmp(S(1).type, '()')
                %obj(indexes).field
                %tmp = sl_CList;
                tmp = builtin('subsref', obj.m_datList, S(1));
                [varargout{1:nargout}] = builtin('subsref', tmp, S(2:end));
            else
                [varargout{1:nargout}] = builtin('subsref', obj, S);
            end
        end %subsref
        
        % =================================================================
        %> @brief Overloads set method for operator ()
        %>
        %> Sets the item(s) at index position(s) (i) in the list.
        %> i must be (a) valid index position(s) in the list (i.e., 0 < i <= size()).
        %> It is equivalent to at(), 
        %>
        %> @param S struct array with two fields, type and subs.
        %> @param value Assignment value (right-hand side)
        % =================================================================
        function obj = subsasgn(obj, S, value)

            if length(S) == 1 && strcmp(S(1).type, '()')
                % obj(indexes) -> obj.m_datList(indexes)
                S = substruct('.', 'm_datList', '()', S(1).subs);
            elseif length(S) > 1 && strcmp(S(1).type, '()')
                % obj(indexes).field -> obj.field(indexes)
                [S(1) S(2)] = deal(S(2), S(1));
            end

            obj = builtin('subsasgn', obj, S, value);
        end %subsasgn

        % =================================================================
        %> @brief Returns the item of the first position.
        %>
        %> Returns a the first item in the list. The list must not be empty. 
        %> If the list can be empty, call isEmpty() before calling this function.
        %>
        %> @return value the first item of the list.
        % =================================================================
        function value = first(obj)
                value = obj.m_datList(1);
        end % first
        
        % =================================================================
        %> @brief Returns the item of the last position.
        %>
        %> Returns a the last item in the list. The list must not be empty.
        %> If the list can be empty, call isEmpty() before calling this function.
        %> 
        %> @return value the last item of the list.
        % =================================================================
        function value = last(obj)
                value = obj.m_datList(obj.size);
        end % last
        
        % =================================================================
        %> @brief Whether list contains an occurrence of value in the list.
        %>
        %> Returns true if the list contains an occurrence of value; otherwise returns false.
        %> This function requires the value type to have an implementation of operator==().
        %>
        %> @retval bool true if the list contains an occurrence of value;
        %>              otherwise false.
        %> @retval idx indices where the value occurs.
        % =================================================================
        function [bool, idx] = contains(obj, value)
            bool = false;
            idx = [];
            if ~obj.isEmpty() 
                if strcmp(class(value),class( obj.first() ))
                    if ischar(value) || iscell(value)
                        idx = find(strncmp(obj.m_datList, value, length(value)));
                    else
                        idx = find(obj.m_datList == value);
                    end
                    if ~isempty(idx)
                        bool = true;
                    end
                else
                    error(['Input argument (' class(value) ') and list containing types (' class(obj.first()) ') are not identically.']);
                end
            end
        end % contains
        
        % =================================================================
        %> @brief Returns all index positions of the value in the list.
        %>        Returns -1 if no item matched.
        %>
        %> Returns all index positions of the value in the list.
        %> Returns -1 if no item matched.
        %>
        %> @retval idx indices where the value occurs.
        % =================================================================
        function idx = indexOf(obj, value)
            [~, idx] = obj.contains(value);
            if isempty(idx)
                idx = -1;
            end
        end % indexOf
        

        % =================================================================
        %> @brief Appends item(s);
        %>
        %> Append takes different input arguments.
        %> Option 1: append( value ); Inserts value at the end of the list.
        %> Option 2: append ( sl_CList other );
        %>           Appends the items of the value list to this list.
        %>
        %> @param varargin different options (see descritpion)
        % =================================================================
        function obj = append(obj, varargin)
            if obj.isEmpty()
                if isa(varargin{1}, 'sl_CList')
                    obj.m_datList = varargin{1}.m_datList;
                else
                    obj.m_datList = varargin{1};
                end
            else
                if isa(varargin{1}, 'sl_CList')
                    if ~strcmp(class(varargin{1}.first()), class(obj.first()))
                        error(['Input argument (' class(varargin{1}.first()) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    obj.m_datList = [obj.m_datList varargin{1}.m_datList];
                else
                    if ~strcmp(class(varargin{1}), class(obj.first()))
                        error(['Input argument (' class(varargin{1}) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    obj.m_datList = [obj.m_datList varargin{1}];
                end
            end
        end % append
        
        % =================================================================
        %> @brief Prepends item(s);
        %>
        %> Prepend takes different input arguments.
        %> Option 1: prepend( value ); Inserts value at the end of the list.
        %> Option 2: prepend ( sl_CList other );
        %>           Prepends the items of the value list to this list.
        %>
        %> @param varargin different options (see descritpion)
        % =================================================================
        function obj = prepend(obj, varargin)
            if obj.isEmpty()
                if isa(varargin{1}, 'sl_CList')
                    obj.m_datList = varargin{1}.m_datList;
                else
                    obj.m_datList = varargin{1};
                end
            else
                if isa(varargin{1}, 'sl_CList')
                    if ~strcmp(class(varargin{1}.first()), class(obj.first()))
                        error(['Input argument (' class(varargin{1}.first()) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    obj.m_datList = [varargin{1}.m_datList obj.m_datList];
                else
                    if ~strcmp(class(varargin{1}), class(obj.first()))
                        error(['Input argument (' class(varargin{1}) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    obj.m_datList = [varargin{1} obj.m_datList];
                end
            end
        end % prepend
        
        % =================================================================
        %> @brief Inserts item(s);
        %>
        %> Inserts value at index position i in the list. If i is 1, the 
        %> value is prepended to the list. If i is size+1, the value is appended to the list.
        %>
        %> Insert takes different input arguments.
        %> Option 1: insert( i, value ); Inserts value at position i.
        %> Option 2: insert( i, sl_CList other ); Insert the items of
        %>                      the value list to this list at position i.
        %>
        %> @param i the index where value should be inserted.
        %> @param varargin different options (see descritpion)
        % =================================================================
        function obj = insert(obj, i, varargin)
            if isscalar(i) && i - floor(i) == 0 && i <= obj.size+1 && i > 0 && ~obj.isEmpty()
            
                if isa(varargin{1}, 'sl_CList')
                    if ~strcmp(class(varargin{1}.first()), class(obj.first()))
                        error(['Input argument (' class(varargin{1}.first()) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    if i == 1
                        obj.prepend(varargin{1});
                    elseif i == obj.size+1
                        obj.append(varargin{1});
                    else
                        obj.m_datList = [obj.m_datList(1:i-1) varargin{1}.m_datList obj.m_datList(i:obj.size())];
                    end
                else
                    if ~strcmp(class(varargin{1}), class(obj.first()))
                        error(['Input argument (' class(varargin{1}) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    if i == 1
                        obj.prepend(varargin{1});
                    elseif i == obj.size+1
                        obj.append(varargin{1});
                    else
                        obj.m_datList = [obj.m_datList(1:i-1) varargin{1} obj.m_datList(i:obj.size())];
                    end
                end
                
            else
                error('i is not a valid index.')
            end
        end % insert
        
        % =================================================================
        %> @brief Copie parts of the list;
        %>
        %> Returns a list whose elements are copied from this list, 
        %> starting at position pos. If length is < 0, all elements from pos
        %> are copied; otherwise length elements (or all remaining elements
        %> if there are less than length elements) are copied.
        %>
        %> @param pos starting copy position.
        %> @param length number of elements which should be coppied.
        % =================================================================
        function midList = mid(obj, pos, length)
            
            if isscalar(pos) && pos - floor(pos) == 0 && pos <= obj.size() && pos > 0 && ~obj.isEmpty()
                midList = sl_CList();
                if length > 0 && pos+length-1 <= obj.size
                    midList.m_datList = obj.m_datList(pos:pos+length-1);
                else
                    midList.m_datList = obj.m_datList(pos:end);
                end
            else
                error('pos is not a valid index.')
            end
        end % mid
        
        % =================================================================
        %> @brief Removes specified value from the list.
        %>
        %> Removes all occurrences of value in the list and returns the
        %> number of entries removed.
        %>
        %> @param value The value which should be removed.
        % =================================================================
        function obj = removeAll(obj, value)
            [bool, idx] = obj.contains(value);
            if bool
                obj.m_datList(idx) = [];  
            end
        end % removeAll
        
        % =================================================================
        %> @brief Removes specified value from the list.
        %>
        %> Removes the item at index position i. i must be a valid index position in the list (i.e., 0 < i <= size()).
        %>
        %> @param i the index of the item which should be deleted.
        % =================================================================
        function obj = removeAt(obj, i)
            if isscalar(i) && i - floor(i) == 0 && i <= obj.size() && i > 0 && ~obj.isEmpty()
                obj.m_datList(i) = [];
            else
                error('i is not a valid index.')
            end
        end % removeAt
        
        % =================================================================
        %> @brief Removes first occurence of specified value from the list.
        %>
        %> Removes the first occurrence of value in the list and returns
        %> true on success; otherwise returns false.
        %>
        %> @param value The value which should be removed.
        % =================================================================
        function obj = removeOne(obj, value)
            [bool, idx] = obj.contains(value);
            if bool
                obj.m_datList(idx(1)) = [];  
            end
        end % removeAll
        
        % =================================================================
        %> @brief Removes first item.
        %> 
        %> Removes the first item in the list. Calling this function is
        %> equivalent to calling removeAt(1). The list must not be empty.
        %> If the list can be empty, call isEmpty() before calling this function.
        % =================================================================
        function obj = removeFirst(obj)
            if ~isempty(obj.m_datList)
                obj.m_datList(1) = [];
            else
                error('Not able to remove first item, list is empty.')
            end
        end % removeFirst
        
        % =================================================================
        %> @brief Removes last item.
        %> 
        %> Removes the last item in the list. Calling this function is 
        %> equivalent to calling removeAt(size() - 1). The list must not be
        %> empty. If the list can be empty, call isEmpty() before calling
        %> this function.
        % =================================================================
        function obj = removeLast(obj)
            if ~isempty(obj.m_datList)
                obj.m_datList(end) = [];
            else
                error('Not able to remove last item, list is empty.')
            end
        end % removeLast
        
        % =================================================================
        %> @brief Replaces item(s);
        %>
        %> Replaces the item at index position i with value.
        %> i must be a valid index position in the list (i.e., 0 < i <= size()).
        %>
        %> Insert takes different input arguments.
        %> Option 1: replace( i, value ); Replace value at position i.
        %> Option 2: replace( i, sl_CList other ); Replaces the items of
        %>                      the value list of this list at position i.
        %>
        %> @param i the index where value should be inserted.
        %> @param varargin different options (see descritpion)
        % =================================================================
        function obj = replace(obj, i, varargin)
            if isscalar(i) && i - floor(i) == 0 && i <= obj.size+1 && i > 0 && ~obj.isEmpty()
            
                if isa(varargin{1}, 'sl_CList')
                    if ~strcmp(class(varargin{1}.first()), class(obj.first()))
                        error(['Input argument (' class(varargin{1}.first()) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    

                    obj.m_datList(i:i+varargin{1}.size-1) = varargin{1}.m_datList;
                else
                    if ~strcmp(class(varargin{1}), class(obj.first()))
                        error(['Input argument (' class(varargin{1}) ') and list containing types (' class(obj.first()) ') are not identically.']);
                    end
                    
                    obj.m_datList(i) = varargin{1};
                end
                
            else
                error('i is not a valid index.')
            end
        end % replace
        
        % =================================================================
        %> @brief Removes specified value from the list.
        %>
        %> Exchange the item at index position i with the item at index
        %> position j. This function assumes that both i and j are at least
        %> 0 but less than size(). To avoid failure, test that both i and j
        %> are at least 0 and less than size().
        %>
        %> @param i the index of the item which should be deleted.
        % =================================================================
        function obj = swap(obj, i, j)
            if isscalar(i) && i - floor(i) == 0 && i <= obj.size() && i > 0 && ~obj.isEmpty()
                if isscalar(j) && j - floor(j) == 0 && j <= obj.size() && j > 0
                    obj.m_datList([i,j]) = obj.m_datList([j,i]);
                else
                    error('j is not a valid index.')
                end
            else
                error('i is not a valid index.')
            end
        end % removeAt
        
        % =================================================================
        %> @brief Clears the list.
        %>
        %> Removes all items from the list.
        % =================================================================
        function obj = clear(obj)
                obj.m_datList = [];
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
            valType = sl_valType.List;
        end % getType
        
        % =================================================================
        %> @brief Returns the name of the class.
        %>
        %> @return the name of the class.
        % =================================================================
        function name = Name()
            %% getName
            name = 'sl_CList';
        end % getName
    end % static methods
end

