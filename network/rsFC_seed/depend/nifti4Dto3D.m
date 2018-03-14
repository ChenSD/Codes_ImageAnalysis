function nifti4Dto3D (datadir, imgprev)
% add fsl path to system path
path1 = getenv('PATH');
path1 = [path1 ':/usr/share/fsl/5.0/bin'];
setenv('PATH', path1);
% Datadir is the current directory
tempdir = pwd;
cd(datadir);
unix(sprintf ('gunzip -fq %s', [imgprev, 'I.nii.gz']));
% Check whether 4-D Nifti file exists
nifti_file = spm_select('List', datadir, ['^', imgprev, 'I.*\.nii']);
if isempty(nifti_file)
  fprintf('There is no NIFTI file in %s \n', datadir);
elseif size(nifti_file,1) > 1
  fprintf(['Warning: multiple NIFTI files with same image prefix in ', ...
           ' %s, aborting ... \n'], datadir);
else
  fprintf('Splitting 4-D nifti file: %s \n', deblank(nifti_file));
  setenv('FSLOUTPUTTYPE', 'NIFTI');
  %unix(sprintf('source /Users/genghaiyang/Applications/fsl/etc/fslconf/fsl.sh'));
  %unix(sprintf('echo %s','$PATH'));
  unix(sprintf('fslsplit %s %s', ...
               deblank(nifti_file), [imgprev, 'I_']));
  unix(sprintf('/bin/rm -rf %s', deblank(nifti_file)));
  unix(sprintf('gunzip -fq %s', [imgprev, 'I_*.nii.gz']));
end
cd(tempdir);
end
