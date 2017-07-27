classdef sl_CUtility
    %SL_CUTILITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        %Methods in a separate file
        mat = readSLMat(p_sFilename,p_sType)
        
        %Concatenates structures
        A = catstruct(varargin)

        %Arrange Figures; Kindly provided by Christian Arzt
        ArrFig(varargin)
        
        function initSLEnv()
            isOpen = matlabpool('size') > 0;
            if isOpen
                matlabpool close force;
            end
            
            t_scheduler = findResource('scheduler', 'configuration', defaultParallelConfig);
            matlabpool(t_scheduler);
        end
        
        
        function p_CpObj = copy(p_orgObj)
            %ToDo does not perform a deep copy
            t_propNames = properties(p_orgObj); 
            for i=1:length(t_propNames) 
              p_CpObj.(t_propNames{i}) = p_orgObj.(t_propNames{i}); 
            end
        end
        
    end
    
end

