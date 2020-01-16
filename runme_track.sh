#!/bin/bash

export TUTORIAL_DATA=~/freesurfer_rta;export SUBJECTS_DIR=$TUTORIAL_DATA/reconall2020;cd $TUTORIAL_DATA/tutorial
<<COMMENTOUT1
echo "fsl_sub running $COMMANDNAME with parallel processing disabled"
FSLPARALLEL=0; export FSLPARALLEL
time trac-all -bedp -c ~/git/tr_accel/dmrirc.rta
COMMENTOUT1
echo "fsl_sub running $COMMANDNAME with parallel processing enabled"
FSLPARALLEL=1; export FSLPARALLEL
time trac-all -bedp -c ~/git/tr_accel/dmrirc.rta
#time bedpostx $BEDPOSTDIR

