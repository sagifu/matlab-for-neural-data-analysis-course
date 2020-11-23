clear; close all; clc;

% create figure which will appear as long as the experiment is occurring
h = figure('units','normalized', 'Position', [0 0 1 1]);
h.Name = 'Visual Search Experiment';
h.NumberTitle = 'off';
h.ToolBar = 'none';
h.MenuBar = 'none';
h.Color = 'w';
axis off;

% set boolean variables
run = 1;
trialBool = 0;
stopExp = 0;
run_mode = 1;

while run   % experiment big loop
    % for now, we hope the experiment will run only once
    run = 0;
    % set parameters
    nTrials = 30;
    minSize = 4;
    stepSize = 4;
    maxSize = 16;
    tempSymbols = minSize:stepSize:maxSize;
    tempConj = [0 1];
    % to make sure each set size will appear once in each search type,
    % we combine the sizes vector with search type into a balanced 2-dimension matrix
    [A B] = meshgrid(tempSymbols, tempConj);
    temp = reshape(cat(2,A',B'),[],2);
    % then randomize their order.
    randLocation = randperm(length(temp));
    RandomBlocks = temp(randLocation, :);
    % save them on seperate variables for comfort
    Nsymbols = RandomBlocks(:,1);
    isConj = RandomBlocks(:,2);
    % count the number of conditions
    nCondition = length(RandomBlocks(:,1));
    % and number of total trials
    totalTrials = nCondition*nTrials;
    
    % create targets' existance vector - later on will be shuffled
    isTarget = zeros(1,nTrials);
    isTarget(1:nTrials/2) = 1;
    % create/empty the data structure
    ExperimentData = struct();
    
    %% Set auto run RT matrices
    
    % Creating gaussian mixed distribution for each of the four conditions
    %       with four values each, representing four set sizes
    % Then, numbers equal to half of the trials, were taken randomly
    %       from the "Response" distribution so that the automated run will
    %       have "Realistic" response time.
    if run_mode
        gm = gmdistribution([0.6 0.6 0.6 0.6], [0.1 0.1 0.1 0.1]);
        AutoFTar = random(gm, nTrials/2);
        gm = gmdistribution([0.6 0.7 0.7 0.8], [0.1 0.1 0.1 0.1]);
        AutoFnoTar = random(gm, nTrials/2);
        gm = gmdistribution([1.0 1.4 1.7 2], [0.1 0.1 0.2 0.2]);
        AutoCTar = random(gm, nTrials/2);
        gm = gmdistribution([1.0 1.5 1.9 2.3], [0.1 0.1 0.2 0.2]);
        AutoCnoTar = random(gm, nTrials/2);
    end
    
    
    
    %% Greetings and instructions message
    
    g = text(0.5, 0.5, {'Greetings dear friend!'; ...
        'Thank you for participating in this experiment.'; ...
        ' '; ...
        'In the following experiment you will need to identify a unique character, under two conditions:'; ...
        "FEATURE - you will be instructed to find a single character (either an O or a X)"; ...
        'such that all shapes are with the same changing color.'; ...
        "CONJUNCTION - you will be instructed to find a combination of shape and color (e.g., a blue X)."; ...
        'Keep in mind!'; ...
        'The color will not be instructed, it keeps changing. Only the shape will be announced, it stays constant.'; ...
        ' '; ...
        "What will you need to do if you find the desired character?"; ...
        "That's easy, you should press the 'A' button"; ...
        "Otherwise, press the 'L' button"; ...
        'We ask you to response as accurate and as fast as possible'; ...
        ' '; ...
        'When you are ready to start the experiment, press spacebar'});
    g.FontSize = 18;
    g.HorizontalAlignment = 'center';
    axis off;
    if run_mode
        pause(10);
        key = ' ';
    else
        pause();
        key = h.CurrentCharacter;
    end
    % wait for an adequate response
    while strcmpi(key, ' ') == 0
        pause();
        key = h.CurrentCharacter;
    end
    clf; % clear figure
    
    %% Experiment blocks
    
    for type = 1:nCondition
        % shuffle targets' existance order
        isTarget = isTarget(randperm(length(isTarget)));
        % clear temporary data for this block usage
        tempData = [];
        % choose target shape randomly
        b = rand();
        if b < 0.5
            correct_ans = 'X';
        else
            correct_ans = 'O';
        end
        % present the participant with the relevant stimulus shape
        % and whether it is a feature or conjunction
        if isConj(type) == 0
            g = text(0.5, 0.5, {'In this block, you need to search for'; ...
                ['the character - ' (correct_ans)]; ...
                'Press spacebar in order to start this block'});
            g.FontSize = 20;
            g.HorizontalAlignment = 'center';
        else
            g = text(0.5, 0.5, {'In this block, you need to search for'; ...
                ['a unique character - ' (correct_ans)]; ...
                'Press spacebar in order to start this block'});
            g.FontSize = 20;
            g.HorizontalAlignment = 'center';
        end
        axis off;
        if run_mode
            pause(2);
            key = ' ';
        else
            pause();
            key = h.CurrentCharacter;
        end
        % wait for an adequate response
        while strcmpi(key, ' ') == 0
            pause();
            key = h.CurrentCharacter;
        end
        clf;
        %% Blocks' trials
        if run_mode
            FNT = randperm(nTrials/2);
            FNTcount = 1;
            FT = randperm(nTrials/2);
            FTcount = 1;
            CNT = randperm(nTrials/2);
            CNTcount = 1;
            CT = randperm(nTrials/2);
            CTcount = 1;
        end
        for a = 1:nTrials
            tic;    % start counting response time
            % display current stimuli
            display_stimuli(Nsymbols(type), isTarget(a), isConj(type),correct_ans)
            if run_mode
                randAns = rand();
                if isConj(type)
                    if isTarget(a)
                        pause(AutoCTar(CT(CTcount),Nsymbols(type)/stepSize));
                        CTcount = CTcount +1;
                        if randAns > 0.05
                            key = 'a';
                        else
                            key = 'l';
                        end
                    else
                        pause(AutoCnoTar(CNT(CNTcount),Nsymbols(type)/stepSize));
                        CNTcount = CNTcount +1;
                        if randAns > 0.05
                            key = 'l';
                        else
                            key = 'a';
                        end
                    end
                else
                    if isTarget(a)
                        pause(AutoFTar(FT(FTcount),Nsymbols(type)/stepSize));
                        FTcount = FTcount +1;
                        if randAns > 0.05
                            key = 'a';
                        else
                            key = 'l';
                        end
                    else
                        pause(AutoFnoTar(FNT(FNTcount),Nsymbols(type)/stepSize));
                        FNTcount = FNTcount +1;
                        if randAns > 0.05
                            key = 'l';
                        else
                            key = 'a';
                        end
                    end
                end
            else
                pause();
                key = h.CurrentCharacter;
            end
            % wait for an adequate response
            while strcmpi(key, 'a') == 0 && strcmpi(key, 'l') == 0
                pause();
                key = h.CurrentCharacter;
            end
            RT = toc;   % stop counting response time
            % check if the answer is correct
            if isTarget(a) == 1
                acc = strcmpi(key, 'a');
            else
                acc = strcmpi(key, 'l');
            end
            % temporarily saves the variables
            tempData = [tempData ; RT, acc];
            clf; % clear figure
        end
        if sum(tempData(:,2)) < 20    % if doesn't have enough data
            trialBool = 1;            % stop the experiment and start over
            break;
        end
        % save data in a structure called ExperimentData
        % with blocks' numbers as sub-structures
        ExperimentData.(sprintf('Block%d',type)).setSize = Nsymbols(type);
        ExperimentData.(sprintf('Block%d',type)).targetOrder = isTarget;
        ExperimentData.(sprintf('Block%d',type)).isConjunction = isConj(type);
        ExperimentData.(sprintf('Block%d',type)).RT = tempData(:,1);
        ExperimentData.(sprintf('Block%d',type)).accuracy = tempData(:,2);
    end
    %% End experiment
    
    save ('Raw Data.mat', 'ExperimentData');
    %save('all_data.mat');
    
    %% Data exclusion
    
    for n = 1:nCondition
        
        % doesn't preprocess if not enough data
        if trialBool
            break;
        end
        
        % filter out data of wrong answers
        helpVec = find(ExperimentData.(sprintf('Block%d',n)).accuracy == 0);
        ExperimentData.(sprintf('Block%d',n)).accuracy(helpVec) = [];
        ExperimentData.(sprintf('Block%d',n)).RT(helpVec) = [];
        ExperimentData.(sprintf('Block%d',n)).targetOrder(helpVec) = [];
        
        % filter out data of too long of reaction time
        helpVec = find(ExperimentData.(sprintf('Block%d',n)).RT > 3);
        ExperimentData.(sprintf('Block%d',n)).accuracy(helpVec) = [];
        ExperimentData.(sprintf('Block%d',n)).RT(helpVec) = [];
        ExperimentData.(sprintf('Block%d',n)).targetOrder(helpVec) = [];
        
        if length(ExperimentData.(sprintf('Block%d',n)).accuracy) < 20
            trialBool = 1;
            break;
        end
        
        % split data into two halves by first indicator: Feature or
        % Conjunction
        if isConj(n) == 0
            Feature.(sprintf('Block%d',n)) = ExperimentData.(sprintf('Block%d',n));
            
            % now split this data into two halves by second indicator:
            % Target or no-Target
            helpVec = find(Feature.(sprintf('Block%d',n)).targetOrder == 0);
            Feature.(sprintf('Block%d',n)).NoTarget = Feature.(sprintf('Block%d',n)).RT(helpVec);
            helpVec = find(Feature.(sprintf('Block%d',n)).targetOrder == 1);
            Feature.(sprintf('Block%d',n)).Target = Feature.(sprintf('Block%d',n)).RT(helpVec);
            
            % in arraies, calculate mean response time and std of each
            % block. Simultaniously, sort them by their set size.
            FmeanRTnoTar(Feature.(sprintf('Block%d',n)).setSize/stepSize) = mean(Feature.(sprintf('Block%d',n)).NoTarget);
            FstdRTnoTar(Feature.(sprintf('Block%d',n)).setSize/stepSize) = std(Feature.(sprintf('Block%d',n)).NoTarget);
            
            FmeanRTTar(Feature.(sprintf('Block%d',n)).setSize/stepSize) = mean(Feature.(sprintf('Block%d',n)).Target);
            FstdRTTar(Feature.(sprintf('Block%d',n)).setSize/stepSize) = std(Feature.(sprintf('Block%d',n)).Target);
        else
            Conjunction.(sprintf('Block%d',n)) = ExperimentData.(sprintf('Block%d',n));
            
            % now split this data into two halves by second indicator:
            % Target or no-Target
            helpVec = find(Conjunction.(sprintf('Block%d',n)).targetOrder == 0);
            Conjunction.(sprintf('Block%d',n)).NoTarget = Conjunction.(sprintf('Block%d',n)).RT(helpVec);
            helpVec = find(Conjunction.(sprintf('Block%d',n)).targetOrder == 1);
            Conjunction.(sprintf('Block%d',n)).Target = Conjunction.(sprintf('Block%d',n)).RT(helpVec);
            
            % in arraies, calculate mean response time and std of each
            % block. Simultaniously, sort them by their set size.
            CmeanRTnoTar(Conjunction.(sprintf('Block%d',n)).setSize/stepSize) = mean(Conjunction.(sprintf('Block%d',n)).NoTarget);
            CstdRTnoTar(Conjunction.(sprintf('Block%d',n)).setSize/stepSize) = std(Conjunction.(sprintf('Block%d',n)).NoTarget);
            
            CmeanRTTar(Conjunction.(sprintf('Block%d',n)).setSize/stepSize) = mean(Conjunction.(sprintf('Block%d',n)).Target);
            CstdRTTar(Conjunction.(sprintf('Block%d',n)).setSize/stepSize) = std(Conjunction.(sprintf('Block%d',n)).Target);
        end
        
    end
    
    %% Run again section
    % if the data isn't sufficient, we ask the participant to start over.
    % he has the choice not to.
    % Automated run will continue the experiment untill sufficient data
    % will be collected
    if trialBool
        g = text(0.5, 0.5, {'Sorry, the experiment was terminated due to insufficient data.'; ...
            'We would ask you to start over'; ...
            'Press spacebar in order to start the experiment from the top,';...
            'otherwise, press the escape button.'});
        g.FontSize = 20;
        g.HorizontalAlignment = 'center';
        axis off;
        
        if run_mode
            pause(4);
            key = ' ';
        else
            pause();
            key = h.CurrentCharacter;
        end
    % wait for an aduqate response
        while strcmpi(key, ' ') == 0 && strcmpi(key, '') == 0 
            pause();
            key = h.CurrentCharacter;
        end
        
        if strcmpi(key, ' ') == 1      % if the participant wants to start over
            run =1;                    % start over
        elseif strcmpi(key, '') == 1  % if the participant wants to quit
            stopExp = 1;               % quit
            break;
        end
        clf;    % clear figure
    end
