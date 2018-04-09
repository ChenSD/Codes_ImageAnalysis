paralist.postfix = 'hao';
paralist.data_type = 'nii';
paralist.pipeline = 'swcar';
paralist.server_path = '/home/haolei/Data/Preproc';
paralist.stats_path = '/home/haolei/Data/FirstLv';
paralist.parent_folder = '';
fid = fopen('/home/haolei/Data/Codes/ActiveAnaly/FirstLv_spm12/list_firstlv_all1.txt');
SubLists = {};
Cnt_List = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    SubLists(Cnt_List,:) = linedata{1}; %#ok<*SAGROW>
    Cnt_List = Cnt_List + 1;
end
fclose(fid);
paralist.subjectlist = SubLists;
paralist.exp_sesslist = {'ANT1','ANT2'};
paralist.task_dsgn = 'ANT_rig_hao.m';
paralist.contrastmat = '/home/haolei/Data/Codes/ActiveAnaly/FirstLv_spm12/contrast/ANT_3cRig_hao.mat';
paralist.preprocessed_folder = 'smoothed_spm12';
paralist.stats_folder = 'ANT/stats_spm12_swcar';
paralist.include_mvmnt = 1;
paralist.include_volrepair = 0;
paralist.volpipeline = 'swavr';
paralist.volrepaired_folder = 'volrepair_spm12';
paralist.repaired_stats = 'stats_spm12_VolRepair';
paralist.template_path = '/home/haolei/Data/Codes/ActiveAnaly/FirstLv_spm12/depend';
