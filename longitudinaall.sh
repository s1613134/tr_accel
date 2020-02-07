#!/bin/bash
set -x # debug mode

# users definition
BASELONG_ID_REGEXP=^U2800[12]_[12]$

FRSURFER_SCRIPTNAME=/usr/local/freesurfer/bin/recon-all

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); 
do 
	running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep "$FRSURFER_SCRIPTNAME" | wc -l)
	done
#	$FRSURFER_SCRIPTNAME $fid &
	{ $FRSURFER_SCRIPTNAME -base $fid -tp ${fid}_1 -tp ${fid}_2 -all;$FRSURFER_SCRIPTNAME -long ${fid}_1 $fid -all;$FRSURFER_SCRIPTNAME -long ${fid}_2 $fid -all; }&
done

wait

# QC base
#~/git/fs-scripts/fs_qc_base.sh <base fsid>

# QC long
#~/git/fs-scripts/fs_qc_long.sh <base fsid>
#for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); do ~/git/fs-scripts/fs_qc_long.sh $fid; done

echo "end of longitudinaall.sh"

