% written by hao (2017/03/15)
% rock3.hao@gmail.com
% qinlab.BNU

clear

%% ------------------------------ Set Up ------------------------------- %%
% Set Path
addpath (genpath ('/Users/hao1ei/Toolbox/spm8'));
addpath (genpath ('/Users/hao1ei/Toolbox/spm8_scripts'));

% Basic Configure
YourName     = 'Hao';
Dcm2niiTool  = 'dcm2niix';
DataInfoName = 'DataInfo_Hao.xlsx';

RawImgDir  = '/Users/hao1ei/Downloads/ProcessBatch_Hao_Test/Rawdata/';
ArrImgDir  = '/Users/hao1ei/Downloads/ProcessBatch_Hao_Test/data/';
ScriptDir  = '/Users/hao1ei/MyProjects/ImgProcess/';
BatchDir   = '/Users/hao1ei/Toolbox/spm8_scripts/ProcBatch/';
SliceOrder = '[1:2:33 2:2:32]';

% Function Switch
ImgConvert      = 1; % 0=Skip  1=Run
DelCache        = 0; % 0=Skip  1=Delete cache floder
MultiImgChoose  = 0; % 0=Skip  1=Choose last image
TimePointDel    = 0; % 0=Skip  1=Run
SubRename       = 0; % 0=Skip  1=Run
PreProcess      = 0; % 0=Skip  1=Run
MoveExclusion   = 0; % 0=Skip  1=Run

%% ---------------------------- Read Lists ----------------------------- %%
% Info.xlsx Content Order:
% SubName, SubNewName, fmriName, fmriKeyword, mriName, mriKeyword, TimeDel, TimeRemain
[~,SubName,~]     = xlsread(DataInfoName,1,'A:A');
[~,SubNewName,~]  = xlsread(DataInfoName,1,'B:B');
[~,fmriName,~]    = xlsread(DataInfoName,1,'C:C');
[~,fmriKeyword,~] = xlsread(DataInfoName,1,'D:D');
[~,TimeDel,~]     = xlsread(DataInfoName,1,'E:E');
[~,TimeRemain,~]  = xlsread(DataInfoName,1,'F:F');
[~,mriName,~]     = xlsread(DataInfoName,1,'G:G');
[~,mriKeyword,~]  = xlsread(DataInfoName,1,'H:H');

%% ----------------------------- Img Convert --------------------------- %%
if ImgConvert == 1
    for i = 1:length(SubName)
        YearID = ['20',SubNewName{i,1}(1:2)];
        SubImgDir = fullfile(RawImgDir,SubName{i,1});
        OutImgDir = fullfile(ArrImgDir,YearID,SubName{i,1},'Cache');
        mkdir (OutImgDir);
        if strcmp(Dcm2niiTool,'dcm2niix') == 1
            unix(sprintf([Dcm2niiTool,' -x y -z y -o ',OutImgDir,' ',SubImgDir,'/*']));
        elseif strcmp(Dcm2niiTool,'dcm2nii') == 1
            unix(sprintf([Dcm2niiTool,' -g y -o ',OutImgDir,' ',SubImgDir,'/*']));
        end
        
        % Arrange mri
        for j = 1:length(mriName)
            mriDir = fullfile(ArrImgDir,YearID,SubName{i,1},'mri',mriName{j,1});
            mkdir (mriDir);
            TempmriName = dir([OutImgDir,'/*',mriKeyword{j,1},'*']);
            if isempty(TempmriName)
                unix(['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',mriName{j,1},'_NoExist_',YourName,'.txt']);
            elseif length(TempmriName) == 1
                unix(['mv ',[OutImgDir,'/',TempmriName(1,1).name],' ',mriDir,'/I.nii.gz']);
                unix(['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',mriName{j,1},'_YesExist_',YourName,'.txt']);
            elseif length(TempmriName) >= 2
                unix(['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',mriName{j,1},'_MoreThan2_',YourName,'.txt']);
                if MultiImgChoose == 1
                    unix(['mv ',[OutImgDir,'/',TempmriName(length(TempmriName),1).name],' ',mriDir,'/I.nii.gz']);
                end
            end
        end
        
        % Arrange fmri
        for j = 1:length(fmriName)
            fmriDir = fullfile(ArrImgDir,YearID,SubName{i,1},'fmri',fmriName{j,1},'unnormalized');
            % TaskDesignDir=fullfile(ArrImgDir,YearID,SubName{i,1},'fmri',fmriName{j,1},'task_design');
            mkdir (fmriDir);
            % mkdir (TaskDesignDir);
            TempfmriName = dir ([OutImgDir,'/*',fmriKeyword{j,1},'*']);
            mriDir = fullfile (ArrImgDir,YearID,SubName{i,1},'mri',mriName{1,1});
            if isempty(TempfmriName)
                unix (['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',fmriName{j,1},'_NoExist_',YourName,'.txt']);
            elseif length(TempfmriName) == 1
                unix (['mv ',[OutImgDir,'/',TempfmriName(1,1).name],' ',fmriDir,'/I.nii.gz']);
                mriYN = exist([mriDir,'/I.nii.gz'],'file');
                if mriYN == 2
                    unix(['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',fmriName{j,1},'_YesExist_',YourName,'.txt']);
                end
            elseif length(TempfmriName) >= 2
                unix (['echo ',SubNewName{i,1},' >> ',ScriptDir,'SubList_',fmriName{j,1},'_MoreThan2_',YourName,'.txt']);
                if MultiImgChoose == 1
                    unix (['mv ',[OutImgDir,'/',TempfmriName(length(TempfmriName),1).name],' ',fmriDir,'/I.nii.gz']);
                end
            end
        end
        
        % Delete Convert Cache
        if DelCache == 1
            rmdir (OutImgDir,'s')
        end
    end
