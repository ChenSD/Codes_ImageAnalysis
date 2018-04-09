%-----------------------------------------------------------------------
% Job saved on 16-Sep-2017 20:06:09 by cfg_util (rev $Rev: 6460 $)
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
% matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = {''};
% matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = {''};

%%
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File',...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', ...
    substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
% matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Con1';
% matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0];
% matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Con2';
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
% matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% Run Batch
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);