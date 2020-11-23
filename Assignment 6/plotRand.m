function plotRand(nGraphs, RData, LData, C3, C4, fs, Font)
% plotRand is a function which plots Data according to given parameters
%
% INPUT ARGUMENTS:
%     -nGraphs - number of trials to be plotted from each data setsץ MUST
%         be a multiple of 4
%     -RData - 3-D array of row EEG signals
%         first dimension - trials
%         second dimension - samples
%         third dimension - electrode
%     -LData - 3-D array of row EEG signals - similar to RData
%     -C3 - a scalar index of third dimension of the data
%     -C4 - a scalar index of third dimension of the data
%     -fs - sampling frequency
%     -Font - a structure containing the font size of axes labels, title,
%         sgtitle, legend, ticks and color label

% set location of ylabel
Line = nGraphs/4;
if Line/2 == round(Line/2)
    yLab = nGraphs/2+1;
else
    yLab = nGraphs/2-1;
end
% get length of each data set
LnLeft = size(LData,1);
LnRight = size(RData,1);

% choose random trials from each condition
RrandTrials = randi(LnLeft, nGraphs);
LrandTrials = randi(LnRight, nGraphs);

% allocate a figure for each condition
RH = figure('units','centimeters','Position',[0 0 24 12], 'Visible', 'Off');
sgtitle('Right hand imagine', 'FontSize', Font.sgtitle);
LH = figure('units','centimeters','Position',[0 0 24 12], 'Visible', 'Off');
sgtitle('Left hand imagine', 'FontSize', Font.sgtitle);

% loop over trials to be plotted
for n = 1:nGraphs
    figure(RH); hold on;
    subplot(nGraphs/4,4,n); hold on;
    plot(1:size(RData, 2), RData(RrandTrials(n),:,C3), 'r'); hold on;
    plot(1:size(RData, 2), RData(RrandTrials(n),:,C4), 'b');
    x_tick = (0:fs:size(RData,2));
    xticks(x_tick);    
    x_tick = x_tick/fs;
    xticklabels(x_tick);
    set(gca,'FontSize', Font.tick);
    ylim([-30 30]);
    if n == yLab
        ylabel('Amplitude [\muV]', 'FontSize', Font.axes);
    end
    if n >= nGraphs-3 && n <= nGraphs
        xlabel('Time [sec]', 'FontSize', Font.axes);
    end

    figure(LH); hold on;
    subplot(nGraphs/4,4,n); hold on;
    plot(1:size(LData, 2), LData(LrandTrials(n),:,C3), 'r'); hold on;
    plot(1:size(LData, 2), LData(LrandTrials(n),:,C4), 'b');
    x_tick = (0:fs:size(RData,2));
    xticks(x_tick);
    x_tick = x_tick/fs;
    xticklabels(x_tick);
    set(gca,'FontSize', Font.tick);
    ylim([-30 30]);
    if n == yLab
        ylabel('Amplitude [\muV]', 'FontSize', Font.axes);
    end
    if n >= nGraphs-3 && n <= nGraphs
        xlabel('Time [sec]', 'FontSize', Font.axes);
    end
end

legend({'C3','C4'}, 'FontSize', 10, 'Position',[0.9 0.9 0.1 0.1]);
figure(RH);
legend({'C3','C4'}, 'FontSize', 10, 'Position',[0.9 0.9 0.1 0.1]);

end
