% Run a repeated measures ANOVA testing the effect of load on working
% memory capacity and precision.
%
% Author: Nigel Rogasch

%%
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
load([pathData,'colourWheelStandardMixture.mat']);

%% Perform Shapiro-Wilk test of normality, Mauchly test of sphericity and RMANOVA for WM capacity

% Define the data
compName = 'wmCapacity';
input = wmCapacity;

% Shapiro-Wilk test
for i = 1:size(input,2)
    [~,sw.(compName)(1,i)] = swtest(input(:,i));
end

% Reorganise data
data.(compName) = array2table(input, 'VariableNames', {'Load2', 'Load4', 'Load6'});

% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'Loads'});

% Fit the repeated measures model
rmModel.(compName) = fitrm(data.(compName), 'Load2-Load6~1', 'WithinDesign', withinDesign);

% Mauchly test for sphericity
mauchlyOutput.(compName) = mauchly(rmModel.(compName));

% Perform RMANOVA for WM capacity
ranovatbl.(compName) = ranova(rmModel.(compName));

% Perform post hoc tests (t-test)
% Load 2 vs load 4
compName = 'wmCapacity2v4';
x1 = wmCapacity(:,1);
x2 = wmCapacity(:,2);

[~,p.(compName),ci.(compName),stat.(compName)] = ttest(x1,x2);
pBonf.(compName) = p.(compName)*3;
mean_x1  = nanmean(x1);
mean_x2  = nanmean(x2);
meanDiff.(compName) = (mean_x1 - mean_x2);
deltas   = x1 - x2;         % differences
sdDeltas = nanstd(deltas);  % standard deviation of the diffferences
d.(compName) =  meanDiff.(compName) / sdDeltas;   % Cohen's d (paired version)

% Load 4 vs load 6
compName = 'wmCapacity4v6';
x1 = wmCapacity(:,2);
x2 = wmCapacity(:,3);

[~,p.(compName),ci.(compName),stat.(compName)] = ttest(x1,x2);
pBonf.(compName) = p.(compName)*3;
mean_x1  = nanmean(x1);
mean_x2  = nanmean(x2);
meanDiff.(compName) = (mean_x1 - mean_x2);
deltas   = x1 - x2;         % differences
sdDeltas = nanstd(deltas);  % standard deviation of the diffferences
d.(compName) =  meanDiff.(compName) / sdDeltas;   % Cohen's d (paired version)

%%

% Define the data
compName = 'precision';
input = precision;

% Shapiro-Wilk test
for i = 1:size(input,2)
    [~,sw.(compName)(1,i)] = swtest(input(:,i));
end

% Reorganise data
data.(compName) = array2table(input, 'VariableNames', {'Load2', 'Load4', 'Load6'});

% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'Loads'});

% Fit the repeated measures model
rmModel.(compName) = fitrm(data.(compName), 'Load2-Load6~1', 'WithinDesign', withinDesign);

% Mauchly test for sphericity
mauchlyOutput.(compName) = mauchly(rmModel.(compName));

% Perform RMANOVA for WM capacity
ranovatbl.(compName) = ranova(rmModel.(compName));

% Perform post hoc tests (t-test)
% Load 2 vs load 4
compName = 'precision2v4';
x1 = precision(:,1);
x2 = precision(:,2);

[~,p.(compName),ci.(compName),stat.(compName)] = ttest(x1,x2);
pBonf.(compName) = p.(compName)*3;
mean_x1  = nanmean(x1);
mean_x2  = nanmean(x2);
meanDiff.(compName) = (mean_x1 - mean_x2);
deltas   = x1 - x2;         % differences
sdDeltas = nanstd(deltas);  % standard deviation of the diffferences
d.(compName) =  meanDiff.(compName) / sdDeltas;   % Cohen's d (paired version)

% Load 4 vs load 6
compName = 'precision4v6';
x1 = precision(:,2);
x2 = precision(:,3);

[~,p.(compName),ci.(compName),stat.(compName)] = ttest(x1,x2);
pBonf.(compName) = p.(compName)*3;
mean_x1  = nanmean(x1);
mean_x2  = nanmean(x2);
meanDiff.(compName) = (mean_x1 - mean_x2);
deltas   = x1 - x2;         % differences
sdDeltas = nanstd(deltas);  % standard deviation of the diffferences
d.(compName) =  meanDiff.(compName) / sdDeltas;   % Cohen's d (paired version)