% written by hao (2017/07/11)
% rock3.hao@gmail.com
% qinlab.BNU
clear
restoredefaultpath

%% ------------------------------ Set Up ------------------------------- %%
% Set Path
spm_dir    = '/home/haolei/Toolbox/spm12';
script_dir = '/home/haolei/Data/Codes/ActiveAnaly/FirstLv_spm12';

% Basic Configure
postfix = 'hao';
run_num = 2;
sublist = fullfile (script_dir,'list_firstlv_all1.txt');
img_dir = '/home/haolei/Data/Preproc';

% Individual Activity Statistics
task_name      = 'ANT';
sess_list      = 'ANT1'',''ANT2'; % Single Run: 'Run'; Multiple Run: 'Run1'',''Run2'',''Run3'.
indivstats_dir = '/home/haolei/Data/FirstLv';
contrast_file  = '/home/haolei/Data/Codes/ActiveAnaly/FirstLv_spm12/contrast/ANT_3cRig_hao.mat';
task_design    = 'ANT_rig_hao.m';

%% The following do not need to be modified
% ------------------------- Individual Analysis ------------------------- %
addpath (genpath (spm_dir));
addpath (genpath (script_dir));

cd (script_dir)
if ~exist('res&log','dir')
    mkdir (fullfile(script_dir,'res&log'))
end

iconfigname = ['config_indivstats_',task_name,'_',postfix,'.m'];
iconfig     = fopen(iconfigname,'a');
fprintf (iconfig,'%s\n',['paralist.postfix = ''',postfix,''';']);
fprintf (iconfig,'%s\n','paralist.data_type = ''nii'';');
fprintf (iconfig,'%s\n','paralist.pipeline = ''swcar'';');
fprintf (iconfig,'%s\n',['paralist.server_path = ''',img_dir,''';']);
fprintf (iconfig,'%s\n',['paralist.stats_path = ''',indivstats_dir,''';']);
fprintf (iconfig,'%s\n','paralist.parent_folder = '''';');
fprintf (iconfig,'%s\n',['fid = fopen(''',sublist,''');']);
fprintf (iconfig,'%s\n','SubLists = {};');
fprintf (iconfig,'%s\n','Cnt_List = 1;');
fprintf (iconfig,'%s\n','while ~feof(fid)');
fprintf (iconfig,'%s\n','    linedata = textscan(fgetl(fid), ''%s'', ''Delimiter'', ''\t'');');
fprintf (iconfig,'%s\n','    SubLists(Cnt_List,:) = linedata{1}; %#ok<*SAGROW>');
fprintf (iconfig,'%s\n','    Cnt_List = Cnt_List + 1;');
fprintf (iconfig,'%s\n','end');
fprintf (iconfig,'%s\n','fclose(fid);');
fprintf (iconfig,'%s\n','paralist.subjectlist = SubLists;');
if run_num == 1
    fprintf (iconfig,'%s\n',['paralist.exp_sesslist = ''',sess_list,''';']);
end
if run_num > 1
    fprintf (iconfig,'%s\n',['paralist.exp_sesslist = {''',sess_list,'''};']);
end
fprintf (iconfig,'%s\n',['paralist.task_dsgn = ''',task_design,''';']);
fprintf (iconfig,'%s\n',['paralist.contrastmat = ''',contrast_file,''';']);
fprintf (iconfig,'%s\n','paralist.preprocessed_folder = ''smoothed_spm12'';');
fprintf (iconfig,'%s\n',['paralist.stats_folder = ''',task_name,'/stats_spm12_swcar'';']);
fprintf (iconfig,'%s\n','paralist.include_mvmnt = 1;');
fprintf (iconfig,'%s\n','paralist.include_volrepair = 0;');
fprintf (iconfig,'%s\n','paralist.volpipeline = ''swavr'';');
fprintf (iconfig,'%s\n','paralist.volrepaired_folder = ''volrepair_spm12'';');
fprintf (iconfig,'%s\n','paralist.repaired_stats = ''stats_spm12_VolRepair'';');
fprintf (iconfig,'%s\n',['paralist.template_path = ''',fullfile(script_dir,'depend'),''';']);
fclose (iconfig);

movefile (iconfigname,fullfile(script_dir,'depend'))
indivstats_qin2hao_spm12 (iconfigname)

movefile (fullfile(script_dir,'depend',iconfigname),fullfile(script_dir,'res&log'))
movefile ('log*',fullfile(script_dir,'res&log'))

%% All Done
clear
