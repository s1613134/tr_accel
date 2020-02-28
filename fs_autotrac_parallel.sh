#!/bin/bash
# For-loop for recon-all with qcache in parallel
# Usage: fs_autorecon_parallel.sh <nifti file(s)>
# Wild card can be used.
# nifti file name will be the subject id for FreeSurfer
# e.g. con001.nii -> con001

# 11 Feb 2020 K.Nemoto

#set -x #for debugging


#Check OS
os=$(uname)

#Check number of cores (threads)
if [ $os == "Linux" ]; then
  ncores=$(nproc)
elif [ $os == "Darwin" ]; then 
  ncores=$(sysctl -n hw.ncpu)
else
  echo "Cannot detect your OS!"
  exit 1
fi

echo "Your logical cores are $ncores "

#Set parameter for parallel processing
# If $ncores >= 2, set maxrunning as $ncores - 1
# else, set maxrunning as 1

if [ $ncores -gt 1 ]; then
  maxrunning=$(($ncores - 1))
else
  maxrunning=1
fi


#Check if the files are specified
if [ $# -lt 2 ]
then
  echo "Please specify subjectlist and dmrirc file!"
  echo "Usage: $0 <subjectlist> <dmrirc>"
  exit 1
fi


#Display $SUBJECTS_DIR and ask to proceed
while true
do
  echo "Your current SUBJECTS_DIR is $SUBJECTS_DIR"
  echo "Do you want to proceed (yes/no)? "

  read answer

  case $answer in
    [Yy]*)
      break
      ;;
    [Nn]*)
      echo -e "Abort. \n"
      exit
      ;;
    *)
      echo -e "Type yes or no.\n"
      ;;
  esac
done

#Confirm subjectlist and dmrirc
while true
do
  echo "subjectlist is ${1} and dmrirc is ${2}."
  echo "Are they correct (yes/no)?"

  read answer

  case $answer in
    [Yy]*)
      break
      ;;
    [Nn]*)
      echo -e "Abort. \n"
      exit
      ;;
    *)
      echo -e "Type yes or no.\n"
      ;;
  esac
done

#trac-all -prep
cat $1 | while read fsid dwi
do
  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  while [ $running -gt $maxrunning ];
  do
    sleep 60
    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  done
  trac-all -prep -c $2 -i $dwi -s $fsid &
done
# "wait" can not catch trac-all!!
running=$(ps -aux | grep 'bin/trac-all' | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep 'bin/trac-all' | wc -l)
done # wait


#trac-all -bedp
cat $1 | while read fsid dwi
do
  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  while [ $running -gt $maxrunning ];
  do
    sleep 60
    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  done
    trac-all -bedp -c $2 -i $dwi -s $fsid &
done
# "wait" can not catch trac-all!!
running=$(ps -aux | grep 'bin/trac-all' | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep 'bin/trac-all' | wc -l)
done # wait


#trac-all -path
cat $1 | while read fsid dwi
do
  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  while [ $running -gt $maxrunning ];
  do
    sleep 60
    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  done
    trac-all -path -c $2 -i $dwi -s $fsid &
done
# "wait" can not catch trac-all!!
running=$(ps -aux | grep 'bin/trac-all' | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep 'bin/trac-all' | wc -l)
done # wait

# for retry
temphoge=$(grep "^set dtroot = " $2);eval $(echo ${temphoge#set}|sed -e "s/ //g") # set dtroot
dtrootdepth=$(echo ${dtroot}|sed -e "s@/@ @g"|wc -w)
grep " exited with ERRORS" ${dtroot}/U280*/scripts/trac-all.log|while read templine;do tempword=(${templine//\:/ });tempworddiv=($(echo ${tempword[0]}|sed -e "s@/@ @g"));echo ${tempworddiv[${dtrootdepth}]};done|sort|uniq>${dtroot}/trac_path_retrylist.txt
<<"AUTORETRY_COMMENTOUT"
trac_path_retryfidnum=$(cat ${dtroot}/trac_path_retrylist.txt|wc -l)
while [ $trac_path_retryfidnum -gt 0 ];
do
	cat ${dtroot}/trac_path_retrylist.txt| while read fsid
	do
	  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
	  while [ $running -gt $maxrunning ];
	  do
	    sleep 60
	    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
	  done # while [ $running -gt $maxrunning ];
	  mv -b ${dtroot}/${fsid}/scripts/trac-all.log ${dtroot}/${fsid}/scripts/trac-all.log.old
	  dwi=D_${fsid}_PA.nii
	  { trac-all -prep -c $2 -i $dwi -s $fsid ;\
	    trac-all -bedp -c $2 -i $dwi -s $fsid ;\
	    trac-all -path -c $2 -i $dwi -s $fsid ; } &
	done # while read fsid
	# "wait" can not catch trac-all!!
	running=$(ps -aux | grep 'bin/trac-all' | wc -l)
	while [ $running -gt 1 ]; # 1 for grep itself
	do
	    sleep 60
	    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
	done # wait
	grep " exited with ERRORS" ${dtroot}/U280*/scripts/trac-all.log|while read templine;do set ${templine//\//  };echo ${$(expr ${dtrootdepth} + 1)};done|sort|uniq>${dtroot}/trac_path_retrylist.txt
	trac_path_retryfidnum=$(cat ${dtroot}/trac_path_retrylist.txt|wc -l)
done # while [ $trac_path_retryfidnum -gt 0 ];
AUTORETRY_COMMENTOUT

# statistics
<<COMMENTOUT
fsid_list=()
ii=0
for fsid_dwi in $(cat $1) # "cat $1 | while read fsid dwi" causes scope problem
do
	ii=$(expr $ii + 1)
	if [ $(expr $ii % 2) = 1 ]; then
		fsid_list+=(${fsid_dwi})
	fi
done
COMMENTOUT
cat $1 | while read fsid dwi
do
	trac-all -stat -c $2 -s $fsid
done

echo "the end of fs_autotrac_parallel"

#exit

