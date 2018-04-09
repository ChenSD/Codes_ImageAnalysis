% Written by Hao (2017/10/26)
% haol.psy@gmail.com
% Qinlab.BNU
clear
restoredefaultpath

%% Set Up
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
firlv_dir  = '/Users/hao1ei/Downloads/Test/FirLv';
seclv_dir  = '/Users/hao1ei/Downloads/Test/SecLv';
script_dir = '/Users/hao1ei/xScript/Image/ActiveAnaly/SecLv_spm12';
subjlist   = fullfile (script_dir, 'list_MultiReg.txt');

tconname = 'MultiReg';
tconweig = [0 1 0];

task_name  = 'ANT';
group_name = 'CBDC_MultiReg';
cond_name  = {'Alert'; 'Orient'; 'Conflict'};

%% Run Second Level
addpath (genpath (spm_dir));
addpath (genpath (script_dir));
load (fullfile (script_dir,'depend','seclv_MultiReg.mat'));

subtab = readtable(subjlist,'Delimiter','\t');
[rowi,coli] = size(subtab);
sublist = table2array(subtab(:,1));

for col_i = 2:coli
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(col_i-1).c = table2array(subtab(:,col_i));
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(col_i-1).cname = subtab.Properties.VariableNames{col_i};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(col_i-1).iCC = 1;
end

for i = 1:length(cond_name)
    con_name = cond_name{i};
    imgdir = {};
    for j = 1:length(sublist)
        yearID = ['20', sublist{j,1}(1:2)];
        imgdir{j,1} = fullfile (firlv_dir, yearID, sublist{j,1}, ...
            ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
            ['con_000', num2str(i), '.nii']); %#ok<*AGROW>
    end
    res_dir = fullfile (seclv_dir, group_name, cond_name{i});
    
    run (fullfile (script_dir, 'depend', 'seclv_MultiReg.m'));
end

%% Analysis Done
disp ('=== Second Level Analysis Done ===');
