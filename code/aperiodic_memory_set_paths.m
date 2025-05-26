% Sets the correct paths. Run at the start before running the other scripts
%
% Author: Nigel Rogasch

% Path to the folders downloaded from github (modify as required)
pathIn = 'G:\My Drive\Science\Projects\projects\2025_Aperiodic activity and working memory\final\';

% Create the required paths for the folders
pathData = [pathIn,'data\'];
pathFigures = [pathIn,'figures\'];
pathCode = [pathIn,'code\'];
pathStats = [pathIn,'stats\'];

% Add the paths
addpath(pathIn);
addpath(pathData);
addpath(pathFigures);
addpath(pathCode);
addpath(pathStats);

% Set the path to BrewerMap
addpath([pathCode,'BrewerMap-3.2.5']);

% Set the path to RainCloudPlots
addpath([pathCode,'RainCloudPlots-1.1\tutorial_matlab']);

% Set the path to Fieldtrip
addpath([pathCode,'fieldtrip-20250114']);
ft_defaults;

% Save the paths texts for use in scripts
save([pathData,'pathInfo.mat'], 'pathIn','pathData','pathFigures','pathCode','pathStats');