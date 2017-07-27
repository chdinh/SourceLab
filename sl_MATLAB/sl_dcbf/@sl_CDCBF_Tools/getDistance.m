%> @file    getDistance.m
%> @author  Peter Hoemmen <peter.hoemmen@tu-ilmenau.de>
%> @version	1.0
%> @date	March, 2012
%>
%> @section	LICENSE
%>
%> Copyright (C) 2012 Peter Hoemmen. All rights reserved.
%>
%> No part of this program may be photocopied, reproduced,
%> or translated to another program language without the
%> prior written consent of the author.
%>
%> @brief   File holdes function for distance measurement between dipoles

% =================================================================
%> @brief Calculates distance between activated dipoles and
%> localized dipoles
%>
%> getDistance finds the distance between simulated and calculated
%> dipoles. It lists the calculated Dipoles in the first two columns 
%> ordered by best pseudo-Z-score from top to bottom (see function 
%> bestPseudoZ)
%> The last two columns of bestDistance list the distance between the
%> calculated dipole and the simulated ones
%> column three lists the distance of dipole in column one,
%> column four lists the distance of dipole in column two
%> 
%> @param t_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
%> @param bestPseudoZ Holds the 50 dipoles with best pseudo-Z-score
%> @param p_Dipole Holds information about the activated dipole pair.
%>
%> @retval X Lists coordinates of activated dipoles
%> @retval Y Lists coordinates of localized dipoles with best
%> pseudo-Z-score
%> @retval bestDistance lists distances between best localized and
%> activated dipole pair
% =================================================================
function [ X, Y, bestDistance ] = getDistance( ForwardSolution, bestPseudoZ, p_Dipole )
%> number of activated dipole pairs
numCorrDipolePairs = length(p_Dipole.Idx)/2;
%% find dipol coordinates
      X = ForwardSolution.getCoordinate(p_Dipole.Idx);
      Y(:,1:3) = ForwardSolution.getCoordinate(bestPseudoZ(:,2));   %Coordinates of dipoles with best pseudo-Z-score
      Y(:,4:6) = ForwardSolution.getCoordinate(bestPseudoZ(:,3));
 
%% get distance
      bestDistance = bestPseudoZ(:,2:3);
      %> stores minimum distances of calculations
      %> (min(activated1-localized1,activated1-localized2))
      %> (min(activated2-localized1,activated2-localized2))
      dist = zeros(numCorrDipolePairs,1);
      %> sum of distance values stored in dist
      bd = zeros(numCorrDipolePairs,size(Y,1));
        for i = 1: size(Y,1)
            for j = 1: numCorrDipolePairs
                d(1,1) = sqrt((X(j+j-1,1)-Y(i,1))^2 + (X(j+j-1,2)-Y(i,2))^2 + (X(j+j-1,3)-Y(i,3))^2);
                d(2,1) = sqrt((X(j+j,1)-Y(i,1))^2 + (X(j+j,2)-Y(i,2))^2 + (X(j+j,3)-Y(i,3))^2);
                dist(j,i+i-1) = (min(d));
                d(1,1) = sqrt((X(j+j-1,1)-Y(i,4))^2 + (X(j+j-1,2)-Y(i,5))^2 + (X(j+j-1,3)-Y(i,6))^2);
                d(2,1) = sqrt((X(j+j,1)-Y(i,4))^2 + (X(j+j,2)-Y(i,5))^2 + (X(j+j,3)-Y(i,6))^2);
                dist(j,i+i) = (min(d));
                bd(j,i) = dist(j,i+i-1) + dist(j,i+i);
            end;
            
            %> Index of best distance in bd
            k = find(bd(:,i)==min(bd(:,i)));
            bestDistance(i,3) = dist(k,i+i-1);
            bestDistance(i,4) = dist(k,i+i);
            
        end;
end
           