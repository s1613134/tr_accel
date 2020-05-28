#!/bin/bash
set -x # debug mode

# usage:
#  1. collect <<fid>>.nii,.bvec,.bval files of DWI in working directory
#  !!! temp !!!
#     collect <<design filename>>.mat.txt <<design filename>>.con.txt files from Excel file in working directory
#
#  2. type as follows
# 		tbssG2V1.sh "<<fid>>" "<<group1 in regular expression>>" "<<group2 in regular expression>>" <<design filename>>
# 	for example
# 		tbssG2V1.sh "D_U280*_*_PA" "^D_U280.*_1_PA$" "^D_U280.*_2_PA$" design_g2v1
#	note that wild card in regular expression is not * but .*

# users definition
TBSSALL_ID=$1
TBSSALL_1REGEXP=$2
TBSSALL_2REGEXP=$3
DESIGN_FILENAME=$4

#cd $SUBJECTS_DIR
temp_n1=$(ls |grep ${TBSSALL_1REGEXP}|wc -l)
temp_n2=$(ls |grep ${TBSSALL_2REGEXP}|wc -l)

# for Chris Rorden's fsl_sub case
export FSLPARALLEL=1

#
# $DESIGN_FILENAME.mat.txt and $DESIGN_FILENAME.con.txt from excel file
#
# !!! todo !!!
# call python .py to make .txt files
#
Text2Vest $DESIGN_FILENAME.mat.txt $DESIGN_FILENAME.mat
Text2Vest $DESIGN_FILENAME.con.txt $DESIGN_FILENAME.con

# FA
mkdir TBSS;cp ${TBSSALL_ID}/*FA.nii.gz TBSS
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
rename "s@TBSS/@TBSS/CON_@" $(ls TBSS/*|grep $(echo ${TBSSALL_1REGEXP%$}|cut -c 2-)_FA.nii.gz$)
rename "s@TBSS/@TBSS/PAT_@" $(ls TBSS/*|grep $(echo ${TBSSALL_2REGEXP%$}|cut -c 2-)_FA.nii.gz$)
#
cd TBSS;
tbss_1_preproc *FA.nii.gz
tbss_2_reg -T
#tbss_3_postreg -T # for a few samples case
tbss_3_postreg -S # for many samples case
tbss_4_prestats 0.2

# nonFA
mkdir MD;cp ../${TBSSALL_ID}/*MD.nii.gz MD
rename "s@MD/@MD/CON_@" $(ls MD/*|grep $(echo ${TBSSALL_1REGEXP%$}|cut -c 2-)_MD.nii.gz$)
rename "s@MD/@MD/PAT_@" $(ls MD/*|grep $(echo ${TBSSALL_2REGEXP%$}|cut -c 2-)_MD.nii.gz$)
rename "s/_MD.nii.gz/_FA.nii.gz/" MD/*_MD.nii.gz
tbss_non_FA MD

# stats
cd stats
mv ../../$DESIGN_FILENAME.mat .
mv ../../$DESIGN_FILENAME.con .
randomise -i all_FA_skeletonised -o tbssFA -m mean_FA_skeleton_mask -d $DESIGN_FILENAME.mat -t $DESIGN_FILENAME.con -n 5000 --T2 -V
randomise -i all_MD_skeletonised -o tbssMD -m mean_FA_skeleton_mask -d $DESIGN_FILENAME.mat -t $DESIGN_FILENAME.con -n 5000 --T2 -V

echo "end of tbssG2V1.sh"

# result
fsleyes -std1mm mean_FA_skeleton -cm green -dr 0.2 0.8 tbssFA_tfce_corrp_tstat1 -cm red-yellow -dr 0.95 1 tbssFA_tfce_corrp_tstat2 -cm blue-lightblue -dr 0.95 1 tbssMD_tfce_corrp_tstat1 -cm red-yellow -dr 0.95 1 tbssMD_tfce_corrp_tstat2 -cm blue-lightblue -dr 0.95 1&

