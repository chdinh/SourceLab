%> @file    sl_CRapMusicPwl.m
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
%> @brief   File used to show an example of class description
% =========================================================================
%> @brief   Summary of this class goes here
%
%> Detailed explanation goes here
% =========================================================================
classdef sl_CRapMusicPwl < sl_CRapMusic
    
    methods
        % =================================================================
        function obj = sl_CRapMusicPwl(p_LeadField, p_iN, p_dThr)
            %ToDo Grid has to be part of the forward solution
            
            obj = obj@sl_CRapMusic(p_LeadField, p_iN, p_dThr);
        end

        % =================================================================
        [p_InverseSolution p_CorrDipoleResults p_CorrValues] = calculate(obj, p_Measurement)
    end
        
    methods (Static)
        % =================================================================
        function value = PowellOffset(p_iRow, p_iNumPoints)
            value = p_iRow*p_iNumPoints - (( (p_iRow-1)*p_iRow) / 2); %triangular series 1 3 6 10 ... = (num_pairs*(num_pairs+1))/2
        end

        % =================================================================
        function p_pVecElements = PowellIdxVec(p_iRow, p_iNumPoints)
    
                p_pVecElements = zeros(1,p_iRow+1);
            for i = 0:p_iRow
                p_pVecElements(i+1) = sl_CRapMusicPwl.PowellOffset(i+1,p_iNumPoints)-(p_iNumPoints-p_iRow);
            end

            off = sl_CRapMusicPwl.PowellOffset(p_iRow,p_iNumPoints);
            length = p_iNumPoints - p_iRow;
            k=0;
            for i = p_iRow:p_iRow+length-1
                p_pVecElements(i+1) = off+k;
                k = k + 1;
            end
        end
    end %Methods
end

