end

%% ---------------------------- TimePoint Del -------------------------- %%
if TimePointDel == 1
    for i = 1:length(SubName)
        YearID = ['20',SubNewName{i,1}(1:2)];
        for j = 1:length(fmriName)
            fmriDir=fullfile (ArrImgDir,YearID,SubName{i,1},'fmri',fmriName{j,1},'unnormalized');
            fmriYN = exist ([fmriDir,'/I.nii.gz'],'file');
            if fmriYN == 0
                disp ([SubNewName{i,1},' ',fmriName{j,1},' No_Exist']);
            elseif fmriYN == 2
                unix (['mv ',[fmriDir,'/I.nii.gz'],' ',fmriDir,'/I_all.nii.gz']);
                unix (['fslroi ',fmriDir,'/I_all.nii.gz ',fmriDir,'/I.nii.gz ',TimeDel{j,1},' ',TimeRemain{j,1}]);
            end
        end
    end
end

%% --------------------------- Subject Rename -------------------------- %%
if SubRename == 1
    for i = 1:length(SubName)
        YearID = ['20',SubNewName{i,1}(1:2)];
        SubYN = exist (fullfile(ArrImgDir,YearID,SubName{i,1}),'file');
        if SubYN == 0
            disp ([SubNewName{i,1},' No_Exist']);
        elseif SubYN == 7
            unix (['mv ',ArrImgDir,'/',YearID,'/',SubName{i,1},' ',ArrImgDir,'/',YearID,'/',SubNewName{i,1}]);
        end
    end
end

%% -------------------------- Preprocess fmri -------------------------- %%
mkdir (fullfile(ScriptDir,'LogFiles'))

