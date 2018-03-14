function [signalchange] = roi_signalchange_onesubject_dcan(ROIs, subject_stats_dir, event_duration)

% Computes the percent signal change in each condition, for the
% specified ROI list and SPM.mat design (one subject). Uses the MarsBar tools. Works for
% event-related or block designs.
% 
% ASSUMPTION -> EVENTS ARE IDENTICAL ACROSS SESSIONS
%
% ROIs (cell array or directory string): cell array with filenames of
% ROIs for which to compute the signal change, or directory (the
% *_roi.mats in that dir will be used)
%
% subject_stats_dir (string): directory containing SPM.mat
%
% event_duration: the range over each event/block for which to compute the percent signal change.
% Choice A. if [], if the event duration is computed based on SPM task design
% Choice B. 2-element vector, e.g. [12 30], useful for block-design
% to use 12th-30th seconds of the fitted event response while computing % signal changes
%
% is_similar_multisession = 1 if sessions are similar
% signalchange{Roi}{Session}(Condition) is the signal change for
% Condition in Session for Roi.
%

%--------------------------------------------------------------------------
% genghaiyang change the marsbar path
% addpath /home/yunzhe/Documents/MATLAB/spm12/toolbox/marsbar;
% addpath /home/yunzhe/Documents/MATLAB/spm12/toolbox/marsbar/spm5/;
% addpath /home/yunzhe/Documents/MATLAB/spm12

% SET OUTPUT VARIABLES
% initialize output and temp output
signalchange = {};
signalchange.subject_stats_dir = subject_stats_dir; % subject ID

% some params
event_string = 'signed max-min';

% reminder
display(['Using ', event_string, [' to compute percent signal change.' ...
    ' See MarsBar FAQ for explanation']]);

%--------------------------------------------------------------------------
% get ROIs
if iscell(ROIs) % already a cell array
    ROI_list = ROIs;
elseif ischar(ROIs) % is string, check if valid directory
    if isdir(ROIs)
        [files,subdir] = spm_select('List',ROIs,'.*\_roi.mat$');
        if (isempty(files)) error('Folder contains no ROIs'); end
        for i=1:size(files,1)
            ROI_list{i} = strcat(ROIs, '/', files(i,:));
        end
    end
else
    error('Please enter a valid ROI cell array or folder');
end

%--------------------------------------------------------------------------
% check EVENT DURATION
if (isempty(event_duration))
    DEFAULT_EVENT = 1; % compute signalchange based on event
    % durations in SPM
else
    DEFAULT_EVENT = 0; % use window
end

%--------------------------------------------------------------------------
% load SPM.mat
SPM_mat = [subject_stats_dir, '/SPM.mat'];
load(SPM_mat);
% get number of sessions and ROIs
nsess = size(SPM.nscan,2);
nroi = length(ROI_list);

% unzip images from all sessions
imgdirs = {};
for i=1:nsess
    if i ==1
      first_img_in_sess = 1;
    else
      first_img_in_sess = sum(SPM.nscan(1:i-1))+1;
    end
    [p,n,e] = fileparts(SPM.xY.VY(first_img_in_sess).fname);
    imgtype = e(2:end);
    imgdir = p;
    % Z = unzip_if_zipped(imgdir,imgstring); %VM
    % keep track of, to zip back up later
    if strcmp(imgtype, 'img')
      unix(['gunzip -fq ', imgdir, '/*.img.gz']); %VM avoid extra script
      unix(['gunzip -fq ', imgdir, '/*.hdr.gz']); %VM avoid extra script
    else
      unix(['gunzip -fq ', imgdir, '/swcarI.nii.gz']);
    end
    imgdirs{i} = imgdir;
end

%--------------------------------------------------------------------------

for r=1:nroi % for each ROI

    display(['Processing ROI: ', ROI_list{r}])
    
    roi_obj = maroi(ROI_list{r}); 

    signalchange.roi_name{r} = label(roi_obj); % set ROI name
    

    D  = mardo(SPM_mat);

    %save roi_obj.mat roi_obj
    % Fetch data into marsbar data object
    Y  = get_marsy(roi_obj, D, 'wtmean');
 
    % Get contrasts from original design
    xCon = get_contrasts(D);
    % Estimate design on ROI data
    E = estimate(D, Y);
    
%     E = estimate(D, Y, struct('redo_covar', 1, ... 
% 			    'redo_whitening', 1)); % original
% 						   % covariance for
% 						   % each ROI
    
    % Put contrasts from original design back into design object
    E = set_contrasts(E, xCon);
    % Get definitions of all events in model
    % (only covariates of interest, which were specified in SPM.Sess)
    [e_specs, e_names] = event_specs(E);
    n_events = size(e_specs, 2);

    %--------------------------------------------------------------------------
    %if EVENT  % EVENT-RELATED DESIGN

    % grab durations of events for each condition of interest
    events_per_sess = n_events/nsess;  %!!! SD Caveat 1: What if different # event types for each session?

    for session=1:nsess
        for event=1:events_per_sess;
            e_s = (session-1)*events_per_sess+event;
	    
% Rev: Aug 27, 2008.  Sessions are always treated as NOT BEING SIMILAR
%             if (is_similar_multisession == 1) % sessions are similar
%                 s = 1;
%                 e = e_s;
%             end
%             if (is_similar_multisession == 0) % sessions are not similar
                s = session;
                e = event;
%            end

            signalchange.event_name{s}{e} = e_names(e_s); % set event name
            
            SPM_durs = SPM.Sess(session).U(event).dur;
            durs = SPM_durs;
	
            pcs = [];
            ts  = {};
            LEN = 0;
            if DEFAULT_EVENT  % Use default SPM event duration or different durations
              for d=1:length(durs),	
                [pcs(d), ts{d}] = event_signal_dcan(E, e_specs(:,e_s), durs(d), event_string);
                LEN = max(LEN, length(ts{d}));
              end % for d	
            else
                % Use specified event window
              for d=1:length(durs),	
                [pcs(d), ts] = event_signal_dcan(E, e_specs(:,e_s), durs(d), 'window', event_duration, bf_dt(E));
                LEN = max(LEN, length(ts{d}));
              end % for d
            end
            signalchange.data_roi_sess_event{r}{s}(e) = mean(pcs);
            
            % If the event durations are different, zero pad at the tail
            % before averaging the timeseries.
            timeseries = [];
            for l = 1:size(ts, 2)
                timeseries(:, l) = [ts{l}; zeros(LEN - length(ts{l}), 1)];
            end
            signalchange.ts{r}{s}{e} = mean(timeseries, 2);
            
        end % events in session
    end % sessions

end % for each roi
%--------------------------------------------------------------------------

% zip again
display('Zipping images...');
for j=1:length(imgdirs)
    %zip_imgs(imgdirs{j},imgstring); %VM
    if strcmp(imgtype,'img')
      unix(['gzip -fq -1 ' , imgdirs{j}, '/*.img']); % VM avoid extra scrip;
    else
      unix(['gzip -fq -1 ' , imgdirs{j}, '/swcarI.nii']);
    end
end
display('Done.');

%--------------------------------------------------------------------------
% try getting time course from event-fitted and then computing max sc
% from /fs/plum1_share2/boyce/movies/create_fitted_event_response_mts_wm_2000.m
% signal change
% create fitted time courses
%	[this_tc dt] = event_fitted(E, event_spec, event_duration);    	

	% fitted time course into % signal change
%	tc(:, j) = this_tc / mean(block_means(E)) * 100;	% since block_means(E) returns an Nx1 matrix, N=no. of sessions 

%    end % for j

%    tc_subj{i} = tc;
