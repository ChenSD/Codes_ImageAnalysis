% This script make only sphere ROIs
% It reads in a configuration file. You can find a template of it as named:
% roi_myrois.m.template
% How to run:
% start matlab (ml7spm8) and in matlab command prompt:
% type: roi_make_sphere('myrois.m')
% ----------------------------------------------------------------------- %
% 2009 Stanford Cognitive and Systems Neuroscience Laboratory
% $Id: roi_make_sphere.m 2009-07-15 $
% ----------------------------------------------------------------------- %

function scr_mksph1(Config_File)
warning ('off', 'MATLAB:FINITE:obsoleteFunction')
disp (['Current directory is: ',pwd]);

% -------------------------------------------------------------------------
% Check existence of the configuration file
% -------------------------------------------------------------------------

if(exist(Config_File,'file')==0)
    fprintf ('Cannot find the configuration file ... \n');
    return;
end

Config_File = strtrim(Config_File);
Config_File = Config_File(1:end-2);
eval (Config_File);
clear Config_File;

addpath (genpath(spm_dir));

if exist (roi_folder,'dir')
    cd (roi_folder);
else
    mkdir (roi_folder);
    cd (roi_folder);
end

disp ('Making ROIS ...');

for i=1:length(myroi) %#ok<*USENS>
    coords = myroi{i}.coords;
    radius = myroi{i}.radius;
    r = num2str(radius);
    x = num2str(coords(1));
    y = num2str(coords(2));
    z = num2str(coords(3));
    
    n = num2str(i);
    if length(n) == 1
        n = ['00',n]; %#ok<*NASGU>
    elseif length(n) == 2
        n = ['0', n]; %#ok<*AGROW>
    end
    
    if strcmp(roinum,'yes')
        % name = [myroi{i}.name '_' n '_' x '_' y '_' z '_' r 'mm'];
        name = [myroi{i}.name '_' n '_' r 'mm'];
    elseif strcmp(roinum,'no')
        % name = [myroi{i}.name '_' x '_' y '_' z '_' r 'mm'];
        name = [myroi{i}.name '_' r 'mm'];
    end
    
    roi = maroi_sphere(struct('centre', coords, 'radius', radius));
    roi = label(roi, name);
    filename = [name '_roi.mat'];
    fpath    = fullfile(roi_folder,filename);
    
    if strcmp(roi_form,'mat')
        save(fpath, 'roi');
    elseif strcmp(roi_form,'nii')
        save_as_image(roi, [fpath(1:end-4),'.nii'])
    end
end

cd (script_dir)
disp ('=== Making ROIs is done ===');
end