% Written by Hao (2017/09/26)
% haolpsy@gmail.com
% Qinlab.BNU
clear
restoredefaultpath

%% Set Up
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
firlv_dir  = '/Users/hao1ei/Downloads/Test/FirLv';
seclv_dir  = '/Users/hao1ei/Downloads/Test/SecLv2';
script_dir = '/Users/hao1ei/xCode/Image/ActiveAnaly/SecLv_spm12';
subjlist   = fullfile(script_dir,'sublist.txt');

task_name  = 'ANT';
group_name = 'CBDC';
cond_name  = {'Alert';'Orient';'Conflict'};
cond_contr = [1,0,0; 0,1,0; 0,0,1];

%% Run Second Level
addpath ( genpath (spm_dir));
addpath ( genpath (script_dir));
load (fullfile (script_dir,'depend','seclv_1WayANOVA.mat'));

fid = fopen(subjlist); sublist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

imgdir = {};
for i = 1:length(cond_name)
    for j = 1:length(sublist)
        yearID = ['20', sublist{j,1}(1:2)];
        imgdir{j,i} = fullfile(firlv_dir, yearID, sublist{j,1},...
            ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
            ['con_000',num2str(i),'.nii']); %#ok<*AGROW>
    end
    
    matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(i).scans = imgdir(:,i);
    
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.name = cond_name{i,1};
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.weights = cond_contr(i,:);
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
end
res_dir = fullfile (seclv_dir, group_name);
run (fullfile(script_dir,'depend','seclv_1WayANOVA.m'));

%% Analysis Done
disp('=== Second Level Analysis Done ===');
