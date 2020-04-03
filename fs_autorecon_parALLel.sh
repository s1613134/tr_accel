#!/bin/bash
#
# "expect" must be installed
# 	sudo apt install expect
#
# usage:
# 1. type fs_autorecon_parALLel.sh "<<list of T1 .nii files>>" "<<list of fsids>>" <<suffix of group1>> <<suffix of group2>>
#	for example
#	~/git/tr_accel/fs_autorecon_parALLel.sh "V_U28064_MR[12].nii V_U28065_MR[12].nii" "V_U28064 V_U28065" MR1 MR2
#
# ToDo
# !!! regular expressin in $2 is not supported !!!
#	bad example "V_U2806[45]"
#	good example  "V_U28064 V_U28065"
#

#set -x #for debugging

FSSTEP1_SCRIPTNAME=~/git/fs-scripts/fs_autorecon_parallel.sh
FSSTEP2_SCRIPTNAME=~/git/fs-scripts/fs_autorecon_long.sh
FRSURFER_SCRIPTNAME=/usr/local/freesurfer/bin/recon-all

#
# step1 fs_autorecon_parallel.sh
#
yes| ~/git/fs-scripts/fs_autorecon_parallel.sh $1
echo "yes fs_autorecon_parallel.sh done."

running=$(ps -aux | grep $FSSTEP1_SCRIPTNAME | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep $FSSTEP1_SCRIPTNAME | wc -l)
done

wait
echo "the end of fs_autorecon_parallel.sh main process"

running=$(ps -aux | grep $FRSURFER_SCRIPTNAME | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep $FRSURFER_SCRIPTNAME | wc -l)
done

echo "the end of all fs_autorecon_parallel.sh sub processes"

#
# step2 fs_autorecon_long.sh
#

# "expect" must be installed
# 	sudo apt install expect

<<"TODO"
# ToDo
# !!! regular expressin in $2 is not supported !!!
#	bad example "V_U2806[45]"
#	good example  "V_U28064 V_U28065"
TODO

arg2expanded=$2

expect -c "
set timeout -1
spawn $FSSTEP2_SCRIPTNAME $arg2expanded
expect \"Do you want to proceed (yes/no)? \"
send -- \"yes\n\"
expect \"Index for timepoint 1: \"
send -- \"$3\n\"
expect \"Index for timepoint 2: \"
send -- \"$4\n\"
expect
"
echo "the end of all fs_autorecon_long.sh main process"

<<"FOR_PARALLEL_PROCESSING_PLEASE_CHANGE_FSSTEP2_SCRIPTNAME_AS_FOLLOWS"
maxrunning=$(getconf _NPROCESSORS_ONLN)
running=0

for fsid_base in "$@"
do
  #recon-all -base
  { recon-all -base $fsid_base -tp ${fsid_base}_${tp1} -tp ${fsid_base}_${tp2} -all;

  #recon-all -long
  recon-all -long ${fsid_base}_${tp1} $fsid_base -all;
  recon-all -long ${fsid_base}_${tp2} $fsid_base -all; }&

  running=`expr $running + 1`
  if [ $running -ge $maxrunning ]; then
  	running=0
	wait
  fi
done

wait
FOR_PARALLEL_PROCESSING_PLEASE_CHANGE_FSSTEP2_SCRIPTNAME_AS_FOLLOWS

# 
echo "the end of fs_autorecon_parALLel.sh"

