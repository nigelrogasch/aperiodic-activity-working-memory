% Test the relationship between working memory capacity calculated during
% the colour wheel task and capacity calculated from the complex span
% tasks.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% Load paths
load('pathInfo.mat');

% Creating .mat file for CFA participants
factorScore = importfileSEM('factorScores_myParticipants.csv');
load([pathData,'colourWheelStandardMixture.mat']);
load([pathData,'colourWheelYoungErrorAll.mat']);

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
wmCapacity = wmCapacity(LIA,:);
precision = precision(LIA,:);
guessRate = guessRate(LIA,:);

if ~isequal(ID,IDfact)
    fprintf('Problem!\n');
end

kcd = mean(wmCapacity(:,2:3),2);

% Correlate the two scores
[r,p] = corr(kcd,Behav_data);

% Plot the correlation
figure;
scatter(kcd,Behav_data);

[r2,p2] = corr(wmCapacity(:,1),Behav_data);
figure;
scatter(wmCapacity(:,1),Behav_data);

[r4,p4] = corr(wmCapacity(:,2),Behav_data);
figure;
scatter(wmCapacity(:,2),Behav_data);

[r6,p6] = corr(wmCapacity(:,3),Behav_data);
figure;
scatter(wmCapacity(:,3),Behav_data);