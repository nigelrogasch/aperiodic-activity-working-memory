% Run a multiple linear regression analyses between exponent, alpha suppression,
% and ERPs with working memory capacity extracting the channels from
% significant clusters.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

%% Load capacity data
load([pathData,'colourWheelStandardMixture.mat']);
Behav_data = mean(wmCapacity(:,2:3),2);

%% Load slope data
load([pathData,'grandAverageL02vL04_Slope.mat']);

% Comparisons
loadIn = 'L04Abschange'; % Positive correlation
parameter = 'slope';

% Load stats
loadName = ['correlation_capacity_',parameter,'_',loadIn];
load([pathStats,loadName,'.mat']);

% Extract the data
EEG_data = grandAverage.(loadIn).(parameter);
slopeMean = mean(EEG_data.individual(:,stat.mask),2);

% Save the outlier
outliers.slope = removei;

%% Load alpha suppression data
load([pathData,'grandAverageL02vL04_AlphaChange.mat']);

% Comparisons
loadIn = 'L02vL04n06change'; % Negative correlation

% Load stats
loadName = ['correlation_alpha_capacity_',loadIn];
load([pathStats,loadName,'.mat']);

% Extract the data
EEG_data = grandAverage.(loadIn);
f1 = 8;
f2 = 12;
[~,i1] = min(abs(f1-EEG_data.freq));
[~,i2] = min(abs(f2-EEG_data.freq));
alphaData = mean(EEG_data.powspctrm(:,:,i1:i2),3);
alphaMean = mean(alphaData(:,stat.mask),2);

% Save the outlier
outliers.alpha = removei;

%% Load ERP data
load([pathData,'grandAverageL02vL04_SWN.mat']);

% Comparisons
loadIn = 'L02vL04n06'; % Negative correlation

% Load stats
loadName = ['correlation_erp_capacity_',loadIn];
load([pathStats,loadName,'.mat']);

% Extract the data
EEG_data = grandAverage.(loadIn);
f1 = 0.65;
f2 = 1.45;
[~,i1] = min(abs(f1-EEG_data.time));
[~,i2] = min(abs(f2-EEG_data.time));
erpData = mean(EEG_data.individual(:,:,i1:i2),3);
erpMean = mean(erpData(:,logical(stat.negclusterslabelmat)),2);

% Save the outlier
outliers.erp = removei;

%% Remove outliers
outliersAll = [outliers.slope;outliers.alpha;outliers.erp];
outliersUnique = unique(outliersAll);

% Remove data
Behav_data(outliersUnique) = [];
slopeMean(outliersUnique) = [];
alphaMean(outliersUnique) = [];
erpMean(outliersUnique) = [];

% Combine data
allData(:,1) = slopeMean;
allData(:,2) = alphaMean;
allData(:,3) = erpMean;

%% Run stats

% Correlation check
[r1,p1] = corr(Behav_data,allData);

% Correlations with each variable
[r2,p2] = corr(allData);

% Multiple linear regression
result  = regstats(Behav_data,allData,'linear');

% Save the output
saveName = 'regression_capacity_cluster';
save([pathStats,saveName,'.mat'],'result');

