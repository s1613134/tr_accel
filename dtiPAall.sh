#!/bin/bash
set -x # debug mode

# users definition
# files DTIALL_ID_REGEXP.* -> DTIALL_ID_REGEXP/DTIALL_ID_REGEXP.*
DTIALL_ID_REGEXP=^D_U280.._[12]_PA
DTIALL_SFX_STEP2A=_den
DTIALL_SFX_STEP2B=_noise
DTIALL_SFX_STEP3A=_den_unr
DTIALL_SFX_STEP4A=_den_unr_preproc
DTIALL_SFX_STEP5A=_den_unr_preproc_unbiased
DTIALL_SFX_STEP5B=_bias
DTIALL_SFX_STEP6A=_den_unr_preproc_unbiased_mask

#cd $SUBJECTS_DIR
for fid in $(ls |grep ${DTIALL_ID_REGEXP}\.|sed -e 's/\..*//'|sort|uniq);do 
	mkdir ${fid}
	cp ${fid}.* ${fid}
	dwidenoise ${fid}/${fid}.nii* ${fid}/${fid}${DTIALL_SFX_STEP2A}.nii.gz -noise ${fid}/${fid}${DTIALL_SFX_STEP2B}.nii.gz
	mrdegibbs ${fid}/${fid}${DTIALL_SFX_STEP2A}.nii.gz ${fid}/${fid}${DTIALL_SFX_STEP3A}.nii.gz -axes 0,1
#	dwiextract ${fid}/${fid}${DTIALL_SFX_STEP3A}.nii.gz - -bzero -fslgrad ${fid}/${fid}.bvec ${fid}/${fid}.bval|mrmath - mean ${fid}/${fid}_mean_b0.nii.gz -axis 3
	dwipreproc ${fid}/${fid}${DTIALL_SFX_STEP3A}.nii.gz  ${fid}/${fid}${DTIALL_SFX_STEP4A}.nii.gz -pe_dir PA -rpe_none -eddy_options " --slm=linear" -fslgrad ${fid}/${fid}.bvec ${fid}/${fid}.bval -eddyqc_text ${fid}/${fid}_QC
	cp ${fid}/${fid}.bvec ${fid}/bvecs
	cp ${fid}/${fid}.bval ${fid}/bvals
	dwibiascorrect -fsl ${fid}/${fid}${DTIALL_SFX_STEP4A}.nii.gz ${fid}/${fid}${DTIALL_SFX_STEP5A}.nii.gz -bias ${fid}/${fid}${DTIALL_SFX_STEP5B}.nii.gz -fslgrad ${fid}/bvecs ${fid}/bvals
	dwi2mask ${fid}/${fid}${DTIALL_SFX_STEP5A}.nii.gz ${fid}/${fid}${DTIALL_SFX_STEP6A}.nii.gz -fslgrad ${fid}/bvecs ${fid}/bvals 
	dtifit --bvals=${fid}/bvals --bvecs=${fid}/bvecs --data=${fid}/${fid}${DTIALL_SFX_STEP5A}.nii.gz --mask=${fid}/${fid}${DTIALL_SFX_STEP6A}.nii.gz --out=${fid}/${fid}
	echo "end of "${fid}
done

echo "end of dtiPAall.sh"

