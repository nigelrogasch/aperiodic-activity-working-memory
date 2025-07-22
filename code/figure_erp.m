% Plot the outcomes of slow-wave ERPs.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

%%

% Colour map
cmap = brewermap(12,'Dark2');
cmap2 = brewermap(12,'Set1');
% cmap = colororder();

% Draw figure
f = figure('color','w');
set(gcf,'position',[0,0,600,1000]);

%% PSD plots

% Load data
load([pathData,'grandAverageL02vL04_SWN.mat']);

% Time period
tPeriod = {'Base','Delay'};
tPeriodN = {'FC1','P3'};

% WM loads
wmLoads = {'L02','L04','L06'};
wmLoadsN = {'Load 2','Load 4','Load 6'};

% Electrodes to plot
elec = {'FC1','P3'};


for ti = 1:length(tPeriod)

    % PSD plots
    sp = subplot(4,2,ti);

    for loadi = 1:length(wmLoads)

        % Average over participants
        eleci = find(ismember(grandAverage.(wmLoads{loadi}).label,elec{ti}));
        dataIn = squeeze(grandAverage.(wmLoads{loadi}).individual(:,eleci,:));
        dataMean = mean(dataIn,1);
        dataSE = std(dataIn,[],1)./sqrt(size(dataIn,1));
        time = grandAverage.(wmLoads{loadi}).time*1000;

        % Plot the PSD
        lplot.(['p',num2str(loadi)]) = plot(time,dataMean,'Color',cmap(loadi,:),'linewidth',1.5); hold on;
        fplot = fill([time,fliplr(time)],[dataMean-dataSE,fliplr(dataMean+dataSE)],cmap(loadi,:),'FaceAlpha',0.3,'EdgeColor', 'none');
        set(gca,'xlim',[-100,1500],'ylim',[-5,5],'box','off','tickdir','out','linewidth',1.5);
        xlabel('Time (ms)');
        ylabel('Amplitude (\muV)');
        title(tPeriodN{ti},'fontsize',14);

    end
    
    % Add plots on x axis showing time windows
    plot([0,500],[-4.95,-4.95],'Color',cmap2(2,:),'linewidth',3); hold on;
    plot([650,1450],[-4.95,-4.95],'Color',cmap(4,:),'linewidth',3); hold on;

    % Add figure legend
    if ti == 2
        l = legend('Load 2','','Load 4','','Load 6','box','off','location','southeast');
        l.ItemTokenSize = [10,10];
    end

end


%% Plot the load stats

statFiles = {'erp_L04_L02',...
    'erp_L06_L02',...
    'erp_L06_L04'};

figPos = [4,5,6];
topoN = [1,2,3];

% Load names
loadsN = {'Load 4 vs. 2','Load 6 vs. 2','Load 6 vs. 4'};

