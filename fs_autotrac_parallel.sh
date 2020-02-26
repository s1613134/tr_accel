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
fsid_list=""
cat $1 | while read fsid dwi
do
  running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  while [ $running -gt $maxrunning ];
  do
    sleep 600
    running=$(ps -aux | grep 'bin/trac-all' | wc -l)
  done
  { trac-all -prep -c $2 -i $dwi -s $fsid ;\
    trac-all -bedp -c $2 -s $fsid ;\
    trac-all -path -c $2 -s $fsid ; } &
  fsid_list=${fsid_list}" "$fsid
  echo "fsid_list is "${fsid_list} 
done

wait

trac-all -stat -c $2 -s $fsid_list
echo "the end of fs_autotrac_parallel"

exit

