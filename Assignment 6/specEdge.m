function spectralEdge = specEdge(Data, TH)
% function specEdge recieves data and threshold parameter, and computes the
% index in Data untill which the cumulative summary is under the threshold
%
% INPUT ARGUMENTS:
%     -Data - a column vector or a matrix of column normalized power
%         spectra vectors
%     -TH - a scalar between 0 and 1, indicates the threshold of the
%         spectral edge
%
% OUTPUT ARGUMENTS:
%     -spectralEdge - a scalar or a row vector. indicates the index of each
%         column normalized power spectra vector, that is the edge of the
%         cumulative summary untill the desired threshold

% calculate cumulative summary of each window
sumIs = cumsum(Data, 1);    
% turn into binary vector, below-threshold
sumIs = sumIs < TH;          

% create differקnce vector - the (-1) will be the index in which the
% cumulative summery will be (the highest value under) TH
diffSum = diff(sumIs);      

% find the row indices locations of each window which corresponds with 
% the frequency at the edge of the top decile
[spectralEdge, ~] = find(diffSum == -1); 
spectralEdge = spectralEdge';

end