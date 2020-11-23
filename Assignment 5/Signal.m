function All_Data = Signal(Data, window, overlap, wind, op, fs, Hz, freqs, EdgeTH)
            
All_Data = []; % allocating variable for our final array

for n = 1:length(Data(:,1))

    % split data signals into windows. length and overlap recieved as input
    % arguments. first window will not be zero-padded due to 'nodely'
    % property, last window will not be padded and added to the
    % calculations, using the two output method. (the second output is the
    % last window)
    [PowerSpectra, ~] = buffer(Data(n,:), window, overlap, 'nodelay');
    
    % calculate power spectra for each window, using window and overlap
    % calculated here, rate spectrum and frequency sample recieved as input
    % arguments
    PowerSpectra = pwelch(PowerSpectra, wind, op , Hz, fs);
    
    % normalize the power spectra of each window
    NormalizedPower = normPower(PowerSpectra);
    
    % calculate relative power and log power
    [RelativePower, RelativeLogPower] = CalcRelative(PowerSpectra, Hz, freqs);
    
    % calculate the square root (= standard diviation) of the power
    stdPower = sqrt(sum(PowerSpectra));
    
    % extract coefficients values of log(power) as a function of log(Hz) for each window
    coeff = calcCoeff(PowerSpectra, Hz, n);
    
    % calculate spectral moment for each window
    spectralMoment = Hz*NormalizedPower;    
    
    % extract spectral edge for each window
    spectralEdge = specEdge(NormalizedPower, EdgeTH);
    
    % calculate spectral entropy for each window
    spectralEntropy = specEntropy(NormalizedPower);
    
    %% normalize features and add to matrix
       
    % save all the features across all electrodes
    All_Data = [All_Data;
                RelativePower;
                RelativeLogPower;
                stdPower;
                coeff;
                spectralMoment;
                spectralEdge;
                spectralEntropy];
end
end