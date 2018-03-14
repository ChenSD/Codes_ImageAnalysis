function [beta_average] = roi_beta_onesubject(ROIs, subject_stats_dir)
% Removing the argument is_similar_multisession from the parameter list of
% the function.  Also commenting out a part of the IF condition based on
% the variable is_similar_multisession.

% addpath /home/fmri/fmrihome/SPM/spm8/toolbox/marsbar/;
% addpath /home/fmri/fmrihome/SPM/spm8/toolbox/marsbar/spm5/;
% addpath /home/fmri/fmrihome/SPM/spm8/

% initialize input

session = 1; % NOTE ONLY 1 session for beta scores 

% initialize output 
beta_average = {};
beta_average.subject_stats_dir = subject_stats_dir; % subject ID

%--------------------------------------------------------------------------
% reminder
% display(['Using threshold ', mat2str(tscore_threshold), [' to compute tscore.' ...
% 		    ' See MarsBar FAQ for explanation']]);
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
% load SPM.mat  
SPM_mat = [subject_stats_dir, '/SPM.mat'];
load(SPM_mat);

% get number of sessions and ROIs
nroi = length(ROI_list);
nbetas = size(SPM.Vbeta, 2);  
nsess = size(SPM.nscan,2);
% events_per_sess = nbetas/nsess;
events_per_sess = (nbetas - nsess)/nsess;   % The above line is commented and corrected with this new line by Kumar.

e = 0; 
for session = 1:nsess
%    if (is_similar_multisession == 1) % sessions are similar
        s = session; % update session
        e = 0; % reset e
%     end
%     if (is_similar_multisession == 0) % sessions are not similar
%         s = 1;
%     end

    for event = 1:events_per_sess
        e_s = (session-1)*events_per_sess + event; % actual index into Vbeta

        if (strfind(SPM.Vbeta(e_s).descrip,'bf(1)')) % do not use derivatives bf(2)
            % or constant terms
            e = e + 1; % update event index
            
            beta_img = strcat(SPM.Vbeta(e_s).fname); % removed prefix, SPM now has full filename
 
            % If the SPM mat file is old (how old ??), the beta image 
            % filename may not have the path.
            if(isempty(regexp(beta_img, '/')))
              beta_img = strcat(subject_stats_dir, '/', SPM.Vbeta(e_s).fname);
            end
            beta_average.event_name{s}{e} = SPM.Vbeta(e_s).descrip; ...
		
            unix(['gunzip -fq ', beta_img]); % unzip if zipped

            for r=1:nroi % for each ROI
                % setup ROI
                rois = ROI_list{r};

                roi_obj = maroi(ROI_list{r});
                beta_average.roi_name{r} = label(roi_obj); % ROI names

                roi_betascores = getdata(roi_obj, beta_img, 'l'); % include NaNs
                roi_betascores(isnan(roi_betascores)) = [];
                beta_average.data_roi_sess_event{r}{s}(e) = mean(roi_betascores(find(roi_betascores < inf)));
                % leave out NaNs in mean
            end
            %unix(['gzip -q -1', beta_img]); % gzip back, not for now
        end
    end
end
