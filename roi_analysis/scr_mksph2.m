%% make sphere ROIs
clear
restoredefaultpath

%% Set up
roi_form  = 'nii';
Radius    = 6;
Coordlist = '/Users/hao1ei/xScript/Image/ROICode/list_mksph2.txt';
SPM_Dir   = '/Users/hao1ei/xToolbox/spm12';
ROIfolder = '/Users/hao1ei/Downloads/Test/ROIscrtest/roi_mat_nii';

%% Make Sphere ROI
ROICoord = load (Coordlist);
addpath (genpath (SPM_Dir));

if ~exist (ROIfolder, 'dir')
    mkdir (ROIfolder);
end

for i = 1:size(ROICoord, 1)
    n = num2str(i);
    if length(n) == 1
        n = ['00', n]; %#ok<*AGROW>
    elseif length(n) == 2
        n = ['0', n];
    end
    
    coords = ROICoord(i, :);
    name = ['ROI_', n];
    
    roi = maroi_sphere(struct('centre', coords, 'radius', Radius));
    roi = label(roi, name);
    
    
    r = num2str(Radius);
    x = num2str(coords(1));
    y = num2str(coords(2));
    z = num2str(coords(3));
    
    filename = [name  '_' x '_' y '_' z '_' r 'mm_roi.mat'];
    filepath = fullfile(ROIfolder, filename);
    
    if strcmp(roi_form,'mat')
        save(filepath, 'roi');
    elseif strcmp(roi_form,'nii')
        save_as_image(roi, [filepath(1:end-4),'.nii'])
    end
end

disp('=== Making ROIs is Done ===');