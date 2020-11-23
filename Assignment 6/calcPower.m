function Array = calcPower(Data, window, overlap, Hz, fs, Mean, startTime, endTime)
% function calcPower recieves data and calculates the power of each row
%
% INPUT ARGUMENTS:
%   - Data - either a row vector or a matrix with row EEG signals
%   - window - a scalar which represents window size
%   - overlap - a scalar which represents overlaping window size
%   - Hz - desired frequencies vector
%   - fs - frequency sampling rate
%   - Mean - boolean indicates whether the output is desired to be mean or
%       not. Default is False
%   - startTime - time, in TP, from which the power calculation will begin.
%       if doesn't have an input, it begins from the top
%   - endTime - time, in TP, until which the power calculation will be 
%       calculated. if doesn't have an input, it will be the length of the
%       signal
%
% OUTPUT ARGUMENTS:
%   - Array - power spectra of all input signals
%             if Mean is True - 
%             Array is a structure with mean and standard deviations of the
%             power spectra (in dBs) of each frequency across all input 
%             signals


% if doesn't have input for variables, their values are determinant.
% - endTime is the length of the signal
% - startTime is the starting point of the signal (= 1)
% - Mean is False
if nargin < 6
    endTime = size(Data,2);
    startTime = 1;
    Mean = 0;
elseif nargin < 7
    endTime = size(Data,2);
    startTime = 1;
elseif nargin < 8
    endTime = size(Data,2);
end


% check startTime validity.
% if equal 0, meant from the top -> equal 1
if startTime == 0
    startTime = 1;
end

% power spectra calculation
Power = pwelch(Data(:,startTime:endTime)', window, overlap, Hz, fs);

% create return variable
if Mean
    Power = pow2db(Power);
    Array.std = std(Power,0,2)';
    Array.mean = mean(Power,2)';
else
    Array = Power;
end

end