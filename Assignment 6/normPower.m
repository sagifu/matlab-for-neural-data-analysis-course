function NormalizedPower = normPower(Data)
% function normPower recieves data of power spectra and returns the
% normalized power spectra
%
% INPUT ARGUMENT:
%     -Data - a column vector or a matrix of column power spectra vectors
%
% OUTPUT ARGUMENT:
%     -NormalizedPower - a column vector or a matrix of column normalized 
%         power spectra vectors

% allocate matrix
NormalizedPower = zeros(size(Data));    

% loop over frequencies
for n = 1:length(Data(:,1))
    % divide each frequency of each window, by the sum of the power of
    % each window
    NormalizedPower(n,:) = Data(n,:)./sum(Data,1); 
end
end