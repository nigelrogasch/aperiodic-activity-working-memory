% Plot the effects of load on aperiodic activity
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

%% Plot the topoplots

statFiles = {'slope_L04Abschange_L02Abschange',...
    'slope_L06Abschange_L02Abschange',...
    'slope_L06Abschange_L04Abschange',...
    'offset_L04Abschange_L02Abschange',...
    'offset_L06Abschange_L02Abschange',...
    'offset_L06Abschange_L04Abschange'};

xLeft   = 0.05;
xMid    = 0.35;
xRight  = 0.65;
yTop    = 0.5;
yBottom = 0.1;
tScale  = 0.33;

statPos = {[xLeft, yTop, tScale, tScale],...
    [xMid, yTop, tScale, tScale],...
    [xRight, yTop, tScale, tScale],...
    [xLeft, yBottom, tScale, tScale],...
    [xMid, yBottom, tScale, tScale],...
    [xRight, yBottom, tScale, tScale]};


f = figure('color','w');
set(gcf,'position',[1400,250,900,600]);

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
        text(0.5, 1.1, 'Load 4 vs. load 2', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        text(-0.05, 0.5, 'Exponent', 'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    elseif topox == 2
        text(0.5, 1.1, 'Load 6 vs. load 2', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
        text(0.5, 1.4, 'Load effect', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
    elseif topox == 3
        text(0.5, 1.1, 'Load 6 vs. load 4', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
    elseif topox == 4
        text(-0.05, 0.5, 'Offset', 'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized','Rotation',90);
    end
end

% Plot the colorbar
c2 = colorbar('Position', [xRight+0.3, yBottom+0.2, 0.015, tScale], 'LineWidth', 1.5, 'FontSize', 14, 'Ticks', [cfg.zlim(1) (cfg.zlim(1)+cfg.zlim(2))/2 cfg.zlim(2)]);
title(c2,'\itt');

%% Add annotations

th=annotation('textbox',[0.01,0.91,0,0],'String','A','LineStyle','none','fontsize',24,'fontweight','bold');
th=annotation('textbox',[0.01,0.46,0,0],'String','B','LineStyle','none','fontsize',24,'fontweight','bold');

% th=annotation('textbox',[0.03,.68,0,0],'String','C','LineStyle','none','fontsize',24,'fontweight','bold');
% th=annotation('textbox',[0.03,.38,0,0],'String','E','LineStyle','none','fontsize',24,'fontweight','bold');
% th=annotation('textbox',[0.48,.68,0,0],'String','D','LineStyle','none','fontsize',24,'fontweight','bold');
% th=annotation('textbox',[0.48,.38,0,0],'String','F','LineStyle','none','fontsize',24,'fontweight','bold');

%% Set the colour maps

for topox = 1:length(statFiles)
    colormap(ax.(['tp',num2str(topox)]), flipud(brewermap(12,'PiYG')));
end


%% Save the figure

print(f,'-dpng',[pathFigures,'figure_aperiodic_load']);
