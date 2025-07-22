% main.m runs all of the statistical analysis and generates the figures for
% the study:
%
% Task-related changes in aperiodic activity are related to visual working 
% memory capacity independent of event-related potentials and alpha 
% oscillations
%
% Before running this script, ensure to update the file paths in:
% aperiodic_memory_set_paths.m
%
% Also, make sure the current folder is set to the folder containting
% main.m
%
% Author: Nigel Rogasch

%% Clear the command window, workspace and figures

clc; clear; close all;

%% Set the paths

run(fullfile('code','aperiodic_memory_set_paths.m'));

%% Performance on the continuous recall task

% RM-ANOVA for recall task
run('stats_working_memory_load.m');

% Figure 3 for recall task performance
run('figure_working_memory_performance.m');

%% Effect of task on aperiodic activity

% Permutation statistics comparing aperodic activity across task
run('stats_aperiodic_task.m');

% Figure 4 comparing aperodic activity across task
run('figure_aperiodic_task.m');

%% Effect of working memory load on aperiodic activity

% Permutation statistics comparing aperodic activity across loads
run('stats_aperiodic_load.m');

% Figure 5 comparing aperodic activity across loads
run('figure_aperiodic_load.m');

%% Relationship between changes in aperiodic activity and working memory performance

% Permutation statistics correlating aperodic activity with working memory
% capacity
run('stats_correlations_aperiodic_capacity.m');

% Figure 6 correlating aperodic activity with working memory capacity
run('figure_correlations_aperiodic_capacity.m');

% Permutation statistics correlating aperodic activity with working memory
% precision
run('stats_correlations_aperiodic_precision.m');

% Stastitcs corrlating working memory capacity and complex span performance
run('stats_correlations_capacity_span.m');

% Permutation statistics correlating aperodic activity with complex span
run('stats_correlations_aperiodic_span.m');

% Figure 7 correlating aperodic activity with complex span
run('figure_correlations_aperiodic_span.m');

%% Alpha-band oscillatory power and slow wave ERPs 

% Permutation statistics comparing alpha oscillations across task and loads
run('stats_alpha_task.m');
run('stats_alpha_load.m');

% Permutation statistics correlating alpha oscillations with working memory
% capacity and complex span
run('stats_correlations_alpha_capacity.m');
run('stats_correlations_alpha_span.m');

% Figure 8 plotting alpha oscillation findings
run('figure_alpha.m');

% Permutation statistics comparing slow-wave ERPs across loads
run('stats_erp_load.m');

% Permutation statistics correlating slow-wave ERPs with working memory
% capacity and complex span
run('stats_correlations_erp_capacity.m');
run('stats_correlations_erp_span.m');

% Figure 9 plotting ERP findings
run('figure_erp.m');

%% Relationship between EEG measures and working memory capacity

% Multiple linear regression analyses between exponent, alpha suppression,
% and ERPs with working memory capacity
run('stats_multiple_regression_capacity_cluster.m');
run('stats_multiple_regression_capacity_peak.m');

% Multiple linear regression analyses between exponent, alpha suppression,
% and ERPs with complex span
run('stats_multiple_regression_span_cluster.m');
run('stats_multiple_regression_span_peak.m');

%% Supplementary analysis

% Supplementary figure 1
run('figure_aperiodic_task_delay_minus_base.m');

% Supplementary figure 2
run('stats_aperiodic_task_erp_corrected.m');
run('figure_aperiodic_task_erp_corrected.m');

%% Finish