% written by hao (2017/09/26)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% Set up
taskname = 'ANT';
conname  = {'Alert','Orient'};
netname  = 'Ventral';
subjlist = '/Users/hao1ei/xScript/Image/BrainNetwork/list_test.txt';

roi_form  = 'mat'; % 'mat' or 'nii'
roi_dir   = '/Users/hao1ei/Downloads/Test/AttNetVentral_Yeo/AttNetVentral_Yeo';
ppifolder = 'stats_spm12_swcar_gPPI_mask';
filetype  = 'spmT'; % 'spmT' or 'con'

spm8_dir  = '/Users/hao1ei/xToolbox/spm8'; % spm8 directory
firlv_dir = '/Users/hao1ei/Downloads/Test/FirLv';

%% ===================================================================== %%
% Add Path
addpath (genpath (spm8_dir));

% Acquire Subject list
fid  = fopen (subjlist); sublist = {}; cnt  = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    sublist (cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose (fid);

% Acquire ROI file & list
roi_list = dir (fullfile (roi_dir, ['*.', roi_form]));
roi_list = struct2cell (roi_list);
roi_list = roi_list (1, :);
roi_list = roi_list';

%% Extract Correlation Matrix
for con_i = 1:length(conname)
    allvector = {'Scan_ID'};
    
    for sub_i = 1:length(sublist)
        allvector{sub_i+1,1}=sublist{sub_i,1};
        roiloop1 = 1;
        roiloop2 = 0;
        
        for roi_i = 1:length(roi_list)^2
            roiloop2 = roiloop2 + 1;
            if roiloop2 > length(roi_list)
                roiloop1 = roiloop1 + 1;
                roiloop2 = 1;
            end
            
            allvector{1,roi_i+1} = [conname{1,con_i}, ...
                '_',num2str(roiloop1),'_',num2str(roiloop2)];
            roifile = fullfile(roi_dir, roi_list{roiloop2,1});
            yearID = ['20', sublist{sub_i,1}(1:2)];
            subjfile = fullfile (firlv_dir, yearID, sublist{sub_i,1}, ...
                'fmri', 'stats_spm12', taskname, ppifolder, ...
                ['PPI_',roi_list{roiloop1,1}(1:end-4)], ...
                [filetype,'_PPI_',conname{1,con_i},'_',sublist{sub_i,1},'.img']);
            
            if strcmp(roi_form, 'nii')
                mean = rex(subjfile,roifile);
            end
            if strcmp(roi_form, 'mat')
                roi_obj = maroi(roifile);
                roi_data = get_marsy(roi_obj, subjfile, 'mean');
                mean = summary_data(roi_data);
            end
            
            allvector{sub_i+1,roi_i+1} = mean;
        end
    end
    
    % eval(['save res_extr_corrvect_', task_name, ' allvector']);
    save_name = ['res_corrvect_',taskname,'_',conname{1,con_i},'_',netname,'.csv'];
    
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(allvector);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, allvector{row_i,:}); end;
    fclose(fid);
end



%% Extract Correlation Matrix Done
disp('=== Extract Vector Done ===');
