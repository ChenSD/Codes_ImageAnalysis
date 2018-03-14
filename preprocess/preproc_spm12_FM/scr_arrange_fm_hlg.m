% written by hao (2017/06/14)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% ------------------------------ Set Up ------------------------------- %%
% Basic Configure
your_name   = 'hao';
script_dir  = '/home/haolei/Data/MyData/Dev_ANT/Codes/Preprocess/Preproc_spm12_FM_HA';
rawimg_dir  = '/home/haolei/Data/MyData/Dev_ANT/CBDnew/CBDHA';
arrimg_dir  = '/home/haolei/Data/MyData/Dev_ANT/Preproc_HA';
imgall_list = fullfile(script_dir,'list_SubImgAll.txt');
subj_list   = fullfile(script_dir,'list_SubPreproc.txt');

fmri_name       = {'ANT1'; 'ANT2'};
fmri_keyword    = {'CHA1'; 'CHA2'};
fmri_timedel    = {'4'   ; '4'   };
fmri_timeremain = {'173' ; '173' };

rest_name       = {'REST'};
rest_keyword    = {'rest'};
rest_timedel    = {'5'   };
rest_timeremain = {'235' };

mri_name    = {'anatomy'};
mri_keyword = {'co*t1'  };

fieldmp_name    = {'S1_FieldMap'; 'S2_FieldMap'};
fieldmp_keyword = {'S1'         ; 'S2'         };

% Function Switch
img_conv    = 0; % 0=Skip  1=Run
fm_rename   = 0; % 0=Skip  1=Run
img_arrange = 0; % 0=Skip  1=Run
mv_file     = 0; % 0=Skip  1=Run
timpnt_del  = 0; % 0=Skip  1=Run
sub_rename  = 1; % 0=Skip  1=Run

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
        subimgdir    = fullfile(rawimg_dir,imgall{i,1});
        subimgfolder = dir(subimgdir);
        for for_i = 3:length(subimgfolder)
            
            indir  = fullfile(subimgdir,subimgfolder(for_i,1).name,imgall{i,1});
            outdir = fullfile(arrimg_dir,'Cache',[imgall{i,1}(1:9),'_',num2str(for_i-2)]);
            
            mkdir (outdir)
            unix(sprintf(['dcm2nii -g n -o ',outdir,' ',indir]));
        end
    end
end

if fm_rename == 1
    for j=1:length(sub2list)
        outimgdir  = fullfile(arrimg_dir,'Cache',sub2list{j,1}(1:10));
        outimgdir1 = fullfile(arrimg_dir,'Cache',[sub2list{j,1}(1:10),'_1']);
        outimgdir2 = fullfile(arrimg_dir,'Cache',[sub2list{j,1}(1:10),'_2']);
        mkdir (outimgdir)
        
        cd (outimgdir1)
        tempfieldmapname1 = dir([outimgdir1,'/*grefieldmappings*']);
        if length(tempfieldmapname1) == 3
            s1_fieldmap = {tempfieldmapname1.name};
        end
        unix(sprintf(['mv ',s1_fieldmap{1,1},' S1_mag_shortTE.nii']));
        unix(sprintf(['mv ',s1_fieldmap{1,2},' S1_mag_longTE.nii']));
        unix(sprintf(['mv ',s1_fieldmap{1,3},' S1_phase.nii']));
        unix(sprintf(['mv *.nii ',outimgdir]));
        
        cd (outimgdir2)
        tempfieldmapname2 = dir([outimgdir2,'/*grefieldmappings*']);
        if length(tempfieldmapname2) == 3
            s2_fieldmap = {tempfieldmapname2.name};
        end
        unix(sprintf(['mv ',s2_fieldmap{1,1},' S2_mag_shortTE.nii']));
        unix(sprintf(['mv ',s2_fieldmap{1,2},' S2_mag_longTE.nii']));
        unix(sprintf(['mv ',s2_fieldmap{1,3},' S2_phase.nii']));
        unix(sprintf(['mv *.nii ',outimgdir]));
    end
end

