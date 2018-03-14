% Configuration file for gPPI.m
% Shaozheng Qin adapted for his poject on January 1, 2014
% Lei Hao readapted for his poject on September 12, 2017
% ======================================================================= %
clear
restoredefaultpath

%% gzip swcar.nii
gzip_swcar = 0; % 1:yes or 0:no

%% Set Path
spm_dir    = '/Users/hao1ei/xToolbox/spm8';
script_dir = '/Users/hao1ei/xScript/Image/BrainNetwork/gPPI_mask';

%% Please specify the data server path
paralist.data_server = '/Users/hao1ei/Downloads/Test/data';

%% added by Hao specify the stats server path
paralist.server_path_stats = '/Users/hao1ei/Downloads/Test/FirLv';

%% Please specify the parent folder of the static data
% For YEAR data structure, use the first one
% For NONE YEAR data structure, use the second one
paralist.parent_folder = ['']; %#ok<*NBRAK>

%% Please specify the subject list file (.txt) or a cell array
subjlist = fullfile(script_dir, 'list_test.txt');

%% Please specify the stats folder name (eg., stats_spm8)
paralist.stats_folder = '/ANT/stats_spm12_swcar';

%% get ROI file list
paralist.roi_nii_folder = '/Users/hao1ei/Downloads/Test/AttNetVentral_Yeo/AttNetVentral_Yeo';

%% Please specify the task to include
% set = { '1', 'task1', 'task2'} -> must exist in all sessions
% set = { '0', 'task1', 'task2'} -> does not need to exist in all sessions
paralist.tasks_to_include = {'1', 'NoCue', 'DoubCue','CentCue','SpatCue'};

%% mask file, restricting the analysis on voxels within the mask
paralist.mask_file = '/Users/hao1ei/Downloads/Test/AttNetVentral_Yeo/AttNetVentral_Union_roi.nii';

%% Please specify the confound names
paralist.confound_names = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6'};

%% make T contrast
Pcon.Contrasts(1).left     = {'DoubCue'};
Pcon.Contrasts(1).right    = {'NoCue'};
Pcon.Contrasts(1).STAT     = 'T';
Pcon.Contrasts(1).Weighted = 0;
Pcon.Contrasts(1).name     = 'Alert';

Pcon.Contrasts(2).left     = {'SpatCue'};
Pcon.Contrasts(2).right    = {'CentCue'};
Pcon.Contrasts(2).STAT     = 'T';
Pcon.Contrasts(2).Weighted = 0;
Pcon.Contrasts(2).name     = 'Orient';

% Pcon.Contrasts(3).left     = {'InconFlk'};
% Pcon.Contrasts(3).right    = {'ConFlk'};
% Pcon.Contrasts(3).STAT     = 'T';
% Pcon.Contrasts(3).Weighted = 0;
% Pcon.Contrasts(3).name     = 'Conflict';

%% ===================================================================== %%
% Acquire Subject list
fid = fopen (subjlist); paralist.subject_list = {}; cnt = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    paralist.subject_list(cnt, :) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose (fid);

% Acquire ROI file & list
roi_list = dir (fullfile (paralist.roi_nii_folder, ['*.nii']));
roi_list = struct2cell (roi_list);
roi_list = roi_list (1, :);
roi_list = roi_list';

paralist.roi_file_list = {};
for roi_i = 1:length (roi_list)
    paralist.roi_file_list {roi_i,1} = fullfile (paralist.roi_nii_folder, roi_list {roi_i, 1});
end
paralist.roi_name_list = strtok (roi_list, '.');

% Add Path
addpath (genpath (spm_dir));
addpath (genpath (script_dir));