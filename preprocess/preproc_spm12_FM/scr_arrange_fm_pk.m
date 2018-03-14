% written by hao (2017/06/14)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% ------------------------------ Set Up ------------------------------- %%
% Basic Configure
your_name   = 'hao';
script_dir  = '/home/haolei/Data/MyData/Dev_ANT/Codes/Preprocess/Preproc_spm12_FM_PA';
rawimg_dir  = '/home/haolei/Data/MyData/Dev_ANT/CBDnew/CBDPA';
arrimg_dir  = '/home/haolei/Data/MyData/Dev_ANT/Preproc_PA';
imgall_list = fullfile(script_dir,'list_SubImgAll1.txt');
subj_list   = fullfile(script_dir,'list_SubPreproc.txt');

fmri_name       = {'ANT1';'ANT2'};
fmri_keyword    = {'CHA1';'CHA2'};
fmri_timedel    = {'4';'4'};
fmri_timeremain = {'173';'173'};

rest_name       = {'REST'};
rest_keyword    = {'rest'};
rest_timedel    = {'5'   };
rest_timeremain = {'235' };

mri_name        = {'anatomy'};
mri_keyword     = {'co*t1'  };

fieldmp_name    = {'S1_FieldMap'; 'S2_FieldMap'};
fieldmp_keyword = {'S1'         ; 'S2'         };

% Function Switch
img_conv   = 0; % 0=Skip  1=Run
timpnt_del = 0; % 0=Skip  1=Run
sub_rename = 1; % 0=Skip  1=Run

%% ---------------------------- Read Lists ----------------------------- %%
fid = fopen(imgall_list); imgall = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    imgall(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

fid = fopen(subj_list); sub2list = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sub2list(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

%% ----------------------------- Img Convert --------------------------- %%
if img_conv == 1
    for i = 1:length(imgall)
        subimg_dir  = fullfile(rawimg_dir,imgall{i,1});
        outimg_dir  = fullfile(arrimg_dir,'Cache',imgall{i,1}(1:10));
        if ~exist(outimg_dir)
            mkdir (outimg_dir)
        end
        outimg_dir1 = fullfile(arrimg_dir,'Cache',[imgall{i,1}(1:10),'_1']);
        outimg_dir2 = fullfile(arrimg_dir,'Cache',[imgall{i,1}(1:10),'_2']);
        
        if exist(outimg_dir1)&&exist(outimg_dir2)
            return
            
        elseif ~exist(outimg_dir1) %#ok<*EXIST>
            mkdir (outimg_dir1)
            cd (outimg_dir1)
            unix(sprintf(['dcm2nii -g n -o ',outimg_dir1,' ',subimg_dir]));
            
            tempfieldmap_name1 = dir([outimg_dir1,'/*grefieldmappings*']);
            if length(tempfieldmap_name1) == 3
                s1_fieldmap = {tempfieldmap_name1.name};
            end
            unix(sprintf(['mv ',s1_fieldmap{1,1},' S1_mag_shortTE.nii']));
            unix(sprintf(['mv ',s1_fieldmap{1,2},' S1_mag_longTE.nii']));
            unix(sprintf(['mv ',s1_fieldmap{1,3},' S1_phase.nii']));
            
            unix(sprintf(['mv *.nii ',outimg_dir]));
        elseif exist(outimg_dir1)
            mkdir (outimg_dir2)
            cd (outimg_dir2)
            unix(sprintf(['dcm2nii -g n -o ',outimg_dir2,' ',subimg_dir]));
            
            tempfieldmap_name2 = dir([outimg_dir2,'/*grefieldmappings*']);
            if length(tempfieldmap_name2) == 3
                s2_fieldmap = {tempfieldmap_name2.name};
            end
            unix(sprintf(['mv ',s2_fieldmap{1,1},' S2_mag_shortTE.nii']));
            unix(sprintf(['mv ',s2_fieldmap{1,2},' S2_mag_longTE.nii']));
            unix(sprintf(['mv ',s2_fieldmap{1,3},' S2_phase.nii']));
            
            unix(sprintf(['mv *.nii ',outimg_dir]));
            
            if exist(outimg_dir)
                unix(sprintf(['rm -rf ',outimg_dir1]));
            end
            
            if exist(outimg_dir)
                unix(sprintf(['rm -rf ',outimg_dir2]));
            end
            
            cd (script_dir)
        end
    end
    
    for i = 1:length(sub2list)
        yearID     = ['20',sub2list{i,2}(1:2)];
        outimg_dir = fullfile(arrimg_dir,'Cache',sub2list{i,1});
        % Arrange mri
        for j = 1:length(mri_name)
            mri_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri',mri_name{j,1});
            mkdir (mri_dir);
            tempmri_name = dir([outimg_dir,'/*',mri_keyword{j,1},'*']);
            if isempty(tempmri_name)
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_no_',your_name,'.txt']);
            elseif length(tempmri_name) == 1
                unix(['mv ',[outimg_dir,'/',tempmri_name(1,1).name],' ',mri_dir,'/I.nii']);
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_yes_',your_name,'.txt']);
            elseif length(tempmri_name) >= 2
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_morethan2_',your_name,'.txt']);
            end
        end
        
        % Arrange FieldMap
        for j = 1:length(fieldmp_name)
            fmap_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri',fieldmp_name{j,1});
            mkdir (fmap_dir);
            tempmri_name = dir([outimg_dir,'/*',fieldmp_keyword{j,1},'*']);
            if length(tempmri_name) == 3
                unix(['mv ',outimg_dir,'/*',fieldmp_keyword{j,1},'* ',fmap_dir]);
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fieldmp_name{j,1},'_yes_',your_name,'.txt']);
            elseif length(tempmri_name) < 3
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fieldmp_name{j,1},'_notenough_',your_name,'.txt']);
            end
        end
        
        % Arrange fmri
        for j = 1:length(fmri_name)
            fmri_dir     = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},'unnormalized');
            fieldmap_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},[fmri_name{j,1},'_FieldMap']);
            mkdir (fmri_dir);
            tempfmri_name = dir ([outimg_dir,'/*',fmri_keyword{j,1},'*']);
            mri_dir = fullfile (arrimg_dir,yearID,sub2list{i,1},'mri',mri_name{1,1});
            if isempty(tempfmri_name)
                unix (['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fmri_name{j,1},'_no_',your_name,'.txt']);
            elseif length(tempfmri_name) == 1
                unix (['mv ',[outimg_dir,'/',tempfmri_name(1,1).name],' ',fmri_dir,'/I.nii']);
                
                % Attention, Need to Change
                fmap_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri','S2_FieldMap');
                mkdir (fieldmap_dir)
                unix(['cp ',fmap_dir,'/*S2* ',fieldmap_dir]);
                % Attention, Need to Change
                
                mriYN = exist([mri_dir,'/I.nii'],'file');
                if mriYN == 2
                    unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fmri_name{j,1},'_yes_',your_name,'.txt']);
                end
            elseif length(tempfmri_name) >= 2
                unix (['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fmri_name{j,1},'_morethan2_',your_name,'.txt']);
            end
        end
        
        % Arrange REST
        for j = 1:length(rest_name)
            fmri_dir     = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},'unnormalized');
            fieldmap_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},[rest_name{j,1},'_FieldMap']);
            mkdir (fmri_dir);
            tempfmri_name = dir ([outimg_dir,'/*',rest_keyword{j,1},'*']);
            mri_dir = fullfile (arrimg_dir,yearID,sub2list{i,1},'mri',mri_name{1,1});
            if isempty(tempfmri_name)
                unix (['echo ',sub2list{i,2},' >> ',script_dir,'/list_',rest_name{j,1},'_no_',your_name,'.txt']);
            elseif length(tempfmri_name) == 1
                unix (['mv ',[outimg_dir,'/',tempfmri_name(1,1).name],' ',fmri_dir,'/I.nii']);
                
                % Attention, Need to Change
                fmap_dir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri','S1_FieldMap');
                mkdir (fieldmap_dir)
                unix(['cp ',fmap_dir,'/*S1* ',fieldmap_dir]);
                % Attention, Need to Change
                
                mriYN = exist([mri_dir,'/I.nii'],'file');
                if mriYN == 2
                    unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',rest_name{j,1},'_yes_',your_name,'.txt']);
                end
            elseif length(tempfmri_name) >= 2
                unix (['echo ',sub2list{i,2},' >> ',script_dir,'/list_',rest_name{j,1},'_morethan2_',your_name,'.txt']);
            end
        end
    end
