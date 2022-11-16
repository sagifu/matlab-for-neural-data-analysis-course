clear; close all; clc;

% The following code was written in MATLAB
%   Version - R2020a

%% Load data
dirPath = '..\DATA_DIR\';
initialData = dir([dirPath '**\*.edf']);

%% Experiment parameters
fs = 256;         % frequancy sample rate          
Hz = 6:0.1:14;    % rate spectrum
window = 4*fs;    % window length (=4sec)
channel = 19;     % the elctrode channel to be analyzed

%% Experiment data structures 

Data = struct();

emptyCellArr = {};

% building structure for each condition with specific fields
DataEO = struct('name', emptyCellArr,...
                'hdr', emptyCellArr,...
                'records', emptyCellArr);
DataEC = struct('name', emptyCellArr,...
                'hdr', emptyCellArr,...
                'records', emptyCellArr);
O = 1;  % EO condition count
C = 1;  % EC condition count
deleteAfter = [];   % an array to delete subjects with insufficient data

%% Preprocess loop

for n = 1:length(initialData)
    
    % Boolean variables check if the name contains the required labels
    % if not, save the index of the problematic data to later on exclusion
    % and skip to next data index
    EOCheck = regexp(initialData(n).name,'EO');
    ECCheck = regexp(initialData(n).name,'EC');
    EDFCheck = regexp(initialData(n).name,'.edf');
    if isempty(EOCheck) && isempty(ECCheck) || isempty(EDFCheck)
        deleteAfter(end+1) = n;
        continue;
    end
    
    % Extract relevant data from the initial data
    Data(n).name = initialData(n).name;
    fullFileName = fullfile(initialData(n).folder,initialData(n).name);
    [Data(n).hdr, Data(n).records] = edfread(fullFileName, 'targetSignals', channel);
    
    % divide non-problematic data between conditions and keep counts
    if ~isempty(EOCheck)
        DataEO(O) = Data(n);
        O = O + 1;
    else
        DataEC(C) = Data(n);
        C = C + 1;
    end
end
% delete excluded data from all data structure
Data(deleteAfter) = [];

nSubjects = length(DataEC); % number of subjects

%% Analysis and plotting loop

for n = 1:nSubjects     % for each subject
    h = figure('units', 'normalized', 'Position', [0.25 0 0.5 1]);hold on; % create figure
    h.Name = ['Subject no. ' num2str(n)];                                  % write the subject number in the headline
    sgtitle(['Brain wave analysis for subject no. ' num2str(n)], 'FontSize', 18);          % give super title for all plots
    
    % activate designated functions for each analysis method
    [WelchEC, WelchEO] = signalWelch(DataEC(n).records, DataEO(n).records, h, window, Hz, fs);
    [FFTEC, FFTEO] = signalFFT(DataEC(n).records, DataEO(n).records, h, Hz, fs);
    [DFTEC, DFTEO] = signalDFT(DataEC(n).records, DataEO(n).records, h, window, Hz, fs);
end
