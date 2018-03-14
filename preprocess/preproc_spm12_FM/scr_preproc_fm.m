% written by hao (2017/06/14)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% ------------------------------ Set Up ------------------------------- %%
% Set Path
spm_dir     = '/home/haolei/Toolbox/spm12';
script_dir  = '/home/haolei/Data/MyData/Dev_ANT/Codes/Preprocess/Preproc_spm12_FM_PA';
preproc_dir = '/home/haolei/Data/MyData/Dev_ANT/Preproc_PA';

subjlist      = fullfile(script_dir,'list_REST_yes_hao.txt');
filemap_mfile = fullfile(script_dir,'depend','pm_defaults_Prisma_ep2d_224_64.m');

fmri_name    = {'REST'}; % if multi run, use: {'Run1';'Run2'}
tr           = 2;
data_type    = 'nii';
t1_filter    = 'I';
mag_filter   = 'S1_mag_shortTE';
vdm_filter   = 'vdm5_scS1_phase';
func_filter  = 'I';
phase_filter = 'S1_phase';
slice_order  = [1:2:33 2:2:32];

%% Function Switch
preproc   = 0;
mergefile = 0;
moveexclu = 1;

%% The following do not need to be modified
%% Import SubList
fid = fopen(subjlist); sublist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

%% -------------------------- Preprocess fmri -------------------------- %%
% SliceTiming = 'a > ar'; Realign = 'u > c'; Normalise = 'w'; Smooth = 's'.
addpath (genpath (spm_dir));
addpath (genpath (fullfile (script_dir,'depend')));
[nsub,~] = size(sublist);

if preproc ==1
    for isub = 1:nsub
        for run = 1:length(fmri_name)
            yearID  = ['20',sublist{isub,1}(1:2)];
            subj_dir = sublist{isub};
            disp ([subj_dir,' Preprocess Started']);
            
            T1Dir    = fullfile (preproc_dir,yearID,subj_dir,'mri','anatomy');
            FuncDir  = fullfile (preproc_dir,yearID,subj_dir,'fmri',fmri_name{run,1},'unnormalized');
            FinalDir = fullfile (preproc_dir,yearID,subj_dir,'fmri',fmri_name{run,1},'smoothed_spm12');
            MagDir   = fullfile (preproc_dir,yearID,subj_dir,'fmri',fmri_name{run,1},[fmri_name{run,1},'_FieldMap']);
            PhaseDir = fullfile (preproc_dir,yearID,subj_dir,'fmri',fmri_name{run,1},[fmri_name{run,1},'_FieldMap']);
            VDM_Dir  = fullfile (preproc_dir,yearID,subj_dir,'fmri',fmri_name{run,1},[fmri_name{run,1},'_FieldMap']);
            
            cd (MagDir)
            FieldMap_1CreateVDM (MagDir,mag_filter,PhaseDir,phase_filter,FuncDir,func_filter,T1Dir,t1_filter,data_type,filemap_mfile);
            cd (FuncDir)
            FieldMap_2SlicTim2Coreg (VDM_Dir,vdm_filter,FuncDir,func_filter,T1Dir,t1_filter,slice_order,tr,data_type);
            FieldMap_3Seg2Smooth (VDM_Dir,vdm_filter,FuncDir,func_filter,T1Dir,t1_filter,slice_order,tr,data_type);
        end
    end
end

