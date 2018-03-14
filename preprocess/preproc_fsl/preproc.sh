#!/bin/bash

analy_dir=/Users/hao1ei/Downloads/Preproc_Test/Preproc_FSL
sublist=/Users/hao1ei/MyProjects/Scripts/Preprocess/Preproc_FSL/Sublist.txt

for isub in `cat ${sublist}`
do

bet ${analy_dir}/${isub}/RawData/3D.nii.gz ${analy_dir}/${isub}/RawData/3D_brain.nii.gz -f 0.35 -R
echo $isub bet done

cd ${analy_dir}/${isub}/Preproc

for run in 1 2
do
sed -e "s/16-16-16.1SWUC/$isub/" ${analy_dir}/16-16-16.1SWUC/Preproc/ANT${run}.feat/design.fsf > ANT${run}.fsf
feat ANT${run}.fsf
done
echo $isub preprocess done

done

echo All Done