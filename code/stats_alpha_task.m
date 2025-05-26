% Run a permutation test comparing the effects of task on aperiodic activity.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
load([pathData,'grandAverageL02vL04_AlphaChange.mat']);
load([pathData,'extras', filesep,'neighbours_GWM.mat']);

% Conditions to compare
comparisons = {'L02','Delay','Base';...
    'L04','Delay','Base';...
    'L06','Delay','Base'};

%% Run analysis

for compi = 1:size(comparisons,1)

    % Setting up our comparisons (e.g. L2 vs L4 etc.)
    D1 = grandAverage.(comparisons{compi,2}).(comparisons{compi,1});
    D2 = grandAverage.(comparisons{compi,3}).(comparisons{compi,1});

    %this is creating the settings for the stats. 2 levels: clustering and
    %permuations.
    cfg = [];
    cfg.channel     = {'all'};
    cfg.minnbchan        = 2; %minimum number of channels for cluster
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.alpha       = 0.05;
    % cfg.avgovertime = 'yes'; %collapsing all time points down into single value. can change this between no and yes depending if you want time included
    cfg.avgoverfreq = 'yes';
    cfg.frequency   = [8 12]; 
    cfg.avgoverchan = 'no'; %can change this between no and yes depending if you want all channels included
    cfg.statistic   = 'depsamplesT';
    cfg.numrandomization = 5000;
    cfg.correctm    = 'cluster';
    cfg.method      = 'montecarlo';
    cfg.tail             = 0; % Two-tailed
    cfg.correcttail = 'prob'; % Correct probability values for two-tailed test
    cfg.clustertail      = 0; % Two-tailed
    cfg.neighbours  = neighbours;
    cfg.parameter   = 'powspctrm';

    subj = size(D1.powspctrm,1); %enter number of participants

    %design for within subject test
    design = zeros(2,2*subj);
    for i = 1:subj
        design(1,i) = i;
    end
    for i = 1:subj
        design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;

    cfg.design = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;

    %define variables for comparison
    seedDetails = rng('default');
    [stat] = ft_freqstatistics(cfg, D1, D2);

    % Calculate the effect size
    if size(stat.posclusters,2) > 0
        if stat.posclusters(1).prob < 0.05
            chanN = stat.posclusterslabelmat == 1;

            cfg = [];
            cfg.channel     = {stat.label{chanN}};
            cfg.avgoverchan = 'yes';
            cfg.avgoverfreq = 'yes';
            cfg.frequency   = [8 12]; 
            cfg.method = 'analytic';
            cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD

            cfg.design = design;
            cfg.uvar  = 1;
            cfg.ivar  = 2;

            effect_avg = ft_freqstatistics(cfg, D1, D2);
            cohensdPos = effect_avg.cohensd;
        else
            cohensdPos = NaN;
        end
    else
        cohensdPos = NaN;
    end
    
    if size(stat.negclusters,2) > 0
        if stat.negclusters(1).prob < 0.05
            chanN = stat.negclusterslabelmat == 1;

            cfg = [];
            cfg.channel     = {stat.label{chanN}};
            cfg.avgoverchan = 'yes';
            cfg.avgoverfreq = 'yes';
            cfg.frequency   = [8 12];
            cfg.method = 'analytic';
            cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD

            cfg.design = design;
            cfg.uvar  = 1;
            cfg.ivar  = 2;

            effect_avg = ft_freqstatistics(cfg, D1, D2);
            cohensdNeg = effect_avg.cohensd;
        else
            cohensdNeg = NaN;
        end
    else
        cohensdNeg = NaN;
    end

    % Save the output
    saveName = ['alpha_',comparisons{compi,1},'_',comparisons{compi,2},'_',comparisons{compi,3}];
    save([pathStats,saveName,'.mat'],'stat','seedDetails','cohensdPos','cohensdNeg');

end

%% Read out the results
clc;

for compi = 1:size(comparisons,1)
    
    % Load the results
    loadName = ['alpha_',comparisons{compi,1},'_',comparisons{compi,2},'_',comparisons{compi,3}];
    load([pathStats,loadName,'.mat']);
    
    % Positive cluster
    if size(stat.posclusters,2) > 0
        input1 = stat.posclusters(1).prob;
    else
        input1 = 1;
    end
    input2 = cohensdPos;

    % Negative cluster
    if size(stat.negclusters,2) > 0
        input3 = stat.negclusters(1).prob;
    else
        input3 = 1;
    end
    input4 = cohensdNeg;

    formatSpec = '%s %s vs %s: pos. p = %.3f, pos. cd = %.2f, neg. p = %.3f, neg. cd = %.2f\n';
    fprintf(formatSpec,comparisons{compi,1},comparisons{compi,2}, comparisons{compi,3}, input1,input2,input3,input4);
end