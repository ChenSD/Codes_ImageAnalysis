% written by hao (2017/08/06)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% Set up
subj_list = '/Users/hao1ei/xCode/Image/ROICode/list_test.txt';
roi_dir   = '/Users/hao1ei/Downloads/Test/AttNetDorsal_Yeo';
roi_name  = 'DorsalAtt_1_roi.mat';

spm8_dir  = '/Users/hao1ei/xToolbox/spm8'; % must spm8
firlv_dir = '/Users/hao1ei/Downloads/Test/FirLv';

con_name  = {'Alert';'Orient';'Conflict'};
con_num   = ['1'    ;     '2';       '3'];

%% ===================================================================== %%
% Add Path
addpath (genpath (spm8_dir));

% Acquire Subject list
fid  = fopen (subj_list); subj = {}; Cnt  = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    subj (Cnt,:) = linedata{1}; Cnt = Cnt + 1; %#ok<*SAGROW>
end
fclose (fid);

%% Extract Mean Value
roifile  = fullfile(roi_dir, roi_name);
roi_form = roifile(end-2:end);

for con_i = 1:length(con_name)
    mean = {'Scan_ID',roi_name(1:end-4)};
    for sub_i = 1:length(subj)
        YearID = ['20', subj{sub_i,1}(1:2)];
        subjfile = fullfile (firlv_dir, YearID, subj{sub_i,1}, ...
            '/fmri/stats_spm12/ANT/stats_spm12_swcar/', ...
            ['con_000',con_num(con_i,1),'.nii']);
        
        mean{sub_i+1,1} = subj{sub_i,1};
        if strcmp(roi_form, 'nii')
            mean{sub_i+1,2} = rex(subjfile,roifile);
        end
        if strcmp(roi_form, 'mat')
            roi_obj = maroi(roifile);
            roi_data = get_marsy(roi_obj, subjfile, 'mean');
            mean{sub_i+1,2} = summary_data(roi_data);
        end
    end
    
    %% Save Results
    save_name = ['res_extrmean_1roi_', con_name{con_i}, '.csv'];
    
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(mean);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, mean{row_i,:}); end;
    fclose(fid);
    
end

%% Done
clear all
disp('=== Extract Done ===');