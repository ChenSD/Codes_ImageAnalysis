% written by hao (2017/10/12)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% Set up
img_type  = 'spmT'; % 'spmT' or 'con'
task_name = 'ANT';
thresval  = 0.5;
mask_file = '/Users/hao1ei/Downloads/Test/ANT_AllCond_union_roi.nii';

spm_dir    = '/Users/hao1ei/xToolbox/spm12';
firlv_dir  = '/Users/hao1ei/Downloads/Test/FirLv';
script_dir = '/Users/hao1ei/xScript/Image/ActiveAnaly';
subjlist   = fullfile(script_dir,'list_test.txt');

%% Calculate Overlap Voxels in Mask
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

allres = {'Scan_ID','OverlapNum'};
for sub_i = 1:length(sublist)
    yearID = ['20',sublist{sub_i,1}(1:2)];
    mask   = spm_read_vols(spm_vol(mask_file));
    allres{sub_i+1,1} = sublist{sub_i,1};
    
    sub_fileA = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
        ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
        [img_type,'_0001.nii']);
    sub_fileO = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
        ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
        [img_type,'_0002.nii']);
    sub_fileC = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
        ['fmri/stats_spm12/', task_name, '/stats_spm12_swcar'], ...
        [img_type,'_0003.nii']);
    
    sub_imgA = spm_read_vols(spm_vol(sub_fileA));
    sub_imgA(find(sub_imgA<thresval))=0;
    sub_imgA(find(sub_imgA>=thresval))=1;
    
    sub_imgO = spm_read_vols(spm_vol(sub_fileO));
    sub_imgO(find(sub_imgO<thresval))=0;
    sub_imgO(find(sub_imgO>=thresval))=1;
    
    sub_imgC = spm_read_vols(spm_vol(sub_fileC));
    sub_imgC(find(sub_imgC<thresval))=0;
    sub_imgC(find(sub_imgC>=thresval))=1;
    
    overlap_comb = sub_imgA & sub_imgO & sub_imgC & mask;
    
    sub_vect = overlap_comb(mask(:)==1);
    voxelnum = num2str(sum(sub_vect>0));
    
    allres{sub_i+1,2} = voxelnum;    
end

%% Save Results
save_name = ['res_acti_overlapnum_', task_name, '.csv'];

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