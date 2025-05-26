% Plot summary of working memory performance
%
% Author: Nigel Rogasch

%%
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Load data
load([pathData,'colourWheelStandardMixture.mat']);
load([pathData,'colourWheelYoungErrorAll.mat']);

% WM loads - plot error for each

loadWM = {'load2';'load4';'load6'};
loadWMt = {'Load 2';'Load 4';'Load 6'};

for lx = 1:length(loadWM)
    dataTemp = [];
    for ix = 1:length(errorAll.(loadWM{lx}))
        dataTemp(ix,:) = errorAll.(loadWM{lx}){ix};
    end
    dataError.(loadWM{lx}) = dataTemp(:);
end

fig = figure('color','w');
for fx = 1:length(loadWM)
    sp.(['sp',num2str(fx)])=subplot(2,6,fx*2-1:fx*2);
    histogram(dataError.(loadWM{fx}),'normalization','probability','binWidth',10);
    xlabel('Error (degrees)');
    ylabel('Probability');
    title(loadWMt{fx});
    set(gca,'box','off','tickdir','out','ylim',[0,0.3],'xlim',[-180,180],'linewidth',1.5,'fontsize',18);
end

wmM = {'cap','prec'};
sbi = [7,9;10,12];

for rx = 1:length(wmM)
    % Generate some data
    if strcmp(wmM{rx},'cap')
        data{1,1} = wmCapacity(:,1);
        data{2,1} = wmCapacity(:,2);
        data{3,1} = wmCapacity(:,3);
    elseif strcmp(wmM{rx},'prec')
        data{1,1} = precision(:,1);
        data{2,1} = precision(:,2);
        data{3,1} = precision(:,3);
    end
    
    %cl(1,:) = cb(#colour you want to use, :)
    % Set colours with cbrewer
    % [cb] = cbrewer('seq','YlGnBu', 7, 'pchip');
    cb = brewermap(7,'YlGnBu');
    cl = [];
    cl(1, :) = cb(5, :);
    
    % Generate rain cloud plot
    sp.(['sp',num2str(rx+3)])=subplot(2,6,sbi(rx,1):sbi(rx,2));
    h   = rm_raincloud(data, cl);
    set(gca, 'tickdir','out','yticklabel',{'L6';'L4';'L2'},'linewidth',1.5,'fontsize',18);
%     ylabel('WM Load');
    if strcmp(wmM{rx},'cap')
        set(gca, 'tickdir','out','yticklabel',{'L6';'L4';'L2'},'linewidth',1.5,'fontsize',18,'xlim',[0,6],'ylim',[-3,17]);
        xlabel('Capacity (k)');
    elseif strcmp(wmM{rx},'prec')
        set(gca, 'tickdir','out','yticklabel',{'L6';'L4';'L2'},'linewidth',1.5,'fontsize',18,'xlim',[0,100],'ylim',[-0.1,0.5]);
        xlabel('Precision (s.d.)');
    end
    
end

set(fig,'position',[350,120,1000,850]);

set(sp.sp1,'position',[0.09,0.5838,0.2368,0.3412]);
set(sp.sp3,'position',[0.7082,0.5838,0.2368,0.3412]);
set(sp.sp4,'position',[0.1,0.07,0.3714,0.3412]);
set(sp.sp5,'position',[0.58,0.07,0.3714,0.3412]);

annotation('textbox',[0.01,0.88,0.1,0.1],'String','A','fontsize',24,'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.31,0.88,0.1,0.1],'String','B','fontsize',24,'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.61,0.88,0.1,0.1],'String','C','fontsize',24,'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.03,0.37,0.1,0.1],'String','D','fontsize',24,'LineStyle','none','FontWeight','bold');
annotation('textbox',[0.48,0.37,0.1,0.1],'String','E','fontsize',24,'LineStyle','none','FontWeight','bold');

% Save the figure
savename = [pathFigures,'figure_working_memory_performance'];
set(gcf,'PaperPositionMode','auto');
print(fig,'-dpng',savename);
