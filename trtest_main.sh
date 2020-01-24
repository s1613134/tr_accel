export TUTORIAL_DATA=~/freesurfer_rta;export SUBJECTS_DIR=$TUTORIAL_DATA;cd $SUBJECTS_DIR

cp -r ~/freesurfer_rta/reconall2020_prep ~/freesurfer_rta/reconall2020_temp

qsubjects_dir=$SUBJECTS_DIR/qsub_temp
mkdir $qsubjects_dir

# separate trac-all -bedp -c ~/git/tr_accel/dmrirc.rta
trac-all -bedp -c ~/git/tr_accel/dmrirc.rta -jobs $qsubjects_dir/parallel_jobs.txt

# do each process
source $qsubjects_dir/parallel_jobs.pre.txt

# do each line
numline=0
cat $qsubjects_dir/parallel_jobs.txt|while read line; do
	sed -e "s@#contents@$line@" ~/git/tr_accel/qsub_template.sh > $qsubjects_dir/trtstsub$numline.sh;
	qsub -e $qsubjects_dir/qsuberr$numline.txt $qsubjects_dir/trtstsub$numline.sh;
	numline=`expr $numline + 1`;
done

# wait until all job done
running=$(qstat|grep 'trtstsub'|wc -l)
while [ $running -gt 0 ];
do
	sleep 60
    	running=$(qstat|grep 'trtstsub'|wc -l)
done

rm $SUBJECTS_DIR/trtstsub*.sh.o*

source $qsubjects_dir/parallel_jobs.post.txt

#rm -fr $qsubjects_dir
cp ~/freesurfer_rta/reconall2020_temp ~/freesurfer_rta/reconall2020_qsub_bedp

