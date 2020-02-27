#!/bin/bash
# For-loop for recon-all with qcache in parallel
# Usage: fs_autorecon_parallel.sh <nifti file(s)>
# Wild card can be used.
# nifti file name will be the subject id for FreeSurfer
# e.g. con001.nii -> con001

# 11 Feb 2020 K.Nemoto

#set -x #for debugging

<<COMMENTOUT
# definition in late dmrirc file
# Output directory where trac-all results will be saved
export dtroot=${SUBJECTS_DIR}/tracula # trallall_outputs
#set subjlist = (hogehogeid) # use -s option!
export dcmroot=/mnt/data/synapsology # ${SUBJECTS_DIR}
#set dcmlist = (dcmhogehoge) # use -i option!
export bvecfile=${SUBJECTS_DIR}/bvecs_synapsology.txt
export bvalfile=${SUBJECTS_DIR}/bvals_synapsology.txt
COMMENTOUT

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


#trac-all -prep -bedp -path
fsid_list=""
cat $1 | while read fsid dwi
do
  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  while [ $running -gt $maxrunning ];
  do
    sleep 60
    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  done
  { trac-all -prep -c $2 -i $dwi -s $fsid ;\
    trac-all -bedp -c $2 -i $dwi -s $fsid ;\
    trac-all -path -c $2 -s $fsid ; } &
  fsid_list=${fsid_list}" "$fsid
  echo "fsid_list is "${fsid_list} 
done

# "wait" can not catch trac-all!!
running=$(ps -aux | grep 'bin/trac-all' | wc -l)
while [ $running -gt 1 ]; # 1 for grep itself
do
	sleep 60
	running=$(ps -aux | grep 'bin/trac-all' | wc -l)
done # wait

# auto retry
temphoge=$(grep "^set dtroot = " $2);eval $(echo ${temphoge#set}|sed -e "s/ //g") # set dtroot
dtrootdepth=$(echo ${dtroot}|sed -e "s@/@ @g"|wc -w)
#grep "trac-preproc exited with ERRORS" ${dtroot}/U280*/scripts/trac-all.log|while read templine;do set ${templine//\//  };echo ${$(expr ${dtrootdepth} + 1)};done|sort|uniq>${dtroot}/trac_path_retrylist.txt
#grep "trac-paths exited with ERRORS" ${dtroot}/U280*/scripts/trac-all.log|while read templine;do set ${templine//\//  };echo ${$(expr ${dtrootdepth} + 1)};done|sort|uniq>${dtroot}/trac_path_retrylist.txt
grep " exited with ERRORS" ${dtroot}/U280*/scripts/trac-all.log|while read templine;do set ${templine//\//  };echo ${$(expr ${dtrootdepth} + 1)};done|sort|uniq>${dtroot}/trac_path_retrylist.txt
trac_path_retryfidnum=$(cat ${dtroot}/trac_path_retrylist.txt|wc -l)
echo trac_path_retryfidnum=${trac_path_retryfidnum}
<<AUTORETRY_COMMENTOUT
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
	    trac-all -path -c $2 -s $fsid ; } &
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

trac-all -stat -c $2 -s $fsid_list

echo "fsid_list is "${fsid_list} 
echo "the end of fs_autotrac_parallel"

#exit

