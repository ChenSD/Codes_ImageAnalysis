% written by hao (2017/08/06)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% Set up
ConvFunc = 'mat2nii'; % 'nii2mat'

% Directory with ROIs to convert
SPM_dir     = '/Users/hao1ei/xToolbox/spm12';
ROI_sourdir = '/Users/hao1ei/xFiles/Projects/BrainDev_ANT/Image/mask/ParietalSubregions4Attention';

%% ROI format convert
% For batch converting the contents of a directory of ROIs
addpath (genpath (SPM_dir));

if strcmp(ConvFunc,'mat2nii')
    ROI_savedir = [ROI_sourdir,'_nii',];
    if ~exist (ROI_savedir,'dir')
        mkdir (ROI_savedir)
    end
    
    ROI_namearray = dir(fullfile(ROI_sourdir, '*.mat'));
    for ROI_num = 1:length(ROI_namearray)
        ROI_array{ROI_num} = maroi(fullfile(ROI_sourdir, ROI_namearray(ROI_num).name)); %#ok<*SAGROW>
        ROI_conv = ROI_array{ROI_num};
        ROI_name = strtok(ROI_namearray(ROI_num).name, '.');
        save_as_image(ROI_conv, fullfile(ROI_savedir, [ROI_name,'.nii']))
    end
end

if strcmp(ConvFunc,'nii2mat')
    ROI_savedir = [ROI_sourdir,'_mat',];
    if ~exist (ROI_savedir,'dir')
        mkdir (ROI_savedir)
    end
    
    ROI_namearray = dir(fullfile(ROI_sourdir, '*.nii'));
    for ROI_num = 1:length(ROI_namearray)
        ROI_name = ROI_namearray(ROI_num).name;
        ROI_conv = maroi_image(struct('vol', spm_vol(fullfile(ROI_sourdir,ROI_name)), 'binarize', 0, 'func', 'img'));
        ROI_conv = maroi_matrix(ROI_conv);
        ROI_conv = label(ROI_conv, ROI_name);
        saveroi(ROI_conv, fullfile(ROI_savedir, [strtok(ROI_namearray(ROI_num).name, '.'),'_roi.mat']))
    end
end
