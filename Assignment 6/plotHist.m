function plotHist(Feat, rightLoc, leftLoc, bin_edges, FeatLabel, Time, ...
    Bands, VAR, Font)
% function plotHist recieves a matrix of features and additional parameters
% and plots distinguishing histograms of each feature by their classes
%
% INPUT ARGUMENTS:
%     -Feat - a row vector or a matrix inwhich each row represents a
%         feature
%     -rightLoc - a vector which contains the second dimension indices of
%         Feat, which belongs to a class
%     -lefttLoc - a vector which contains the second dimension indices of
%         Feat, which belongs to a class
%     -bin_edges - a vector which contain the edges of the bins to plotted
%         in the histograms
%     -FeatLabel - a structure with two fields, name and count. for each
%         feature (by the field 'name'), the count will decide the amount
%         of subplots to be plotted in the same figure.
%     -Time - a N-by-2 array. each row contains two scalars, which
%         represents the range of time inwhich the power was calculated.
%     -Bands - a N-by-2 array. each row contains two scalars, which
%         represents the range of frequencies inwhich the power was
%         calculated. row size MUST be equal to Time
%     -VAR - a N-by-2 array. N amplitude variance windows were calculated, 
%         for each 2 scalars indicating the experiment time range 
%     -Font - a structure containing the font size of axes labels, title,
%         sgtitle, legend, ticks and color label

% compute z scores of features
Feat = zscore(Feat')';
% compute the number of plot
n_hist = size(FeatLabel,2);
% allocate histogram index variable
Idx = 1;

% plot
for n = 1:n_hist
    h = figure('units','centimeters','Position',[0 0 10 10]); hold on;
    % get number of plots to a single figure
    n_count = FeatLabel(n).count;
    % plot if one per figure
    if n_count == 1
        histogram(Feat(Idx,rightLoc),bin_edges);
        histogram(Feat(Idx,leftLoc),bin_edges);
        Idx = Idx +1;
        set(gca,'FontSize', Font.tick);
        legend('Right','Left', 'FontSize', Font.legend);
        title(FeatLabel(n).name, 'FontSize', Font.title);
        xlabel('Z-scores', 'FontSize', Font.axes);
        ylabel('counts', 'FontSize', Font.axes);
    else
        % if more than one plot per figure
        % creates a super title
        sgtitle(FeatLabel(n).name, 'FontSize', Font.sgtitle);
        % run as the number of subplots
        for a = 1:n_count
            % create plot
            subplot(2,n_count/2,a); hold on;
            histogram(Feat(Idx,rightLoc),bin_edges);
            histogram(Feat(Idx,leftLoc),bin_edges);
            Idx = Idx +1;
            set(gca,'FontSize', Font.tick);
            legend('Right','Left', 'FontSize', Font.legend);
            xlabel('Z-scores', 'FontSize', Font.axes);
            ylabel('counts', 'FontSize', Font.axes);
            % add decription by name
            if contains(FeatLabel(n).name, 'bandpower')
                h.Position = [0 0 16 16];
                title(['Band: ' num2str(Bands(a,1)) '-' num2str(Bands(a,2))...
                    ', Time: ' num2str(Time(a,1)) '-' num2str(Time(a,2))], ...
                    'FontSize', Font.title);
            end
            if contains(FeatLabel(n).name, 'VAR')
                h.Position = [0 0 16 12];
                title(['Amplitude Variance, experiment time: ' ...
                    num2str(VAR(a,1)) '-' num2str(VAR(a,2))], ...
                    'FontSize', Font.title);
            end
            if contains(FeatLabel(n).name, 'coefficients')
                if a == n_count
                    h.Position = [0 0 16 12];
                    title('linear constant coefficient of logarithmic plot', ...
                        'FontSize', Font.title);
                else
                    title(['linear ' num2str(n_count-a) ' order coefficient of logarithmic plot'], ...
                    'FontSize', Font.title);
                end
            end
        end
    end

end
