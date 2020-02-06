#!/bin/bash
set -x # debug mode

# users definition
FRSURFER_SCRIPTSDIR=~/git/fs-scripts
FRSURFER_SCRIPTNAME=$FRSURFER_SCRIPTSDIR/recon-all
ANALYSIS_ID_REGEXP=^U2800[34]_MR[12]

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	done
	$FRSURFER_SCRIPTNAME -s $fid -hippocampal-subfields-T1 &
done

wait

for fid in $(ls |grep "$ANALYSIS_ID_REGEXP"); 
do 
	running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
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

