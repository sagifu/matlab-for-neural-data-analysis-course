function display_stimuli(n_symbols, target, conj, correct_ans)

% Choose a random color
a = rand();
if a < 0.5
    colorT = 'r';
else
    colorT = 'b';
end
% know what is the correct answer and what isn't
if strcmpi(correct_ans, 'O')
    distract = 'X';
else
    distract = 'O';
end
% arbitrary number representing the screen segments
N = 50;
% create random locations, without replacement
locations = [randperm(N ,n_symbols)/N; randperm(N ,n_symbols)/N]';
% create stimuli cell array and fill it with the incorrect answer stimuli
X_vec = cell(1,n_symbols);
X_vec(:) = cellstr(distract);

% display stimuli section
% different for conjunction-feature, target-no target
if ~conj            % in feature mode
    if target       % if there is a target, create one correct answer and display
        X_vec(randi(length(X_vec))) = cellstr(correct_ans);
        g = text (locations(:,1), locations(:,2),X_vec, 'color', colorT, 'FontSize', 18);
        axis off;
    else            % otherwise, just display
        g = text (locations(:,1), locations(:,2),X_vec, 'color', colorT, 'FontSize', 18);
        axis off;
    end
else                % in conjunction mode
    if strcmpi(colorT, 'b') % dicide which color to be assigned to which shape
        colorNT = 'r';
    else
        colorNT = 'b';
    end
    % create a vector of locations for half the answers, will contain the
    % correct answer
    correctLoc = zeros(1,n_symbols);
    correctLoc(randperm(n_symbols,n_symbols/2)) = 1;
    
    X_vec(correctLoc == 1) = cellstr(correct_ans);
    
    if target   
        % if there is a target, choose a random location out of the correct
        % answer locations, display it so it is conjunction, other
        % character will stay ordinary
        tempLocation = find(correctLoc==1);
        conjLocation = tempLocation(randi(length(tempLocation)));
        correctLoc(conjLocation) = 2;
        g = text (locations(correctLoc == 0,1), locations(correctLoc == 0,2),X_vec(correctLoc == 0), 'color', colorT, 'FontSize', 18);
        hold on;
        g = text (locations(correctLoc == 1,1), locations(correctLoc == 1,2),X_vec(correctLoc == 1), 'color', colorNT, 'FontSize', 18);
        g = text (locations(correctLoc == 2,1), locations(correctLoc == 2,2),X_vec(correctLoc == 2), 'color', colorT, 'FontSize', 18);
        axis off;
    else
        % otherwise, display each stimuli shape in its color
        g = text (locations(correctLoc == 1,1), locations(correctLoc == 1,2),X_vec(correctLoc == 1), 'color', colorNT, 'FontSize', 18);
        hold on;
        g = text (locations(correctLoc == 0,1), locations(correctLoc == 0,2),X_vec(correctLoc == 0), 'color', colorT, 'FontSize', 18);
        axis off;
        hold off;
    end
end
end

