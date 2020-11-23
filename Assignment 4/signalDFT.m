function [DFTEC, DFTEO] = signalDFT(signalEC, signalEO, h, window, Hz, fs)
% the following function recieves a signal vector for each of the two
% conditions, analyses them by fft method and plots them.
% returns the analysed data

Frequan = 0:fs/window:fs/2;                     % frequancy spectrum to be analyzed
rng = (Frequan>=Hz(1) & Frequan<=Hz(end));      % the range of the desired rate spectrum
XaxeFreq = Frequan(rng);                        % the frequancy spectrum of the desired range

% set window indices
n = 0:window-1;
k = 0:window-1;

% create exponent matrix which represents the fourier tranform
WMat = exp((-2*pi*1i/window)*n'*k);

% create signal matrix for each condition split into windows with no
% overlaps and with zero-padding only at the end of the last window
windMatEC = buffer(signalEC, window, 0, 'nodelay');
windMatEO = buffer(signalEO, window, 0, 'nodelay');

% multiply matrices and recieve the complex coefficients
% normalize by dividng by window length
DFTEC = (WMat*windMatEC)/window;
DFTEO = (WMat*windMatEO)/window;

% calculate the power of the frequancies
DFTEC = (abs(DFTEC)).^2;
DFTEO = (abs(DFTEO)).^2;

% calculate mean across windows
DFTEC = mean(DFTEC,2)';
DFTEO = mean(DFTEO,2)';

% save only the data in range
DFTEC = DFTEC(rng);
DFTEO = DFTEO(rng);

% find IAF maximum value and index
DiffDFT = DFTEC - DFTEO;
[MaxVal, MaxInd] = max(DiffDFT);

% plot
figure(h); hold on;
subplot(3,1,3); plot(0:length(XaxeFreq)-1,DFTEC); hold on;
subplot(3,1,3); plot(0:length(XaxeFreq)-1,DFTEO);
subplot(3,1,3); line([MaxInd-1 MaxInd-1], [DFTEC(MaxInd) DFTEO(MaxInd)], 'Color','k','LineStyle','--');
g = text(MaxInd, DFTEC(MaxInd)*1.1, ['Value = ' num2str(MaxVal) ', Frequancy = ' num2str(Frequan(MaxInd)+Hz(1))]);
g.HorizontalAlignment = 'center';

xlabel('Frequancy [Hz]', 'FontSize', 14);
ylabel('Power', 'FontSize', 14);
ylim([0 DFTEC(MaxInd)*1.2]);

x_tick = 0:round(length(XaxeFreq)/(Hz(end)-Hz(1))):length(XaxeFreq);
xticks(x_tick);
xticklabels(XaxeFreq(1):XaxeFreq(end));
xlim([0 length(XaxeFreq)-1]);

legend('EC', 'EO', 'IAF');
title('PowerSpectrum - DFT', 'FontSize', 16);
hold off;
end