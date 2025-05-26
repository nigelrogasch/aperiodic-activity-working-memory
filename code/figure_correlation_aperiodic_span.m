% Plot the correlations between aperiodic activity and complex span.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

%% Plot the topoplots

statFiles = {'correlation_span_slope_L02Abschange',...
    'correlation_span_slope_L04Abschange',...
    'correlation_span_slope_L06Abschange',...
    'correlation_span_slope_L02vL04n06Abschange'};

xLeft   = 0.15;
xRight  = 0.65;
y1      = 0.74;
y2      = 0.51;
y3      = 0.28; 
y4      = 0.05;
tScale  = 0.22;
xScale  = 0.25;
yScale  = 0.17;

% Define position for topoplots
statPos = {[xLeft, y1, tScale, tScale],...
    [xLeft, y2, tScale, tScale],...
    [xLeft, y3, tScale, tScale],...
    [xLeft, y4, tScale, tScale]};

% Define position for scatter plots
corPos = {[xRight, y1+0.01, xScale, yScale],...
    [xRight, y2+0.01, xScale, yScale],...
    [xRight, y3+0.01, xScale, yScale],...
    [xRight, y4+0.01, xScale, yScale]};

% Define the horizontal topoplot labels
horzTopo = {'Load 2'; 'Load 4'; 'Load 6'; 'Set size effect'};

% Define the xlimits for each graph
xlimits = [-12,12;-12,12;-12,12;-12,12];

% Define ylabel
yLabelIn = {'delay-base';...
    'delay-base';...
    'delay-base';...
    'supra-sub'};

% Define xlabel
xLabelIn = {'K';'K';'K';'Kcd'};

% Colour map
cmap = brewermap(12,'Dark2');

f = figure('color','w');
set(gcf,'position',[1400,100,900,1200]);

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
    TPdata.time = stat.time;
    TPdata.label = stat.label;
    
    ax.(['tp',num2str(topox)]) = axes('Position', statPos{topox});
    cfg.figure = 'gcf';
    ft_topoplotER(cfg,TPdata);

    % Include labels next to plots
    text(-0.35,0.5, horzTopo{topox}, 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);

    % Plot the colorbar
    c2 = colorbar('Position', [xLeft+0.25, statPos{topox}(2)+0.03, 0.015, tScale-0.1], 'LineWidth', 1.5, 'FontSize', 14, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
    title(c2,'\itr');

    % Plot a scatter plot
    axScat.(['tp',num2str(topox)]) = axes('Position', corPos{topox});

    % Find the desired electrode
    elecName = 'CZ';
    eleci = find(ismember(stat.label, elecName));

    % Plot
    scatter(Behav_data,EEG_data.individual(:,eleci),'filled','MarkerFaceColor',cmap(3,:),'MarkerEdgeColor',cmap(3,:));hold on;
    P = polyfit(Behav_data,EEG_data.individual(:,eleci),1);
    yfit = polyval(P,Behav_data);
    plot(Behav_data,yfit,'linewidth',1.5,'color',cmap(3,:));
    [r,p] = corr(Behav_data',EEG_data.individual(:,eleci));
    set(gca,'ylim',[-0.6,1],'xlim',xlimits(topox,:),'linewidth',1.5,'tickdir','out','fontsize',12);
    xlabel('Complex span (factor score)','fontsize',12);
    ylabel(['\Delta Exponent (',yLabelIn{topox},')'],'fontsize',12);
    rText = sprintf('r = %0.2f\np = %0.3f',r,p);
    xPos = xlimits(topox,1)+(xlimits(topox,2)-xlimits(topox,1))*0.05;
    text(xPos,0.8,rText);
    % pText = sprintf('p = %0.2f',p);

end

% % Plot the colorbar
% c2 = colorbar('Position', [xRight+0.3, yBottom+0.2, 0.015, tScale], 'LineWidth', 1.5, 'FontSize', 14, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
% title(c2,'\itt');

%% Add annotations

th=annotation('textbox',[xLeft-0.1,y1+tScale,0,0],'String','A','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xRight-0.12,y1+tScale,0,0],'String','B','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xLeft-0.1,y2+tScale,0,0],'String','C','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xRight-0.12,y2+tScale,0,0],'String','D','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xLeft-0.1,y3+tScale,0,0],'String','E','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xRight-0.12,y3+tScale,0,0],'String','F','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xLeft-0.1,y4+tScale,0,0],'String','G','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[xRight-0.12,y4+tScale,0,0],'String','H','LineStyle','none','fontsize',24,'fontweight','bold');


%% Set the colour maps

for topox = 1:length(statFiles)
    colormap(ax.(['tp',num2str(topox)]), flipud(brewermap(12,'BrBG')));
end

%% Save the figure

print(f,'-dpng',[pathFigures,'figure_correlation_aperiodic_span']);