if PreProcess == 1
    for i = 1:length(fmriName)
        cd (ScriptDir)
        SubList = ['SubList_',fmriName{i,1},'_YesExist_',YourName,'.txt'];
        movefile (SubList,BatchDir)
        
        pConfigName1 = ['Config_Preproc1_',fmriName{i,1},'_',YourName,'.m'];
        pConfig1 = fopen (pConfigName1,'a');
        fprintf (pConfig1,'%s\n',['paralist.YourName = ''',YourName,''';']);
        fprintf (pConfig1,'%s\n',['paralist.ServerPath = ''',ArrImgDir,''';']);
        fprintf (pConfig1,'%s\n',['SubLists = textread(''SubList_',fmriName{i,1},'_YesExist_',YourName,'.txt'',''%s'');']); % or textscan
        fprintf (pConfig1,'%s\n','paralist.SubjectList = SubLists;');
        fprintf (pConfig1,'%s\n',['paralist.SessionList = {''',fmriName{i,1},'''};']);
        fprintf (pConfig1,'%s\n',['paralist.sliceorder = ',SliceOrder,';']);
        fprintf (pConfig1,'%s\n','paralist.InputImgPrefix = '''';');
        fprintf (pConfig1,'%s\n','paralist.EntirePipeLine = ''swcar'';');
        fprintf (pConfig1,'%s\n','paralist.SPGRSubjectList = '''';');
        
        movefile (pConfigName1,BatchDir)
        cd (BatchDir)
        preprocessfmri_qin_hao (pConfigName1)
        
        cd (ScriptDir)
        pConfigName2 = ['Config_Preproc2_',fmriName{i,1},'_',YourName,'.m'];
        pConfig2 = fopen (pConfigName2,'a');
        fprintf (pConfig2,'%s\n',['paralist.YourName = ''',YourName,''';']);
        fprintf (pConfig2,'%s\n',['paralist.ServerPath = ''',ArrImgDir,''';']);
        fprintf (pConfig2,'%s\n',['SubLists = textread(''SubList_',fmriName{i,1},'_YesExist_',YourName,'.txt'',''%s'');']); % or textscan
        fprintf (pConfig2,'%s\n','paralist.SubjectList = SubLists;');
        fprintf (pConfig2,'%s\n',['paralist.SessionList = {''',fmriName{i,1},'''};']);
        fprintf (pConfig2,'%s\n',['paralist.sliceorder = ',SliceOrder,';']);
        fprintf (pConfig2,'%s\n','paralist.InputImgPrefix = ''car'';');
        fprintf (pConfig2,'%s\n','paralist.EntirePipeLine = ''swcar'';');
        fprintf (pConfig2,'%s\n','paralist.SPGRSubjectList = '''';');
        
        movefile (pConfigName2,BatchDir)
        cd (BatchDir)
        preprocessfmri_qin_hao (pConfigName2)
        
        movefile (SubList,ScriptDir)
        movefile (pConfigName1,fullfile(ScriptDir,'LogFiles'))
        movefile (pConfigName2,fullfile(ScriptDir,'LogFiles'))
    end
end

%% ------------------------- Movement Exclusion ------------------------ %%
if MoveExclusion == 1
    for i = 1:length(fmriName)
        cd (ScriptDir)
        SubList = ['SubList_',fmriName{i,1},'_YesExist_',YourName,'.txt'];
        movefile (SubList,BatchDir)
        
        mConfigName = ['Config_Movexcl_',fmriName{i,1},'_',YourName,'.m'];
        mConfig = fopen (mConfigName,'a');
        fprintf (mConfig,'%s\n',['paralist.YourName = ''',YourName,''';']);
        fprintf (mConfig,'%s\n',['paralist.ServerPath = ''',ArrImgDir,''';']);
        fprintf (mConfig,'%s\n','paralist.PreprocessedFolder = ''smoothed_spm8'';');
        fprintf (mConfig,'%s\n',['SubLists = textread(''SubList_',fmriName{i,1},'_YesExist_',YourName,'.txt'',''%s'');']); % or textscan
        fprintf (mConfig,'%s\n','paralist.SubjectList = SubLists;');
        fprintf (mConfig,'%s\n',['paralist.SessionList = {''',fmriName{i,1},'''};']);
        fprintf (mConfig,'%s\n','paralist.ScanToScanCrit = 0.5;');
        
        movefile (mConfigName,BatchDir)
        cd (BatchDir)
        movement_exclusion_hao(mConfigName)
        
        movefile (SubList,fullfile(ScriptDir,'LogFiles'))
        movefile (mConfigName,fullfile(ScriptDir,'LogFiles'))
        movefile ('Log_*',fullfile(ScriptDir,'LogFiles'))
    end
end
cd (ScriptDir)
movefile ('SubList*',fullfile(ScriptDir,'LogFiles'))
%% All Done
clear
disp ('All Done');