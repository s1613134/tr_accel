#!/bin/bash
set -x # debug mode

# users definition
FRSURFER_SCRIPTSDIR=~/git/fs-scripts
FRSURFER_SCRIPTNAME=$FRSURFER_SCRIPTSDIR/fs_longitudinal.sh
BASELONG_ID_REGEXP=^U2800[234]

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_MR[12]$//"|sort|uniq); 
do 
	running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	done
	$FRSURFER_SCRIPTNAME $fid &
done

wait

# QC base
#$FRSURFER_SCRIPTSDIR/fs_qc_base.sh <base fsid>

# QC long
#$FRSURFER_SCRIPTSDIR/fs_qc_long.sh <base fsid>
#for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_MR[12]$//"|sort|uniq); do $FRSURFER_SCRIPTSDIR/fs_qc_long.sh $fid; done

echo "end of longitudinaall.sh"

