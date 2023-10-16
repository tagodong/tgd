#!/bin/bash
# Run affine transformation according to mean template using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1

dof_path='/home/d2/motor/g20001_24000/recon_nii'
mat_path='/home/d2/motor/g20001_24000/g2rmat'

file_name=$(ls -d $dof_path/affine*.xform);
file_name=(${file_name//,/ });
len=$(ls -l ${dof_path}/affine*.xform | grep "^-" | wc -l);
step_size=1

for ((i=0;i<$len;i=i+$step_size))
do

    name_num=$(basename -s .xform ${file_name[$i]});
    
    # Set k to the number of the name.
    k=${name_num:6};

    start_time=$(date +%s)

    cmtk dof2mat $dof_path/affine$k.xform/registration > $mat_path/g2r$k.txt

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $name_num

done

