clear; clc; close all;

%% Loading data
load('SpikesX10U12D');

%% Setting dimensions lengths
len_i = length(SpikesX10U12D(:,1,1));   % set the length of the first dimension (units)
len_j = length(SpikesX10U12D(1,:,1));   % set the length of the second dimension (direction)
len_k = length(SpikesX10U12D(1,1,:));   % set the length of the third dimension (repitition)

%% Setting bin and trial time
bin_length = 0.02;      % set bin duration
trial_length = 1.28;    % set trial length

t_bin = [0:bin_length:trial_length]';   % set bin vector
len_b = length(t_bin)-1;                % set the length of the aforementioned vector

%% Creating arraies 

% 4-D array [unit, direction, repitition, bin]
t_SpikeS_arr = zeros(len_i,len_j,len_k,len_b);

% PSTH array and random display unit
random_unit = randi(10);
t_PSTH_vec = zeros(len_j,len_b);

% Direction/orientation assisstant arraies
for_calc = zeros(1,len_k);                      % a vector for future calculations for direction/orientation selectivity
m_firing_rate = zeros(len_i, len_j);            % an array to save the mean of spikes for each unit and direction for direction/orientation selectivity
sd_firing_rate = zeros(len_i, len_j);           % an array to save the std of spikes for each unit and direction for direction/orientation selectivity


  % CALCULATION LOOPS
  
for i = 1:len_i         % for each unit
    for j = 1:len_j     % for each direction
        for k = 1:len_k % for each repitition
            
                % Create 4-D array
            t_vec = SpikesX10U12D(i,j,k).TimeList;
            t_SpikeS_arr(i,j,k,:) = histcounts(t_vec, t_bin);   % count spikes per bins per repitition
            
            
                % Direction/orientation side calculation
            for_calc(1,k) = length(t_vec);          % remember the number of spikes in each repitition in order to calculate mean and std of spikes
        end             % end repititions
        m_firing_rate(i,j) = mean(for_calc);        % calculate mean of spikes in unit i, direction j
        sd_firing_rate(i,j) = std(for_calc);        % calculate std of spikes in unit i, direction j
        
            % PSTH - bin calculation across repititions
        if i == random_unit
            t_PSTH_vec(j,:) = sum(t_SpikeS_arr(random_unit,j,:,:));
        end
        
    end                 % end direction
end                     % end unit


%% Plotting

t_PSTH_vec = t_PSTH_vec/(len_k*bin_length);  % divide by bin length and number of repititions in order to create the mean rate per second
PSTH_max = max(max(t_PSTH_vec));             % find the single max value within the whole array
dtheta = 360/len_j;                          % "gap" variable - the angle size between two sequential directions

figure ('Units', 'centimeters', 'Position', [0 0 25 15]); hold on;
for a = 1:len_j
    
    subplot(2,len_j/2,a); hold on; % create subplot on the main figure
    
    % plot the data
    bar(t_PSTH_vec(a,:), 'histc');
    
    % add descriptions
    xlim([0 length(t_PSTH_vec(1,:))]);
    ylim([0 PSTH_max+5]);
    
    x_ticks = 0:0.5/bin_length:len_b;       % ticks steps in half seconds
    xticks(x_ticks);
    xticklabels(x_ticks/(1/bin_length));    % divide so the labels will appear in seconds
    
    if a > len_j/2
        xlabel('time[Sec]', 'FontSize', 14);      % appear at the 2nd row
    end
    
    if a == 1 || a == len_j/2+1
        ylabel('rate[Hz]', 'FontSize', 14);       % appear at the first subplot of each row
    end
    
    title(['\theta = ', num2str(dtheta*(a-1)), char(176)], 'FontSize', 14);
    sgtitle(['Unit #', num2str(random_unit), ' - PSTH per direction'], 'FontSize', 16);
end


%% Direction/orientation selectivity

m_firing_rate = m_firing_rate/trial_length; % divide so it will be actually mean and not sum

% set degree/radian vectors
deg_for_fit = 0:dtheta:dtheta*(len_j-1);            % experimental degree vector
rad_for_fit = deg2rad(deg_for_fit);                 % experimental radian vector
deg_for_plot = 0:0.01:360;                          % detailed degree vector
rad_for_plot = deg2rad(deg_for_plot);               % detailed radian vector


%% Set fit functions 

% direction selective:
VM_drct =  fittype('A * exp (k * cos (x - PO))',...
    'coefficients', {'A', 'k', 'PO'},...
    'independent', 'x');

fitOD = fitoptions(VM_drct);
fitOD.Lower = [0    , 0,    -pi];
fitOD.Upper = [inf  , inf,   pi];

% orientation selective:
VM_ornt =  fittype('A * exp (k * cos (2*(x - PO)))',...
    'coefficients', {'A', 'k', 'PO'},...
    'independent', 'x');

fitOO = fitoptions(VM_ornt);
fitOO.Lower = [0    , 0,    -pi];
fitOO.Upper = [inf  , inf,   pi];
% A, k & PO are fitted for independent variable x


%% Plotting

figure ('Units', 'centimeters', 'Position', [0 0 25 15]); hold on;
for i = 1:len_i
    
    % set best start point 
    A_start = max(m_firing_rate(i,:));                              % amplitude maximum height
    k_start = 1/var(m_firing_rate(i,:));                            % 1 divided by firing rate variance
    PO_start = (find(max(m_firing_rate(i,:)))-1)*deg2rad(dtheta);   % the angle in which the neuron fires the most
    
    fitOD.Startpoint = [A_start,  k_start,   PO_start];
    fitOO.Startpoint = [A_start,  k_start,   PO_start];
    
    % fit both direction and orientationn
    [fitResult_ornt, GoF_ornt] = fit(rad_for_fit', m_firing_rate(i,:)', VM_ornt, fitOO);
    [fitResult_drct, GoF_drct] = fit(rad_for_fit', m_firing_rate(i,:)', VM_drct, fitOD);
    
    subplot (2,len_i/2, i); hold on; % create subplot on the main figure
    % plot the data
    errorbar (deg_for_fit, m_firing_rate(i,:), sd_firing_rate(i,:), 'o');
    % plot the best fitted curve
    if GoF_drct.rmse < GoF_ornt.rmse
        plot(deg_for_plot, fitResult_drct(rad_for_plot), 'r');
    else
        plot(deg_for_plot, fitResult_ornt(rad_for_plot), 'r');
    end
    
    % Add descriptions
    
    xlim([0, deg_for_plot(end)]);
    ylim([min(m_firing_rate(i,:))-max(sd_firing_rate(i,:)), max(sd_firing_rate(i,:))+max(m_firing_rate(i,:))]);
    
    x_ticks = 0:dtheta*3:deg_for_plot(end);
    xticks(x_ticks);
    xticklabels(x_ticks);
    
    if i > len_i/2
        xlabel('direction[deg]', 'FontSize', 14);
    end
    
    if i == len_i/2
        ylim([min(m_firing_rate(i,:))-max(sd_firing_rate(i,:)), max(sd_firing_rate(i,:))*2+max(m_firing_rate(i,:))]);
        legend({'raw data', 'fitted function'}, 'Location','NorthEast');     % add legend to the right-upper subplot
    end
    
    if i == 1 || i == len_i/2+1
        ylabel('rate[Hz]', 'FontSize', 14);                             % appear at the first subplot of each row
    end
    
    title(['Unit #', num2str(i)], 'FontSize', 14);
    sgtitle('Direction/orientation selectivity - von Mises fit per unit', 'FontSize', 16);
end