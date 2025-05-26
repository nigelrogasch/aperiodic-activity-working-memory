% Plot the effects of task on aperiodic activity
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
slopeData = load([pathData,'grandAverageL02vL04_Slope.mat']);
psdData = load([pathData,'grandAverageL02vL04_AlphaChange.mat']);

% Electrodes to plot
elec1 = 'FCZ';
elec2 = 'PO7';

% Frequency range
freqRange = [3,30];

% Conditions
cond = {'Base','Delay'};

% Loads
loads = {'L02','L04','L06'};


%% Plot the topoplots

statFiles = {'slope_L02_Delay_Base',...
    'slope_L04_Delay_Base',...
    'slope_L06_Delay_Base',...
    'offset_L02_Delay_Base',...
    'offset_L04_Delay_Base',...
    'offset_L06_Delay_Base'};

xLeft   = 0.2;
xMid    = 0.45;
xRight  = 0.7;
yTop    = 0.82;
yBottom = 0.69;
tScale  = 0.12;

statPos = {[xLeft, yTop, tScale, tScale],...
    [xMid, yTop, tScale, tScale],...
    [xRight, yTop, tScale, tScale],...
    [xLeft, yBottom, tScale, tScale],...
    [xMid, yBottom, tScale, tScale],...
    [xRight, yBottom, tScale, tScale]};


f = figure('color','w');
set(gcf,'position',[1400,250,900,1000]);