%% Merge Files
if mergefile==1
    for isub = 1:nsub
        yearID = ['20',sublist{isub,1}(1:2)];
        disp ([sublist{isub},' Preprocess Started']);
        
        for run = 1:length(fmri_name)
            SubjTaskDir = fullfile(preproc_dir,yearID,sublist{isub},'fmri',fmri_name{run,1},'unnormalized');
            FinalDir    = fullfile(preproc_dir,yearID,sublist{isub},'fmri',fmri_name{run,1},'smoothed_spm12');
            FMDir       = fullfile(preproc_dir,yearID,sublist{isub},'fmri',fmri_name{run,1},[fmri_name{run,1},'_FieldMap']);
            AnatDir     = fullfile(preproc_dir,yearID,sublist{isub},'mri','anatomy');
            cd (SubjTaskDir);
            
            unix (sprintf ('fslmerge -a swcarI swmcarI0*.nii'));
            unix (sprintf ('fslmerge -a wcarI wmcarI0*.nii'));
            
            unix (sprintf ('rm swmcarI0*.nii'));
            unix (sprintf ('rm wmcarI0*.nii'));
            unix (sprintf ('rm mcarI0*.nii'));
            unix (sprintf ('rm carI0*.nii'));
            
            rpFile       = fullfile(SubjTaskDir,'rp_arI.txt');
            MeanFile     = fullfile(SubjTaskDir,'meancarI.nii');
            VlmRep_GS    = fullfile(SubjTaskDir,'VolumRepair_GlobalSignal.txt');
            SmoothFile   = fullfile(SubjTaskDir,'swcarI.nii.gz');
            NoSmoothFile = fullfile(SubjTaskDir,'wcarI.nii.gz');
            
            mkdir (FinalDir)
            movefile(rpFile,FinalDir)
            movefile(MeanFile,FinalDir)
            movefile(VlmRep_GS,FinalDir)
            movefile(SmoothFile,FinalDir)
            movefile(NoSmoothFile,FinalDir)
            
            unix (sprintf ('rm arI.nii'));
            unix (sprintf ('rm arI_uw.mat'));
            unix (sprintf ('rm arI.mat'));
            unix (sprintf ('rm BiasField_meancarI.nii'));
            unix (sprintf ('rm c1meancarI.nii'));
            unix (sprintf ('rm c2meancarI.nii'));
            unix (sprintf ('rm c3meancarI.nii'));
            unix (sprintf ('rm c4meancarI.nii'));
            unix (sprintf ('rm c5meancarI.nii'));
            unix (sprintf ('rm meancarI_seg8.mat'));
            unix (sprintf ('rm mmeancarI.nii'));
            unix (sprintf ('rm uI.nii'));
            unix (sprintf ('rm wfmag_I.nii'));
            
            cd (FMDir)
            unix (sprintf ('rm bmask*.nii'));
            unix (sprintf ('rm sc*.nii'));
            unix (sprintf ('rm fpm_sc*.nii'));
            unix (sprintf ('rm m*.nii'));
            unix (sprintf ('rm vdm*.nii'));
            
            cd (AnatDir)
            unix (sprintf ('rm I_seg8.mat'));
            unix (sprintf ('rm I_sn.mat'));
            unix (sprintf ('rm y_I.nii'));
        end
    end
end
%% ------------------------- Movement Exclusion ------------------------ %%
if moveexclu ==1
    for k = 1:length(fmri_name)
        mConfigName = ['config_movexclu_',fmri_name{k,1},'.m'];
        mConfig = fopen (mConfigName,'a');
        fprintf (mConfig,'%s\n',['paralist.ServerPath = ''',preproc_dir,''';']);
        fprintf (mConfig,'%s\n','paralist.PreprocessedFolder = ''smoothed_spm12'';');
        
        fprintf (mConfig,'%s\n',['fid = fopen(''',subjlist,''');']);
        fprintf (mConfig,'%s\n','ID_List = {};');
        fprintf (mConfig,'%s\n','Cnt_List = 1;');
        fprintf (mConfig,'%s\n','while ~feof(fid)');
        fprintf (mConfig,'%s\n','linedata = textscan(fgetl(fid), ''%s'', ''Delimiter'', ''\t'');');
        fprintf (mConfig,'%s\n','ID_List(Cnt_List,:) = linedata{1};');
        fprintf (mConfig,'%s\n','Cnt_List = Cnt_List + 1;');
        fprintf (mConfig,'%s\n','end');
        fprintf (mConfig,'%s\n','fclose(fid);');
        
        fprintf (mConfig,'%s\n','paralist.SubjectList = ID_List;');
        fprintf (mConfig,'%s\n',['paralist.SessionList = {''',fmri_name{k,1},'''};']);
        fprintf (mConfig,'%s\n','paralist.ScanToScanCrit = 0.5;');
        
        movexclu_spm12_fm_hao(mConfigName)
    end
    
    if ~exist('res&log','dir')
        mkdir (fullfile(script_dir,'res&log'))
    end
    movefile ('log_movement*.txt','res&log')
    movefile ('config_movexclu*.m','res&log')
end

%% All Done
cd (script_dir)
clear
disp ('All Done');