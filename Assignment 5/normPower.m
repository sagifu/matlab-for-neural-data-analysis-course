function NormalizedPower = normPower(Data)
% function normPower recieves Data and computes the normalized power of
% each frequuency in each column.
%
% INPUT ARGUMENTS:
%   - Data - either a column vector or a 2-D matrix inwhich each column
%   represents the power of an EEG signal
%
% OUTPUT ARGUMENTS:
%   - NormalizedPower - a column vector or an array, at the size of data. contains
%   the normalized power of each frequency for each power vector.

% allocate matrix
NormalizedPower = zeros(size(Data));    

% loop over frequencies
for n = 1:length(Data(:,1))
    % divide each frequency of each window, by the sum of the power of
    % each window
    NormalizedPower(n,:) = Data(n,:)./sum(Data,1); 
end
end