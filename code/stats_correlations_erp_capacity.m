% Permutation statistics correlating slow-wave ERP with working memory
% capacity
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
load([pathData,'grandAverageL02vL04_SWN.mat']);
load([pathData,'colourWheelStandardMixture.mat']);
load([pathData,'extras', filesep,'neighbours_GWM.mat']);

% Conditions to compare
comparisons = {'L02vL04n06'};

%% Run analysis

for compi = 1:size(comparisons,1)

    % Setting up our comparisons (e.g. EEG_data vs Behav_data etc.)
    EEG_data = grandAverage.(comparisons{compi,1});

    % Get the appropriate behavioural data
    if strcmp(comparisons{compi,1},'L02')
        Behav_data = wmCapacity(:,1)';
    elseif strcmp(comparisons{compi,1},'L04')
        Behav_data = wmCapacity(:,2)';
    elseif strcmp(comparisons{compi,1},'L06')
        Behav_data = wmCapacity(:,3)';
    elseif strcmp(comparisons{compi,1},'L02vL04n06')
        Behav_data = mean(wmCapacity(:,2:3),2)';
    end

    % Check for outliers. Remove participant if more than 4 electrodes have
    % a z-score > 3
    outlier = [];
    outlierAll = [];
    for ex=1:length(EEG_data.label)
        f1 = 0.65;
        f2 = 1.45;
        [~,i1] = min(abs(f1-EEG_data.time));
        [~,i2] = min(abs(f2-EEG_data.time));
        dataInput = mean(EEG_data.individual(:,:,i1:i2),3);
        sd=zscore(dataInput(:,ex));
        outlier{ex}=find(sd>3|sd<-3);
        outlierAll = [outlierAll,outlier{ex}'];
    end

    % Count the outliers per participant
    [outlierSum, outlierUnique] = groupcounts(outlierAll');

    % Remove participants
    removei = outlierUnique(outlierSum > 3);

    if ~isempty(removei)
        EEG_data.individual(removei,:,:) = [];
        Behav_data(:,removei) = [];
    end
    
    nParticipants = length(Behav_data);

    %this is creating the settings for the stats. 2 levels: clustering and
    %permuations.
    cfg = [];
    cfg.avgovertime = 'yes';
    cfg.latency     = [.65,1.45];
    cfg.avgoverchan = 'no'; %can change this between no and yes depending if you want all channels included
    cfg.channel = {'all'};
    cfg.method = 'montecarlo';
    cfg.statistic = 'ft_statfun_correlationT'; %'ft_statfun_correlationT';
    cfg.correctm = 'cluster'; % is influecing the p-values. 'holm' is closest to result from [r1,p1] = corr(wm_load(:,2),offsetAll);
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.clustertail = 0;
    cfg.minnbchan = 2;
    cfg.neighbours = neighbours;
    cfg.alpha = 0.05;
    cfg.tail = 0; %
    cfg.correcttail = 'prob';
    cfg.numrandomization = 5000;

    % Design
    design = [];
    subj = size(Behav_data,2); % ## length(ID);
    design(1,1:subj) = Behav_data(1,:); %load 2: 1 row; load 4: 2 row; load 6: 3 row
    cfg.design = design; % design matrix.
    cfg.ivar  = 1;  % number or list with indices indicating the independent variable(s)

    % Run the statistics
    seedDetails = rng('default');
    stat = ft_timelockstatistics(cfg, EEG_data); % If data is time-amplitude change it to ft_timelockstatistics

    % Calculate the effect size (mean rho)
    if isfield(stat,'posclusters')
        if size(stat.posclusters,2) > 0
            if stat.posclusters(1).prob < 0.05
                chanN = stat.posclusterslabelmat == 1;
                cohensdPos = mean(stat.rho(chanN));
            else
                cohensdPos = NaN;
            end
        else
            cohensdPos = NaN;
        end
    else
        cohensdPos = NaN;
    end

    if isfield(stat,'negclusters')
        if size(stat.negclusters,2) > 0
            if stat.negclusters(1).prob < 0.05
                chanN = stat.negclusterslabelmat == 1;
                cohensdNeg = mean(stat.rho(chanN));
            else
                cohensdNeg = NaN;
            end
        else
            cohensdNeg = NaN;
        end
    else
        cohensdNeg = NaN;
    end

    % Save the output
    saveName = ['correlation_erp_capacity_',comparisons{compi,1}];
    save([pathStats,saveName,'.mat'],'stat','seedDetails','cohensdPos','cohensdNeg','nParticipants','removei','Behav_data','EEG_data');

end

%% Read out the results
clc;

for compi = 1:size(comparisons,1)
    
    % Load the results
    loadName = ['correlation_erp_capacity_',comparisons{compi,1}];
    load([pathStats,loadName,'.mat']);
    
    % Positive cluster
    if isfield(stat,'posclusters')
        if size(stat.posclusters,2) > 0
            input1 = stat.posclusters(1).prob;
        else
            input1 = 1;
        end
    else
        input1 = 1;
    end
    input2 = cohensdPos;

    % Negative cluster
    if isfield(stat,'posclusters')
        if size(stat.negclusters,2) > 0
            input3 = stat.negclusters(1).prob;
        else
            input3 = 1;
        end
    else
        input3 = 1;
    end
    input4 = cohensdNeg;

    formatSpec = 'Capacity %s: n = %d, pos. p = %.3f, pos. cd = %.2f, neg. p = %.3f, neg. cd = %.2f\n';
    fprintf(formatSpec,comparisons{compi,1},nParticipants,input1,input2,input3,input4);
end