#!/bin/bash
set -x # debug mode

# users definition
BASELONG_ID_REGEXP=^U280.._[12]$

FRSURFER_SCRIPTNAME=/usr/local/freesurfer/bin/recon-all

maxrunning=$(getconf _NPROCESSORS_ONLN)

for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); 
do
	running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux|grep "$FRSURFER_SCRIPTNAME"|while read -a tempary;do for ii in "${!tempary[@]}";do if [ $ii -ge 12 ];then echo -n "${tempary[$ii]} ";fi;done;echo "";done|sort|uniq|wc -l)
	done
	{ $FRSURFER_SCRIPTNAME -base $fid -tp ${fid}_1 -tp ${fid}_2 -all;$FRSURFER_SCRIPTNAME -long ${fid}_1 $fid -all;$FRSURFER_SCRIPTNAME -long ${fid}_2 $fid -all; }&
done

wait

# QC base
#~/git/fs-scripts/fs_qc_base.sh <base fsid>
#for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); do ~/git/fs-scripts/fs_qc_base.sh $fid; done

# QC long
#~/git/fs-scripts/fs_qc_long.sh <base fsid>
#for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); do ~/git/fs-scripts/fs_qc_long.sh $fid; done
<<COMMENTOUT
for fid in $(ls |grep "$BASELONG_ID_REGEXP"|sed -e "s/_[12]$//"|sort|uniq); do freeview \
 -v ${fid}_1.long.${fid}/mri/norm.mgz \
    ${fid}_2.long.${fid}/mri/norm.mgz \
 -f ${fid}_1.long.${fid}/surf/lh.pial:edgecolor=red \
    ${fid}_1.long.${fid}/surf/rh.pial:edgecolor=red \
    ${fid}_1.long.${fid}/surf/lh.white:edgecolor=blue \
    ${fid}_1.long.${fid}/surf/rh.white:edgecolor=blue \
 -f ${fid}_2.long.${fid}/surf/lh.pial:edgecolor=pink \
    ${fid}_2.long.${fid}/surf/rh.pial:edgecolor=pink \
    ${fid}_2.long.${fid}/surf/lh.white:edgecolor=lightblue \
    ${fid}_2.long.${fid}/surf/rh.white:edgecolor=lightblue \
 -layout 1 -viewport coronal -zoom 2; done
COMMENTOUT

echo "end of longitudinaall.sh"

