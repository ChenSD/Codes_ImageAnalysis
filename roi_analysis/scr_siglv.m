% This script produce ROI statistics
% It helps you figure out if a particular ROI is in fact changing between
% conditions in your experiment. Statistics are:
% *Percent Signal Change
% *t-score average
% *t-score percent voxels activated
% *beta average
% -------------------------------------------------------------------------
% 2009-2010 Stanford Cognitive and Systems Neuroscience Laboratory
% Tianwen Chen
% $Id: roi_signallevel.m rev.1 2010-01-24 $
% -------------------------------------------------------------------------

function scr_siglv(Config_File)

warning('off', 'MATLAB:FINITE:obsoleteFunction')
disp(['Current directory is: ',pwd]);
c     = fix(clock);
disp('==================================================================');
fprintf('ROI Signal Level Analysis start at %d/%02d/%02d %02d:%02d:%02d\n',c);
disp('==================================================================');
fname = sprintf('roi_signallevel-%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
diary(fname);
disp(['Current directory is: ',pwd]);
disp('------------------------------------------------------------------');

% Load configuration file
% ----------------------------------------------------------------------- %
if ~exist(Config_File,'file')
    fprintf('Cannot find the configuration file ... \n');
    return;
end
Config_File = strtrim(Config_File);
Config_File = Config_File(1:end-2);
eval(Config_File);
clear Config_File;

% Read in parameters
% ----------------------------------------------------------------------- %
% server_path        = strtrim(paralist.server_path);
server_path_stats  = strtrim(paralist.server_path_stats);
parent_folder      = strtrim(paralist.parent_folder);
% subjlist_file    = strtrim(paralist.subjlist_file);
subjects           = strtrim(paralist.subject);
stats_folder       = strtrim(paralist.stats_folder);
roi_folder         = strtrim(paralist.roi_folder);
roi_list           = strtrim(paralist.roi_list);
tscore_threshold   = paralist.tscore_threshold;
roi_result_folder  = strtrim(paralist.roi_result_folder);
marsbar_path       = strtrim(paralist.marsbar_path);
ScrDir             = strtrim(Script_Dir);

disp('-------------- Contents of the Parameter List --------------------');
disp(paralist);
disp('------------------------------------------------------------------');
clear paralist;

%-Add marsbar to the search path
%--------------------------------------------------------------------------
if ~exist(marsbar_path, 'dir')
    fprintf('Marsbar toolbox does not exist: %s \n', marsbar_path);
    diary off;
    return;
end

%-Check the roi_folder
%--------------------------------------------------------------------------
if ~exist(roi_folder, 'dir')
    fprintf('Folder does not exist: %s \n', roi_folder);
    diary off;
    return;
end

% Check the roi_result_folder % Add by Hao
if ~exist(roi_result_folder, 'dir')
    mkdir (roi_result_folder)
end

numsub = length(subjects);

%-Construct the subject stats path
sub_stats = cell(numsub,1);
if isempty(parent_folder)
    for subcnt = 1:numsub
        pfolder = ['20' subjects{subcnt}(1:2)];
        sub_stats{subcnt} = fullfile(server_path_stats, pfolder, subjects{subcnt}, ...
            'fmri', 'stats_spm12', stats_folder);
    end
else
    for subcnt = 1:numsub
        sub_stats{subcnt} = fullfile(server_path_stats, parent_folder, subjects{subcnt}, ...
            'fmri', 'stats_spm12', stats_folder); % edited by genghaiyang add stats path
    end
end

cd (roi_result_folder) % Add by Hao
save sub_stats.mat sub_stats

% default, measure sc using entire event duration as coded in task_design
event_duration = [];

%-ROI list
if ~isempty(roi_list)
    ROIName = roi_list;
    NumROI = length(ROIName);
    roi_file = cell(NumROI, 1);
    cd (roi_result_folder) % Add by Hao
    save x.mat roi_folder ROIName
    
    for iROI = 1:NumROI
        ROIFile = spm_select('List', roi_folder, ROIName{iROI});
        save roifile.mat ROIFile
        
        if isempty(ROIFile)
            error('Folder contains no ROIs');
        end
        roi_file{iROI} = fullfile(roi_folder, ROIFile);
    end
end

%--------------------------------------------------------------------------
% run through all the subjects...
for ithsubject = 1:numsub
    disp('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    fprintf('Processing subject: %s ...... \n', subjects{ithsubject});
    sub_stats_dir = sub_stats{ithsubject};
    if ~exist(sub_stats_dir, 'dir')
        fprintf('Folder does not exist: %s \n', sub_stats_dir);
        cd(ScrDir);
        diary off; return;
    end
    
    % get percent signal change
    [signalchange{ithsubject}] = roi_signalchange_onesubject_dcan(roi_file, sub_stats_dir, event_duration);
    
    % get tscore average and percent voxels activated in ROI
    [tscore_average{ithsubject}, tscore_percent_voxels{ithsubject}] = roi_tscore_onesubject(roi_file,sub_stats_dir,tscore_threshold);
    
    % get beta average in ROI
    [beta_average{ithsubject}] = roi_beta_onesubject(roi_file,sub_stats_dir);
    
    save roi.mat roi_file
end % subjects


% make a folder to hold roi statistics
if ~exist (roi_result_folder, 'dir')
    mkdir(roi_result_folder);
end

% % get summary data and stats for percent signal change,
signal = signalchange; % change to generic name before saving
%[signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_signalchange signal % signal_means signal_stderr signal_stats
%
% % get summary data and stats for tscore_average
signal = tscore_average; % change to generic name before saving
% [signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_tscore_average signal % signal_means signal_stderr signal_stats
%
% % get summary data and stats for tscore_percent_voxels
signal = tscore_percent_voxels; % change to generic name before saving
% [signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_tscore_percent_voxels signal % signal_means signal_stderr signal_stats

% get summary data and stats for tscore_average
signal = beta_average; % change to generic name before saving
%[signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_beta_average signal % signal_means signal_stderr signal_stats

% PrintROIResults('signalchange');
% PrintROIResults('tscore_average');
% PrintROIResults('tscore_percent_voxels');
% PrintROIResults('beta_average');

disp('-----------------------------------------------------------------');
fprintf('Changing back to the directory: %s \n', ScrDir);
cd (ScrDir);
c = fix(clock);
disp('==================================================================');
fprintf('ROI Signal Level Analysis finished at %d/%02d/%02d %02d:%02d:%02d \n',c);
disp('==================================================================');
diary off;
clear all;
close all;

end
