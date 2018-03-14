%% This configuration file is read by roi_signallevel.m
% ----------------------------------------------------------------------- %
% 2009-2010 Stanford Cognitive and Systems Neuroscience Laboratory
% $Id: roi_signallevel_config.m.template 2010-01-24 $
% ----------------------------------------------------------------------- %

%% Set Path
clear
restoredefaultpath;
SPM_Dir    = '/Users/hao1ei/xToolbox/spm12';
Script_Dir = '/Users/hao1ei/xCode/Image/ROICode';

%% Please specify the server path
paralist.server_path = '/Users/hao1ei/Downloads/Test/data';

%% Please specify the server path of statistics, added by genghaiyang
paralist.server_path_stats = '/Users/hao1ei/Downloads/Test/FirLv';

%% Please specify the parent folder
paralist.parent_folder = ['']; %#ok<*NBRAK>

%% Please specify the subject list (in a .txt file or cell array
paralist.subjlist_file = '/Users/hao1ei/xCode/Image/ROICode/list_test.txt';

%% Please specify the folder containing SPM analysis results
paralist.stats_folder = '/ANT/stats_spm12_swcar';

%% Please specify the folder (full path) holding defined ROIs
ROI_form = 'mat';
paralist.roi_folder = '/Users/hao1ei/Downloads/Test/AttNetDorsal_Yeo';

%% Please specify the t statistic threshol
paralist.tscore_threshold = 2.33;

%% Please specify the folder name to hold saved roi statistics
% You can change it to different studies or settings
paralist.roi_result_folder = '/Users/hao1ei/xCode/Image/ROICode/res_siglv_c';

%% ===================================================================== %%
% Acquire Subject list
fid = fopen(paralist.subjlist_file);
paralist.subject = {};
Cnt_List = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    paralist.subject(Cnt_List,:) = linedata{1}; %#ok<*SAGROW>
    Cnt_List = Cnt_List + 1;
end
fclose(fid);

% Acquire ROI file & list
ROI_list = dir(fullfile(paralist.roi_folder, ['*.',ROI_form]));
ROI_list = struct2cell(ROI_list);
ROI_list = ROI_list(1,:);
ROI_list = ROI_list';
paralist.roi_list = ROI_list;

% Please specify the path of the Marsbar toolbox 
paralist.marsbar_path = fullfile(SPM_Dir,'/toolbox/marsbar');

% Add Path
addpath (genpath (SPM_Dir));
addpath (genpath (Script_Dir));