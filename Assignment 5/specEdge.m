function spectralEdge = specEdge(Data, TH)
% function specEdge receives normalized power spectra data and a
% threshold, and calculates the frequency until which the cumulative energy
% equals (or the highest value UNDER) the threshold.
%
% INPUT ARGUMENTS:
%   - Data - either a column vector or a 2-D matrix inwhich each column
%       represents a normalized power spectra.
%   - TH - a scalar between 0 and 1, which represents the threshold
%
% OUTPUT ARGUMENTS:
%   - spectralEdge - either a scalar or a row vector inwhich each scalar
%       represents the index of the normalized power spectra until which 
%       the cumulative energy equals (or the highest value UNDER) the 
%       threshold.

% calculate cumulative summary of each column vector
sumIs = cumsum(Data, 1);    

% turn into binary vector, below-threshold
sumIs = sumIs < TH;          

% create difference vector - the (-1) value will be the index in which the
% cumulative summery will be (the highest value UNDER) the threshold
diffSum = diff(sumIs);      

% find the row indices locations of each column vector which corresponds 
% with the frequency at the edge of the threshold
[spectralEdge, ~] = find(diffSum == -1); 
spectralEdge = spectralEdge';

end