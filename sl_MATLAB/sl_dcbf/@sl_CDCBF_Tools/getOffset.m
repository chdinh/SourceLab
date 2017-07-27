%> @file    getOffset.m
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
%> @brief   File holdes function to calculate offset between stimulation
%> and localization lead field

% =================================================================
%> @brief calculates offset between stimulation and localization lead field
%>
%> get offset calcolates the menimum failiure of the distance measurement
%> coming from the different lead fields used for stimulation and
%> localization. The distance between the activated dipole in the
%> activation lead field and the nearest dipole to  it in the localization
%> lead field is defined as offset
%> 
%> @param t_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
%> @param p_Dipole Holds information about the activated dipole pair.
%>
%> @param Offset Lists offset to distance values for both of dipoles of one
%> dipole pair in all three cartesian directions
% =================================================================
%% to do --> more than one dipole pair
function [ Offset ] = getOffset( ForwardSolution, p_Dipole )

%%
%> Coordinates of activated dipoles
X = ForwardSolution.getCoordinate(p_Dipole.Idx);

%%
%> Coordinates of localized dipole pair
Y = [ForwardSolution.src(1,1).rr;...
    ForwardSolution.src(1,2).rr];

%[1 2 3; 5 6 7; 8 9 10; 11 12 13];
%> Distance between activated dipole pair in actication lead field and
%> nearest to it in localization lead field
dist = zeros(size(Y,1), length(p_Dipole.Idx));

%%
for i = 1:length(p_Dipole.Idx)
    
    X_new = repmat(X(i,:),size(Y,1),1);%X_new = repmat(X(i,:),size(Y,1),1);
    
    dist(:,i) = sqrt((X_new(:,1)-Y(:,1)).^2 + (X_new(:,2)-Y(:,2)).^2 + (X_new(:,3)-Y(:,3)).^2);
end

Offset = zeros(1,size(dist,2));
for i = 1 : size(dist,2)
    Offset(1,i) = min(dist(:,i));
end;
end