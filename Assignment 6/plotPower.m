function plotPower(Data, subData, Hz, Ch, Font)
% function plotPower recieves power spectra Data and displays it.
%
% INPUT ARGUMENTS:
%   - Data - a structure containing row vectors of the mean power spectra 
%       data and its standard deviation.
%   - subData - a structure containing row vectors of the mean power spectra 
%       data and its standard deviation.
%   - Hz - a vector containing the frequencies which the Data represents.
%   - Hand - string to indicate which hand is imagined. either 'Right' or
%       'Left'.
%   - Ch - string to indicate which channel is plotted. either 'C3' or
%       'C4'.
%   - Font - a structure containing the font size of axes labels, title,
%       sgtitle, legend, ticks and color label

% calcualte the length of the frequency vector
LNHz = length(Hz);
% calculate x-axis values of standard deviation to be filled
x = (1:LNHz);
x2 = [x, fliplr(x)];
% calculate y-axis values of standard deviation of Data to be filled
curve1Data = (Data.mean + Data.std);
curve2Data = (Data.mean - Data.std);
inBetweenData = [curve2Data, fliplr(curve1Data)];
% calculate y-axis values of standard deviation of subData to be filled
curve1subData = (subData.mean + subData.std);
curve2subData = (subData.mean - subData.std);
inBetweensubData = [curve2subData, fliplr(curve1subData)];

% plot
fill(x2, inBetweenData, 'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
plot(x, Data.mean, 'r', 'LineWidth', 2); hold on;
fill(x2, inBetweensubData, 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
plot(x, subData.mean, 'k', 'LineWidth', 2);
title(['Channel ' Ch], 'FontSize', Font.title);
set(gca,'FontSize', Font.tick); 
ylabel('Power [dB]', 'FontSize', Font.axes);
xlabel('Frequency [Hz]', 'FontSize', Font.axes);
ylim([-25 5]);
xlim([0 LNHz]);
x_tick = 0:LNHz/8:LNHz;
xticks(x_tick);
n = LNHz/Hz(end);
xticklabels(x_tick/n);
legend({'Right-std', 'Right-mean', 'Left-std', 'Left-mean'}, 'FontSize', 12);

end