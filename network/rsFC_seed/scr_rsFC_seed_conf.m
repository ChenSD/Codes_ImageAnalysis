% fconnect_wm_csf_nogs_final('fconnect_wm_csf_nogs_final_config.m')
clear
restoredefaultpath

%% Parameter configuration for functional connectivity

% Please specify the data type
paralist.data_type = 'nii';

% Please specify the raw data server
paralist.raw_server =  '/Users/hao1ei/Downloads/Test/data';

% Please specify the path for output folder
paralist.output_folder ='/Users/hao1ei/Downloads/Test/rsFC_seed';
% Please specify the path for subject list file OR a cell array
%paralist.subjectlist = 'subjectslist_new_51-100.txt';

spm_dir    = '/Users/hao1ei/xToolbox/spm12';
script_dir = '/Users/hao1ei/xScript/Image/BrainNetwork/rsFC_seed';
subjlist   = fullfile(script_dir, 'list_test.txt');

% Please specify the session name
paralist.sess_folder = 'REST';

% Please specify the preprocessed output folder
paralist.preprocessed_folder = 'smoothed_spm12';

% Please specify the prefix to the preprocessed images (pipeline)
paralist.imagefilter = 'swcar';

% Please specify the TR of your data (in seconds)
paralist.TR = 2;

% Please specify the option of bandpass filtering.
% Set to 1 to bandpass filter, 0 to skip.
paralist.bandpass_on = 1;     

% Please specify bandpass filter parameters 
% If not bandpassing (i.e. bandpass_on = 0), then these values are ignored.
% Lower frequency bound for filtering (in Hz)
paralist.fl = 0.008;
% Upper frequency bound for filtering (in Hz)
paralist.fh = 0.1;

% Please specify the ROI folders
roi_form         = 'mat';
paralist.roi_dir = '/Users/hao1ei/Downloads/Test/AttNetDorsal_Yeo/AttNetDorsal_Yeo';

% Please specify the number of truncated images from the beginning and end
% (unit in SCANS not seconds, a two element vector, 1st slot for the beginning, 
% and 2nd slot for the end, 0 means no truncation)
paralist.NUMTRUNC   = [0,0];

% =========================================================================
% Acquire Subject list
fid = fopen (subjlist); paralist.subjectlist = {}; cnt = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    paralist.subjectlist (cnt, :) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose (fid);

% Acquire ROI file & list
roi_list = dir(fullfile (paralist.roi_dir, ['*.', roi_form]));
roi_list = struct2cell (roi_list);
roi_list = roi_list (1, :);
paralist.roi_list = roi_list';

% white matter and CSF roi files
wm_csf_roi_file = cell(2,1);
wm_csf_roi_file{1} = fullfile(script_dir, 'depend/white_mask_p08_d1_e1_roi.mat');
wm_csf_roi_file{2} = fullfile(script_dir, 'depend/csf_mask_p08_d1_e1_roi.mat');

% Add Path
addpath (genpath (spm_dir));
addpath (genpath (script_dir));