function [WelchEC, WelchEO] = signalWelch(signalEC, signalEO, h, window, Hz, fs)
% the following function recieves a signal vector for each of the two
% conditions, analyses them by Welch method and plots them.
% returns the analysed data

% recieves pwelch results for each signal
% includes:
%   - window length (third of the window given)
%   - overlap (none)
%   - rate spectrum to be analyzed
%   - sampling rate
WelchEC = pwelch(signalEC, window, [], Hz, fs);
WelchEO = pwelch(signalEO, window, [], Hz, fs);

% find IAF maximum value and index
DiffWelch = WelchEC - WelchEO;
[MaxVal, MaxInd] = max(DiffWelch);

% plot
figure(h); hold on;
subplot(3,1,1); plot(WelchEC); hold on;
subplot(3,1,1); plot(WelchEO);
subplot(3,1,1); line([MaxInd MaxInd], [WelchEC(MaxInd) WelchEO(MaxInd)], 'Color','k','LineStyle','--');
g = text(MaxInd, WelchEC(MaxInd)*1.1, ['Value = ' num2str(MaxVal) ', Frequancy = ' num2str(MaxInd/10 + Hz(1))]);
g.HorizontalAlignment = 'center';

xlabel('Frequancy [Hz]', 'FontSize', 14);
ylabel('Power', 'FontSize', 14);
ylim([0 WelchEC(MaxInd)*1.2]);

x_tick = 0:10:length(WelchEC);
xticks(x_tick);
xticklabels(x_tick/10 +Hz(1));
xlim([0 length(WelchEC)]);

legend('EC', 'EO', 'IAF');
title('PowerSpectrum - Welch', 'FontSize', 16);
hold off;
end