% Plot the topoplots
for topox = 1:length(statFiles)
    % Load the stat file
    loadFile = [statFiles{topox},'.mat'];
    load([pathStats,loadFile]);

    % Set fieldtrip cfg for topoplots
    cfg = [];
    cfg.layout             = 'quickcap64.mat';
    cfg.comment            = 'no';
    cfg.interactive        = 'no';
    cfg.markersymbol       = '.';
    cfg.markersize         = 3; % Slightly bigger marker for clarity
    % cfg.parameter          = 'data';
    cfg.gridscale          = 128; % Higher grid resolution for smoother plots
    cfg.zlim               = [-3, 3];
    cfg.highlight          = 'on';
    cfg.highlightsymbol    = '*';
    cfg.highlightcolor     = 'w';
    cfg.highlightsize      = 4;
    cfg.style              = 'straight';
    cfg.highlightchannel   =  find(stat.mask);

    % Create dummy dimord
    TPdata = [];
    TPdata.avg = stat.stat;
    TPdata.dimord = 'chan_time';
    TPdata.time = stat.time;
    TPdata.label = stat.label;
    ax.(['tp',num2str(topox)]) = axes('Position', statPos{topox});
    cfg.figure = 'gcf';
    ft_topoplotER(cfg,TPdata);

    % Include labels above plots
    if topox == 1
        text(0.5, 1.1, 'Load 2', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        text(-0.6, 0.5, 'Exponent', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    elseif topox == 2
        text(0.5, 1.1, 'Load 4', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        text(0.5, 1.4, 'Delay vs. Baseline', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
    elseif topox == 3
        text(0.5, 1.1, 'Load 6', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
    elseif topox == 4
        text(-0.6, 0.5, 'Offset', 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    end
end

% Plot the colorbar
c2 = colorbar('Position', [xRight+0.18, yBottom+0.07, 0.015, tScale], 'LineWidth', 1.5, 'FontSize', 10, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
title(c2,'\itt');

%%
% FCZ electrode plots

[~,elec] = ismember(elec1,psdData.grandAverage.Base.L04.label);
elecName = elec1;

[~,f1] = min(abs(freqRange(1)-psdData.grandAverage.Base.L04.freq));
[~,f2] = min(abs(freqRange(2)-psdData.grandAverage.Base.L04.freq));

meanPSD1 = squeeze(mean(psdData.grandAverage.Base.L04.powspctrm(:,elec,f1:f2),1));
meanPSD2 = squeeze(mean(psdData.grandAverage.Delay.L04.powspctrm(:,elec,f1:f2),1));
freq = psdData.grandAverage.Base.L04.freq(f1:f2);

subplot(3,2,3)
h1 = plot(log10(freq),log10(meanPSD1),'color','b','linewidth',2);hold on;
h2 = plot(log10(freq),log10(meanPSD2),'color','r','linewidth',2);hold on;

set(gca,'xlim',[log10(3),log10(30)],'ylim',[-1.5,1],'box','off','tickdir','out','linewidth',2,'fontsize',12);
xlabel('log_1_0 Frequency (Hz)','fontsize',14);
ylabel('log_1_0 PSD (\muV^2/Hz)','fontsize',14);
title([elecName, ' electrode']);

indExp(:,1) = slopeData.grandAverage.Base.L04.slope.individual(:,elec);
indExp(:,2) = slopeData.grandAverage.Delay.L04.slope.individual(:,elec);

indOff(:,1) = slopeData.grandAverage.Base.L04.offset.individual(:,elec);
indOff(:,2) = slopeData.grandAverage.Delay.L04.offset.individual(:,elec);

meanExp = mean(indExp,1);
stdExp(1) = std(indExp(:,1),[],1)./sqrt(size(indExp,1));
stdExp(2) = std(indExp(:,2),[],1)./sqrt(size(indExp,1));

meanOff = mean(indOff,1);
stdOff(1) = std(indOff(:,1),[],1)./sqrt(size(indExp,1));
stdOff(2) = std(indOff(:,2),[],1)./sqrt(size(indExp,1));

L1 = meanOff(1) - log10(freq.^meanExp(1));
L2 = meanOff(2) - log10(freq.^meanExp(2));
h3 = plot(log10(freq),L1,'--','color','b','linewidth',2); hold on;
h4 = plot(log10(freq),L2,'--','color','r','linewidth',2); hold on;

[~,pExp1] = ttest(indExp(:,1),indExp(:,2));
[~,pOff1] = ttest(indOff(:,1),indOff(:,2));

legend([h1,h2],{'Baseline','Delay'},'box','off');

subplot(3,4,9)
for x = 1:size(indExp,1)
    plot(indExp(x,:),'.-','color','k'); hold on;
end
errorbar([0.8,2.2],mean(indExp,1),[stdExp(1),stdExp(2)],'.','color','b','linewidth',2,'markersize',15);
set(gca,'xlim',[0.5,2.5],'xtick',[1,2],'ylim',[0,2.5],'xticklabel',{'Baseline','Delay'},'box','off','tickdir','out','linewidth',2,'fontsize',12);
ylabel('Exponent');
text(1.5,2.3,'*','color','r','fontsize',30);
title([elecName,' exponent']);

subplot(3,4,10)
for x = 1:size(indOff,1)
    plot(indOff(x,:),'.-','color','k'); hold on;
end
errorbar([0.8,2.2],mean(indOff,1),[stdOff(1),stdOff(2)],'.','color','b','linewidth',2,'markersize',15);
set(gca,'xlim',[0.5,2.5],'xtick',[1,2],'ylim',[-1,2.5],'xticklabel',{'Baseline','Delay'},'box','off','tickdir','out','linewidth',2,'fontsize',12);
ylabel('Offset');
title([elecName,' offset']);

% PO7 electrode plot

[~,elec] = ismember(elec2,psdData.grandAverage.Base.L04.label);
elecName = elec2;

meanPSD1 = squeeze(mean(psdData.grandAverage.Base.L04.powspctrm(:,elec,f1:f2),1));
meanPSD2 = squeeze(mean(psdData.grandAverage.Delay.L04.powspctrm(:,elec,f1:f2),1));
freq = psdData.grandAverage.Base.L04.freq(f1:f2);

subplot(3,2,4)
h1 = plot(log10(freq),log10(meanPSD1),'color','b','linewidth',2);hold on;
h2 = plot(log10(freq),log10(meanPSD2),'color','r','linewidth',2);hold on;

set(gca,'xlim',[log10(3),log10(30)],'ylim',[-1.5,1],'box','off','tickdir','out','linewidth',2,'fontsize',12);
xlabel('log_1_0 Frequency (Hz)','fontsize',14);
ylabel('log_1_0 PSD (\muV^2/Hz)','fontsize',14);
title([elecName, ' electrode']);

indExp(:,1) = slopeData.grandAverage.Base.L04.slope.individual(:,elec);
indExp(:,2) = slopeData.grandAverage.Delay.L04.slope.individual(:,elec);

indOff(:,1) = slopeData.grandAverage.Base.L04.offset.individual(:,elec);
indOff(:,2) = slopeData.grandAverage.Delay.L04.offset.individual(:,elec);

meanExp = mean(indExp,1);
stdExp(1) = std(indExp(:,1),[],1)./sqrt(size(indExp,1));
stdExp(2) = std(indExp(:,2),[],1)./sqrt(size(indExp,1));

meanOff = mean(indOff,1);
stdOff(1) = std(indOff(:,1),[],1)./sqrt(size(indExp,1));
stdOff(2) = std(indOff(:,2),[],1)./sqrt(size(indExp,1));

L1 = meanOff(1) - log10(freq.^meanExp(1));
L2 = meanOff(2) - log10(freq.^meanExp(2));
h3 = plot(log10(freq),L1,'--','color','b','linewidth',2); hold on;
h4 = plot(log10(freq),L2,'--','color','r','linewidth',2); hold on;

[~,pExp2] = ttest(indExp(:,1),indExp(:,2));
[~,pOff2] = ttest(indOff(:,1),indOff(:,2));

legend([h1,h2],{'Baseline','Delay'},'box','off');

subplot(3,4,11)
for x = 1:size(indExp,1)
    plot(indExp(x,:),'.-','color','k'); hold on;
end
errorbar([0.8,2.2],mean(indExp,1),[stdExp(1),stdExp(2)],'.','color','b','linewidth',2,'markersize',15);
set(gca,'xlim',[0.5,2.5],'xtick',[1,2],'ylim',[-0.5,2],'xticklabel',{'Baseline','Delay'},'box','off','tickdir','out','linewidth',2,'fontsize',12);
ylabel('Exponent');
title([elecName,' exponent']);
text(1.5,1.8,'*','color','r','fontsize',30);

subplot(3,4,12)
for x = 1:size(indOff,1)
    plot(indOff(x,:),'.-','color','k'); hold on;
end
errorbar([0.8,2.2],mean(indOff,1),[stdOff(1),stdOff(2)],'.','color','b','linewidth',2,'markersize',15);
set(gca,'xlim',[0.5,2.5],'xtick',[1,2],'ylim',[-1,2.5],'xticklabel',{'Baseline','Delay'},'box','off','tickdir','out','linewidth',2,'fontsize',12);
ylabel('Offset');
title([elecName,' offset']);
text(1.5,2.2,'*','color','r','fontsize',30);

%subplot('position',[0.39,0.93,0.065,0.065]);
plotStruc = slopeData.grandAverage.Delay.L02.slope;
plotStruc.avg = plotStruc.individual;
cfg = [];
cfg.layout = 'quickcap64.mat';
cfg.comment = 'no';
cfg.interactive = 'no';
cfg.zlim = [-1,1];
cfg.markersymbol = '.';
cfg.style = 'blank';
cfg.highlight = 'on';
cfg.highlightchannel = elec1;
cfg.highlightsymbol = '.';
cfg.highlightsize = 20;

tp5 = axes('Position', [0.39,0.62,0.065,0.065]);
cfg.figure = 'gcf';
ft_topoplotER(cfg,plotStruc);

% subplot('position',[0.83,0.93,0.065,0.065]);
tp6 = axes('Position',[0.83,0.62,0.065,0.065]);
cfg.figure = 'gcf';
cfg.highlightchannel = elec2;
ft_topoplotER(cfg,plotStruc);

%% Add annotations

th=annotation('textbox',[0.03,.97,0,0],'String','A','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[0.03,.82,0,0],'String','B','LineStyle','none','fontsize',24,'fontweight','bold');

th=annotation('textbox',[0.03,.68,0,0],'String','C','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[0.03,.38,0,0],'String','E','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[0.48,.68,0,0],'String','D','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[0.48,.38,0,0],'String','F','LineStyle','none','fontsize',24,'fontweight','bold');

%% Set the colour maps

for topox = 1:length(statFiles)
    colormap(ax.(['tp',num2str(topox)]), flipud(brewermap(12,'RdBu')));
end


%% Save the figure

print(f,'-dpng',[pathFigures,'figure_aperiodic_task']);
% saveas(f,[pathFigures,'figure_aperiodic_task'],'png');


