function scr_rsFC_roi2roi(Config_File)
tic
% This is the configuration template file for copy data from a group of participants
% Show the system information and write log files
warning('off', 'MATLAB:FINITE:obsoleteFunction')
c = fix(clock);
disp('==================================================================');
fprintf('copy files start at %d/%02d/%02d %02d:%02d:%02d\n',c);
disp('==================================================================');
% fname = sprintf('copy and rename files -%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
% diary(fname);
disp(['Current directory is: ',pwd]);
disp('------------------------------------------------------------------');
% ------------------------------------------------------------------------
% Check existence of the configuration file
% ------------------------------------------------------------------------

Config_File = strtrim(Config_File);
if ~exist(Config_File,'file')
    fprintf('Cannot find the configuration file ... \n');
    diary off;
    return;
end
Config_File = Config_File(1:end-2);

% ------------------------------------------------------------------------
% Read individual stats parameters
% ------------------------------------------------------------------------
eval(Config_File);
clear Config_File;

scriptdir     = script_dir;
raw_server    = strtrim(paralist.preproc_dir);
subjlist_file = strtrim(paralist.subjlist_file);
output_folder = strtrim(paralist.output_dir);
sess_folder   = strtrim(paralist.sess_folder);
data_type     = strtrim(paralist.data_type);
imagefilter   = strtrim(paralist.imagefilter);
roi_dir       = strtrim(paralist.roi_dir);
roi_list      = strtrim(paralist.roi_list);

NFRAMES  = paralist.NFRAMES;
NUMTRUNC = paralist.NUMTRUNC;
TR_val   = paralist.tr_val;

fl = paralist.fl;
fh = paralist.fh;

bandpass_on     = paralist.bandpass_on;
wm_csf_roi_file = paralist.wm_csf_roi_file;

% ------------------------------------------------------------------------
% Load subject list, constrast file and batchfile
% ------------------------------------------------------------------------
subjects = subjlist_file;
numsubj  = length(subjects);
imagedir = cell(numsubj,1);

% movement states
mvmntdir = cell(numsubj,2);

% create results directory
outputdir = output_folder;
mkdir (fullfile(outputdir, 'ROI_ts'))
mkdir (fullfile(outputdir, 'r_map'))

% update roi list
if ~isempty(roi_list)
    ROIName = roi_list;
    NumROI = length(ROIName);
    roi_file = cell(NumROI, 1);
    for iROI = 1:NumROI
        ROIFile = spm_select('List', roi_dir, ['^', ROIName{iROI}]);
        % save roifile.mat ROIFile
        if isempty(ROIFile)
            error('Folder contains no ROIs');
        end
        roi_file{iROI} = fullfile(roi_dir, ROIFile);
    end
end

for cnt = 1:numsubj
    pfolder = ['20', subjects{cnt}(1:2)];
    % sessionlink_dir{cnt} = fullfile(raw_server, pfolder{cnt}, ....
    %                                subjects{cnt}, 'fmri', sess_folder);
    imagedir{cnt} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, 'smoothed_spm12');
    mvmntdir{cnt,1} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, 'unnormalized');
    mvmntdir{cnt,2} = fullfile(raw_server, pfolder, subjects{cnt}, ...
        'fmri', sess_folder, 'smoothed_spm12');
end

