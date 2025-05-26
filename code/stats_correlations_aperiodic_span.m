% Test the relationship between changes in aperiodic features during
% working memory and working memory performance on a battery of complex
% span tasks.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
load([pathData,'grandAverageL02vL04_Slope.mat']);
load([pathData,'colourWheelStandardMixture.mat']);
factorScore = importfileSEM('factorScores_myParticipants.csv');
load([pathData,'colourWheelYoungErrorAll.mat']);
load([pathData,'extras', filesep,'neighbours_GWM.mat']);

% Extract the complex span factor score
Behav_data = factorScore(:,6);
logI = ~isnan(Behav_data);
Behav_data = Behav_data(logI);

% Make an ID variable from the SEM input
for x = 1:size(factorScore,1)
    if factorScore(x,1) >=1 && factorScore(x,1)<=9
        IDfact{x,1} = ['00',num2str(factorScore(x,1))];
    elseif factorScore(x,1) >=10 && factorScore(x,1)<=99
        IDfact{x,1} = ['0',num2str(factorScore(x,1))];
    elseif factorScore(x,1) >=100 && factorScore(x,1)<=200
        IDfact{x,1} = num2str(factorScore(x,1));
    end
end

IDfact = IDfact(logI);

% Find the participants with complex working memory scores that overlap
LIA = ismember(ID,IDfact);

% Sanity check
ID = ID(LIA);

% Now make sure the two lists match
LIB = ismember(IDfact,ID);
IDfact = IDfact(LIB);
Behav_data = Behav_data(LIB);

% Flip the Behav_data dimensions
Behav_data_all = Behav_data';

% Conditions to compare
comparisons = {'slope','L02Abschange';...
    'slope','L04Abschange';...
    'slope','L06Abschange';...
    'slope','L02vL04n06Abschange'};

%% Run analysis

for compi = 1:size(comparisons,1)
    
    % Reset Behav_data
    Behav_data = Behav_data_all;

    % Setting up our comparisons (e.g. EEG_data vs Behav_data etc.)
    EEG_data = grandAverage.(comparisons{compi,2}).(comparisons{compi,1});

    % Match IDs between slope data and behaviour data
    EEG_data.individual = EEG_data.individual(LIA,:);

    % Check that EEG data and behaviour data match
    if ~isequal(ID,IDfact)
        error('Problem!\n');
    end

    if size(EEG_data.individual,1) ~= length(Behav_data)
        error('Problem!\n');
    end

    % Check for outliers. Remove participant if 4 or more electrodes have
    % a z-score > 3
    outlier = [];
    outlierAll = [];
    for ex=1:length(EEG_data.label)
        sd=zscore(EEG_data.individual(:,ex));
        outlier{ex}=find(sd>3|sd<-3);
        outlierAll = [outlierAll,outlier{ex}'];
    end

    % Count the outliers per participant
    [outlierSum, outlierUnique] = groupcounts(outlierAll');

    % Remove participants
    removei = outlierUnique(outlierSum > 3);

    if ~isempty(removei)
        EEG_data.individual(removei,:) = [];
        Behav_data(:,removei) = [];
    end
    
    nParticipants = length(Behav_data);

    %this is creating the settings for the stats. 2 levels: clustering and
    %permuations.
    cfg = [];
    cfg.avgovertime = 'yes';
    cfg.avgoverchan = 'no'; %can change this between no and yes depending if you want all channels included
    cfg.channel = {'all'};
    cfg.method = 'montecarlo';
    cfg.statistic = 'ft_statfun_correlationT'; %'ft_statfun_correlationT';
    cfg.correctm = 'cluster'; % is influecing the p-values. 'holm' is closest to result from [r1,p1] = corr(wm_load(:,2),offsetAll);
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.clustertail = 1;
    cfg.minnbchan = 2;
    cfg.neighbours = neighbours;
    cfg.alpha = 0.05;
    cfg.tail = 1; %
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
    saveName = ['correlation_span_',comparisons{compi,1},'_',comparisons{compi,2}];
    save([pathStats,saveName,'.mat'],'stat','seedDetails','cohensdPos','cohensdNeg','nParticipants','removei','Behav_data','EEG_data');

end

%% Read out the results
clc;

for compi = 1:size(comparisons,1)
    
    % Load the results
    loadName = ['correlation_span_',comparisons{compi,1},'_',comparisons{compi,2}];
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
    if isfield(stat,'negclusters')
        if size(stat.negclusters,2) > 0
            input3 = stat.negclusters(1).prob;
        else
            input3 = 1;
        end
    else
        input3 = 1;
    end
    input4 = cohensdNeg;

    formatSpec = 'Span %s vs %s: n = %d, pos. p = %.3f, pos. cd = %.2f, neg. p = %.3f, neg. cd = %.2f\n';
    fprintf(formatSpec,comparisons{compi,1},comparisons{compi,2},nParticipants,input1,input2,input3,input4);
end