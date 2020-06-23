#!/bin/bash
# add SUVR list on out_file
# Usage: PET2SUVR <in_file> <atlas> <out_file>
# 23 Jun 2020 

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
  echo "Usage: PET2SUVR <in_file> <atlas> <out_file>"
  exit 1
fi

in_file=$1
atlas=$2
out_file=$3

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
    crb_ave=$(echo "$crb_ave + ${voxelz[$ii]} * ${amyloidz[$ii]}"|bc)
done
crb_mean=$(echo $crb_ave / $crb_all|bc) # integer
#echo int crb_mean is $crb_mean
## vermis
vms_ave=0
for ii in $(seq $(expr $voxelz_hdr + $vms_s - 1) $(expr $voxelz_hdr + $vms_e - 1));do
    vms_ave=$(echo "$vms_ave + ${voxelz[$ii]} * ${amyloidz[$ii]}"|bc)
done
vms_mean=$(echo $vms_ave / $vms_all|bc) # integer
#echo int vms_mean is $vms_mean

# calculate SUVR
outlist1=("") # empty array
outlist2=("") # empty array
outlist3=("") # empty array#
#outlist4=("") # empty array
for ii in $(seq $voxelz_hdr $(expr $voxelz_hdr + $crb_s - 2));do
	crb_suvr=$(echo "0.01*(100 * ${amyloidz[$ii]} / $crb_mean)"|bc)
	vms_suvr=$(echo "0.01*(100 * ${amyloidz[$ii]} / $vms_mean)"|bc)
	outlist1+=(${amyloidz[$ii]})
	outlist2+=($crb_suvr)
	outlist3+=($vms_suvr)
	#outlist4+=($ii)
done
outlist0=($in_file $atlas ${outlist1[@]} ${outlist2[@]} ${outlist3[@]}) # ${outlist4[@]})

# write result
echo ${outlist0[@]} >> $out_file
