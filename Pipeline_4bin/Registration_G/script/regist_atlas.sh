#!/bin/bash
# Run affine transformation according to atlas using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1

# Set the green chanel image directory path that is needed to register.
green_dir="/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving"

for ((j=3;j<=4;j++))
do
    # Set the green chanel image directory path that is needed to register.
    green_path=$green_dir/0$j/g/dual_Crop

    # Set the output green chanel image directory path that is registegreen.
    regist_green_path=$green_dir/0$j/g/template
    mkdir $regist_green_path

    # Set the atlas path.
    zbbfish="/home/user/tgd/Pipeline_4bin/Registration/data/Atlas/atlas1_bin.nii"

    # Read the green images.
    file_name=$(ls $green_path/Green*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l $green_path/Green*.nii | grep "^-" | wc -l);

    # Set the template step (recommend 100).
    step_size=50

    for ((i=0;i<$len;i=i+$step_size))
    do
        name_num=$(basename -s .nii ${file_name[$i]});

        # Set k to the number of the name.
        k=${name_num:5};

        start_time=$(date +%s)

        # Initialize affine matrix.
        cmtk make_initial_affine --threads 20 --principal-axes $zbbfish ${green_path}/Green${k}.nii ${green_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --threads 20 --initial ${green_path}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${green_path}/affine${k}.xform $zbbfish ${green_path}/Green${k}.nii

        # Apply affine matrix.
        cmtk reformatx --threads 20 -o ${regist_green_path}/template${k}.nii --floating ${green_path}/Green${k}.nii $zbbfish ${green_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done