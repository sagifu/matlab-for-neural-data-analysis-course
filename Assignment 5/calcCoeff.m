function coeff = calcCoeff(Data, Hz, a)

% preallocate array for the linear coefficients of the logarithmic power
% as a function of the logarithmic frequencies
coeff = zeros(2, size(Data, 2));    

% figure(); hold on;

% loop over windows
for n = 1:size(Data, 2)
    % extract two coefficients (polynom in order 1) for each window
    coeff(:,n) = polyfit(log(Hz), log(Data(:,n)), 1)';
    
%     plot(log(Hz),log(Data(:,n)));
end
end
% title(['electrode number ' num2str(a)]);
% x_tic = log([1 4.5 8 11.5 15 30 40]);
% xticks(x_tic);
% x_tic = exp(x_tic);
% xticklabels(x_tic);
% xlabel('Frequency[Hz]');
% ylabel('Power[dB]');
