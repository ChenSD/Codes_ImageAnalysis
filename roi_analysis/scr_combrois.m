% written by hao (2017/08/06)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% Set up
form_input = 'nii';
comb_name  = 'GrpAdult_O.nii';
comb_func  = 'union'; % 'union' or 'inter'

% Directory with spm and ROIs to combine
spm_dir = '/Users/hao1ei/xToolbox/spm12';
roi_dir = '/Users/hao1ei/xData/BrainDev_ANT/Image/Mask/GrpAdult_map';

%% Multiple ROIs Combine
addpath (genpath (spm_dir));

% Make the Intersection ROI
if strcmp(comb_func,'union')
    lab_name = [comb_name(1:end-4), '_', comb_func];
    roi_name = [comb_name(1:end-4), '_', comb_func,'_roi'];
    
    roi_array = dir (fullfile(roi_dir, ['*.',form_input]));
    for roi_i = 1:length(roi_array)
        if strcmp(form_input,'mat')
            roi_list{roi_i} = maroi (fullfile(roi_dir, roi_array(roi_i).name)); %#ok<*SAGROW>
        elseif strcmp(form_input,'nii')
            roi_list{roi_i} = maroi_image (struct('vol', spm_vol(fullfile(roi_dir,roi_array(roi_i).name)), 'binarize', 0, 'func', 'img'));
            roi_list{roi_i} = maroi_matrix(roi_list{roi_i});
        end
    end
    roi_comb = roi_list{1};
    for i = 2:length(roi_array)
        roi_comb = roi_comb | roi_list{i};
    end
    roi_comb = label (roi_comb, lab_name);
    
    if strcmp(comb_name(end-2:end),'mat')
        saveroi (roi_comb, fullfile(roi_dir, roi_name));
    elseif strcmp(comb_name(end-2:end),'nii')
        save_as_image(roi_comb, fullfile(roi_dir, [roi_name,'.nii']))
    end
end

% Make the Intersection ROI
if strcmp(comb_func,'inter')
    lab_name = [comb_name(1:end-4), '_', comb_func];
    roi_name = [comb_name(1:end-4), '_', comb_func,'_roi'];
    
    roi_array = dir (fullfile(roi_dir, ['*.',form_input]));
    for roi_i = 1:length(roi_array)
        if strcmp(form_input,'mat')
            roi_list{roi_i} = maroi (fullfile(roi_dir, roi_array(roi_i).name)); %#ok<*SAGROW>
        elseif strcmp(form_input,'nii')
            roi_list{roi_i} = maroi_image (struct('vol', spm_vol(fullfile(roi_dir,roi_array(roi_i).name)), 'binarize', 0, 'func', 'img'));
            roi_list{roi_i} = maroi_matrix(roi_list{roi_i});
        end
    end
    
    roi_comb = roi_list{1};
    for i = 2:length(roi_array)
        roi_comb = roi_comb & roi_list{i};
    end
    roi_comb = label (roi_comb, lab_name);
    
    if strcmp(comb_name(end-2:end),'mat')
        saveroi (roi_comb, fullfile(roi_dir, roi_name));
    elseif strcmp(comb_name(end-2:end),'nii')
        save_as_image(roi_comb, fullfile(roi_dir, [roi_name,'.nii']))
    end
end

disp ('=== ROIs Combine Done ===');