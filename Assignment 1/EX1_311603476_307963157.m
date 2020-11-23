%TAC%
% Redundant for loop  -1
% Infecient rate clac -1
% Total -2

clear; clc; %close all;

%% Load datasets

load('S1.mat')
load('S2.mat')

Si = S2;

%% Setting parameters

fs = 10000;
dt = 1/fs;
N = length(Si);
t = dt*(1:N);

%% Deviding data to below/over threshold = -40 mV

SaTH = zeros(1,N);

for i = 1:N
    if Si(i) < -40
        SaTH(i) = 0;
    else
        SaTH(i) = 1;
    end
end
%TAC%redundant for loop, chould be written in 1 line !- 1

%% Creating vectors of APs initial time and ending time

PassTH = diff(SaTH);
[valuesL, L2H] = find(PassTH==1);  
[valuesH, H2L] = find(PassTH==-1);

L2H = L2H + 1;      % meant for correction - the spikes' initial time was reduced by one with the 'diff' function

%% Detecting the specific time and voltage of the peak of the APs

locMaxVal = zeros(1,length(H2L));
LM = zeros(1,length(H2L));

for n = 1:length(H2L)
    AP_Start = L2H(n);
    AP_End = H2L(n);
    [locMaxVal(n), LM(n)] = max(Si(AP_Start:AP_End));
end


%% Clearing data of false APs

forClear = find(locMaxVal<0);

L2H(forClear) = [];
H2L(forClear) = [];
LM(forClear) = [];
locMaxVal(forClear) = [];
%TAC% what is it for ? 

%% Add the AP time of each spike to the initial time of the spike

LM = LM + L2H - 1;      % the time of the beginning of the spike was counted twice

%% Setting parameters for data collection - spikes' rate

batch_size = 3000;             % 1 dt = 100uS, 3000 dt = the length of a pulse cycle
n_batches = N/batch_size;      % number of batches
SC = zeros(1,n_batches);       % a spike counter vector
batch_start = 1;
batch_end = 3000;

forTextX = zeros(1,n_batches);  % for plotting purposes

%% Collecting spikes' count

for a = 1:n_batches
    for n = 1:length(LM)
        if LM(n)>batch_start && LM(n)<batch_end % if a spike's time is within iteration 'a'
            SC(a) = SC(a) + 1;                  % add count for the spike
        end
    end
    forTextX(a) = batch_start + (batch_size / 3); % for plotting purposes
    batch_start = batch_start + batch_size;     % update batch time
    batch_end = batch_end + batch_size;
end
%TAC% Infecient coding, can be easly done with one loop over segments -1

R = SC/0.2;                % calculating rate per second - SC's rate is per 200mS
%TAC% - 0.2 is magic number ! 
%% Creating display vectors of the APs initial time, ending time and peak time values
%  at 't' (time vector) length
L2HP = nan(1,N);
L2HP(L2H) = Si(L2H);
H2LP = nan(1,N);
H2LP(H2L) = Si(H2L);
LMP = nan(1,N);
LMP(LM) = Si(LM);

%% Plot

forTextX = forTextX/fs;   % adjusting the "time" - x axis

forTextY = zeros(1,length(forTextX)) + max(locMaxVal) + 5;

% converting int data into string data
RPM = {1,length(R)};
for n = 1:length(R)
    RPM{n} = num2str(R(n));
end

figure; %TAC% elegant conding requries using figure func before any new figure -0
plot(t,Si); xlabel('Time[sec]');ylabel('Voltage[mV]');
hold on
scatter(t,L2HP-1,'r');          % Points moved to create difference
scatter(t,H2LP+1,'k');          % Points moved to create difference
scatter(t,LMP,'b');
text(forTextX,forTextY,RPM);
hold off
