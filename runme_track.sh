#!/bin/bash
<< COMMENTOUT1
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null
BEDPOSTDIR=$SCRIPTPATH/bedpost
BEDPOSTOUTDIR=$BEDPOSTDIR.bedpostX

rm -rf $BEDPOSTOUTDIR
echo "fsl_sub running $COMMANDNAME with parallel processing disabled"
FSLPARALLEL=0; export FSLPARALLEL
time bedpostx $BEDPOSTDIR

rm -rf $BEDPOSTOUTDIR
COMMENTOUT1
echo "fsl_sub running $COMMANDNAME with parallel processing enabled"
FSLPARALLEL=1; export FSLPARALLEL
export TUTORIAL_DATA=~/freesurfer_tutorial/tutorial_data_20190918_1558;export SUBJECTS_DIR=$TUTORIAL_DATA/diffusion_recons;cd $TUTORIAL_DATA/diffusion_tutorial
trac-all -bedp -c $TUTORIAL_DATA/../dmrirc.tutorial2
#time bedpostx $BEDPOSTDIR

