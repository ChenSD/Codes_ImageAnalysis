% Script for computing functional connectivity (resting state + seed-based)
% motion parameters are bandpass filtered if bandpass filtering is turned on
% Without global signal regression, but regress out white matter and CSF
% signals
% To run conversion: type at Matlab command line:
% >> fconnect_wm_csf_nogs_final (config_file)

function scr_rsFC_seed (Config_File)
warning('off', 'MATLAB:FINITE:obsoleteFunction')
c = fix(clock);
fname = sprintf('fconnect-%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
diary(fname);
disp('==================================================================');
fprintf('Functional Connectivity starts at %d/%02d/%02d %02d:%02d:%02d\n',c);
disp('==================================================================');
disp(['Current directory is: ',pwd]);
disp('------------------------------------------------------------------');

Config_File = strtrim(Config_File);
%-Check existence of configuration file
if ~exist(Config_File,'file')
    fprintf('Cannot find the configuration file ... \n');
    diary off; return;
end
Config_File = Config_File(1:end-2);
% Run the configuration file
eval(Config_File);

% -------------------------------------------------------------------------
%-Read in contruct parameters
%-Get field names and values
fdname = fieldnames(paralist);
fdlength = length(fdname);
for i = 1:fdlength
    fdval = paralist.(fdname{i});
    if ischar(fdval)
        eval([genvarname(fdname{i}) '= strtrim(fdval);']);
    else
        eval([genvarname(fdname{i}) '= fdval;']);
    end
end
disp('-------------- Contents of the Parameter List --------------------');
disp(paralist);
disp('------------------------------------------------------------------');
clear paralist;

stats_folder = 'stats_spm12';
%-Construct additional parameters
subjects = subjectlist;
sublength = length(subjects);

%-Initialize path parameters
sessionlink_dir = cell(sublength,1);
imagedir = cell(sublength,1);
mvmntdir = cell(sublength,2);
subject_dir = cell(sublength,1);

%-update roi list
if ~isempty(roi_list)
    ROIName = roi_list;
    NumROI = length(ROIName);
    roi_file = cell(NumROI, 1);
    for iROI = 1:NumROI
        ROIFile = spm_select('List', roi_dir, ['^', ROIName{iROI}]);
        if isempty(ROIFile)
            error('Folder contains no ROIs');
        end
        roi_file{iROI} = fullfile(roi_dir, ROIFile);
    end
end

%-set the TR
TR_val = TR;

for cnt = 1:sublength
    pfolder = ['20', subjects{cnt}(1:2)];
    
    sessionlink_dir{cnt} = fullfile(raw_server, pfolder, ....
        subjects{cnt}, 'fmri', sess_folder);
    
    imagedir{cnt} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, preprocessed_folder);
    
    mvmntdir{cnt,1} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, 'unnormalized');
    
    mvmntdir{cnt,2} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, preprocessed_folder);
    
    subject_dir{cnt} = fullfile(output_folder, pfolder, ...
        subjects{cnt}, 'fmri', 'resting_state');
end

