% Plot the difference between the delay and baseline spectra
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
psdData = load([pathData,'grandAverageL02vL04_AlphaChange.mat']);

% Electrodes to plot
elec1 = {'FCZ','PO7'};

% Frequency range
freqRange = [3,30];

%% Calculate the difference between delay and baseline spectra

% Plot electrode 1
f = figure('color','w');
set(gcf,'Position',[150,400,1000,500]);

for chanx = 1:length(elec1)
    [~,elec] = ismember(elec1{chanx},psdData.grandAverage.Base.L04.label);
    elecName = elec1{chanx};

    % Difference (log10)
    psdDiff = log10(psdData.grandAverage.Delay.L04.powspctrm) - log10(psdData.grandAverage.Base.L04.powspctrm);

    [~,f1] = min(abs(freqRange(1)-psdData.grandAverage.Base.L04.freq));
    [~,f2] = min(abs(freqRange(2)-psdData.grandAverage.Base.L04.freq));

    % Extract the difference
    dataIn = squeeze(psdDiff(:,elec,f1:f2));
    meanPSD = mean(dataIn,1);
    ciPSD = (std(dataIn,[],1)./sqrt(size(dataIn,1))).*1.96;
    freq = psdData.grandAverage.Base.L04.freq(f1:f2);

    subplot(1,2,chanx)
    plot(log10(freq),meanPSD,'linewidth',2); hold on;

    upperCI = meanPSD + ciPSD;
    lowerCI = meanPSD - ciPSD;

    % Plot shaded error bars
    fill([log10(freq), fliplr(log10(freq))], [upperCI, fliplr(lowerCI)], 'b', ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none');

    % Plot dotted line at 0
    plot([0.4,1.6],[0,0],'k--');

    % Set the axis limits
    set(gca,'xlim',[0.4,1.6],'ylim',[-0.4,0.05],'box','off','tickdir','out','linewidth',2,'fontsize',12);
    xlabel('Log10 Frequency (Hz)');
    ylabel('\Delta PSD (delay-baseline)');
    title(elecName);

    % Calculate the difference in spectra that were below 0
    sigReduce = upperCI < 0;
    sigReduceFreq = freq(sigReduce);
    fprintf('%s reduced between %0.2f and %0.2f Hz\n',elecName,min(sigReduceFreq),max(sigReduceFreq));

end

% Save the figure
print(f,'-dpng',[pathFigures,'figure_aperiodic_task_delay_minus_base']);