%% ----------------------------- Img Arrange --------------------------- %%
if img_arrange == 1
    for i = 1:length(sub2list)
        yearID    = ['20',sub2list{i,2}(1:2)];
        outimgdir = fullfile(arrimg_dir,'Cache',sub2list{i,1});
        
        % Arrange FieldMap
        for j = 1:length(fieldmp_name)
            fmapdir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri',fieldmp_name{j,1});
            mkdir (fmapdir);
            tempmriname = dir([outimgdir,'/*',fieldmp_keyword{j,1},'*']);
            if length(tempmriname) == 3
                if mv_file == 1
                    unix(['mv ',outimgdir,'/*',fieldmp_keyword{j,1},'* ',fmapdir]);
                end
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fieldmp_name{j,1},'_yes_',your_name,'.txt']);
            elseif length(tempmriname) < 3
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fieldmp_name{j,1},'_notenough_',your_name,'.txt']);
            end
        end
        
        % Arrange fmri
        for j = 1:length(fmri_name)
            fmridir     = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},'unnormalized');
            fieldmapdir = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},[fmri_name{j,1},'_FieldMap']);
            mkdir (fmridir);
            tempfmriname = dir ([outimgdir,'/*',fmri_keyword{j,1},'*']);
            tempmriname = dir ([outimgdir,'/*',mri_keyword{1,1},'*']);
            
            
            if mv_file == 1
                unix (['mv ',[outimgdir,'/',tempfmriname(1,1).name],' ',fmridir,'/I.nii']);
            end
            % Attention, Need to Change
            fmapdir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri','S2_FieldMap');
            mkdir (fieldmapdir)
            if mv_file == 1
                unix(['cp ',fmapdir,'/*S2* ',fieldmapdir]);
            end
            % Attention, Need to Change
            
            mriYN = exist(fullfile(outimgdir,tempmriname.name),'file');
            if mriYN == 2
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',fmri_name{j,1},'_yes_',your_name,'.txt']);
            end
            
        end
        
        % Arrange REST
        for j = 1:length(rest_name)
            fmridir     = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},'unnormalized');
            fieldmapdir = fullfile(arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},[rest_name{j,1},'_FieldMap']);
            mkdir (fmridir);
            tempfmriname = dir ([outimgdir,'/*',rest_keyword{j,1},'*']);
            tempmriname  = dir ([outimgdir,'/*',mri_keyword{1,1},'*']);
            
            if mv_file == 1
                unix (['mv ',[outimgdir,'/',tempfmriname(1,1).name],' ',fmridir,'/I.nii']);
            end
            
            % Attention, Need to Change
            fmapdir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri','S1_FieldMap');
            mkdir (fieldmapdir)
            if mv_file == 1
                unix(['cp ',fmapdir,'/*S1* ',fieldmapdir]);
            end
            % Attention, Need to Change
            
            mriYN = exist(fullfile(outimgdir,tempmriname.name),'file');
            if mriYN == 2
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',rest_name{j,1},'_yes_',your_name,'.txt']);
            end
            
        end
        
        % Arrange mri
        for j = 1:length(mri_name)
            mridir = fullfile(arrimg_dir,yearID,sub2list{i,1},'mri',mri_name{j,1});
            mkdir (mridir);
            tempmriname = dir([outimgdir,'/*',mri_keyword{j,1},'*']);
            if isempty(tempmriname)
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_no_',your_name,'.txt']);
            elseif length(tempmriname) == 1
                if mv_file == 1
                    unix(['mv ',[outimgdir,'/',tempmriname(1,1).name],' ',mridir,'/I.nii']);
                end
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_yes_',your_name,'.txt']);
            elseif length(tempmriname) >= 2
                unix(['echo ',sub2list{i,2},' >> ',script_dir,'/list_',mri_name{j,1},'_morethan2_',your_name,'.txt']);
            end
        end
        
    end
end

%% ---------------------------- TimePoint Del -------------------------- %%
if timpnt_del == 1
    for i = 1:length(sub2list)
        yearID = ['20',sub2list{i,2}(1:2)];
        
        for j = 1:length(fmri_name)
            fmridir = fullfile (arrimg_dir,yearID,sub2list{i,1},'fmri',fmri_name{j,1},'unnormalized');
            fmriYN  = exist ([fmridir,'/I.nii'],'file');
            if fmriYN == 0
                disp ([sub2list{i,1},' ',fmri_name{j,1},' No_Exist']);
            elseif fmriYN == 2
                unix (['mv ',[fmridir,'/I.nii'],' ',fmridir,'/I_all.nii']);
                unix (['fslroi ',fmridir,'/I_all.nii ',fmridir,'/I.nii ',fmri_timedel{j,1},' ',fmri_timeremain{j,1}]);
                unix (['gunzip ',fmridir,'/I.nii.gz']);
            end
        end
        
        for j = 1:length(rest_name)
            fmridir = fullfile (arrimg_dir,yearID,sub2list{i,1},'fmri',rest_name{j,1},'unnormalized');
            fmriYN  = exist ([fmridir,'/I.nii'],'file');
            if fmriYN == 0
                disp ([sub2list{i,1},' ',rest_name{j,1},' No_Exist']);
            elseif fmriYN == 2
                unix (['mv ',[fmridir,'/I.nii'],' ',fmridir,'/I_all.nii']);
                unix (['fslroi ',fmridir,'/I_all.nii ',fmridir,'/I.nii ',rest_timedel{j,1},' ',rest_timeremain{j,1}]);
                unix (['gunzip ',fmridir,'/I.nii.gz']);
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