for FCi = 1:numsubj
    disp('----------------------------------------------------------------');
    fprintf('Processing subject: %s \n', subjects{FCi});
    temp_dir = strcat(output_folder, '/temp_',subjects{FCi});
    if exist(temp_dir, 'dir')
        unix(sprintf('/bin/rm -rf %s', temp_dir));
    end
    mkdir(temp_dir);
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
    cd (temp_dir);
    unix ('gunzip -fq *');
    newimagefilter = imagefilter;
    
    % Bandpass filter data if it is set to 'ON'
    if bandpass_on == 1
        disp('Bandpass filtering data ......................................');
        bandpass_final_SPM(2, fl, fh, temp_dir, imagefilter, data_type);
        % Prefix update for filtered data
        newimagefilter = ['filtered', imagefilter];
    end
    % Step 1 -------------------------------------------------------------
    % Extract ROI timeseries
    disp ('Extracting ROI timeseries ....................................');
    [all_roi_ts, roi_names] = extract_ROI_timeseries_eigen1(roi_file, ...
        temp_dir, 1, 0, newimagefilter, data_type);
    all_roi_ts = all_roi_ts';
    % Total number of ROIs
    numroi = length(roi_names);
    
    % Step 2 -------------------------------------------------------------
    % Extract white matter and CSF signals
    disp ('Extract white matter and CSF signals .........................');
    [wm_csf_ts, ~] = extract_ROI_timeseries_eigen1(wm_csf_roi_file, ...
        temp_dir, 1, 0, newimagefilter, data_type);
    wm_csf_ts = wm_csf_ts';
    
    % Truncate ROI and global timeseries,is this detrend prepross?
    % all_roi_ts = all_roi_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2), :);
    all_roi_ts = all_roi_ts(NUMTRUNC(1)+1:NFRAMES-NUMTRUNC(2), :);
    % global_ts = org_global_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2));
    
    % wm_csf_ts = wm_csf_ts(NUMTRUNC(1)+1:end-NUMTRUNC(2), :);
    wm_csf_ts = wm_csf_ts(NUMTRUNC(1)+1:NFRAMES-NUMTRUNC(2), :);
    NumVolsKept = size(wm_csf_ts, 1);
    wm_csf_ts = wm_csf_ts - repmat(mean(wm_csf_ts, 1), NumVolsKept, 1);
    
    % ====================================================================
    % STEP 3 -------------------------------------------------------------
    % Filtering out wm_csf_ts and mvnt
    
    % Run through multiple ROIs
    for roicnt = 1:numroi
        rts = all_roi_ts(:,roicnt);
        % Extracte covariates for each ROI
        disp('Regressing out wm, csf, and movement signals .................');
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
            cd(scriptdir);
            diary off; return;
        end
        
        % Demeaned ROI timeseries and wm+csf signals
        rts = rts - mean(rts)*ones(size(rts, 1), 1);
        
        % bandpass filtering the movement parameters
        if bandpass_on == 1
            mvmnt = bandpass_final_SPM_ts(TR_val, fl, fh, mvmnt);
        end
        % mvmnt = mvmnt(NUMTRUNC(1)+1:NUMTRUNC(1)+NumVolsKept, :);
        mvmnt = mvmnt(NUMTRUNC(1)+1:NFRAMES-NUMTRUNC(2), :);
        
        % ts with Covariates
        % ts = [rts wm_csf_ts mvmnt];
        % Regressor for intercept
        
        xm = ones(length(rts),1);
        xm = xm./norm(xm);
        % D = [xm global_signal csf_signal(:) wm_signal(:)];
        D = [xm wm_csf_ts mvmnt];
        
        % Regressed out covariates of no interest
        % x = down_sample_data(:,r);
        % beta_hat = D\x;
        % x = x - (D*beta_hat);
        beta_hat = D\rts;
        rts = rts - (D*beta_hat);
        all_roi_ts(:,roicnt) = rts;
    end
    outputfile = strcat(output_folder, '/roi_ts/roi_ts_', subjects{FCi}, '_', sess_folder, '.mat');
    save(outputfile, 'all_roi_ts', 'roi_names');
    
    % Compute Functional Connectivity
    tempMatrix = zeros(NumROI,NumROI);
    CONNECTIVITY_MEASURE = 'pearson';
    if(strcmpi(CONNECTIVITY_MEASURE,'pearson'))
        % W = corrcoef(all_roi_ts);
        W = ComputePearsonCorrelations(all_roi_ts);
    elseif (strcmpi(CONNECTIVITY_MEASURE,'wavelet'))
        W = ComputeWaveletCorrelations(all_roi_ts);
    end
    
    tempMatrix = tempMatrix + W;
    % PIPELINE = 'swcar';
    rmap_name=strcat(output_folder, '/r_map/r_map_', subjects{FCi}, '_', sess_folder, '.mat');
    save(rmap_name,'W');
    % unix(sprintf('gzip -fq %s', strcat(smootheddir,[PIPELINE 'I.nii'])));
    % GroupMatrix(:,:,FCi) = tempMatrix;
    
    % cd(datapath);
    % save(['Group_' PIPELINE '_network_23ROIs_wm_csf_mvmnt_eigen1.mat'], 'GroupMatrix');
    % cd(currentdir);
    clear all_roi_ts W
    unix (sprintf('rm -r %s',temp_dir));
end
cd   (scriptdir)
disp ('Job finished');
toc
end