end

%% ---------------------------- TimePoint Del -------------------------- %%
if timpnt_del == 1
    for i = 1:length(sub2list)
        yearID = ['20',sub2list{i,2}(1:2)];
        
        for j = 1:length(fmri_name)
            fmri_dir = fullfile (arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},'unnormalized');
            fmriYN   = exist ([fmri_dir,'/I.nii'],'file');
            if fmriYN == 0
                disp ([sub2list{i,1},' ',fmri_name{j,1},' No_Exist']);
            elseif fmriYN == 2
                unix (['mv ',[fmri_dir,'/I.nii'],' ',fmri_dir,'/I_all.nii']);
                unix (['fslroi ',fmri_dir,'/I_all.nii ',fmri_dir,'/I.nii ',fmri_timedel{j,1},' ',fmri_timeremain{j,1}]);
                unix (['gunzip ',fmri_dir,'/I.nii.gz']);
            end
        end
        
        for j = 1:length(rest_name)
            fmri_dir = fullfile (arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},'unnormalized');
            fmriYN   = exist ([fmri_dir,'/I.nii'],'file');
            if fmriYN == 0
                disp ([sub2list{i,1},' ',rest_name{j,1},' No_Exist']);
            elseif fmriYN == 2
                unix (['mv ',[fmri_dir,'/I.nii'],' ',fmri_dir,'/I_all.nii']);
                unix (['fslroi ',fmri_dir,'/I_all.nii ',fmri_dir,'/I.nii ',rest_timedel{j,1},' ',rest_timeremain{j,1}]);
                unix (['gunzip ',fmri_dir,'/I.nii.gz']);
            end
        end
        
    end
end

%% --------------------------- Subject Rename -------------------------- %%
if sub_rename == 1
    for i = 1:length(sub2list)
        yearID = ['20',sub2list{i,2}(1:2)];
        subYN = exist (fullfile(arrimg_dir,yearID,sub2list{i,1}),'file');
        if subYN == 0
            disp ([sub2list{i,1},' No_Exist']);
        elseif subYN == 7
            unix (['mv ',arrimg_dir,'/',yearID,'/',sub2list{i,1},' ',arrimg_dir,'/',yearID,'/',sub2list{i,2}]);
        end
    end
end

%% All Done
clear
disp ('All Done');