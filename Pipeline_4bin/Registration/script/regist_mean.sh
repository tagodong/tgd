#!/bin/bash
# Run affine transformation according to mean template using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1

# Set the red and green chanel image directory path that is needed to register.
red_dir="/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving"
green_dir="/home/d2/20230704_1052_g8s-lssm-tph2-chri_8dpf/free-moving"

for ((j=1;j<=4;j++))
do
    # Set the red and green chanel image directory path that is needed to register.
    red_path=$red_dir/0$j/r/dual_Crop
    green_path=$green_dir/0$j/g/dual_Crop

    # Set the output green chanel image directory path that is registered.
    regist_red_path=$red_dir/0$j/r/regist_red
    mkdir $regist_red_path
    regist_green_path=$green_dir/0$j/g/regist_green
    mkdir $regist_green_path

    # Set the mean template path.
    mean_template=$red_dir/0$j/r/template/mean_template.nii

    # Read the images.
    file_name=$(ls $red_path/Red*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${red_path}/Red*.nii | grep "^-" | wc -l);
    # Set the step.
    step_size=1
    echo $red_path

    for ((i=0;i<$len;i=i+$step_size))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:3};

        start_time=$(date +%s)

        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes $mean_template ${red_path}/Red${k}.nii ${red_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${red_path}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform $mean_template ${red_path}/Red${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${red_path}/Red${k}.nii $mean_template ${red_path}/affine${k}.xform
        cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${green_path}/Green${k}.nii $mean_template ${red_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done
