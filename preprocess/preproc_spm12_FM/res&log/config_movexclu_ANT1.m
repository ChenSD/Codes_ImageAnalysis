paralist.ServerPath = '/home/haolei/Data/MyData/Dev_ANT/Preproc_PA';
paralist.PreprocessedFolder = 'smoothed_spm12';
fid = fopen('/home/haolei/Data/MyData/Dev_ANT/Codes/Preprocess/Preproc_spm12_FM_PA/list_ANT1_yes_hao.txt');
ID_List = {};
Cnt_List = 1;
while ~feof(fid)
linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
ID_List(Cnt_List,:) = linedata{1};
Cnt_List = Cnt_List + 1;
end
fclose(fid);
paralist.SubjectList = ID_List;
paralist.SessionList = {'ANT1'};
paralist.ScanToScanCrit = 0.5;
