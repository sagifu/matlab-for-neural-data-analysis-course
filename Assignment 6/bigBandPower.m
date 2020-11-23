function Power = bigBandPower(Data, fs, Freq, Time)
% function bigBandPower recieves two 2-D data arraies, calculates the 
% difference between the energy (that is, the area under the power 
% spectrum) of each channel, within a range of Time and Freq.
%
% INPUT ARGUMENTS:
%   - Data - 2-D array. first dimension - indicates frequency.
%                       second dimension - indicates trial.
%   - fs - frequency sampling rate
%   - Freq - an N-by-2 array. each row contains two scalars, which
%       represents the range of frequencies inwhich the power will be
%       calculated.
%   - Time - an N-by-2 array. each row contains two scalars, which
%       represents the range of time inwhich the power will be
%       calculated. row size MUST be equal to Freq
%
% OUTPUT ARGUMENTS:
%   - Power - a N-by-M array. N is the number of rows in Freq 
%       and M is the number of trials (second dimension of Data)

% get the number of rows in Freq 
LN = size(Freq,1);

% allocate a N-by-M array
Power = zeros(LN,size(Data,2));


% loop over rows in Freq
for n = 1:LN
    % for each range of calculation, calculate the bandpower
    Power(n,:) = bandpower(Data(Time(n,1):Time(n,2),:), fs, [Freq(n,1) Freq(n,2)]);
end

end