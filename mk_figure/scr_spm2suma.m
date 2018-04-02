% written by hao (2017/10/15)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Set up
file_head  = 'Merge';
seclv_dir  = '/Users/hao1ei/xData/BrainDev_ANT/Image';
script_dir = '/Users/hao1ei/xScript/Image/MkFigure';
group      = {'Fig_SUMA'};
% group      = {'GrpAll';'NeuroSynth';
%               'GrpCBDA';'GrpCBDC';'GrpSWUA';'GrpSWUC';
%               'MergeC07';'MergeC08';'MergeC09';'MergeC10';
%               'MergeC11';'MergeC12';'MergeC0708';'MergeC1112'};

%% ===================================================================== %%
% Convert spmT map to afni+tlrc.
for grp = 1:length(group)
    grp_dir      = fullfile(seclv_dir, group{grp,1});
    niiconvlist = dir(fullfile(grp_dir, [file_head,'*.nii']));
    cd (grp_dir)
    for nii = 1: length(niiconvlist)
        niifile = niiconvlist(nii).name;
        unix (['3dcopy ', niifile, ' ', niifile(1:end-4)]);
        unix (['3drefit -view tlrc -space MNI ', niifile(1:end-4), '+tlrc.']);
    end
end

cd (script_dir)
disp('=== Convert Done ===');