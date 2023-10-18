#!/bin/bash

# Run Nonrigid transformation using Ants for eyes_crop_mean_template.

for ((j=3;j<=3;j++))
do

    # Set path.
    zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"
    eyes_crop_mean_template=$1/template/eyes_crop_mean_template.nii
    out_path=$1/template

    # Run Nonrigid registration.
    start_time=$(date +%s)

    antsRegistration -d 3 --float 1 -o [${out_path}/Rigid_2_,${out_path}/mean_template_Rigid.nii.gz] \
    -t Rigid[0.1] -m GC[$zbbfish,$eyes_crop_mean_template,1,32,Regular,0.25]  \
    -c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

    antsRegistration -d 3 --float 1 -o [${out_path}/Affine_2_,${out_path}/mean_template_Affine.nii.gz] \
    -t Affine[0.1] -m GC[$zbbfish,${out_path}/mean_template_Rigid.nii.gz,1,32,Regular,0.25]  \
    -c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

    antsRegistration -d 3 --float 1 -o [${out_path}/SyN_2_,${out_path}/mean_template_SyN.nii.gz] \
    -t SyN[0.05,6,0.5] -m CC[$zbbfish,${out_path}/mean_template_Affine.nii.gz,1,2]  \
    -c [200x200x200x200x10,1e-7,10] -f 12x8x4x2x1 -s 4x3x2x1x0

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $name_num

done