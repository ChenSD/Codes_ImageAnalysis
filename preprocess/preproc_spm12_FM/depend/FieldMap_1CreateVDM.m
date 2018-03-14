function FieldMap_1CreateVDM (magdir,magfilter,phasedir,phasefilter,funcdir,funcfilter,t1dir,t1filter,DataType,filemapmfile)
%% 
% this function creates VDM (voxel-distortion map) file based on the phase image and magnitude images, using
% the 'presubtracted phase and magnitude data' module in SPM8 and SPM12;

%% inputs:
% 1) magdir: the directory for magnitude image of shorter TE; magfilter: prefix of the magitude image
% 2) phasedir: the directory for phase image; phasefilter: prefix of the phase image
% 3) funcdir: the directory of functional images the researchers want to preprocess;  funcfilter: prefix of the functional images
% 4) filemapmfile: a .m file contains all the parameters for the fieldmap data. This file would be different across studies, pertinent to the scanner and sequence you use for data collection. Always it could be got from your technician, absolute path
% 5) t1dir and t1filter: the high-resolution anatomic image for each subjects, it is optional, you can leave a ~ if you don't want to align anatomic image to DVM for quality check. If you want to do this, t1 image should be in its absolute path

%% output
% When the function is finished, you will find an file prefixed 'VDM' in the same folder as the phase image; this is the VDM needed in later preprocessing

%% developed by Changming Chen, at Beijing Normal University
% 2016-9-24

clear matlabbatch;
[magimage, ~]   = selectfiles_qin (magdir, magfilter, DataType);
[phaseimage, ~] = selectfiles_qin (phasedir, phasefilter, DataType);
[funcimages, ~] = selectfiles_qin (funcdir, funcfilter, DataType);
[a1,~,~]        = fileparts (mfilename ('fullpath'));
spmver          = spm ('version');
if strfind (spmver,'SPM12')
    load (fullfile (a1,'FieldMap_1CreateVDM.mat'));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[phaseimage{1},',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[magimage{1},',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {filemapmfile};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi = {[funcimages{1},',1']};   % use the first volume of the functional images here, just for quality inspection, please see SPM instruction
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    if exist(t1dir,'var') && exist(t1filter,'var')
        [t1, ~] = selectfiles_qin (t1dir, t1filter, DataType);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = {[t1,',1']};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 1;
    else
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = {''};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    end
    save ('FieldMap_1CreateVDM','matlabbatch');
elseif strfind (spmver,'SPM8')
end
spm_jobman ('run',matlabbatch);
end
