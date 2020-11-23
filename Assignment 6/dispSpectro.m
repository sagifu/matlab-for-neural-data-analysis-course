function dispSpectro(DataRC4, DataRC3, DataLC4, DataLC3, window, overlap, Hz, fs, Font)
% function dispSpectro receives EEG signal(s) data and displays a 
% spectrogram of it.
%
% INPUT ARGUMENTS:
%   - DataRC4 - an array containing row signals. 
%               Class: Right. Elec: C4
%   - DataRC3 - an array containing row signals. 
%               Class: Right. Elec: C3
%   - DataLC4 - an array containing row signals. 
%               Class: Left. Elec: C4
%   - DataLC3 - an array containing row signals. 
%               Class: Left. Elec: C3
%   - window - a scalar equal to window size in seconds multiplied by
%       sampling rate
%   - overlap - a scalar equal to overlap size in seconds multiplied by
%       sampling rate
%   - Hz - frequency vector
%   - fs - sampling rate
%   - Font - a structure containing the font size of axes labels, title,
%       sgtitle, legend, ticks and color label

% get number of trials
N_trial = size(DataRC4, 1);

% allocate arraies according to one result
[~, freqVec, TVec] = spectrogram(DataRC4(1,:), window, overlap, Hz, fs, 'yaxis');
RC4spec = zeros(length(freqVec), length(TVec), N_trial);
RC3spec = zeros(size(RC4spec));
LC4spec = zeros(size(RC4spec));
LC3spec = zeros(size(RC4spec));

for n = 1:N_trial
    % get the spectrogram complex coefficients for each condition and trial
    RC4spec(:,:,n) = spectrogram(DataRC4(n,:), window, overlap, Hz, fs, 'yaxis');
    RC3spec(:,:,n) = spectrogram(DataRC3(n,:), window, overlap, Hz, fs, 'yaxis');
    LC4spec(:,:,n) = spectrogram(DataLC4(n,:), window, overlap, Hz, fs, 'yaxis');
    LC3spec(:,:,n) = spectrogram(DataLC3(n,:), window, overlap, Hz, fs, 'yaxis');
    
    % translate into power
    RC4spec(:,:,n) = abs(RC4spec(:,:,n)).^2;
    RC3spec(:,:,n) = abs(RC3spec(:,:,n)).^2;
    LC4spec(:,:,n) = abs(LC4spec(:,:,n)).^2;
    LC3spec(:,:,n) = abs(LC3spec(:,:,n)).^2;
    
    % turn units into dB
    RC4spec(:,:,n) = 10*log10(RC4spec(:,:,n));
    RC3spec(:,:,n) = 10*log10(RC3spec(:,:,n));
    LC4spec(:,:,n) = 10*log10(LC4spec(:,:,n));
    LC3spec(:,:,n) = 10*log10(LC3spec(:,:,n));
end
% calculate mean over trials
RC4spec = mean(RC4spec, 3);
RC3spec = mean(RC3spec, 3);
LC4spec = mean(LC4spec, 3);
LC3spec = mean(LC3spec, 3);

% plot
figure('units','centimeters','Position',[0 0 16 10]); hold on;
sgtitle('Spectograms', 'FontSize', Font.sgtitle);
subplot(2,2,1);
imagesc(RC4spec);
g = gca;
g.YDir = 'normal';
x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
title('C4 right', 'FontSize', Font.title);

subplot(2,2,2);
imagesc(LC4spec);
g = gca;
g.YDir = 'normal';
x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
title('C4 left', 'FontSize', Font.title);

subplot(2,2,3);
imagesc(RC3spec);
g = gca;
g.YDir = 'normal';
x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
title('C3 right', 'FontSize', Font.title);

subplot(2,2,4);
imagesc(LC3spec);
g = gca;
g.YDir = 'normal';
x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
c = colorbar;
title('C3 left', 'FontSize', Font.title);

c.Position = [0.866,0.166,0.0232,0.665];
c.Label.String = 'Power [dB]';
c.Label.FontSize = Font.colorlabel;

% plot the difference
figure('units','centimeters','Position',[0 0 16 10]); hold on;
sgtitle('Spectograms', 'FontSize', Font.sgtitle);
subplot(1,2,1);
imagesc(RC4spec-LC4spec);
g = gca;
g.YDir = 'normal';
x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
c = colorbar;
c.Label.String = 'Power [dB]';
c.Label.FontSize = Font.colorlabel;
title('C4 right-left', 'FontSize', Font.title);

subplot(1,2,2);
imagesc(RC3spec-LC3spec);
g = gca;
g.YDir = 'normal';x_tick = 0:length(TVec)/6:length(TVec);
xticks(x_tick);
x_tick = x_tick/(length(TVec)/6);
xticklabels(x_tick);
yticklabels(5:5:max(Hz));
set(gca,'FontSize', Font.tick);
ylabel('Frequency [Hz]', 'FontSize', Font.axes);
xlabel('Time [sec]', 'FontSize', Font.axes);
axis square;
colormap(jet);
c = colorbar;
c.Label.String = 'Power [dB]';
c.Label.FontSize = Font.colorlabel;
title('C3 right-left', 'FontSize', Font.title);


end