end
close;

if ~stopExp   
    
    %% Coefficients and slopes
    % using the polyfit function for the input arguments of x axis values 
    % and y axis experimental-values (polynomial order 1), we get back the optimal
    % coefficients of the linear function best fitted to the results.
    % using the polyval function for the input arguments of the
    % aforementioned coefficients and x axis values, we get back the y axis
    % fitted-values 
    coeffFeatTar = polyfit(tempSymbols, FmeanRTTar, 1);
    slopeValFeatTar = polyval(coeffFeatTar, tempSymbols);
    coeffFeatNoTar = polyfit(tempSymbols, FmeanRTnoTar, 1);
    slopeValFeatNoTar = polyval(coeffFeatNoTar, tempSymbols);
    coeffConjTar = polyfit(tempSymbols, CmeanRTTar, 1);
    slopeValConjTar = polyval(coeffConjTar, tempSymbols);
    coeffConjNoTar = polyfit(tempSymbols, CmeanRTnoTar, 1);
    slopeValConjNoTar = polyval(coeffConjNoTar, tempSymbols);
    
    %% Correlation
    % using the function corrcoef with the inputs of x axis values and y
    % axis values, we get back the correlation and p-value for each
    % condition
    [R_FeatTar, P_FeatTar] = corrcoef(tempSymbols, FmeanRTTar);
    [R_FeatNoTar, P_FeatNoTar] = corrcoef(tempSymbols, FmeanRTnoTar);
    [R_ConjTar, P_ConjTar] = corrcoef(tempSymbols, CmeanRTTar);
    [R_ConjNoTar, P_ConjNoTar] = corrcoef(tempSymbols, CmeanRTnoTar);
    
    %% Plotting
    
    h1 = figure('units', 'normalized', 'Position', [0 0 1 0.5]);
    hold on;
    errorbar(tempSymbols, FmeanRTnoTar, FstdRTnoTar, 'r');
    errorbar(tempSymbols, CmeanRTnoTar, CstdRTnoTar, 'b');
    plot(tempSymbols, slopeValFeatNoTar, 'g--');
    plot(tempSymbols, slopeValConjNoTar, 'k--');
    g = text((maxSize-(stepSize/2)), 1.3, {['Con R = ' num2str(R_ConjNoTar(1,2))], ...
                                           ['Con P = ' num2str(P_ConjNoTar(1,2))], ...
                                           ['Feat R = ' num2str(R_FeatNoTar(1,2))], ...
                                           ['Feat P = ' num2str(P_FeatNoTar(1,2))]});
    g.HorizontalAlignment = 'center';
    xticks(tempSymbols);
    xlabel('Set size', 'FontSize', 17);
    ylabel('Response Time [sec]', 'FontSize', 17);
    title('No-target search results', 'FontSize', 18);
    L = legend('Feature-experiment', 'Conjunction-experiment', 'Feature-slope values', 'Conjunction-slope values');
    L.Location = 'NorthWest';
    hold off;
    
    h2 = figure('units', 'normalized', 'Position', [0 0.5 1 0.5]);
    hold on;
    errorbar(tempSymbols, FmeanRTTar, FstdRTTar, 'r');
    errorbar(tempSymbols, CmeanRTTar, CstdRTTar, 'b');
    plot(tempSymbols, slopeValFeatTar, 'g--');
    plot(tempSymbols, slopeValConjTar, 'k--');
    g = text((maxSize-(stepSize/2)), 1.3, {['Con R = ' num2str(R_ConjTar(1,2))], ...
                                           ['Con P = ' num2str(P_ConjTar(1,2))], ...
                                           ['Feat R = ' num2str(R_FeatTar(1,2))], ...
                                           ['Feat P = ' num2str(P_FeatTar(1,2))]});
    g.HorizontalAlignment = 'center';
    xticks(tempSymbols);
    xlabel('Set size', 'FontSize', 17);
    ylabel('Response Time [sec]', 'FontSize', 17);
    title('Target search results', 'FontSize', 18);
    L = legend('Feature-experiment', 'Conjunction-experiment', 'Feature-slope values', 'Conjunction-slope values');
    L.Location = 'NorthWest';
    hold off;
    
end