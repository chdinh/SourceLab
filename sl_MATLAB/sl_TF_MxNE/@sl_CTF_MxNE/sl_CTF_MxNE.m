%> @file    sl_CTF_MxNE.m
%> @author  Daniel Strohmeier <daniel.strohmeier@tu-ilmenau.de>
%> @version	1.0
%> @date	October, 2011
%>
%> @section	LICENSE
%>
%> Copyright (C) 2011 Daniel Strohmeier. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File contains the declaration of the sl_CTF_MxNE class.
% =========================================================================
%> @brief   The sl_CList class provides TF_MxNE algorithm.
%
%> sl_CTF_MxNE is a mixed norm based MNE algorithm in the time-frequency 
%> domain.
% =========================================================================

classdef sl_CTF_MxNE < sl_CImagingInverseAlgorithm
    %% SL_CTF_MXNE 
    
    properties
        results
        m_norient
        m_maxit
        m_tol
        m_lambdal21
        m_lambdal1
    end
    
    methods
        % =================================================================
        %> @brief sl_CTF_MxNE class constructor
        %>
        %> The sl_CTF_MxNE class constructor takes different input arguments.
        %> Option 1: sl_CList ();
        %> Option 2: sl_CList ( sl_CPair other ) -> copy constructor;
        %>
        %> @param varargin different options (see descritpion)
        %>
        %> @return instance of the sl_CList class.
        % =================================================================
        function obj = sl_CTF_MxNE(p_ForwardSolution, varargin)
            %% sl_CList    
            if nargin == 1 && isa(varargin{1}, 'sl_CTF_MxNE') %Copy Constructor
                obj.m_ForwardSolution = varargin{1}.m_ForwardSolution;
                obj.m_norient = varargin{1}.m_norient;
                obj.m_maxit = varargin{1}.m_maxit;
                obj.m_tol = varargin{1}.m_tol;
                obj.results = varargin{1}.results;
            else
                p = inputParser;
                p.addRequired('p_ForwardSolution', @(x)isa(x, 'sl_CForwardSolution'));
                p.addParamValue('norient', 3, @(x)isnumeric(x) && x<=3);
                p.addParamValue('maxit', 300, @(x)isnumeric(x) && x<=1000);
                p.addParamValue('tol', 1e-4, @(x)isnumeric(x) && x<=1e-3);
                p.addParamValue('lambdal21', 1, @(x)isnumeric(x) && x<=1000);
                p.addParamValue('lambdal1', 0.1, @(x)isnumeric(x) && x<=1);
                
                p.parse(p_ForwardSolution, varargin{:});
                obj.m_ForwardSolution = p.Results.p_ForwardSolution;
                obj.m_norient = p.Results.norient;
                obj.m_maxit = p.Results.maxit;
                obj.m_tol = p.Results.tol;
                obj.m_lambdal21 = p.Results.lambdal21;
                obj.m_lambdal1 = p.Results.lambdal1;
            end
        end % sl_CTF_MxNE
        
        %%
        [X,Z,idx,pobj,options] = calculate(obj, M)
        [coef] = sparse_dgts(obj, f, params, options)
        
        %%
        % =================================================================
        %> @brief Plots both items of the pair.
        %>
        % =================================================================
        % plot Funktion überarbeiten
        function plot(obj, varargin)
            figure('Name', 'First Item');
            plot(obj.results, varargin);
            figure('Name', 'Second Item');
            plot(obj.second, varargin);
        end;
    end
end

