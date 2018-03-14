% Configuration file for rsFC_roi2roi
% Shaozheng Qin adapted for his poject on January 1, 2014
% Lei Hao readapted for his poject on October 19, 2017
% ======================================================================= %
clear
restoredefaultpath

%% Set up
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
script_dir = '/Users/hao1ei/xScript/Image/BrainNetwork/rsFC_roi2roi';
subjlist   = fullfile(script_dir, 'list_test.txt');

% Preprocessing directory & results output directory
paralist.preproc_dir = '/Users/hao1ei/Downloads/Test/data';
paralist.output_dir  = '/Users/hao1ei/Downloads/Test/rsFC_roi2roi';

% ROI format & directory
roi_form         = 'mat';
paralist.roi_dir = '/Users/hao1ei/Downloads/Test/AttNetVentral_Yeo/AttNetVentral_Yeo';

% Basic configuration
paralist.sess_folder = 'REST';
paralist.data_type   = 'nii';
paralist.NUMTRUNC    = [0,0]; % delete and remain
paralist.NFRAMES     = 175;
paralist.imagefilter = 'swcar';

paralist.tr_val      = 2;
paralist.bandpass_on = 1;
paralist.fl          = 0.008;
paralist.fh          = 0.1;

%% ===================================================================== %%
% Acquire Subject list
fid = fopen (subjlist); paralist.subjlist_file = {}; cnt = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    paralist.subjlist_file (cnt, :) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose (fid);

% Acquire ROI file & list
roi_list = dir(fullfile(paralist.roi_dir, ['*.', roi_form]));
roi_list = struct2cell(roi_list);
roi_list = roi_list(1, :);
paralist.roi_list = roi_list';

% white matter and CSF roi files
paralist.wm_csf_roi_file = cell(2,1);
paralist.wm_csf_roi_file{1} = fullfile(script_dir, 'depend/white_mask_p08_d1_e1_roi.mat');
paralist.wm_csf_roi_file{2} = fullfile(script_dir, 'depend/csf_mask_p08_d1_e1_roi.mat');

% Add Path
addpath (genpath (spm_dir));
addpath (genpath (script_dir));