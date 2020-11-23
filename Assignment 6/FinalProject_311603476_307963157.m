clear; close all; clc;
%% documentary
% The following script creates a pipeline by extracting features from two
% EEG electrodes, C3 and C4. The aim of the pipeline is to predict whether
% the subject imagines right or left limb movement.
%
% Script uses the following self-written functions:
%     
%
%
%
%% Load training data and preprocess

load('motor_imagery_train_data');

% get binary vector which represents the identity of each trial by its
% condition - left or right hand imagine
leftID = find(~cellfun(@isempty, regexp(P_C_S.attributename, 'LEFT')));
rightID = find(~cellfun(@isempty, regexp(P_C_S.attributename, 'RIGHT')));

% get the indices of each condition using the binary vector
leftLoc = find(P_C_S.attribute(leftID,:) == 1);
rightLoc = find(P_C_S.attribute(rightID,:) == 1);

% get the indices of all labeled data signals
allLoc = sort([leftLoc rightLoc]);

% create label vector
label = cell(length(allLoc),1);
label(leftLoc) = cellstr('left');
label(rightLoc) = cellstr('right');

% number of labeled trials
LN = length(allLoc);

% third dimension in all signal matrices represents different electrodes
%   1 - C3 electrode
%   2 - C4 electrode
C3 = 1;
C4 = 2;

% extract all labeled data and by electrodes
All_Data = P_C_S.data(allLoc,:,[C3 C4]);
C3_Data = P_C_S.data(allLoc,:,C3);
C4_Data = P_C_S.data(allLoc,:,C4);

%% Set parameters

% set boolean variables for visualization of plots
visualize = 0;

% get sample rate
fs = P_C_S.samplingfrequency;

% frequencies vector and its length
Hz = 0.5:0.1:40;
LNHz = length(Hz);

% calculate TP of experiment que end time
queEndSec = 2.25;
queEndTP = queEndSec*fs;

% number of random trials to be displayd
nGraphs = 20;

% features' histograms bin length parameter
bin_edges = -4:0.2:4;

% window size and overlap time (in sec) to be calculated in spectrogram and
% Welch's method
windInSec = 1.25;
OLInSec = 1.24;
% window and overlap time (in TP)
window = floor(windInSec*fs);
overlap = floor(OLInSec*fs);

% AMPLITUDE VARIANCE - feature extrction parameters
dim = 2;                           % array dimension which be calculated
VarWindInSec = 1.5;                % window size in seconds
VarWind = floor(VarWindInSec*fs);  % window size in TPs

% standard deviation area of interest
area_std_inter = Hz>14 & Hz<18;
area_std_inter = find(area_std_inter == 1);

% SPECTRAL EDGE - threshold for feature extraction
partTH = 0.45;
fullTH = 0.55;

% PCA - set dimension to compress to
dimComp = 3;

% K-FOLD - number of groups
k_fold = 9;
k_bin = ceil(LN/k_fold);    % length of each group rounded upwise

% number of iterations for feature selection simulation
n_iter = 500;

% font graphics parameters
Font = struct('axes', 18, ...
            'title', 16, ...
            'sgtitle', 18, ...
            'legend', 12, ...
            'tick', 12, ...
            'colorlabel', 16);

% number of feature selected
FeatNum = 12;

%% Bandpower feature extraction parameters

%%% set parameters from spectrogram
% band frequencies of interest in experiment
Bands = [14 19; ...
    8 13; ...
    31 36; ...
    16 21];

% seconds of interest in experiment
% IMPORTANT: the gap between seconds MUST be greater than window size
% in seconds.
TimeInSec = [4 6; ...
    4 6; ...
    4 6; ...
    0.5 4];

% seconds of interest in TP
Time = floor(TimeInSec*fs);
%% Partial power by frequency calculation
% Data split into conditions for graphic purposes

% set mean boolean variable for calcPower function
Mean = 1;

