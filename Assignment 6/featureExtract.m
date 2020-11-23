function [Feat, FeatLabel, VAR] = featureExtract(fs, Hz, C3_Data, C4_Data, ...
    VarWind, dim, partTH, fullTH, window, overlap, queEndTP, ...
    area_std_interest, Bands, Time)
% featureExtract recieves data sets and parameters, extracts features and
% returns a row feature matrix
%
% INPUT ARGUMENTS:
%     -fs - sampling rate
%     -Hz - frequency vector
%     -C3_Data - 2-D matrix containing row EEG signals
%     -C4_Data - 2-D matrix containing row EEG signals
%     -VarWind - variance feature window size
%     -dim - variance feature calculation dimension 
%     -partTH - partial power spectra spectral edge feature threshold
%     -fullTH - power spectra spectral edge feature threshold
%     -window - window size for spectrogram and power spectra calculation
%     -overlap - overlaping window size for spectrogram and power spectra 
%         calculation
%     -queEndTP - an index indicates the end of the experiment que
%     -area_std_interest - a vector containing indices of a signal
%         represents the area in which the standard deviation will be a
%         feature
%     -Bands - bands array of interesting energy feature areas
%     -Time - time array of interesting energy feature areas. MUST be the
%         same size as Bands
%
% OUTPUT ARGUMENTS:
%     -Feat - 2-D matrix containing the following row features
%         -std - standard deviation in a specific frequency range
%         -var - amplitude variance
%         -bandpower - the energy of specific areas of time and frequencies
%         -specttral entropy - system (function) complexity
%         -spectral edge - the frequency threshold of cumulative sum
%         -spectral moment - 
%         -coefficients - the linear coefficients of logarithmic display
%     -FeatLabel - structure containing the name of a feature and the
%       number of features it holds
%     -VAR - an M-by-2 matrix inwhich each row has two scalars indicating
%       the beggining and ending of the window iwhich the amplitude variance
%       was calculated

%% full power spectra calculation and normalization
fullPower = struct('C3',calcPower(C3_Data(:,:), window, overlap, Hz, fs), ...
    'C4',calcPower(C4_Data(:,:), window, overlap, Hz, fs));
% normalize full power
PowerNorm.C3 = normPower(fullPower.C3);
PowerNorm.C4 = normPower(fullPower.C4);

%% partial power spectra calculation and normalization
% set mean boolean variable for calcPower function
Mean = 0;
% calculate partial power spectra (imaginery part - from que end untill 
% experiment end)
partPow = struct('C3',calcPower(C3_Data(:,:), window, overlap, Hz, fs, Mean, queEndTP), ...
    'C4',calcPower(C4_Data(:,:), window, overlap, Hz, fs, Mean, queEndTP));
% normalize partial power
partNormPow.C3 = normPower(partPow.C3);
partNormPow.C4 = normPower(partPow.C4);

%% allocate arraies and parameters for features and feature labels
Feat = [];
FeatLabel = struct();
FeatIdx = 1;
LNFeat = length(Feat);

%% MEAN
% convert power spectra into dB units
dBpartC3 = pow2db(partPow.C3);
dBpartC4 = pow2db(partPow.C4);
% extract mean of dB power spectra in area of interest
Feat = [Feat; ...
    mean(dBpartC3(area_std_interest,:)); ...
    mean(dBpartC4(area_std_interest,:))];
% add label of mean
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'MEAN C3', 'MEAN C4'});

%% STD
% extract std of dB power spectra in area of interest
Feat = [Feat; ...
    std(dBpartC3(area_std_interest,:)); ...
    std(dBpartC4(area_std_interest,:))];
% add label of standard deviation
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'STD C3', 'STD C4'});

%% VAR
% extract the amplitude variance
[VarC3, ~, ~] = calcVAR(C3_Data,VarWind,dim);
[VarC4, tempVAR, numOfWind] = calcVAR(C4_Data,VarWind,dim);
VAR(1:numOfWind,:) = tempVAR(1:numOfWind,:);
Feat = [Feat; VarC3; VarC4];
% add label of variance
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'VAR C3', 'VAR C4'});

%% ENERGY
% extract the energy of specific frequency bands and time
Feat = [Feat; ...
    bigBandPower(C4_Data', fs, Bands, Time); ...
    bigBandPower(C3_Data', fs, Bands, Time)];
% add label of bandpower
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'bandpower C4', 'bandpower C3'});

%% SPECTRAL EDGE
% calculate the spectral edge of the full normalized power
Feat = [Feat; ...
    specEdge(PowerNorm.C3, fullTH); ...
    specEdge(PowerNorm.C4, fullTH)];
% add label of full power spectral edge
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'full power spectral edge C3', 'full power spectral edge C4'});
% calculate the spectral edge of the partial normalized power
Feat = [Feat; ...
    specEdge(partNormPow.C3, partTH); ...
    specEdge(partNormPow.C4, partTH)];
% add label of partial power spectral edge
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'partial power spectral edge C3', 'partial power spectral edge C4'});

%% SPECTRAL MOMENT
% calculate the spectral moment of the full normalized power
Feat = [Feat; ...
    Hz*PowerNorm.C3; ...
    Hz*PowerNorm.C4];
% add label of full power spectral moment
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'full power spectral moment C3', 'full power spectral moment C4'});
% calculate the spectral moment of the partial normalized power
Feat = [Feat; ...
    Hz*partNormPow.C3; ...
    Hz*partNormPow.C4];
% add label of partial power spectral moment
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'partial power spectral moment C3', 'partial power spectral moment C4'});
%% COEFFICIENTS
% calculate coefficients of logarithmiic display of full power
C3coeff = calcCoeff(fullPower.C3, Hz);
C4coeff = calcCoeff(fullPower.C4, Hz);

Feat = [Feat; C3coeff; C4coeff];
% add label of full power coefficients
[LNFeat, FeatLabel, FeatIdx] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'full power coefficients C3', 'full power coefficients C4'});
% calculate coefficients of logarithmiic display of partial power
C3coeff = calcCoeff(partPow.C3, Hz);
C4coeff = calcCoeff(partPow.C4, Hz);

Feat = [Feat; C3coeff; C4coeff];
% add label of partial power coefficients
[~, FeatLabel, ~] = labeling(Feat, LNFeat, FeatLabel, ...
    FeatIdx, {'partial power coefficients C3', 'partial power coefficients C4'});
