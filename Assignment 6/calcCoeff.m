function coeff = calcCoeff(Data, Hz)
% function calcCoeff recieves data and and a frequency vector and returns
% two coefficients of the fitted linear polynom of the logarithmic display
% of the data
%
% INPUT ARGUMENTS:
%     -Data - a column vector or a matrix of column power spectra vectors 
%     -Hz - a frequency vector
%
% OUTPUT ARGUMENTS:
%     -coeff - a 2-by-N matrix. N is the number of columns in Data.

% allocate array for the linear coefficients of the logarithmic power
% as a function of the logarithmic frequencies
coeff = zeros(2, size(Data, 2));    

% loop over windows
for n = 1:size(Data, 2)
    % extract two coefficients (polynom in order 1) for each window
    coeff(:,n) = polyfit(log(Hz), log(Data(:,n)), 1)';
end

end
