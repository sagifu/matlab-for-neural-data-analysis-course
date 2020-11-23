function [FFTEC, FFTEO] = signalFFT(signalEC, signalEO, h, Hz, fs)
% the following function recieves a signal vector for each of the two
% conditions, analyses them by fft method and plots them.
% returns the analysed data

LN = length(signalEC);                      % length of the signal
Frequan = 0:fs/LN:fs/2;                     % frequancy spectrum to be analyzed
rng = (Frequan>=Hz(1) & Frequan<=Hz(end));  % the range of the desired rate spectrum
XaxeFreq = Frequan(rng);                    % the frequancy spectrum of the desired range

% normalized fft results of each condition
FFTEC = fft(signalEC)./length(signalEC);   
FFTEO = fft(signalEO)./length(signalEO);

% calculate the power of the frequancies
FFTEC = abs(FFTEC).^2;
FFTEO = abs(FFTEO).^2;

% save only the data in range
FFTEC = FFTEC(rng);
FFTEO = FFTEO(rng);

% find IAF maximum value and index
DiffFFT = FFTEC - FFTEO;
[MaxVal, MaxInd] = max(DiffFFT);

% plot
figure(h); hold on;
subplot(3,1,2); plot(0:length(XaxeFreq)-1, FFTEC); hold on;
subplot(3,1,2); plot(FFTEO);
subplot(3,1,2); line([MaxInd MaxInd], [FFTEC(MaxInd) FFTEO(MaxInd)], 'Color','k','LineStyle',':', 'LineWidth',1);
g = text(MaxInd, FFTEC(MaxInd)*1.1, ['Value = ' num2str(MaxVal) ', Frequancy = ' num2str(Frequan(MaxInd)+Hz(1))]);
g.HorizontalAlignment = 'center';

xlabel('Frequancy [Hz]', 'FontSize', 14);
ylabel('Power', 'FontSize', 14);
ylim([0 FFTEC(MaxInd)*1.2]);

x_tick = 0:round(length(XaxeFreq)/(Hz(end)-Hz(1))):length(XaxeFreq);
xticks(x_tick);
xticklabels(XaxeFreq(1):XaxeFreq(end));
xlim([0 length(XaxeFreq)-1]);

legend('EC', 'EO', 'IAF');
title('PowerSpectrum - FFT', 'FontSize', 16);
hold off;
end