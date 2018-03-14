% hao adapted for his poject on September 12, 2017 from Qin
% ======================================================================== %
clear
restoredefaultpath

%% Set up configure
% Set up
roi_form   = 'nii';
roinum     = 'yes'; % 'yes' or 'no'
radius     = 6;
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
script_dir = '/Users/hao1ei/xScript/Image/ROICode';

% This is the folder which you will save defined ROIs
roi_folder = '/Users/hao1ei/Downloads/Test/ROIscrtest/roi_mat';

% Define ROIs by specifying name, coordinates and radius
myroi{1}.name    = 'MergeC_A_SPL_L';
myroi{1}.coords  = [-28,-64,54];
myroi{1}.radius  = radius;

myroi{2}.name    = 'MergeC_A_SPL_R';
myroi{2}.coords  = [28,-64,52];
myroi{2}.radius  = radius;

myroi{3}.name    = 'MergeC_A_FS_L';
myroi{3}.coords  = [-30,-4,52];
myroi{3}.radius  = radius;

myroi{4}.name    = 'MergeC_A_FS_R';
myroi{4}.coords  = [26,2,54];
myroi{4}.radius  = radius;

myroi{5}.name    = 'MergeC_O_SPL_L';
myroi{5}.coords  = [-30,-60,56];
myroi{5}.radius  = radius;

myroi{6}.name    = 'MergeC_O_SPL_R';
myroi{6}.coords  = [22,-64,48];
myroi{6}.radius  = radius;

myroi{7}.name    = 'MergeC_C_ACC';
myroi{7}.coords  = [-4,2,56];
myroi{7}.radius  = radius;

myroi{8}.name    = 'MergeC_C_dACC';
myroi{8}.coords  = [2,24,36];
myroi{8}.radius  = radius;

myroi{9}.name    = 'MergeC_C_Insula_L';
myroi{9}.coords  = [-30,20,8];
myroi{9}.radius  = radius;

myroi{10}.name    = 'MergeC_C_Insula_R';
myroi{10}.coords  = [38,20,6];
myroi{10}.radius  = radius;
