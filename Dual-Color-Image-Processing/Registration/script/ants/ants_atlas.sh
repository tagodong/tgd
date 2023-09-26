#!/bin/bash
# Run affine transformation according to atlas using CMTK.

for ((j=3;j<=3;j++))
do

    # Set the green chanel image directory path that is needed to register.
    path_g="/home/d1/20230620_1607_g8s-lssm-tph2-chri_11dpf_fix/fix/g"
    green_path=${path_g}/template

    # Set the atlas path.
    zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii"

    # Read the red images.
    file_name=$(ls $green_path/Green*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l $green_path/Green*.nii | grep "^-" | wc -l);

    # Set the template step (recommend 100).
    # step_size=100

    for ((i=0;i<$len;i=i+1))
    do
        name_num=$(basename -s .nii ${file_name[$i]});

        # Set k to the number of the name.
        k=${name_num:5};

        start_time=$(date +%s)

        # Initialize affine matrix.
        
        antsRegistration -d 3 --float 1 -o [${green_path}/Rigid${k}_,${green_path}/G_Rigid${k}.nii.gz] \
        -t Rigid[0.1] -m GC[$zbbfish,${green_path}/Green${k}.nii,1,32,Regular,0.25]  \
        -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

        antsRegistration -d 3 --float 1 -o [${green_path}/Affine${k}_,${green_path}/template${k}.nii.gz] \
        -t Affine[0.1] -m GC[$zbbfish,${green_path}/G_Rigid${k}.nii.gz,1,32,Regular,0.25]  \
        -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

        antsRegistration -d 3 --float 1 -o [${green_path}/SyN${k}_,${green_path}/G_SyN${k}.nii.gz] \
        -t SyN[0.05,6,0.5] -m CC[$zbbfish,${green_path}/template${k}.nii.gz,1,2]  \
        -c [200x200x200x200x10,1e-7,10] -f 12x8x4x2x1 -s 4x3x2x1x0
        
        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done