% calculate mean power spectra and standard-deviation of each condition
% with self-written function
partialPower = struct('RC3', calcPower(C3_Data(rightLoc,:), window, overlap, Hz, fs, Mean, queEndTP), ...
                          'RC4', calcPower(C4_Data(rightLoc,:), window, overlap, Hz, fs, Mean, queEndTP), ...
                          'LC3', calcPower(C3_Data(leftLoc,:), window, overlap, Hz, fs, Mean, queEndTP), ...
                          'LC4', calcPower(C4_Data(leftLoc,:), window, overlap, Hz, fs, Mean, queEndTP));

%% Visualize data - several ways
if visualize
    % display random trials of each condition, in order to visualy search for
    % identifying features
    plotRand(nGraphs, All_Data(rightLoc,:,:), All_Data(leftLoc,:,:), C3, C4, fs, Font);
    
    % use of split data by condition for graphic purposes
    % display spectrogram using self-written function
    dispSpectro(C4_Data(rightLoc,:), C3_Data(rightLoc,:), ...
        C4_Data(leftLoc,:), C3_Data(leftLoc,:), window, overlap, Hz, fs, Font);
    
    % Mean partial power and standard-deviation by frequency display
    figure('units','centimeters','Position',[3.5 4.5 16 10]);hold on;
    sgtitle('Mean dB power spectra and std', 'FontSize', Font.sgtitle);
    subplot(2,1,1); plotPower(partialPower.RC3, partialPower.LC3, Hz, 'C3', Font);
    subplot(2,1,2); plotPower(partialPower.RC4, partialPower.LC4, Hz, 'C4', Font);
    shg;
end
%% Feature extraction

[Feat, FeatLabel, VAR] = featureExtract(fs, Hz, C3_Data, C4_Data, VarWind, ...
    dim, partTH, fullTH, window, overlap, queEndTP, area_std_inter, ...
    Bands, Time);

