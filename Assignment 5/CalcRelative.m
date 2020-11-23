function [RelativePower, RelativeLogPower] = CalcRelative(Data, Hz, freqs)

% extract the names of frequencies and number
fields = fieldnames(freqs);
numFreq = size(fields,1);

% preallocate matrices for calculations
RelativePower = zeros(numFreq,size(Data,2));
RelativeLogPower = zeros(numFreq,size(Data,2));

% use of formula to calculate the sum of logarithmic total power (of all
% the frequency band)
LogTotPow = sum(log(exp(1).*Data./min(Data)));

% loop over frequency bands
for n = 1:numFreq
    % extract band frequency rates
    temp = freqs.(fields{n});
    % extract data equivalent to band frequency rates
    tempData = Data(find(Hz == temp(1)):find(Hz == temp(end)),:);
    
    % calculate total power by band and total power 
    numerator = sum(tempData, 1);
    denominator = sum(Data, 1);
    
    % calculate relative and relative log power by formula
    RelativePower(n,:) = numerator./denominator;
    RelativeLogPower(n,:) = sum(log(exp(1).*tempData./min(tempData)))./LogTotPow;
end
end