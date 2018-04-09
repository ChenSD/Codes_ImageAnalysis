%-----------------------------------------------------------------------
% Job saved on 26-Oct-2017 01:21:26 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% Set up
spm_mat_dir = res_dir;
if ~exist(spm_mat_dir)
    mkdir (spm_mat_dir)
end
matlabbatch{1}.spm.stats.factorial_design.dir = {spm_mat_dir};

%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = imgdir;
%%
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = [7
%                                                                 10
%                                                                 12
%                                                                 5
%                                                                 8
%                                                                 7];
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'age';
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).iCC = 1;
% %%
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).c = [1
%                                                                 2
%                                                                 1
%                                                                 1
%                                                                 1
%                                                                 2];
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).cname = 'gender';
% matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).iCC = 1;
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = tconname;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = tconweig;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% Run Batch
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);