%% Feature selection
% get features in descending weight order according to neighborhood
% component analysis
select = fscnca(Feat', label);
[~,descendOrder] = sort(select.FeatureWeights, 'descend');

% compute cross-validation
% if visualize is True, simulate the features from 1 to number of features,
% n_iter times each, calculate mean and display.
% if visualize is False, perform k-fold cross-validation once for mean 
% accuracy and standard deviation, and continue
if visualize
    % allocate arraies
    MEAN_Val = zeros(n_iter,size(Feat,1));
    STD_Val = zeros(n_iter,size(Feat,1));
    Train_meanPRED = zeros(n_iter,size(Feat,1));
    Train_stdPRED = zeros(n_iter,size(Feat,1));
    % for each number of features
    for b = 1:size(Feat,1)
        % run n_iter times
        for a = 1:n_iter
            % extract the relevant number of features, according to
            % previous calculation
            tempFeat = Feat(descendOrder(1:b),:);
            
            %% Classifier
            
            % allocate validation accuracy and training error arraies
            ACC = zeros(1,k_fold);
            err = zeros(1,k_fold);
            % permutate the data
            perm = randperm(LN);
            %first index of validation group
            k_start = 1;
            % run k_fold times
            for k = 1:k_fold
                % be aware that the last index of the validation group
                % isn't greater than the length of the data
                if k_start + k_bin - 1 < LN
                    validx = perm(k_start:k_start + k_bin - 1);
                    trnidx = perm;
                    trnidx(k_start:k_start + k_bin - 1) = [];
                else
                    validx = perm(k_start:LN);
                    trnidx = perm;
                    trnidx(k_start:LN) = [];
                end
                % get the validation prediction and error rate of training
                % features
                [ValAcc,err(k)] = classify(tempFeat(:,validx)',tempFeat(:,trnidx)',label(trnidx),'linear');
                % calculate prediction accuracy
                ACC(k) = mean(cellfun(@(a,b) strcmpi(a,b), ...
                    ValAcc, label(validx)));
                % advance group
                k_start = k_start + k_bin;
            end
            % calculate mean accuracy and standard deviation of training
            % and validation for each iteration of ech number of features
            MEAN_Val(a,b) = (mean(ACC)*100);
            STD_Val(a,b) = (std(ACC)*100);
            Train_meanPRED(a,b) = (1 - mean(err))*100;
            Train_stdPRED(a,b) = std(err)*100;
        end
    end
    % calculate the overall mean accuracy and standard deviation of each
    % number of features
    mean_validation = mean(MEAN_Val);
    std_validation = mean(STD_Val);
    mean_train_predict = mean(Train_meanPRED);
    std_train_predict = mean(Train_stdPRED);
    % select number of features that predict with the highest accuracy rate
    FeatNum = find(mean_validation == max(mean_validation));
    % display statistics in command window
    disp(['Mean Validation Accuracy - ' num2str(mean_validation(FeatNum)) '%']);
    disp(['Validation Accuracy Standard-Deviation- ' num2str(std_validation(FeatNum)) '%']);
    disp(['Mean Training Error - ' num2str(100 - mean_train_predict(FeatNum)) '%']);
    disp(['Training Error Standard-Deviation - ' num2str(std_train_predict(FeatNum)) '%']);
    % plot
    figure('units','centimeters','Position',[0 0 16 10]);
    plot(1:size(tempFeat,1),mean_validation,'r'); hold on;
    plot(1:size(tempFeat,1),mean_train_predict,'b');
    set(gca,'FontSize', Font.tick);
    legend('Validation', 'Training', 'FontSize', Font.legend, 'Location', 'southeast');
    title('Accuracy percentage', 'FontSize', Font.title);
    ylabel('Percentage', 'FontSize', Font.axes);
    xlabel('number of features selected', 'FontSize', Font.axes);
else
    %% Classifier
    % extract the relevant number of features, according to previous
    % calculation
    tempFeat = Feat(descendOrder(1:FeatNum),:);
    
    % allocate computing arraies
    ACC = zeros(1,k_fold);
    err = zeros(1,k_fold);
    % permutate the data
    perm = randperm(LN);
    %first index of validation group
    k_start = 1;
    % run k_fold times
    for k = 1:k_fold
        % be aware that the last index of the validation group
        % isn't greater than the length of the data
        if k_start + k_bin - 1 < LN
            validx = perm(k_start:k_start + k_bin - 1);
            trnidx = perm;
            trnidx(k_start:k_start + k_bin - 1) = [];
        else
            validx = perm(k_start:LN);
            trnidx = perm;
            trnidx(k_start:LN) = [];
        end
        % get the validation prediction and error rate of training
        % features
        [ValAcc,err(k)] = classify(tempFeat(:,validx)',tempFeat(:,trnidx)',label(trnidx),'linear');
        % calculate prediction accuracy
        ACC(k) = mean(cellfun(@(a,b) strcmpi(a,b), ...
            ValAcc, label(validx)));
        % advance group
        k_start = k_start + k_bin;
    end
    
    % display statistics in command window
    disp(['Mean Validation Accuracy - ' num2str(mean(ACC)*100) '%']);
    disp(['Validation Accuracy Standard-Deviation- ' num2str(std(ACC)*100) '%']);
    disp(['Mean Training Error - ' num2str((mean(err))*100) '%']);
    disp(['Training Error Standard-Deviation - ' num2str(std(err)*100) '%']);
end

%% test
% load test data
test_Data = load('motor_imagery_test_data').data;
% divide data into electrodes data and extract features
C3_T_Data = test_Data(:,:,C3);
C4_T_Data = test_Data(:,:,C4);
testFeat = featureExtract(fs, Hz, C3_T_Data, C4_T_Data, VarWind, dim, ...
    partTH, fullTH, window, overlap, queEndTP, area_std_inter, ...
    Bands, Time);

% extract the relevant number of features according to previous calculation
FeatForTrain = Feat(descendOrder(1:FeatNum),:);
testFeat = testFeat(descendOrder(1:FeatNum),:);

% get test prediction
TestPred = classify(testFeat',FeatForTrain',label,'linear');

%% Display histogram and PCA
if visualize
    % set values from TP into secons
    VAR = VAR/fs;
    % plot all features as distinguishing histograms
    plotHist(Feat, rightLoc, leftLoc, bin_edges, FeatLabel, TimeInSec, ...
        Bands, VAR, Font);
    % compute and plot PCA
    calcPCA(Feat', dimComp, rightLoc, leftLoc, Font);
end
