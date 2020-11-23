function [LNFeat, FeatLabel, FeatIdx] = ...
    labeling(Feat, LNFeat, FeatLabel, FeatIdx, str)
% function labeling recieves data and parameters and computes the amount of
% additional features that were added to each of the classes
%
% INPUT ARGUMENTS:
%     -Feat - a matrix of row features
%     -LNFeat - a scalar indicates the length of the feature matrix before
%         the new features were added
%     -FeatLabel - a structure containing the name of a feature and the
%         number of features it holds
%     -FeatIdx - a scalar indicating the previous number of types of 
%         features
%     -str - a cell array containing strings which will be the labels of
%         the features
%
% OUTPUT ARGUMENTS:
%     -LNFeat - a scalar indicating the length of the feature matrix after
%         the new features were added
%     -FeatLabel - a structure containing the name of a feature and the
%         number of features it holds
%     -FeatIdx - a scalar indicating the updated number of types of 
%         features

% get number of labels
LN = size(str,2);

% get the number of features of each new feature type (HAS TO BE WHOLE!)
temp = (size(Feat,1) - LNFeat)/LN;
if temp ~= round(temp)
    error(['uneven proportions of features and labels.'; ...
        'each label has to have the same amount of features.']);
end

% add the label and amount of features for each feature type
for n = 1:LN
FeatLabel(FeatIdx).name = cellstr(str{n});
FeatLabel(FeatIdx).count = temp;
FeatIdx = FeatIdx + 1;
end

% update the current amount of features
LNFeat = size(Feat,1);

end