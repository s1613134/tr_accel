# users definition
# note that $SUBJECTS_DIR is overidden in dmrirc.*
TRACKALL_SCRIPTSDIR=~/git/tr_accel
DMRIRC_FILENAME=dmrirc.synapsology
DCM_ID_REGEXP=^U28
DCM_ID_HDR=D_
DCM_ID_FTR=_PA.nii

maxrunning=16
# common definition
TRACKALL_COMMANDLISTNAME=parallel_jobs
TRACKALL_PARALLELJOBNAME=trcalsub
DMRIRC_TEMPNAME=dmrirc.temp
DMRIRC_TEMPLATE=dmrirc.preptemplate

QSUB_TEMP_DIR=$SUBJECTS_DIR/qsub_temp
mkdir $QSUB_TEMP_DIR

# preprocess
for fid in $(ls |grep $DCM_ID_REGEXP); 
do 
	sed -e "s@hogehogeid@$fid@" -e "s@dcmhogehoge@${DCM_ID_HDR}${fid}${DCM_ID_FTR}@" $TRACKALL_SCRIPTSDIR/$DMRIRC_TEMPLATE > $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid;
	running=$(ps -aux | grep 'trac-all' | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep 'trac-all' | wc -l)
	done
#trac-all -prep -c $TRACKALL_SCRIPTSDIR/$DMRIRC_FILENAME
	trac-all -prep -c $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid &
done

wait

# separate trac-all -bedp -c $TRACKALL_SCRIPTSDIR/$DMRIRC_FILENAME
trac-all -bedp -c $TRACKALL_SCRIPTSDIR/$DMRIRC_FILENAME -jobs $QSUB_TEMP_DIR/$TRACKALL_COMMANDLISTNAME.txt

# do each process
# before parallel job
source $QSUB_TEMP_DIR/$TRACKALL_COMMANDLISTNAME.pre.txt

# do each line
numline=0
cat $QSUB_TEMP_DIR/$TRACKALL_COMMANDLISTNAME.txt|while read line; do
	sed -e "s@#contents@$line@" $TRACKALL_SCRIPTSDIR/qsub_template.sh > $QSUB_TEMP_DIR/$TRACKALL_PARALLELJOBNAME$numline.sh;
	qsub -e $QSUB_TEMP_DIR/qsuberr$numline.txt $QSUB_TEMP_DIR/$TRACKALL_PARALLELJOBNAME$numline.sh;
#	qsub $QSUB_TEMP_DIR/$TRACKALL_PARALLELJOBNAME$numline.sh;
	numline=`expr $numline + 1`;
done

# wait until all job done
running=$(qstat|grep '$TRACKALL_PARALLELJOBNAME'|wc -l)
while [ $running -gt 0 ];
do
	sleep 60
    	running=$(qstat|grep '$TRACKALL_PARALLELJOBNAME'|wc -l)
done

rm $SUBJECTS_DIR/$TRACKALL_PARALLELJOBNAME*.sh.o*

# after parallel job
source $QSUB_TEMP_DIR/$TRACKALL_COMMANDLISTNAME.post.txt

# postprocess
for fid in $(ls |grep $DCM_ID_REGEXP); 
do 
	sed -e "s@hogehogeid@$fid@" -e "s@dcmhogehoge@${DCM_ID_HDR}${fid}${DCM_ID_FTR}@" $TRACKALL_SCRIPTSDIR/$DMRIRC_TEMPLATE > $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid; 
	running=$(ps -aux | grep 'trac-all' | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep 'trac-all' | wc -l)
	done
#trac-all -path -c $TRACKALL_SCRIPTSDIR/$DMRIRC_FILENAME
	trac-all -path -c $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid &
done

wait

# QC
<<COMMENTOUT1
cd $SUBJECTS_DIR/hoge
less dmri/dwi_motion.txt
freeview dmri/dtifit_FA.nii.gz
freeview -v $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz dmri/mni/dtifit_FA.bbr.nii.gz
freeview -v dmri/dtifit_FA.nii.gz \
            dpath/rh.ilf_AS_avg33_mni_bbr/path.pd.nii.gz:colormap=heat:isosurface=0,0:color='Red':name=rh.ilf \
            dpath/lh.ilf_AS_avg33_mni_bbr/path.pd.nii.gz:colormap=heat:isosurface=0,0:color='Red':name=lh.ilf
freeview -tv dpath/merged_avg33_mni_bbr.mgz \
         -v dmri/dtifit_FA.nii.gz
COMMENTOUT1

# statistics
for fid in $(ls |grep $DCM_ID_REGEXP); 
do 
	sed -e "s@hogehogeid@$fid@" -e "s@dcmhogehoge@${DCM_ID_HDR}${fid}${DCM_ID_FTR}@" $TRACKALL_SCRIPTSDIR/$DMRIRC_TEMPLATE > $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid; 
	running=$(ps -aux | grep 'trac-all' | wc -l)
	while [ $running -gt $maxrunning ];
	do
		sleep 60
		running=$(ps -aux | grep 'trac-all' | wc -l)
	done
#trac-all -stat -c $TRACKALL_SCRIPTSDIR/$DMRIRC_FILENAME
	trac-all -stat -c $QSUB_TEMP_DIR/$DMRIRC_TEMPNAME$fid &
done

wait

#rm -fr $QSUB_TEMP_DIR

# QC2
<<COMMENTOUT2
less $SUBJECTS_DIR/stats/lh.ilf_AS.avg33_mni_bbr.FA_Avg.txt
freeview -v $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz \
         -w $SUBJECTS_DIR/stats/*.path.mean.txt
COMMENTOUT2