for topox = 1:length(statFiles)
    
    % Load the stat file
    loadFile = [statFiles{topox},'.mat'];
    load([pathStats,loadFile]);

    % Get starting figure position
    sp = subplot(4,3,figPos(topox));
    pos = sp.Position;
    delete(sp);

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
    TPdata.time = 1;
    TPdata.label = stat.label;

    ax.(['tp',num2str(topoN(topox))]) = axes('Position', pos);
    cfg.figure = 'gcf';
    ft_topoplotER(cfg,TPdata);

    % Text above the topolot
    text(0.5, 1.05, loadsN{topox}, 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');

    % Text next to the first topoplot
    if topox == 1
        text(-0.35,0.5, 'Load effect', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    end

    if topox == 3
        % Plot the colorbar
        c2 = colorbar('Position', [pos(1)+0.23, pos(2)+0.02, pos(3)-0.19, pos(4)-0.05], 'LineWidth', 1.5, 'FontSize', 10, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
        title(c2,'\itt');
    end

end

%% Plot the capacity correlation stats

statFiles = {'correlation_erp_capacity_L02vL04n06'};

figPos = [5];
topoN = [4];

for topox = 1:length(statFiles)
    
    % Load the stat file
    loadFile = [statFiles{topox},'.mat'];
    load([pathStats,loadFile]);

    % Get starting figure position
    sp = subplot(4,2,figPos(topox));
    pos = sp.Position;
    pos(1) = pos(1)-0.03;
    delete(sp);

    % Set fieldtrip cfg for topoplots
    cfg = [];
    cfg.layout             = 'quickcap64.mat';
    cfg.comment            = 'no';
    cfg.interactive        = 'no';
    cfg.markersymbol       = '.';
    cfg.markersize         = 3; % Slightly bigger marker for clarity
    % cfg.parameter          = 'data';
    cfg.gridscale          = 128; % Higher grid resolution for smoother plots
    cfg.zlim               = [-0.4, 0.4];
    cfg.highlight          = 'on';
    cfg.highlightsymbol    = '*';
    cfg.highlightcolor     = 'w';
    cfg.highlightsize      = 4;
    cfg.style              = 'straight';
    cfg.highlightchannel   =  find(stat.mask);

    % Create dummy dimord
    TPdata = [];
    TPdata.avg = stat.rho;
    TPdata.dimord = 'chan_time';
    TPdata.time = 1;
    TPdata.label = stat.label;

    ax.(['tp',num2str(topoN(topox))]) = axes('Position', pos);
    cfg.figure = 'gcf';
    ft_topoplotER(cfg,TPdata);

    % Text next to the first topoplot
    if topox == 1
        text(-0.10,0.5, ['\Delta ERP amplitude' newline 'and capacity'], 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    end

    % Plot the colorbar
    c3 = colorbar('Position', [pos(1)+0.32, pos(2)+0.02, pos(3)-0.31, pos(4)-0.05], 'LineWidth', 1.5, 'FontSize', 10, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
    title(c3,'\itr');

    % Plot a scatter plot
    sp = subplot(4,2,figPos(topox)+1);
    sp.Position(1) = 0.6;

    % Find the desired electrode
    elecName = 'FCZ';
    eleci = find(ismember(stat.label, elecName));

    % Extract the EEG data
    f1 = 0.65;
    f2 = 1.45;
    [~,i1] = min(abs(EEG_data.time-f1));
    [~,i2] = min(abs(EEG_data.time-f2));
    dataEEG = mean(EEG_data.individual(:,eleci,i1:i2),3);

    % Plot
    scatter(Behav_data,dataEEG,'filled','MarkerFaceColor',cmap(1,:),'MarkerEdgeColor',cmap(1,:));hold on;
    P = polyfit(Behav_data,dataEEG,1);
    yfit = polyval(P,Behav_data);
    plot(Behav_data,yfit,'linewidth',1.5,'color',cmap(1,:));
    [r,p] = corr(Behav_data',dataEEG);
    xlimits = [0,5];
    ylimits = [-4,4];
    set(gca,'xlim',xlimits,'ylim',ylimits,'linewidth',1.5,'tickdir','out','fontsize',10);
    xlabel('Working memory capacity (Kcd)','fontsize',10);
    ylabel({'\Delta ERP amplitude','(supra-sub)'},'fontsize',10);
    rText = sprintf('r = %0.2f\np = %0.3f',r,p);
    xPos = xlimits(1)+(xlimits(2)-xlimits(1))*0.05;
    text(xPos,3.5,rText);
    pText = sprintf('p = %0.2f',p);

end

%% Plot the span correlation stats

statFiles = {'correlation_erp_span_L02vL04n06'};

figPos = [7];
topoN = [5];

for topox = 1:length(statFiles)
    
    % Load the stat file
    loadFile = [statFiles{topox},'.mat'];
    load([pathStats,loadFile]);

    % Get starting figure position
    sp = subplot(4,2,figPos(topox));
    pos = sp.Position;
    pos(1) = pos(1)-0.03;
    delete(sp);

    % Set fieldtrip cfg for topoplots
    cfg = [];
    cfg.layout             = 'quickcap64.mat';
    cfg.comment            = 'no';
    cfg.interactive        = 'no';
    cfg.markersymbol       = '.';
    cfg.markersize         = 3; % Slightly bigger marker for clarity
    % cfg.parameter          = 'data';
    cfg.gridscale          = 128; % Higher grid resolution for smoother plots
    cfg.zlim               = [-0.4, 0.4];
    cfg.highlight          = 'on';
    cfg.highlightsymbol    = '*';
    cfg.highlightcolor     = 'w';
    cfg.highlightsize      = 4;
    cfg.style              = 'straight';
    cfg.highlightchannel   =  find(stat.mask);

    % Create dummy dimord
    TPdata = [];
    TPdata.avg = stat.rho;
    TPdata.dimord = 'chan_time';
    TPdata.time = 1;
    TPdata.label = stat.label;

    ax.(['tp',num2str(topoN(topox))]) = axes('Position', pos);
    cfg.figure = 'gcf';
    ft_topoplotER(cfg,TPdata);

    % Text next to the first topoplot
    if topox == 1
        text(-0.10,0.5, ['\Delta ERP amplitude' newline 'and span'], 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    end

    % Plot the colorbar
    c4 = colorbar('Position', [pos(1)+0.32, pos(2)+0.02, pos(3)-0.31, pos(4)-0.05], 'LineWidth', 1.5, 'FontSize', 10, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
    title(c4,'\itr');

    % Plot a scatter plot
    sp = subplot(4,2,figPos(topox)+1);
    sp.Position(1) = 0.6;

    % Find the desired electrode
    elecName = 'FCZ';
    eleci = find(ismember(stat.label, elecName));

    % Extract the EEG data
    f1 = 0.65;
    f2 = 1.45;
    [~,i1] = min(abs(EEG_data.time-f1));
    [~,i2] = min(abs(EEG_data.time-f2));
    dataEEG = mean(EEG_data.individual(:,eleci,i1:i2),3);

    % Plot
    scatter(Behav_data,dataEEG,'filled','MarkerFaceColor',cmap(3,:),'MarkerEdgeColor',cmap(3,:));hold on;
    P = polyfit(Behav_data,dataEEG,1);
    yfit = polyval(P,Behav_data);
    plot(Behav_data,yfit,'linewidth',1.5,'color',cmap(3,:));
    [r,p] = corr(Behav_data',dataEEG);
    xlimits = [-14,14];
    ylimits = [-4,4];
    set(gca,'xlim',xlimits,'ylim',ylimits,'linewidth',1.5,'tickdir','out','fontsize',10);
    xlabel('Complex span (factor score)','fontsize',10);
    ylabel({'\Delta ERP amplitude','(supra-sub)'},'fontsize',10);
    rText = sprintf('r = %0.2f\np = %0.3f',r,p);
    xPos = xlimits(1)+(xlimits(2)-xlimits(1))*0.05;
    text(xPos,3.5,rText);
    pText = sprintf('p = %0.2f',p);

end

%% Add annotations

th=annotation('textbox',[0.01,0.96,0,0],'String','A','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.47,0.96,0,0],'String','B','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.01,0.73,0,0],'String','C','LineStyle','none','fontsize',20,'fontweight','bold');
% th=annotation('textbox',[0.01,0.60,0,0],'String','D','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.01,0.52,0,0],'String','D','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.48,0.52,0,0],'String','E','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.01,0.30,0,0],'String','F','LineStyle','none','fontsize',20,'fontweight','bold');
th=annotation('textbox',[0.48,0.30,0,0],'String','G','LineStyle','none','fontsize',20,'fontweight','bold');

%% Set the colour maps

colormap(ax.tp1, flipud(brewermap(12,'PiYG')));
colormap(ax.tp2, flipud(brewermap(12,'PiYG')));
colormap(ax.tp3, flipud(brewermap(12,'PiYG')));

colormap(ax.tp4, flipud(brewermap(12,'PRGn')));
colormap(ax.tp5, flipud(brewermap(12,'BrBG')));

%% Save the figure

print(f,'-dpng',[pathFigures,'figure_erp']);