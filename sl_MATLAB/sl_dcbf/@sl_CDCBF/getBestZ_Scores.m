
% =================================================================
%> @brief gives Combination with best Z-Score
%>
%> writes the Index and the Index values of the amount of numScores best Z_Scores in a [numScores x 3] matrix
%> Loop starts at (numberOfCombinations - (numberOfDipoles + numScores))
%> in order to ignore the combinations of same type
%> ([L1,L1];[L2,L2];...;[LnumberOfDipoles,LnumberOfDipoles])
%> 
%> @param numScores Number of wanted output combinations
%> @param numberOfDipoles Number of dipole sources
%> @param z_Idcs Indices of combinations that were sorted by
%> z-score
%> @param ordered_Idcs Combinations that were sorted by z-score 
%> @param t_ForwardSolution This holds the Lead Field Matrix; of the type sl_CForwardSolution.
%>
%> @retval bestPseudoZ Lists the numScores best combinations with the best pseudo-zscore
%> first column = Index of ordered z-Score, second and thrird
%> columns = dipolepair, fourth and fifth columns = Index of dipole pair 
% =================================================================
function [ bestPseudoZ ] = getBestZ_Scores( numScores, numberOfDipoles , Z_Idcs, ordered_Idcs, ForwardSolution)

selectedIdx = [ForwardSolution.SelectedSources(1,1).idx ForwardSolution.SelectedSources(1,2).idx];
%> numberOfCombinations
j = nchoosek(numberOfDipoles+1,2);
bestPseudoZ = zeros(numScores,1);

%> counter
counter = 1;
for i = (j-(numberOfDipoles+numScores)) : j
    if counter < numScores + 1
        if ordered_Idcs(j,1) ~= ordered_Idcs(j,2)
            bestPseudoZ(counter,1) = Z_Idcs(j,1);
            bestPseudoZ(counter,4) = ordered_Idcs(j,1);
            bestPseudoZ(counter,5) = ordered_Idcs(j,2);
            bestPseudoZ(counter,2) = selectedIdx(bestPseudoZ(counter,4));
            bestPseudoZ(counter,3) = selectedIdx(bestPseudoZ(counter,5));
            counter = counter + 1;
        end;
    end;
    j = j - 1;
end;

end


