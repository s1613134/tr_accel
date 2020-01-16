#!/bin/bash
export TUTORIAL_DATA=~/freesurfer_rta;export SUBJECTS_DIR=$TUTORIAL_DATA;cd $SUBJECTS_DIR

#trac-all -prep -c ~/git/tr_accel/dmrirc.rta
#cp -r ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_prep

cp -r ~/freesurfer_rta/reconall2020_prep ~/freesurfer_rta/reconall2020_temp
FSLPARALLEL=1; export FSLPARALLEL
echo "fsl_sub running $COMMANDNAME with parallel processing enabled(FSLPARALLEL=$FSLPARALLEL)"
time trac-all -bedp -c ~/git/tr_accel/dmrirc.rta>~/temp.txt
cp -r ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_enb_bedp
time trac-all -path -c ~/git/tr_accel/dmrirc.rta>>~/temp.txt
mv ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_enb_path

cp -r ~/freesurfer_rta/reconall2020_prep ~/freesurfer_rta/reconall2020_temp
FSLPARALLEL=0; export FSLPARALLEL
echo "fsl_sub running $COMMANDNAME with parallel processing disabled(FSLPARALLEL=$FSLPARALLEL)"
time trac-all -bedp -c ~/git/tr_accel/dmrirc.rta>>~/temp.txt
cp -r ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_dis_bedp
time trac-all -path -c ~/git/tr_accel/dmrirc.rta>>~/temp.txt
mv ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_dis_path

