#!/bin/bash
set -x # debug mode

# usage:
#  1. collect <<fid>>.nii,.bvec,.bval files of DWI in working directory
#  2. type as follows
# 		tbssAll.sh "<<fid>>" "<<group1 in regular expression>>" "<<group2 in regular expression>>"
# 	for example
# 		tbssAll.sh "D_U280*_*_PA" "^D_U280.*_1_PA$" "^D_U280.*_2_PA$"
#	note that wild card in regular expression is not * but .*

# users definition
TBSSALL_ID=$1
TBSSALL_1REGEXP=$2
TBSSALL_2REGEXP=$3

#cd $SUBJECTS_DIR
temp_n1=$(ls |grep ${TBSSALL_1REGEXP}|wc -l)
temp_n2=$(ls |grep ${TBSSALL_2REGEXP}|wc -l)

# for Chris Rorden's fsl_sub case
export FSLPARALLEL=1

# FA
mkdir TBSS;cp ${TBSSALL_ID}/*FA.nii.gz TBSS
cd TBSS;
#
<<"COMMENTOUT1"
You will make later analysis easier if you name the images in a logical order, 
for example so that all controls are listed before all patients:
  CON_N00300_dti_data_FA.nii.gz
  CON_N00302_dti_data_FA.nii.gz
  CON_N00499_dti_data_FA.nii.gz
  PAT_N00373_dti_data_FA.nii.gz
  PAT_N00422_dti_data_FA.nii.gz
  PAT_N03600_dti_data_FA.nii.gz
COMMENTOUT1
rename "s/^/CON_/" $(ls |grep ${TBSSALL_1REGEXP%$}_FA.nii.gz$)
rename "s/^/PAT_/" $(ls |grep ${TBSSALL_2REGEXP%$}_FA.nii.gz$)
exit
#
tbss_1_preproc *FA.nii.gz
tbss_2_reg -T
#tbss_3_postreg -T # for a few samples case
tbss_3_postreg -S # for many samples case
tbss_4_prestats 0.2

# nonFA
mkdir MD;cp ../${TBSSALL_ID}/*MD.nii.gz MD
rename "s/_MD.nii.gz/_FA.nii.gz/" MD/*_MD.nii.gz
tbss_non_FA MD

# stats
cd stats
design_ttest2 design $temp_n1 $temp_n2
randomise -i all_FA_skeletonised -o tbssFA -m mean_FA_skeleton_mask -d design.mat -t design.con -n 5000 --T2 -V
randomise -i all_MD_skeletonised -o tbssMD -m mean_FA_skeleton_mask -d design.mat -t design.con -n 5000 --T2 -V

echo "end of tbssPAall.sh"

# result
fsleyes -std1mm mean_FA_skeleton -cm green -dr 0.2 0.8 tbssFA_tfce_corrp_tstat1 -cm red-yellow -dr 0.95 1 tbssFA_tfce_corrp_tstat2 -cm blue-lightblue -dr 0.95 1 tbssMD_tfce_corrp_tstat1 -cm red-yellow -dr 0.95 1 tbssMD_tfce_corrp_tstat2 -cm blue-lightblue -dr 0.95 1&

