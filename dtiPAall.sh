#!/bin/bash
set -x # debug mode

# users definition
# files DTIALL_ID_REGEXP1*DTIALL_ID_REGEXP2.* -> ID DTIALL_ID_REGEXP1*DTIALL_ID_REGEXP2
DTIALL_ID_REGEXP1=^D_U28002
DTIALL_ID_REGEXP2=_[12]_PA

#cd $SUBJECTS_DIR
for fid in `ls |grep DTIALL_ID_REGEXP1|grep DTIALL_ID_REGEXP2\\.|sed -e 's/\\..*//'|sort|uniq`;do 
	mkdir $fid
	cp $fid.* $fid
	dwidenoise $fid/$fid.nii $fid/$fid_den.nii -noise $fid/$fid_noise.nii
	mrdegibbs $fid/$fid_den.nii $fid/$fid_den_unr.nii -axes 0,1
	dwiextract $fid/$fid_den_unr.nii - -bzero -fslgrad bvecs.txt bvals.txt|mrmath - mean $fid/$fid_mean_b0.nii -axis 3
	dwipreproc $fid/$fid_den_unr.nii  $fid/$fid_den_unr_preproc.nii -pe_dir PA -rpe_none -eddy_options " --slm=linear" -fslgrad bvecs.txt bvals.txt 
	dwibiascorrect -fsl $fid/$fid_den_unr_preproc.nii $fid/$fid_den_unr_preproc_unbiased.nii -bias $fid/$fid_bias.nii -fslgrad bvecs.txt bvals.txt 
	dwi2mask $fid/$fid_den_unr_preproc_unbiased.nii $fid/$fid_den_unr_preproc_unbiased_mask.nii -fslgrad bvecs.txt bvals.txt 
	dtifit --bvals=bvals.txt --bvecs=bvecs.txt --data=$fid/$fid_den_unr_preproc_unbiased.nii --mask=$fid/$fid_den_unr_preproc_unbiased_mask.nii --out=$fid/$fid
	echo "end of "$fid
done

echo "end of dtiPAall.sh"

