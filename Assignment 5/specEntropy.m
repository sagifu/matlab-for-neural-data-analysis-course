function spectralEntropy = specEntropy(Data)
% function specEntropy recieves normalized power spectra, Data, in columns 
% (either a vector or a matrix) and calculates spectral entropy of this
% data.
%
% INPUT ARGUMENTS:
%   - Data - a column vector or 2-D matrix inwhich each column represents
%   normalized power spectra.
%
% OUTPUT ARGUMENTS:
%   - spectralEntropy - a scalar or a row vector (depends on Data input, 
%       either a vector or a matrix, respectively). represents the spectral
%       entropy of the normalized power spectra.

% allocate variable for loop summing up
spectralEntropy = zeros(1,size(Data,2));   

% loop over frequencies
for n = 1:size(Data,1)
    % compute and sum up the normalized power of each frequency multiplied
    % by the log on the base of 2 of itself, for each window seperately
    spectralEntropy = spectralEntropy + Data(n,:).*log2(Data(n,:));
end
% according to the formula, the minus of sum of products
spectralEntropy = -spectralEntropy;
end
