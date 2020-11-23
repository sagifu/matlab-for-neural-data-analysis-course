function calcPCA(Data, dimComp, RLoc, LLoc, Font)
% function calcPCA recieves data and parameters, computes PCA and displays
% the outcome (display has to be at most three dimensional)
%
% INPUT ARGUMENTS:
%     -Data - a matrix containing row data
%     -dimComp - the dimension into which the data will be compressed
%     -RLoc - a vector which contains the second dimension indices of Feat,
%         which belongs to a class
%     -LLoc - a vector which contains the second dimension indices of Feat,
%         which belongs to a class
%     -Font - a structure containing the font size of axes labels, title,
%         sgtitle, legend, ticks and color label

% get the principal component coefficients of Data
DataPCA = pca(Data);
DataPCAcomp = Data*(DataPCA(:,1:dimComp));

% plot three and two dimensional PCA
if dimComp>2
    figure('units', 'centimeters', 'Position', [0 0 16 12]);
    sgtitle('PCA', 'FontSize', Font.sgtitle*2);
    subplot(1,2,1); hold on;
    scatter(DataPCAcomp(RLoc,1), DataPCAcomp(RLoc,2), 'r', 'fill');
    scatter(DataPCAcomp(LLoc,1), DataPCAcomp(LLoc,2), 'b', 'fill');
    title('two dimensional PCA', 'FontSize', Font.title*1.5);
    legend('Right', 'Left', 'FontSize', Font.legend*1.5);
    xlabel('PC1', 'FontSize', Font.axes*1.5);
    ylabel('PC2', 'FontSize', Font.axes*1.5);
    set(gca, 'FontSize', Font.tick*1.5);
    
    subplot(1,2,2); hold on;
    scatter3(DataPCAcomp(RLoc,1), DataPCAcomp(RLoc,2), DataPCAcomp(RLoc,3), 'r', 'fill');
    scatter3(DataPCAcomp(LLoc,1), DataPCAcomp(LLoc,2), DataPCAcomp(LLoc,3), 'b', 'fill');
    title('three dimensional PCA', 'FontSize', Font.title*1.5);
    legend('Right', 'Left', 'FontSize', Font.legend*1.5);
    xlabel('PC1', 'FontSize', Font.axes*1.5);
    ylabel('PC2', 'FontSize', Font.axes*1.5);
    zlabel('PC3', 'FontSize', Font.axes*1.5);
    set(gca, 'FontSize', Font.tick*1.5);
    view(3);
elseif dimComp == 2
    % plot two dimensional PCA
    figure('units', 'centimeters', 'Position', [0 0 16 12]);
    hold on;
    scatter(DataPCAcomp(RLoc,1), DataPCAcomp(RLoc,2), 'r', 'fill');
    scatter(DataPCAcomp(LLoc,1), DataPCAcomp(LLoc,2), 'b', 'fill');
    title('two dimensional PCA', 'FontSize', Font.title*1.5);
    legend('Right', 'Left', 'FontSize', Font.legend*1.5);
    xlabel('PC1', 'FontSize', Font.axes*1.5);
    ylabel('PC2', 'FontSize', Font.axes*1.5);
    set(gca, 'FontSize', Font.tick*1.5);
end
end