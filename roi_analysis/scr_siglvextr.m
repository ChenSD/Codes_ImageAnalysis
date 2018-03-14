% written by hao (2017/08/06)
% rock3.hao@gmail.com
% qinlab.BNU
clear

%% Set up
task_name = 'ANT';
extr_val  = 'beta'; % 'beta' / 'sigchg' / 'tsc' / 'tsc_pervox'
con_name  = {'NoCue','DoubCue','CentCue','SpatCue','InconFlk','ConFlk'};
firlv_dir = '/Users/hao1ei/Downloads/Test/FirLv';
siglv_dir = '/Users/hao1ei/xCode/Image/ROICode/res_siglv';
subjlist  = '/Users/hao1ei/xCode/Image/ROICode/list_test.txt';

%% ROI Signal Extract
% Acquire Subject list
fid  = fopen (subjlist); Subj = {}; Cnt  = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    Subj (Cnt,:) = linedata{1}; Cnt = Cnt + 1; %#ok<*SAGROW>
end
fclose (fid);

switch extr_val
    case 'beta'
        load(fullfile(siglv_dir,'ROI_beta_average.mat'));
        for sig_i = 1:length(signal)
            sigmatch{sig_i,1}= signal{1,sig_i}.subject_stats_dir;
        end
        
        for con_i = 1:length(con_name)
            sigres = {'Scan_ID'};
            load(fullfile(siglv_dir,'x.mat'));
            for roi_i = 1:length(ROIName)
                sigres{1,roi_i+1} = ROIName{roi_i,1}(1:end-4); %#ok<*AGROW>
            end
            
            for sub_i = 1:length(Subj)
                sigres{sub_i+1,1} = Subj{sub_i,1};
                YearID = ['20', Subj{sub_i,1}(1:2)];
                sub_match = fullfile(firlv_dir, YearID, Subj{sub_i,1}, ...
                    ['/fmri/stats_spm12/',task_name,'/stats_spm12_swcar']);
                
                for roi_i = 1:length(ROIName)
                    sigvl = (signal{1, strcmp(sigmatch, sub_match)}.data_roi_sess_event{1, roi_i}{1,1}(1, con_i) + ...
                        signal{1, strcmp(sigmatch, sub_match)}.data_roi_sess_event{1, roi_i}{1,2}(1,con_i))/2;
                    sigres{sub_i+1,roi_i+1} = sigvl;
                end
            end
            
            %% Save Results
            save_name = ['res_siglv_',con_name{1,con_i}, '.csv'];
            
            fid = fopen(save_name, 'w');
            [nrows,ncols] = size(sigres);
            col_num = '%s';
            for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
            col_num = [col_num, '\n'];
            for row_i = 1:nrows; fprintf(fid, col_num, sigres{row_i,:}); end;
            fclose(fid);
        end
        
% ----------------------------------------------------------------------- %
% ANT_Alert    = {'Scan_ID'};
% ANT_Orient   = {'Scan_ID'};
% ANT_Conflict = {'Scan_ID'};
% for roi_i = 1:length(ROIName)
%     ANT_Alert{1,roi_i+1} = ROIName{2,1}(1:end-4); %#ok<*AGROW>
%     ANT_Orient{1,roi_i+1} = ROIName{2,1}(1:end-4); %#ok<*AGROW>
%     ANT_Conflict{1,roi_i+1} = ROIName{2,1}(1:end-4); %#ok<*AGROW>
% end
% for sub_i = 1:length(Subj)
%     ANT_Alert{sub_i+1,1} = Subj{sub_i,1};
%     ANT_Orient{sub_i+1,1} = Subj{sub_i,1};
%     ANT_Conflict{sub_i+1,1} = Subj{sub_i,1};
%     for roi_i = 1:length(ROIName)
%         ANT_Alert{sub_i+1,roi_i+1} = ...
%             SigLv_DoubCue{sub_i+1,roi_i+1} - SigLv_NoCue{sub_i+1,roi_i+1};
%         ANT_Orient{sub_i+1,roi_i+1} = ...
%             SigLv_SpatCue{sub_i+1,roi_i+1} - SigLv_CentCue{sub_i+1,roi_i+1};
%         ANT_Conflict{sub_i+1,roi_i+1} = ...
%             SigLv_InconFlk{sub_i+1,roi_i+1} - SigLv_ConFlk{sub_i+1,roi_i+1};
%     end
% end
% save xroi_siglv_extr ANT_*
% ----------------------------------------------------------------------- %
    case 'sigchg'
        load(fullfile(siglv_dir,'ROI_signalchange.mat'));
    case 'tsc'
        load(fullfile(siglv_dir,'ROI_tscore_average.mat'));
    case 'tsc_pervox'
        load(fullfile(siglv_dir,'ROI_tscore_percent_voxels.mat'));
end

%% Done
clear all
disp('=== All Done ===');
