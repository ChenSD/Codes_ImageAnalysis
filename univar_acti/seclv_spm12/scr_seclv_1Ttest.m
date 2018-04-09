% Written by Hao (2017/09/26)
% haolpsy@gmail.com
% Qinlab.BNU
clear
restoredefaultpath

%% Set Up
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
firlv_dir  = '/Users/hao1ei/Downloads/Test/FirLv';
seclv_dir  = '/Users/hao1ei/Downloads/Test/SecLv';
script_dir = '/Users/hao1ei/xCode/Image/ActiveAnaly/SecLv_spm12';
subjlist   = fullfile (script_dir, 'sublist.txt');

task_name  = 'ANT';
group_name = 'CBDC';
cond_name  = {'Alert'; 'Orient'; 'Conflict'};

%% Run Second Level
addpath (genpath (spm_dir));
addpath (genpath (script_dir));
load (fullfile (script_dir,'depend','seclv_1Ttest.mat'));

fid = fopen(subjlist); sublist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

for i = 1:length(cond_name)
    con_name = cond_name{i,1};
    imgdir = {};
    for j = 1:length(sublist)
        yearID = ['20', sublist{j,1}(1:2)];
        imgdir{j,1} = fullfile (firlv_dir, yearID, sublist{j,1}, ...
            ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
            ['con_000', num2str(i), '.nii']); %#ok<*AGROW>
    end
    res_dir = fullfile (seclv_dir, group_name, cond_name{i,1});
    
    run (fullfile (script_dir, 'depend', 'seclv_1Ttest.m'));
end

%% Analysis Done
disp ('=== Second Level Analysis Done ===');
