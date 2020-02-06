#!/bin/bash
set -x # debug mode

# users definition
FRSURFER_SCRIPTNAME=/usr/local/freesurfer/bin/recon-all
ANALYSIS_ID_REGEXP=^U2800[34]_MR[12]$

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(expr $(ps -aux|grep recon-all|wc -l) / 2 + 1) # 1 for grep itself
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(expr $(ps -aux|grep recon-all|wc -l) / 2 + 1) # 1 for grep itself
	done
	$FRSURFER_SCRIPTNAME -s $fid -hippocampal-subfields-T1 &
done

wait

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(expr $(ps -aux|grep recon-all|wc -l) / 2 + 1) # 1 for grep itself
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(expr $(ps -aux|grep recon-all|wc -l) / 2 + 1) # 1 for grep itself
	done
	$FRSURFER_SCRIPTNAME -s $fid -brainstem-structures &
done

wait

# QC hippo
#<analysisID>/mri/[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.mgz
#<analysisID>/mri/[lr]h.hippoSfLabels-<T1>-<analysisID>.v10.FsvoxelSpace.mgz
#<analysisID>/mri/[lr]h.hippoSfVolumes-<T1>-<analysisID>.v10.txt

# QC brainstem
#<analysisID>/mri/brainstemSslabels.v10.mgz
#<analysisID>/mri/brainstemSslabels.v10.FsvoxelSpace.mgz
#<analysisID>/mri/brainstemSsVolumes.v10.txt

echo "end of reconsubfieldall.sh"

