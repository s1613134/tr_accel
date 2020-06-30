#!/bin/bash
# add SUVR list on out_file
# Usage: PET2SUVR <in_file list.txt> <atlas list.txt> <out_file>
# 	for example:
#		ls */iirA_*.nii>list_infile.txt;
#		ls */*_aal.nii>list_atlas.txt;
#		PET2SUVR.sh list_infile.txt list_atlas.txt temp.csv
# 25 Jun 2020

## cerebellum [91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108]
crb_s=91
crb_e=108
## vermis [109 110 111 112 113 114 115 116]
vms_s=109
vms_e=116

voxelz_hdr=2 # for "File" "Sub-brick"

# Check if the files are specified
if [ $# -lt 3 ]
then
  echo "less argument!"
  echo "Usage: PET2SUVR <in_file list.txt> <atlas list.txt> <out_file>"
  exit 1
fi

list1=(`cat "$1"`)
list2=(`cat "$2"`)
list1n=${#list1[*]}
list2n=${#list1[*]}
if [ $list1n -ne $list2n ]
then
  echo "list length mismatch!"
  echo "	in_file list:" $list1n
  echo "	atlas list:" $list2n
  exit 1
fi

## make a header
aal_header="Precentral_L 	Precentral_R 	Frontal_Sup_L 	Frontal_Sup_R 	Frontal_Sup_Orb_L 	Frontal_Sup_Orb_R 	Frontal_Mid_L 	Frontal_Mid_R 	Frontal_Mid_Orb_L 	Frontal_Mid_Orb_R 	Frontal_Inf_Oper_L 	Frontal_Inf_Oper_R 	Frontal_Inf_Tri_L 	Frontal_Inf_Tri_R 	Frontal_Inf_Orb_L 	Frontal_Inf_Orb_R 	Rolandic_Oper_L 	Rolandic_Oper_R 	Supp_Motor_Area_L 	Supp_Motor_Area_R 	Olfactory_L 	Olfactory_R 	Frontal_Sup_Medial_L 	Frontal_Sup_Medial_R 	Frontal_Med_Orb_L 	Frontal_Med_Orb_R 	Rectus_L 	Rectus_R 	Insula_L 	Insula_R 	Cingulum_Ant_L 	Cingulum_Ant_R 	Cingulum_Mid_L 	Cingulum_Mid_R 	Cingulum_Post_L 	Cingulum_Post_R 	Hippocampus_L 	Hippocampus_R 	ParaHippocampal_L 	ParaHippocampal_R 	Amygdala_L 	Amygdala_R 	Calcarine_L 	Calcarine_R 	Cuneus_L 	Cuneus_R 	Lingual_L 	Lingual_R 	Occipital_Sup_L 	Occipital_Sup_R 	Occipital_Mid_L 	Occipital_Mid_R 	Occipital_Inf_L 	Occipital_Inf_R 	Fusiform_L 	Fusiform_R 	Postcentral_L 	Postcentral_R 	Parietal_Sup_L 	Parietal_Sup_R 	Parietal_Inf_L 	Parietal_Inf_R 	SupraMarginal_L 	SupraMarginal_R 	Angular_L 	Angular_R 	Precuneus_L 	Precuneus_R 	Paracentral_Lobule_L 	Paracentral_Lobule_R 	Caudate_L 	Caudate_R 	Putamen_L 	Putamen_R 	Pallidum_L 	Pallidum_R 	Thalamus_L 	Thalamus_R 	Heschl_L 	Heschl_R 	Temporal_Sup_L 	Temporal_Sup_R 	Temporal_Pole_Sup_L 	Temporal_Pole_Sup_R 	Temporal_Mid_L 	Temporal_Mid_R 	Temporal_Pole_Mid_L 	Temporal_Pole_Mid_R 	Temporal_Inf_L 	Temporal_Inf_R"
#" 	Cerebelum_Crus1_L 	Cerebelum_Crus1_R 	Cerebelum_Crus2_L 	Cerebelum_Crus2_R 	Cerebelum_3_L 	Cerebelum_3_R 	Cerebelum_4_5_L 	Cerebelum_4_5_R 	Cerebelum_6_L 	Cerebelum_6_R 	Cerebelum_7b_L 	Cerebelum_7b_R 	Cerebelum_8_L 	Cerebelum_8_R 	Cerebelum_9_L 	Cerebelum_9_R 	Cerebelum_10_L 	Cerebelum_10_R 	Vermis_1_2 	Vermis_3 	Vermis_4_5 	Vermis_6 	Vermis_7 	Vermis_8 	Vermis_9 	Vermis_10"
atlaslist=($(echo $aal_header))
atlasn=${#atlaslist[*]}
header_c="" # empty string
header_v="" # empty string
for ii in $(seq 0 $(expr $atlasn - 1));do
	header_c+=${atlaslist[$ii]}"/c "
	header_v+=${atlaslist[$ii]}"/v "
done

## new file
out_file=$3
echo "in_file" "atlas" $aal_header $header_c $header_v > $out_file

for ii in $(seq 0 $(expr $list1n - 1));do
	in_file=${list1[$ii]}
	atlas=${list2[$ii]}
	echo " "$(expr $ii + 1)"/"$list1n $in_file $atlas

	# count voxel in cerebellum and vermis
	voxelz=($(3dROIstats -nzvoxels -nomeanout -mask $atlas $atlas|sed -n 2p))
	voxeln=${#voxelz[*]}
	## cerebellum
	crb_all=0
	for ii in $(seq $(expr $voxelz_hdr + $crb_s - 1) $(expr $voxelz_hdr + $crb_e - 1));do
		crb_all=$(expr $crb_all + ${voxelz[$ii]})
	done
	#echo crb_all is $crb_all
	## vermis
	vms_all=0
	for ii in $(seq $(expr $voxelz_hdr + $vms_s - 1) $(expr $voxelz_hdr + $vms_e - 1));do
		vms_all=$(expr $vms_all + ${voxelz[$ii]})
	done
	#echo vms_all is $vms_all

	# calculate average in cerebellum and vermis
	amyloidz=($(3dROIstats -nzmean -nobriklab -nomeanout -mask $atlas $in_file |sed -n 2p))
	## cerebellum
	crb_ave=0
	for ii in $(seq $(expr $voxelz_hdr + $crb_s - 1) $(expr $voxelz_hdr + $crb_e - 1));do
	    crb_ave=$(echo "$crb_ave + ${voxelz[$ii]} * ${amyloidz[$ii]}"|bc -l)
	done
	crb_mean=$(echo $crb_ave / $crb_all|bc -l) # not integer by -l option
	#echo int crb_mean is $crb_mean
	## vermis
	vms_ave=0
	for ii in $(seq $(expr $voxelz_hdr + $vms_s - 1) $(expr $voxelz_hdr + $vms_e - 1));do
	    vms_ave=$(echo "$vms_ave + ${voxelz[$ii]} * ${amyloidz[$ii]}"|bc -l)
	done
	vms_mean=$(echo $vms_ave / $vms_all|bc -l) # not integer by -l option
	#echo int vms_mean is $vms_mean

	# calculate SUVR
	outlist1=("") # empty array
	outlist2=("") # empty array
	outlist3=("") # empty array
	#outlist4=("") # empty array
	for ii in $(seq $voxelz_hdr $(expr $voxelz_hdr + $crb_s - 2));do
		crb_suvr=$(echo "${amyloidz[$ii]} / $crb_mean"|bc -l)
		vms_suvr=$(echo "${amyloidz[$ii]} / $vms_mean"|bc -l)
		outlist1+=(${amyloidz[$ii]})
		outlist2+=($crb_suvr)
		outlist3+=($vms_suvr)
		#outlist4+=($ii)
	done
	outlist0=($in_file $atlas ${outlist1[@]} ${outlist2[@]} ${outlist3[@]}) # ${outlist4[@]})

	# write result
	echo ${outlist0[@]} >> $out_file

done # for ii in $(seq 0 $(expr $list1n - 1));
