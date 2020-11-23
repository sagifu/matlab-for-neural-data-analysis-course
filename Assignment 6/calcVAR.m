function [variances, VAR, Times] = calcVAR(Data, Batch, dim)
% calcVAR is a function which gets EEG signals, window size and dimension,
% and returns the variances of each signal in each window.
%
% INPUT ARGUMENTS:
%     -Data - a row vector or a matrix with row EEG signals
%     -Batch - a scalar which represents window size
%     -dim - the dimension on which the calculation will be performed
%
% OUTPUT ARGUMENT:
%     -variances - a scalar for each window given
%     -VAR - an M-by-2 matrix containing window edges in seconds
%     -Times - number of windows calculated


% extract the length of the signal
LN = size(Data,2);
% we are interested in the second half of the signals
% first index
start = LN/2;
% last index in the first window
finish = start + Batch;
% number of windows
Times = floor(start/Batch);
% alloocate array for variances
variances = zeros(Times, size(Data,1));
% allocate variable for variance histogram
VAR = [];

% loop over windows
for n = 1:Times
    % if the first index is off limits, break
    if start > LN
        break;
    end
    % if the last index is off limits,
    % the last index will be the final index
    if finish > LN
        finish = LN;
    end
    % calculate the variance of the signal, in the given dimension
    variances(n,:) = var(Data(:,start:finish),0,dim)';
    % save time of windows
    VAR = [VAR; start finish];
    % update window indices
    start = start + Batch;
    finish = finish + Batch;
end

end