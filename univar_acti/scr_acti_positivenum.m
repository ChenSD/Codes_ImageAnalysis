% Written by Hao (2017/10/12)
% haolpsy@gmail.com
% Qinlab.BNU
clear
restoredefaultpath

%% Set up
img_type   = 'spmT'; % 'spmT' or 'con'
task_name  = 'ANT';
cond_name  = {'Avoxelnum';'Ovoxelnum';'Cvoxelnum'};
mask_file  = {'/Users/hao1ei/xData/BrainDev_ANT/Image/ROI/NeuroSynth/ANT_A_fdr01_126.nii';
    '/Users/hao1ei/xData/BrainDev_ANT/Image/ROI/NeuroSynth/ANT_C_fdr01_112.nii';
    '/Users/hao1ei/xData/BrainDev_ANT/Image/ROI/NeuroSynth/ANT_O_fdr01_100.nii'};

spm_dir    = '/Users/hao1ei/xToolbox/spm12';
firlv_dir  = '/Users/hao1ei/Downloads/Test/FirLv';
script_dir = '/Users/hao1ei/xScript/Image/RSA';
subjlist   = fullfile(script_dir,'list_test.txt');

%% Calculate Positive Activation Voxels
% Read subject list
fid = fopen(subjlist); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list + 1; %#ok<*SAGROW>
end
fclose(fid);

% Add path
addpath ( genpath (spm_dir));
addpath ( genpath (script_dir));

allres = {'Scan_ID'};
for con_i = 1:length(cond_name)
    allres{1,con_i+1} = cond_name{con_i,1};
    mask = spm_read_vols(spm_vol(mask_file{con_i,1}));
    
    for sub_i = 1:length(sublist)
        allres{sub_i+1,1} = sublist{sub_i,1};
        
        yearID  = ['20',sublist{sub_i,1}(1:2)];
        sub_file = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
            ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
            [img_type,'_000',num2str(con_i),'.nii']);
        
        sub_img = spm_read_vols(spm_vol(sub_file));
        sub_vect = sub_img(mask(:)==1);
        voxelnum = num2str(sum(sub_vect>0));
        
        allres{sub_i+1,con_i+1} = voxelnum;
    end
end

%% Save Results
save_name = ['res_acti_positivenum_', task_name, '.csv'];

fid = fopen(save_name, 'w');
[nrows,ncols] = size(allres);
col_num = '%s';
for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
col_num = [col_num, '\n'];
for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end;
fclose(fid);

%% Done
clear all
disp('=== RSA Calculate Done ===');