for FCi = 1:sublength
    disp('----------------------------------------------------------------');
    fprintf('Processing subject: %s \n', subjects{FCi});
    % Create local folder holding temporary data
    temp_dir = fullfile(output_folder, ['temp_', subjects{FCi}]);
    if exist(temp_dir,'dir')
        unix(sprintf('/bin/rm -rf %s', temp_dir));
    end
    mkdir (temp_dir)
    
    cd(imagedir{FCi});
    fprintf('Copy files from: %s \n', pwd);
    fprintf('to: %s \n', temp_dir);
    if strcmp(data_type, 'nii')
        unix(sprintf('/bin/cp -af %s %s', [imagefilter, '*.nii*'], temp_dir));
        if exist('unused', 'dir')
            unix(sprintf('/bin/cp -af %s %s', fullfile('unused', [imagefilter, '*.nii*']), temp_dir));
        end
    else
        unix(sprintf('/bin/cp -af %s %s', [imagefilter, '*.img*'], temp_dir));
        unix(sprintf('/bin/cp -af %s %s', [imagefilter, '*.hdr*'], temp_dir));
        if exist('unused', 'dir')
            unix(sprintf('/bin/cp -af %s %s', fullfile('unused', [imagefilter, '*.img*']), temp_dir));
            unix(sprintf('/bin/cp -af %s %s', fullfile('unused', [imagefilter, '*.hdr*']), temp_dir));
        end
    end
    cd(temp_dir);
    unix('gunzip -fq *');
    newimagefilter = imagefilter;
    
    %-Bandpass filter data if it is set to 'ON'
    if bandpass_on == 1
        disp('Bandpass filtering data ......................................');
        bandpass_final_SPM(TR_val, fl, fh, temp_dir, imagefilter, data_type);
        %-Prefix update for filtered data
        newimagefilter = ['filtered', imagefilter];
    end
    
    %-Step 1 ----------------------------------------------------------------
    %-Extract ROI timeseries
    disp('Extracting ROI timeseries ......................................');
    [all_roi_ts, roi_name] = extract_ROI_timeseries(roi_file, temp_dir, 1, ...
        0, newimagefilter, data_type);
    all_roi_ts = all_roi_ts';
    
    % Total number of ROIs
    numroi = length(roi_name);
    
    %-Step 2 ----------------------------------------------------------------
    %-Extract white matter and CSF signals
    disp('Extract white matter and CSF signals ...........................');
    [wm_csf_ts, ~] = extract_ROI_timeseries(wm_csf_roi_file, temp_dir, 1, ...
        0, newimagefilter, data_type);
    wm_csf_ts = wm_csf_ts';
    %-Truncate ROI and global timeseries
    all_roi_ts = all_roi_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2), :);
    %global_ts = org_global_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2));
    wm_csf_ts = wm_csf_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2), :);
    NumVolsKept = size(wm_csf_ts, 1);
    wm_csf_ts = wm_csf_ts - repmat(mean(wm_csf_ts, 1), NumVolsKept, 1);
    
    %-Run through multiple ROIs
    for roicnt = 1:numroi
        rts = all_roi_ts(:,roicnt);
        
        %-STEP 3 --------------------------------------------------------------
        %-Save covariates for each ROI
        disp('Making .txt file with ROI timeseries and white matter and CSF signals ...........');
        % unix(sprintf('gunzip -fq %s', fullfile(mvmntdir{FCi,1}, 'rp_arI*')));
        % unix(sprintf('gunzip -fq %s', fullfile(mvmntdir{FCi,2}, 'rp_arI*')));
        rp2 = dir(fullfile(mvmntdir{FCi,2}, 'rp_arI*.txt'));
        rp1 = dir(fullfile(mvmntdir{FCi,1}, 'rp_arI*.txt'));
        if ~isempty(rp2)
            mvmnt = load(fullfile(mvmntdir{FCi,2}, rp2(1).name));
        elseif ~isempty(rp1)
            mvmnt = load(fullfile(mvmntdir{FCi,1}, rp1(1).name));
        else
            fprintf('Cannot find the movement file: %s \n', subjects{FCi});
            cd(script_dir);
            diary off; return;
        end
        
        %-Demeaned ROI timeseries and wm+csf signals
        rts = rts - mean(rts)*ones(size(rts, 1), 1);
        
        
        %-bandpass filtering the movement parameters
        if bandpass_on == 1
            mvmnt = bandpass_final_SPM_ts(TR_val, fl, fh, mvmnt);
        end
        mvmnt = mvmnt(NUMTRUNC(1)+1:NUMTRUNC(1)+NumVolsKept, :);
        
        %-Covariates
        ts = [rts wm_csf_ts mvmnt]; 
        
        reg_ts_dir = fullfile(subject_dir{FCi}, roi_name{roicnt}, 'regressor_ts');
        if ~exist(reg_ts_dir, 'dir')
            mkdir(reg_ts_dir);
        end
        
        reg_ts_all = fullfile(reg_ts_dir, 'roi_wm_csf_mvmnt.txt');
        save(reg_ts_all,'ts','-ascii','-tabs')
        
        %-STEP 4 --------------------------------------------------------------
        disp('Creating FC directories per subject ............................');
        final_FC_dir = fullfile(subject_dir{FCi}, roi_name{roicnt}, stats_folder);
        mkdir (final_FC_dir);
        cd (final_FC_dir);
        if exist(fullfile(pwd,'SPM.mat'), 'file')
            unix('/bin/rm -rf *');
        end
        
        %-STEP 5 --------------------------------------------------------------
        disp('Creating task_design.mat for FC ................................');
        task_design_FC(reg_ts_all, 2)
        
        
        %-STEP 6 --------------------------------------------------------------
        disp('Running FC .....................................................');
        % stats_fmri_fconnect_noscaling_spm12(temp_dir, data_type, NUMTRUNC, newimagefilter);
        stats_fmri_fconnect_noscaling(temp_dir, data_type, NUMTRUNC, newimagefilter, script_dir, TR_val);
        cd(script_dir)
    end
    % Delete temporary folder
    % unix('/bin/rm -rf temp');
    unix(sprintf('/bin/rm -rf %s', temp_dir));
end
cd(script_dir);
c = fix(clock);
disp('==================================================================');
fprintf('Functional Connectivity finishes at %d/%02d/%02d %02d:%02d:%02d\n',c);
disp('==================================================================');

diary off;
clear all;
close all;
end
